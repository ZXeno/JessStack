---
name: skuld-mcp
description: "Manage Skuld boards, cards, and tasks via MCP tools."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [skuld, mcp, kanban, project-management, dogfooding]
---

# Skuld MCP

Manage Skuld project boards through the `mcp__skuld__*` toolset. Create boards, populate them with cards from story files, and track work across columns.

## When to use

- Creating or populating a Skuld board for a project
- Moving cards between columns to reflect story status
- Adding task checklists to cards for agent-friendly breakdowns
- Creating new feature request cards and tracking them through development
- Implementing new features from card descriptions and creating a trackable to-do list

## Tool inventory (14 tools)

All tools use the `mcp__skuld__*` prefix. Authentication is via scoped MCP tokens (F-02).

### Boards
| Tool | Purpose |
|---|---|
| `list_boards` | List all boards the token can access |
| `get_board` | Get a board with its columns and cards (full state) |
| `create_board` | Create a new board with name and optional description |
| `delete_board` | Soft-delete a board |

### Cards
| Tool | Purpose |
|---|---|
| `list_cards` | List cards matching a filter (by board, column, assignee) |
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

Load full schemas with `tool_describe(name='mcp__skuld__<tool>')` before first use.

## Known gap: no column management

The backend API has `add_column` and `remove_column` endpoints (see PR #4 review), but **no MCP tool exposes column operations**. You cannot add, remove, reorder, or rename columns via MCP.

If you need to add a column, either:
- Ask the user to add it manually through the web UI, or
- Hit the backend API directly via HTTP (bypasses MCP)

This gap should be tracked as a new story when the project reaches that point.

## Default column structure

New boards auto-create four columns. Positions are spaced by 10 to allow insertion between existing columns.

| Column | Position | is_backlog |
|---|---|---|
| Backlog | 0 | true |
| To Do | 10 | false |
| In Progress | 20 | false |
| Done | 30 | false |

The user added a "Code Review" column manually at position 30 (shifting Done to 40). Column ordering follows the `position` field ascending.

## Dogfooding pattern: vault stories to board cards (LEGACY)

This pattern was used to migrate existing vault story files (F-00 through F-22) into Skuld board cards when the board first became operational. It is complete for those stories. New features no longer get story files or story index entries — they get cards with specs directly. See the "New feature creation pattern" below.

### Procedure

1. Read `Projects/skuld_project/stories/00-INDEX.md` from the vault to get the story list and statuses.
2. Read each story file you want to recreate.
3. Get the target board with `get_board` to retrieve column IDs.
4. Map story status to column:
   - **Done** → Done column
   - **Not started** → To Do column
   - **In progress** → In Progress column
   - **Code Review** → Code Review column
   - **Backlog** → Backlog column
5. Create cards with `create_card`, passing the story content as the card description in markdown.
6. Verify with `get_board`.

### Card description format

Use this structure for card descriptions:

```
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

<implementation notes for completed stories>
```

Keep descriptions concise. Card titles use descriptive prefixes: `[MCP] - <description>`, `[FEATURE] - <description>`, `[CHANGE] - <description>`, `[TECH DEBT] - <description>`, `[ISSUE] - <description>`.

## New story creation pattern

When the user requests a new feature that doesn't exist as a story yet, create it on the board:

1. **Get the board** with `get_board` to retrieve the target column ID.
2. **Create the card** with `create_card` in the target column. Write a draft spec as the description using the card description format above.
3. **Update the charter** in the vault — add a feature section (### F-XX), add phase checklist items, and add decisions log entries after grilling locks decisions.
4. **Update the card** with `update_card` after grilling locks the final spec.

The card on the board is the live tracking artifact. The charter in the vault is the canonical spec.

## Working with column IDs

Column IDs are UUIDs assigned at board creation. Always call `get_board` first to retrieve current column IDs before creating or moving cards. Never hardcode column IDs across sessions — they are unique per board.

## Pitfalls

1. **No column tools via MCP.** If a user asks you to add or rename a column, you cannot do it through MCP. State the gap and offer the manual alternatives.
2. **Column IDs are per-board.** Never reuse a column ID from one board on another. Always fetch fresh with `get_board`.
3. **Card positions are per-column.** New cards get position 10 within their column. Multiple cards in the same column will have incrementing positions.
4. **Descriptions support markdown.** Use it to carry structured story content — the web UI renders it.
5. **`get_board` returns a large payload.** Boards with many cards produce a response that exceeds the tool output window and gets truncated. The full response is saved to a spillover file (path printed in the tool result). To extract column IDs from a truncated response, use `tail -c 5000 <spillover-path>` — the `columns` array appears at the end of the JSON payload, after all cards. Do not re-request `get_board` from the API; the full data is already on disk.

See `references/tool-schemas.md` for the full parameter schemas of all 14 tools.
