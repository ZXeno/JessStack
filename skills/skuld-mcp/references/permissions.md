# Permission map

MCP tokens carry a set of scoped permissions. Every tool checks one permission, and several tools also check the token user's role on the board. 21 permissions cover all 37 tools.

| Permission | Tools |
|---|---|
| boards:list | list_boards |
| boards:read | get_board, list_board_access_users, list_iterations, get_charter |
| boards:create | create_board |
| boards:update | update_board |
| boards:delete | delete_board |
| boards:charter | update_charter |
| cards:list | list_cards, list_cards_in_iteration, list_cards_by_iteration_name |
| cards:read | get_card, get_card_comments, get_card_pull_requests |
| cards:create | create_card |
| cards:update | update_card, add_comment, update_comment, add_pull_request, remove_pull_request |
| cards:move | move_card |
| cards:assign | assign_card, assign_card_iteration |
| cards:delete | delete_card |
| cards:tasks:create | add_task |
| cards:tasks:update | update_task |
| cards:tasks:delete | remove_task |
| users:list | list_users |
| categories:list | list_categories |
| categories:manage | none directly; gates novel category names on create_card and update_card |
| columns:manage | create_column, delete_column, rename_column, reorder_column |
| iterations:manage | create_iteration, rename_iteration, delete_iteration |

## Role gates beyond permissions

A permission on the token is necessary but not always sufficient. These tools also check who the token's user is:

- `delete_board`, owner of the board or instance admin
- `update_board`, owner or admin
- `update_charter`, owner or admin
- `create_column`, `delete_column`, `rename_column`, `reorder_column`, owner or admin
- `create_iteration`, `rename_iteration`, `delete_iteration`, owner or admin
- `list_users`, instance admin
- `update_comment`, author of the comment

`create_card` and `update_card` with an `iteration_id` also require cards:assign on the token, on top of their own permission. Assigning a category by a name that does not exist yet also requires categories:manage; assigning an existing name (or a category_id) needs only the card permission. `list_categories` requires access to at least one board, mirroring its HTTP route.

`categories:manage` gates novel category creation through the get-or-create path and registry management over REST; no MCP tool requires it directly.

## Role failures look like missing boards

Role gates on board-scoped tools return not-found rather than forbidden, so callers cannot probe which boards exist. If `get_board` works but `create_iteration` says `board not found` on the same id, the token user is probably not the owner or an admin. There is no tool to fix that; a human transfers ownership from the web UI.

## Token creation

Create tokens from the Skuld web UI Tokens page or `POST /api/tokens`. Grant the smallest set that covers the workflow. A read-only analyst needs boards:list, boards:read, cards:list, cards:read. A work-tracking agent usually needs the card and task permissions plus boards:read, and columns:manage plus iterations:manage only if it also structures the board.
