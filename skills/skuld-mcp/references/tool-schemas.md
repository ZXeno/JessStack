# Skuld MCP Tool Schemas

Full parameter schemas for all 17 Skuld MCP tools. Tool names may appear with a prefix (`mcp__skuld__*` or `skuld__*`) depending on the MCP client.

## Boards

### list_boards
List all boards the token's user can access.

| Parameter | Type | Required |
|---|---|---|
| (none) | | |

Returns: `{ boards: [{ id, name, description, owner_id }] }`

### get_board
Get a board with its columns and cards.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |

Returns: `{ id, name, description, owner_id, columns: [{ id, name, position, is_backlog }], cards: [{ id, board_id, column_id, title }] }`

### create_board
Create a new board with a name and description.

| Parameter | Type | Required |
|---|---|---|
| `name` | string | yes |
| `description` | string (nullable) | no |

Returns: `{ id, name, description, owner_id }`

New boards auto-create 4 default columns: Backlog (pos 0, is_backlog=true), To Do (pos 10), In Progress (pos 20), Done (pos 30).

### delete_board
Soft-delete a board. Only the board owner or an admin may delete. Returns `not_found` (not `forbidden`) for non-owners to avoid leaking board existence.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |

Returns: `{ deleted: bool }`

## Cards

### list_cards
List cards matching a filter. `board_id` is required; the other filters are optional refinements.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `column_id` | string (uuid) | no |
| `assignee_id` | string (uuid) | no |
| `title` | string (nullable) | no |

The `title` parameter performs a case-insensitive substring match (SQL ILIKE).

Returns: `{ cards: [{ id, board_id, column_id, title }] }`

### get_card
Read full card details including description and task items. The board is resolved from the card; a legacy `board_id` field in the arguments is ignored.

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |

Returns: `{ id, board_id, column_id, title, description, position, assignee_id, tasks: [{ id, card_id, content, is_completed, position }] }`. Use the returned `board_id` for follow-up mutation calls.

### create_card
Create a card in a specified column.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `column_id` | string (uuid) | yes |
| `title` | string | yes |
| `description` | string (nullable) | no |

Returns: `{ id, title, description, board_id, column_id, position, assignee_id }`

New cards get position 10 within their column. Subsequent cards in the same column increment position.

### update_card
Update a card title, description, or iteration. Each field is optional; pass only the fields you want to change.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `title` | string (nullable) | no |
| `description` | string (nullable) | no |
| `iteration_id` | string (uuid, nullable) | no |

`iteration_id` omitted means no change; explicit null unassigns the
card's iteration; a value assigns it. Passing `iteration_id` requires
the `cards:assign` permission on the token (in addition to
`cards:update` for the tool itself). The iteration must belong to the
same board, otherwise the call fails with a bad-request error.

Returns: the updated card object.

### delete_card
Soft-delete a card.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |

Returns: `{ deleted: bool }`

### move_card
Move a card to a specified column, optionally anchored.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `column_id` | string (uuid) | yes |
| `after_card_id` | string (uuid) | no |
| `before_card_id` | string (uuid) | no |

`after_card_id` and `before_card_id` are mutually exclusive; at most one
may be supplied. `after_card_id` places the card immediately after that
card in the destination column; `before_card_id` places it immediately
before. When neither is supplied the card is appended at the end. The
anchor must reference a card in the destination column (not the moved
card itself), otherwise the call fails with a bad-request error. The
destination column is renumbered to dense 1..n after the move.

Returns: the updated card object.

### assign_card
Assign a card to a user or unassign (pass null for `assignee_id`).

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `assignee_id` | string (uuid, nullable) | yes (pass null to unassign) |

Returns: the updated card object.

### assign_card_iteration
Assign a card to an iteration or unassign (pass null for `iteration_id`).

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `iteration_id` | string (uuid, nullable) | yes (pass null to unassign) |

The iteration must belong to the same board and not be deleted,
otherwise the call fails with a bad-request error. Assigning the
iteration the card already has still records the audit event (no-op
parity with the HTTP route). Requires the `cards:assign` permission.

Returns: the updated card object.

## Tasks (checklist items on cards)

### add_task
Add a task item to a card.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `content` | string | yes |

Returns: `{ id, card_id, content, is_completed, position }`

### update_task
Rename a task item or mark completed/uncompleted. `content` and `completed` are each optional; pass only the fields you want to change.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `task_id` | string (uuid) | yes |
| `content` | string (nullable) | no |
| `completed` | boolean (nullable) | no |

Returns: the updated task object.

### remove_task
Remove a task item from a card. This is a hard delete (the task is removed from the database, not soft-deleted).

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `card_id` | string (uuid) | yes |
| `task_id` | string (uuid) | yes |

Returns: `{ removed: bool }`

## Users

### list_users
List users with an optional case-insensitive username filter. Requires admin role and `users:list` permission.

| Parameter | Type | Required |
|---|---|---|
| `username` | string (nullable) | no |

Returns: `{ users: [{ id, username }] }`

Pass `username` to filter by a case-insensitive partial match. Omit it to list all users. Only `id` and `username` are returned — no email, role, or other sensitive fields.

### list_board_access_users
List the users on a board's access list. Requires `boards:read` permission and access to the board (no admin role). Missing boards and boards the token cannot read both fail with the same "board not found or access denied" error.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |

Returns: `{ users: [{ user_id, display_name, is_deleted }] }`

Each `user_id` is directly usable as `assign_card`'s `assignee_id`. Soft-deleted users stay listed with `display_name: "Deleted_User"` and `is_deleted: true`; no usernames, roles, or owner flags are exposed.

## Charters

### get_charter
Read the project charter for a board. Requires `boards:read` permission (reused from `get_board`) and board access.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |

Returns: `{ board_id, content: string|null, updated_by: uuid|null, updated_at: string (RFC3339) }`

`content` is `null` if the charter row exists but was never edited. `updated_by` is `null` if the charter has never been edited.

### update_charter
Update the project charter for a board. Requires `boards:charter` permission AND the token's user must be the board owner or an admin (both gates enforced). PUT semantics: the full charter content is replaced. A `charter.updated` event is recorded in `board_history` with before/after content.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `content` | string | yes |

Returns: `{ board_id, content: string|null, updated_by: uuid, updated_at: string (RFC3339) }`

Whitespace is trimmed. An empty content string after trimming is stored as `null`.

## Column data model (read-only via MCP)

Columns are visible in `get_board` output but cannot be created, modified, reordered, renamed, or deleted through MCP tools.

| Field | Type | Description |
|---|---|---|
| `id` | uuid | Unique column identifier (per-board) |
| `name` | string | Display name |
| `position` | integer | Sort order (ascending). Default spacing is 10 |
| `is_backlog` | boolean | Marks the backlog column (typically position 0) |