# Commands

Slash commands for work on Skuld cards. Each command is one markdown file. The file name is the command name.

## Install

Copy the command files to the commands directory of your Claude Code configuration. Run this from the repo root:

```bash
for file in commands/*.md; do
  [ "$(basename "$file")" = "README.md" ] || cp "$file" ~/.claude/commands/
done
```

Do not copy this `README.md`. Claude Code reads each markdown file in that directory as a command.

The copy in `~/.claude/commands/` does not follow changes in this repository. Copy the files again after you change a command.

## Requirements

The commands call these MCP servers and skills. A command fails when one that it uses is missing.

| Requirement | Type | Used by |
|---|---|---|
| Skuld | MCP server | All commands except `impl-work-plan` |
| Gitea | MCP server | `resolve-pr-comments`, `review-skuld-pr` |
| Rune | MCP server | `impl-skuld-card`, `multi-card-implement`, `review-skuld-pr`, `resolve-pr-comments` |
| `unslop` | Skill | All commands except `plan-skuld-card-impl` and `complete-skuld-pr` |
| `grill` | Skill | `plan-skuld-card-impl`, `impl-work-plan`, `impl-skuld-card` |
| `handoff` | Skill | `plan-skuld-card-impl` |
| `review-pr` | Skill | `review-skuld-pr` |
| `rune-send-message` | Skill | `impl-skuld-card`, `multi-card-implement`, `review-skuld-pr`, `resolve-pr-comments` |

`impl-skuld-card` and `multi-card-implement` create a pull request. `complete-skuld-pr` completes a pull request. The command files do not name the tool for these steps.

The commands also load the skills for the language of the repository, for example `rust-skills`.

## Workflow

The commands follow a card across the columns of a Skuld board.

1. Write the story and the acceptance criteria on the card. The `feature-spec-grill` skill does this step.
2. Implement the card. Use one of these paths:
   - Run `plan-skuld-card-impl`, examine the plan, then run `impl-work-plan` with the saved plan.
   - Run `impl-skuld-card` to plan and implement in one step.
   - Run `multi-card-implement` to implement more than one card in one pull request.
3. Run `review-skuld-pr` on the pull request.
4. Run `resolve-pr-comments` to correct the review comments.
5. Run `complete-skuld-pr` to complete the pull request and move the card to Done.

| Command | Card movement |
|---|---|
| `plan-skuld-card-impl` | To In Progress |
| `impl-work-plan` | None |
| `impl-skuld-card` | To In Progress at the start, then to Code Review after the pull request |
| `multi-card-implement` | To In Progress at the start, then to Code Review after the pull request |
| `review-skuld-pr` | None |
| `resolve-pr-comments` | None |
| `complete-skuld-pr` | To Done after the pull request is complete |

## Commands

### `plan-skuld-card-impl`

```
/plan-skuld-card-impl <card_id> [repositories] [instructions]
```

| Argument | Required | Value |
|---|---|---|
| `card_id` | Yes | A Skuld card ID or card URL. |
| `repositories` | No | One or more repository names with their directory paths. Without this argument, the command uses the current directory. |
| `instructions` | No | More instructions for the plan. |

The command does these steps:

1. It reads the card, assigns the card to you, and moves the card to In Progress.
2. If the card has no acceptance criteria, it stops and tells you to run `/feature-spec-grill`.
3. It finds where the repository must change to meet the acceptance criteria.
4. It grills you on the acceptance criteria and the changes until no questions remain.
5. It shows a plan with file names, line numbers, and the effect of each change.
6. It asks where to save the plan. If you give a location, it saves the plan as a handoff document and opens the file.

The command makes no changes to the repository.

### `impl-work-plan`

```
/impl-work-plan <plan_path>
```

| Argument | Required | Value |
|---|---|---|
| `plan_path` | Yes | The path of a plan file. `plan-skuld-card-impl` saves this file. |

The command does these steps:

1. It reads the plan and the work item ID in the plan.
2. It implements the plan with no deviation. If a deviation is necessary, it stops and grills you.
3. It writes unit tests and validates the changes against the acceptance criteria.
4. It saves a report as `<work_item_id>_implementation_report.md` in the directory of the plan, then opens the report.

The report lists the changed files, the changed lines, and the tests for each acceptance criterion.

The command has these limits:

- It makes changes only in the repositories that the plan names.
- It makes no remote requests outside the MCP tools unless you confirm the request.

### `impl-skuld-card`

```
/impl-skuld-card <card_id>
```

| Argument | Required | Value |
|---|---|---|
| `card_id` | Yes | A Skuld card ID. |

The command does these steps:

1. It reads the card and moves the card to In Progress.
2. It makes an implementation plan from the acceptance criteria. If something is not clear, it stops and grills you.
3. It adds each item of the plan as a task on the card, and updates each task when the item is complete.
4. It implements the plan and writes tests.
5. It validates the implementation against the acceptance criteria.
6. If the project has a Docker image or a Docker Compose file, it rebuilds and starts the local dev container.
7. It updates `agents.md` with facts about the codebase only.
8. It commits the changes and creates a pull request.
9. It adds the pull request to the pull request field of the card, then moves the card to Code Review.
10. It sends you a notification with the card name, the card ID, and the pull request URL.

### `multi-card-implement`

```
/multi-card-implement <board_name> [instructions]
```

| Argument | Required | Value |
|---|---|---|
| `board_name` | Yes | The name of a Skuld board. |
| `instructions` | No | A column name, a list of card IDs, or other instructions. Without a column or card IDs, the command uses the cards in To Do. |

The command does the same steps as `impl-skuld-card` for each card, with these differences:

- It creates one pull request for all the cards. The description lists the title and the ID of each card.
- It sends one notification that lists each card and the pull request URL.
- It updates `agents.md` with the relevant changes. The limit to facts about the codebase is not in this command.

### `review-skuld-pr`

```
/review-skuld-pr <pr_url> [card_id]
```

| Argument | Required | Value |
|---|---|---|
| `pr_url` | Yes | The URL of a Gitea pull request. |
| `card_id` | No | A Skuld card ID. Without this argument, the command reads the card ID from the pull request description. |

The command does these steps:

1. It reads the card and its acceptance criteria.
2. It reviews the pull request with the `review-pr` skill. If the description names more than one card, it does one review for each card.
3. It sends you a notification when the review is complete.

### `resolve-pr-comments`

```
/resolve-pr-comments <pr_url> <card_id>
```

| Argument | Required | Value |
|---|---|---|
| `pr_url` | Yes | The URL of a Gitea pull request. |
| `card_id` | Yes | The ID of the Skuld card that has the acceptance criteria. |

The command does these steps:

1. It reads the open comments on the pull request.
2. It validates each comment and makes a work plan.
3. It makes the changes.
4. It validates the changes against the acceptance criteria and the comments.
5. It commits and pushes the changes.
6. It replies to each open comment and resolves it.
7. It sends you a notification with the pull request URL.

### `complete-skuld-pr`

```
/complete-skuld-pr
```

The command has no arguments. It uses the last pull request that the session mentions.

The command does these steps:

1. It finds the last pull request in the session. If the session has no pull request, it tells you to give one and stops.
2. It completes the pull request.
3. It reads the Skuld card ID from the pull request description. If the description has no card ID, it stops with no message.
4. It moves the card to Done.
5. It adds a comment to the card that says the pull request is complete.
6. It makes sure that the pull request is in the pull request field of the card.

## Frontmatter

| Field | Value |
|---|---|
| `name` | The command name. It is the same as the file name. |
| `description` | One line that tells you what the command does. |
| `effort` | The reasoning effort level for the command. |
| `disable-model-invocation` | When `true`, only the user can start the command. All commands except `complete-skuld-pr` set this field to `true`. |
