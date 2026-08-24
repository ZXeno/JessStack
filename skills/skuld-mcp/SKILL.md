---
name: skuld-mcp
description: Manage Skuld boards, cards, tasks, and charters via MCP tools. Use when interacting with a Skuld MCP server to create boards, populate cards, move work across columns, or read/update project charters.
---

# Skuld MCP

Manage Skuld project boards through the Skuld MCP toolset. Create boards, populate them with cards, and track work across columns.

## When to use

- Creating or populating a Skuld board for a project
- Moving cards between columns to reflect work status
- Adding task checklists to cards for structured breakdowns
- Creating new feature cards and tracking them through development
- Listing users to find assignee IDs for card assignment
- Reading or updating a board's project charter (spec document)

## Tool inventory (17 tools)

All tools use the `mcp__skuld__*` prefix (or `skuld__*` depending on the client). Authentication is via scoped MCP tokens. 16 permissions exist; `get_charter` reuses `boards:read`.

### Boards

| Tool | Purpose |
|---|---|
| `list_boards` | List all boards the token can access |
| `get_board` | Get a board with its columns and cards (full state) |
| `create_board` | Create a new board with name and optional description |
| `delete_board` | Soft-delete a board (owner/admin only) |

### Cards

| Tool | Purpose |
|---|---|
| `list_cards` | List cards matching a filter (by board, column, assignee, or title substring) |
| `get_card` | Read full card details including description and task items |
| `create_card` | Create a card in a specified column (requires board_id + column_id) |
| `update_card` | Update a card title or description |
| `delete_card` | Soft-delete a card |
| `move_card` | Move a card to a specified column |
| `assign_card` | Assign a card to a user or unassign (null) |

### Tasks (checklist items on cards)

| Tool | Purpose |
|---|---|
| `add_task` | Add a task item to a card |
| `update_task` | Rename a task item or mark completed/uncompleted |
| `remove_task` | Remove a task item from a card (hard delete) |

### Users

| Tool | Purpose |
|---|---|
| `list_users` | List users with optional case-insensitive username filter (admin + `users:list` permission) |

### Charters

| Tool | Purpose |
|---|---|
| `get_charter` | Read the project charter for a board (`boards:read` permission, board access required) |
| `update_charter` | Update the project charter for a board (`boards:charter` permission, owner/admin only) |

Load full schemas from `references/tool-schemas.md` before first use.

## Known gap: no column management

The backend API has column management endpoints, but **no MCP tool exposes column operations**. You cannot add, remove, reorder, or rename columns via MCP.

If you need to add a column, either:
- Ask the user to add it manually through the web UI, or
- Hit the backend API directly via HTTP (bypasses MCP)

## Charters

Every board has a charter — a markdown document stored in the `board_charter` table (one row per board, created in the same transaction as the board). The charter holds the project specification: stories, acceptance criteria, decisions, and phase tracking.

Use `get_charter` to read the current charter content. Use `update_charter` to replace it (PUT semantics — the full content string replaces what exists). Charter updates require the `boards:charter` permission and owner/admin role. A `charter.updated` event is recorded in `board_history` with before/after content.

The charter is the canonical spec for the board's project. The cards on the board are the live tracking artifacts.

## Default column structure

New boards auto-create four columns. Positions are spaced by 10 to allow insertion between existing columns.

| Column | Position | is_backlog |
|---|---|---|
| Backlog | 0 | true |
| To Do | 10 | false |
| In Progress | 20 | false |
| Done | 30 | false |

Column ordering follows the `position` field ascending. Users may add custom columns (e.g., "Code Review") via the web UI.

## Card description format

Use this structure for card descriptions to carry structured story content:

```
**Phase X | Status: <status>**

---

# <Story Title>

## Story

**As a** <role>
**I want** <capability>
**So that** <benefit>

## Description

<description text>

## Acceptance Criteria

- <criteria as bullet points>

## Dependencies

- <dependency list, if any>

## Notes

<implementation notes>
```

Card titles use descriptive prefixes: `[FEATURE] - <description>`, `[CHANGE] - <description>`, `[TECH DEBT] - <description>`, `[ISSUE] - <description>`.

## Working with column IDs

Column IDs are UUIDs assigned at board creation. Always call `get_board` first to retrieve current column IDs before creating or moving cards. Never hardcode column IDs across sessions — they are unique per board.

## Pitfalls

1. **No column tools via MCP.** If a user asks you to add or rename a column, you cannot do it through MCP. State the gap and offer the manual or HTTP alternatives.
2. **Column IDs are per-board.** Never reuse a column ID from one board on another. Always fetch fresh with `get_board`.
3. **Card positions are per-column.** New cards get position 10 within their column. Multiple cards in the same column will have incrementing positions.
4. **Descriptions support markdown.** Use it to carry structured story content — the web UI renders it.
5. **`get_board` returns a large payload.** Boards with many cards produce a large response. If the response is truncated by your client, the `columns` array appears at the end of the JSON payload, after all cards. Parse the tail or use a JSON streaming parser to extract column IDs rather than re-requesting.
6. **`update_charter` uses PUT semantics.** The full content string replaces the existing charter. There is no patch or append mode. Always `get_charter` first, modify the content in memory, then `update_charter` with the complete new content.

See `references/tool-schemas.md` for the full parameter schemas of all 17 tools.