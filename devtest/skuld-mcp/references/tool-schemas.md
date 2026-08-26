# Skuld MCP Tool Schemas

Full parameter schemas for all 14 `mcp__skuld__*` tools. Load any schema at runtime with `tool_describe(name='mcp__skuld__<tool>')`.

## Boards

### mcp__skuld__list_boards
List all boards the token's user can access.

| Parameter | Type | Required |
|---|---|---|
| (none) | | |

Returns: `{ boards: [{ id, name, description, owner_id }] }`

### mcp__skuld__get_board
Get a board with its columns and cards.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |

Returns: `{ id, name, description, owner_id, columns: [{ id, name, position, is_backlog }], cards: [{ id, title, description, column_id, position, assignee_id }] }`

### mcp__skuld__create_board
Create a new board with a name and description.

| Parameter | Type | Required |
|---|---|---|
| `name` | string | yes |
| `description` | string (nullable) | no |

Returns: `{ id, name, description, owner_id }`

New boards auto-create 4 default columns: Backlog (pos 0, is_backlog=true), To Do (pos 10), In Progress (pos 20), Done (pos 30).

### mcp__skuld__delete_board
Soft-delete a board.

| Parameter | Type | Required |
|---|---|---|
| (passes board_id) | | |

## Cards

### mcp__skuld__list_cards
List cards matching a filter (by board, column, assignee).

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | varies |
| `column_id` | string (uuid) | varies |
| `assignee_id` | string (uuid) | varies |

### mcp__skuld__get_card
Read full card details including description and task items.

| Parameter | Type | Required |
|---|---|---|
| `card_id` or `board_id` + `column_id` + position | | |

### mcp__skuld__create_card
Create a card in a specified column.

| Parameter | Type | Required |
|---|---|---|
| `board_id` | string (uuid) | yes |
| `column_id` | string (uuid) | yes |
| `title` | string | yes |
| `description` | string (nullable) | no |

Returns: `{ id, title, description, board_id, column_id, position, assignee_id }`

New cards get position 10 within their column. Subsequent cards in the same column increment position.

### mcp__skuld__update_card
Update a card title or description.

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |
| `title` | string (nullable) | no |
| `description` | string (nullable) | no |

### mcp__skuld__delete_card
Soft-delete a card.

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |

### mcp__skuld__move_card
Move a card to a specified column.

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |
| `column_id` | string (uuid) | yes |

### mcp__skuld__assign_card
Assign a card to a user or unassign (null).

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |
| `assignee_id` | string (uuid, nullable) | yes (pass null to unassign) |

## Tasks (checklist items on cards)

### mcp__skuld__add_task
Add a task item to a card.

| Parameter | Type | Required |
|---|---|---|
| `card_id` | string (uuid) | yes |
| `title` | string | yes |

### mcp__skuld__update_task
Rename a task item or mark completed/uncompleted.

| Parameter | Type | Required |
|---|---|---|
| `task_id` | string (uuid) | yes |
| `title` | string (nullable) | no |
| `completed` | boolean (nullable) | no |

### mcp__skuld__remove_task
Remove a task item from a card (hard delete).

| Parameter | Type | Required |
|---|---|---|
| `task_id` | string (uuid) | yes |

## Column data model (read-only via MCP)

Columns are visible in `get_board` output but cannot be created, modified, reordered, renamed, or deleted through MCP tools.

| Field | Type | Description |
|---|---|---|
| `id` | uuid | Unique column identifier (per-board) |
| `name` | string | Display name |
| `position` | integer | Sort order (ascending). Default spacing is 10 |
| `is_backlog` | boolean | Marks the backlog column (typically position 0) |
