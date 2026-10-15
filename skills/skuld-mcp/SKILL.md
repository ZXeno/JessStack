---
name: skuld-mcp
description: Drive a Skuld MCP server. Create boards and columns, populate and move cards, manage tasks, comments, iterations, categories, pull request links, and charters through the mcp__skuld__* tools. Use when the user asks to plan, populate, or update work on a Skuld board.
version: 1.3.0
license: MIT
---

# Skuld MCP

Skuld is a self-hosted Kanban board with a built-in MCP server. This skill drives it. Create boards, turn specs into cards, move work across columns, assign people, tag cards with categories, attach pull request links, and keep a project charter current, all over MCP tools.

The server runs inside the Skuld backend at `/mcp`. Streamable HTTP transport, protocol version `2026-07-28`. Authenticate with a scoped MCP token sent as `Authorization: Bearer skuld_...`. Connection setup and token creation are covered in `references/installation.md` and in the Skuld repo under `docs/mcp-setup.md`.

## When to use

- Create or populate a board for a project
- Turn specs, story files, or research reports into cards with task checklists
- Move cards between columns as work progresses
- Assign cards to users and iterations
- Read or update a board's project charter
- Triage card sets in bulk, filtered by iteration, category, assignee, or title

## Tool inventory (37 tools)

Every tool takes a JSON object of the parameters listed in `references/tools.md`. The wire input column names the type in `backend/src/mcp/server/wire/schemas.json`, the committed snapshot of every input and output schema. Check tool schemas at runtime when unsure of a parameter; the client's tool listing is authoritative over this document.

| Tool | Wire input | Permission | Purpose |
|---|---|---|---|
| `list_boards` | `ListBoardsParams` | boards:list | Boards the token can access |
| `get_board` | `GetBoardParams` | boards:read | Board with columns and card briefs |
| `create_board` | `CreateBoardParams` | boards:create | New board with default columns |
| `update_board` | `UpdateBoardParams` | boards:update | Name/description, owner or admin only |
| `delete_board` | `DeleteBoardParams` | boards:delete | Soft-delete, owner or admin only |
| `list_cards` | `ListCardsParams` | cards:list | Filter by column, assignee, title, category |
| `get_card` | `GetCardParams` | cards:read | Full card with tasks and recent comments |
| `create_card` | `CreateCardParams` | cards:create | Card in a column, optional acceptance criteria, iteration and category |
| `update_card` | `UpdateCardParams` | cards:update | Title, description, acceptance criteria, optional iteration and category |
| `move_card` | `MoveCardParams` | cards:move | Column change with optional anchor |
| `assign_card` | `AssignCardParams` | cards:assign | Assignee by user id, null to clear |
| `assign_card_iteration` | `AssignCardIterationParams` | cards:assign | Iteration by id, null to clear |
| `delete_card` | `DeleteCardParams` | cards:delete | Soft-delete |
| `add_task` | `AddTaskParams` | cards:tasks:create | Append a checklist item |
| `update_task` | `UpdateTaskParams` | cards:tasks:update | Rename, complete, or reopen |
| `remove_task` | `RemoveTaskParams` | cards:tasks:delete | Hard delete |
| `list_users` | `ListUsersParams` | users:list | Admin only, optional name filter |
| `list_board_access_users` | `ListBoardAccessUsersParams` | boards:read | Users on a board, resolves assignees |
| `get_charter` | `GetCharterParams` | boards:read | Board charter content |
| `update_charter` | `UpdateCharterParams` | boards:charter | Replace charter, owner or admin only |
| `create_column` | `CreateColumnParams` | columns:manage | Add a column |
| `delete_column` | `DeleteColumnParams` | columns:manage | Soft-delete, cards fall to backlog |
| `rename_column` | `RenameColumnParams` | columns:manage | Rename a column |
| `reorder_column` | `ReorderColumnParams` | columns:manage | Move a column with an anchor |
| `list_iterations` | `ListIterationsParams` | boards:read | Iterations oldest first, with is_current and completed_at |
| `create_iteration` | `CreateIterationParams` | iterations:manage | New iteration, owner or admin |
| `rename_iteration` | `RenameIterationParams` | iterations:manage | Rename, owner or admin |
| `delete_iteration` | `DeleteIterationParams` | iterations:manage | Soft-delete, unassigns its cards |
| `list_cards_in_iteration` | `ListCardsInIterationParams` | cards:list | Cards by iteration id |
| `list_cards_by_iteration_name` | `ListCardsByIterationNameParams` | cards:list | Cards by name substring |
| `get_card_comments` | `GetCardCommentsParams` | cards:read | Full comment list, deleted stubbed |
| `add_comment` | `AddCommentParams` | cards:update | Append a markdown comment |
| `update_comment` | `UpdateCommentParams` | cards:update | Edit own comment, author only |
| `get_card_pull_requests` | `GetCardPullRequestsParams` | cards:read | PR links on a card, oldest first |
| `add_pull_request` | `AddPullRequestParams` | cards:update | Attach an http(s) PR URL |
| `remove_pull_request` | `RemovePullRequestParams` | cards:update | Remove a PR link by id |
| `list_categories` | `ListCategoriesParams` | categories:list | Global category registry with card counts |

Column and iteration writes, plus `update_board`, `delete_board`, and `update_charter`, also require the token's user to be the board owner or an instance admin. `list_users` additionally requires an admin user. The full permission map with role gates is in `references/permissions.md`.

## Core workflows

**Set up a board.** Call `list_boards` to find it or `create_board` to make one. New boards get four columns, Backlog, To Do, In Progress, Done, at sequential positions with Backlog fixed at 0. Fetch column ids fresh with `get_board` every session. Column ids are unique per board, never reuse them across boards. `update_board` changes name or description, owner or admin only. Its `description` is tri-state: omitted leaves it unchanged, `null` clears it, a string sets it. Some MCP clients strip nulls from arguments, so an empty string also clears when `null` does not survive the client.

**Populate cards.** `create_card` with a title, the board id, and the column id. Put the spec in the description as markdown, the web UI renders it. Put the acceptance criteria in `acceptance_criteria` (also markdown) instead of the description; both ride `update_card` later, where omitted leaves a field unchanged, an empty string clears, and `acceptance_criteria` also clears on `null`. Every later mutation on the card (`update_card`, `add_comment`, the task tools) takes the board's id explicitly — the call does not inherit it from the card or its response. Mirror a checklist with one `add_task` call per item, in list order, since tasks append in call order and accept no position argument. Verify with `get_card`.

**Move work.** `move_card` takes the target column plus at most one of `after_card_id` or `before_card_id`. Positions are dense sequential integers renumbered on every change, so treat them as opaque and always anchor moves on neighbor cards.

**Assign work.** Resolve a person to a user id with `list_board_access_users(board_id)`, which needs no admin permission. Never guess a UUID. `assign_card` rejects unknown or deleted ids with `bad_request` but accepts any other valid user id without a board-membership check, so a wrong-but-valid id misroutes the card silently. `list_users` needs an admin and is usually the wrong tool for assignee resolution.

**Categories.** Categories are instance-global names. `list_categories` returns id, name, and card count for every active category. Set a card's category with `create_card`'s or `update_card`'s `category` name field, or `update_card`'s `category_id` (null clears, and the two fields are mutually exclusive). Assigning an existing name needs only the card permission; a novel name additionally requires `categories:manage` and get-or-creates the category atomically with the card write. Category rename and delete stay in the web UI. The response echoes `category_id` and `category_name`, so verify the tag from the echo.

**Pull request links.** `add_pull_request` attaches one http(s) URL to a card, 2048 byte cap; a duplicate URL conflicts. `get_card_pull_requests` lists a card's links oldest first; `remove_pull_request` takes the link id from that listing and hard-deletes the link. Links use the same board-scoped shape as the other card tools: pass `board_id` and `card_id` explicitly.

**Iterations.** One iteration per card or none. Create and manage with the `iterations:manage` tools, list with `list_iterations`, attach at creation or with `assign_card_iteration`. `list_iterations` entries carry `is_current` and `completed_at`; `get_board` carries the board's `current_iteration_id`. Do not infer the current iteration from list order, read the flag. Completed iterations reject assignment with a conflict error on every surface. Completing, reopening, or re-pointing an iteration is REST-only.

**Charters.** `get_charter` reads the markdown charter. `update_charter` replaces the whole content, there is no patch mode, so read, edit in memory, then write back.

## Errors

Tools return JSON-RPC errors with custom codes. Not found is `-32003`, forbidden is `-32002`, conflict is `-32004`, invalid params is the standard `-32602`. Authorization failures on boards mask as `board not found` so board existence does not leak. A not-found for a board you can list usually means a role gate, not a missing board. Details in `references/pitfalls.md`.

## References

- `references/tools.md`, parameter contracts and response shapes for all 37 tools
- `references/permissions.md`, the 21 permissions and which tools and roles gate each
- `references/pitfalls.md`, known failure modes and the habits that avoid them
- `references/installation.md`, connection setup and how to install this skill

## Maintaining this skill

A backend drift test reads this file and fails `cargo test` when a tool name or wire input type is missing from the table above. When you add or change an MCP tool, update the table, `references/tools.md`, and `references/permissions.md` in the same change, then run `cargo test` in `backend/`.

Review checklist for changes to this skill:

- Every tool appears in the inventory table with its wire input type and permission
- Parameter contracts in `references/tools.md` match `backend/src/mcp/server/wire/schemas.json`
- No instance-specific data, no board ids, user ids, usernames, or hostnames from any live deployment
- `cargo test` in `backend/` passes the drift test
