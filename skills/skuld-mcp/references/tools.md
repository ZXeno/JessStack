# Tool reference

Parameter contracts for all 37 tools. Types are JSON schema types; uuid means a string id. Optional parameters are marked, everything else is required. The committed snapshot of every schema lives at `backend/src/mcp/server/wire/schemas.json` in the Skuld repo.

Common pattern: mutation tools take `board_id` plus the id of the thing being changed. `get_card` is the one read tool that takes only `card_id` and resolves the board itself.

## Boards

### list_boards, `ListBoardsParams`

No parameters. Returns `{ boards: [{ id, name, description, owner_id }] }`.

### get_board, `GetBoardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |

Returns `{ id, name, description, owner_id, current_iteration_id, columns: [{ id, name, position, is_backlog }], cards: [{ id, board_id, column_id, title }] }`. Cards are briefs, no description or iteration. `current_iteration_id` identifies the iteration the board's default view shows. Large boards overflow the result window, see pitfalls.

### create_board, `CreateBoardParams`

| Parameter | Type | Required |
|---|---|---|
| name | string | yes |
| description | string, null | no |

Returns `{ id, name, description, owner_id }`. Four default columns are created with the board. Names must be unique among active boards, compared case-insensitively; a duplicate returns `bad_request` (invalid params `-32602`, not the conflict code) with message `board name must be unique`.

### update_board, `UpdateBoardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| name | string, null | no |
| description | string, null | no |

Owner or admin only; non-owners get not-found. At least one of `name` or `description` must be present, an empty call returns `bad_request` with message `no fields to update`. `description` is tri-state: omitted leaves it unchanged, `null` clears it, a string sets it. Some MCP clients strip nulls from arguments; an empty string also clears. Duplicate names return `bad_request` with message `board name must be unique`. Returns the updated `{ id, name, description, owner_id }`.

### delete_board, `DeleteBoardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |

Owner or admin only. Returns `{ deleted: true }`. Non-owners get not-found, not forbidden.

## Cards

### list_cards, `ListCardsParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| column_id | uuid | no |
| assignee_id | uuid | no |
| title | string | no |
| category | string | no |

`title` is a case-insensitive substring match. `category` matches a category name exactly, case-insensitive. Returns `{ cards: [CardInfo] }` with full fields including description, iteration_id, and category_id.

### get_card, `GetCardParams`

| Parameter | Type | Required |
|---|---|---|
| card_id | uuid | yes |

The server resolves the card's board and gates access. Missing and denied both return not-found. Returns the card fields flattened at the top level (id, board_id, column_id, title, description, position, assignee_id, iteration_id, category_id) plus `tasks: [{ id, card_id, content, position, is_completed }]` and `comments`, the most recent 20 non-deleted comments oldest-first with `{ id, card_id, author_id, author_display_name, body, created_at, updated_at, is_deleted }`.

### create_card, `CreateCardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| column_id | uuid | yes |
| title | string | yes |
| description | string, null | no |
| acceptance_criteria | string, null | no |
| iteration_id | uuid, null | no |
| category | string, null | no |

Returns a full card object. `acceptance_criteria` is markdown text for the card's acceptance criteria. Passing an iteration also needs the cards:assign permission. Assigning to a completed iteration returns a conflict. A `category` name get-or-creates in the global registry; a novel name also needs categories:manage.

### update_card, `UpdateCardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| title | string, null | no |
| description | string, null | no |
| acceptance_criteria | string, null | no |
| iteration_id | uuid, null | no |
| category | string, null | no |
| category_id | uuid, null | no |

Omitted fields are unchanged. For iteration_id, omitted means unchanged, explicit null unassigns, a value assigns. The iteration field additionally requires cards:assign. For `acceptance_criteria`, omitted means unchanged, `null` or an empty string clears it, a value sets it. `category` takes a name, case-insensitive, and get-or-creates it: an existing name needs only cards:update, a novel name additionally requires categories:manage. category_id follows the same tri-state for the card's category (explicit null clears) and must reference an active category; `category` is a name alternative, the two are mutually exclusive. Returns the updated card, including the resolved `category_id` and `category_name`, so verify the tag from the echo.

### move_card, `MoveCardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| column_id | uuid | yes |
| after_card_id | uuid, null | no |
| before_card_id | uuid, null | no |

At most one anchor. With no anchor the card goes to the end of the target column. Returns the updated card.

### assign_card, `AssignCardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| assignee_id | uuid, null | no |

Null clears the assignee. Returns the updated card. Resolve user ids first, see pitfalls.

### assign_card_iteration, `AssignCardIterationParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| iteration_id | uuid, null | no |

Null unassigns. Assigning to a completed iteration returns a conflict. Returns the updated card.

### delete_card, `DeleteCardParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |

Returns `{ deleted: true }`.

## Tasks

Tasks are checklist items on a card. All three tools take `board_id` and `card_id`.

### add_task, `AddTaskParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| content | string | yes |

No position parameter. Tasks append in the order the calls execute. Returns the created task.

### update_task, `UpdateTaskParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| task_id | uuid | yes |
| content | string, null | no |
| completed | boolean, null | no |

Returns the updated task.

### remove_task, `RemoveTaskParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| task_id | uuid | yes |

Hard delete, the only hard delete in Skuld. Returns `{ removed: true }`.

## Users and access

### list_users, `ListUsersParams`

| Parameter | Type | Required |
|---|---|---|
| username | string | no |

Admin user plus users:list permission. Case-insensitive substring filter. Returns `{ users: [{ id, username }] }`.

### list_board_access_users, `ListBoardAccessUsersParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |

Needs boards:read on a board the token can access, no admin role. Returns `{ users: [{ user_id, display_name, is_deleted }] }`. These user_id values are the valid assignee ids for `assign_card` on that board. Deleted users render as Deleted_User.

## Charters

### get_charter, `GetCharterParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |

Returns `{ board_id, content, updated_at, updated_by }`. Content is markdown.

### update_charter, `UpdateCharterParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| content | string | yes |

Whole-content replace, PUT semantics. Owner or admin plus boards:charter. Returns `{ board_id, content, updated_at, updated_by }`.

## Columns

All four tools need columns:manage and the owner or admin role on the board.

### create_column, `CreateColumnParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| name | string | yes |
| after_column_id | uuid, null | no |

Appends to the end when no anchor is given. Returns the created column `{ board_id, id, name, position, is_backlog }`.

### rename_column, `RenameColumnParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| column_id | uuid | yes |
| name | string | yes |

Returns the renamed column.

### reorder_column, `ReorderColumnParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| column_id | uuid | yes |
| after_column_id | uuid, null | no |

Anchor-based, no raw positions. Returns `{ board_id, id, name, position, is_backlog, rebalanced }`.

### delete_column, `DeleteColumnParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| column_id | uuid | yes |

Soft-deletes the column and moves its cards to the backlog. The backlog column cannot be deleted. Returns `{ cards_moved }`.

## Iterations

### list_iterations, `ListIterationsParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |

Returns `{ iterations: [{ id, board_id, name, is_current, completed_at }] }` ordered oldest first, completed included, deleted excluded. `completed_at` is an RFC3339 string or null. Exactly one iteration can carry `is_current: true`; a board with no current iteration has none. Completed iterations reject card assignment with a conflict, so check `completed_at` before assigning.

### create_iteration, `CreateIterationParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| name | string | yes |

iterations:manage and owner or admin. Returns `{ id, board_id, name }`.

### rename_iteration, `RenameIterationParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| iteration_id | uuid | yes |
| name | string | yes |

Returns `{ id, board_id, name }`.

### delete_iteration, `DeleteIterationParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| iteration_id | uuid | yes |

Soft-deletes and unassigns every card in the iteration. Returns `{ deleted: true }`.

### list_cards_in_iteration, `ListCardsInIterationParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| iteration_id | uuid | yes |

Returns `{ cards: [CardInfo] }`.

### list_cards_by_iteration_name, `ListCardsByIterationNameParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| iteration | string | yes |

Case-insensitive substring match on iteration name. Returns `{ cards: [CardInfo] }`.

## Categories

Categories form a global registry shared by every board.

### list_categories, `ListCategoriesParams`

No parameters. Needs categories:list. Returns `{ categories: [{ id, name, card_count }] }` ordered by name.

## Comments

### get_card_comments, `GetCardCommentsParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |

Returns `{ comments: [CommentInfo] }` oldest first. Deleted comments appear as stubs with no body.

### add_comment, `AddCommentParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| body | string | yes |

Markdown body, trimmed, 2000 byte cap. Returns `{ comment: CommentInfo }`.

### update_comment, `UpdateCommentParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| comment_id | uuid | yes |
| body | string | yes |

Author's own comments only over MCP. Returns `{ comment: CommentInfo }`.

## Pull requests

### get_card_pull_requests, `GetCardPullRequestsParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |

Returns `{ pull_requests: [PullRequestInfo] }` oldest first, where each entry carries `id`, `card_id`, `url`, `created_by`, and `created_at`.

### add_pull_request, `AddPullRequestParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| url | string | yes |

http or https URLs only, 2048 byte cap, trimmed server-side. A URL already on the card returns a conflict. Returns `{ pull_request: PullRequestInfo }`.

### remove_pull_request, `RemovePullRequestParams`

| Parameter | Type | Required |
|---|---|---|
| board_id | uuid | yes |
| card_id | uuid | yes |
| pull_request_id | uuid | yes |

Hard delete; the removal is recorded in card history. Returns `{ removed: true }`.
