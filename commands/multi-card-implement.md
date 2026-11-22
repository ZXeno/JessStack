---
name: multi-card-implement
description: Implement more than one Skuld card in one pull request (plan, code, test, PR, notify)
effort: high
disable-model-invocation: true
---

Usage: `/multi-card-implement <board_name> [instructions]`

Arguments: `$ARGUMENTS`

The first token is the name of the Skuld board (`board_name`). The remainder is optional instructions (`instructions`). The instructions can contain a column name, a list of card IDs, or other instructions.

Apply the `unslop` skill to all text that you write: card tasks, card comments, commit messages, and the pull request description.

## 1. Read the cards

1. Get the board `board_name` with the Skuld MCP tools.
2. Select the cards:
   - If `instructions` has card IDs, get each card by its ID.
   - If `instructions` has a column name or a column ID, use the cards in that column.
   - If not, use the cards in the "To Do" column.
3. If a card has no acceptance criteria, stop. Tell me to run `/feature-spec-grill` on that card.
4. Move each card to the "In Progress" column.

## 2. Plan

1. Invoke the `code-writing-helper` skill. Follow it for each code change in this command.
2. Load the skills for each language that the change touches.
3. Read `agents.md` and the code that the change touches.
4. Write an implementation plan for each card. Map each acceptance criterion to one or more plan items, and to the evidence that will prove it: a test name, a command and its expected output, or a screenshot.
5. If an acceptance criterion or a plan item is not clear, stop and `/grill` me until we agree.
6. Add each plan item as a task on its card. When you complete an item, mark its task complete.

## 3. Implement

1. Create one branch from the default branch for all the cards. Use the format in "Branch name".
2. Implement the plans. Follow `code-writing-helper`, `agents.md`, and the requirements on each card.
3. Reuse an existing component or implementation when one fits the task. Copy only patterns that pass the workaround check in `code-writing-helper`. Record each workaround that you find with `file:line`.
4. If the root-cause fix is larger than the card, stop and `/grill` me. Give the cause, the size of the correct fix, and the workaround that you rejected.

## 4. Verify

1. If the project has a Dockerfile or a Docker Compose file, remove the local dev container, rebuild it, and start it. Send a request to it and confirm that it responds.
2. Verify the change as `code-writing-helper` says. If a dev container exists, run the code against it.
3. Verification is complete when each acceptance criterion of each card has evidence from a run. A clean build is not evidence.
4. For a frontend change, write the steps that I use to test the change by hand.
5. If a check fails and you cannot fix the cause, stop and `/grill` me. Do not create the pull request until the check passes or I approve.

## 5. Record facts

Add a fact to `agents.md` only when a future agent needs it and no check can enforce it. Write facts about the codebase only. Do not name cards or stories.

## 6. Pull request

1. Commit the changes.
2. Create one pull request. Write a terse description with these parts:
   - A list of the title and the full ID of each card.
   - What the change does.
   - The manual test steps, for a frontend change.
3. Add a comment to each card with these sections:
   - **Verification.** Each acceptance criterion of the card and its evidence.
   - **Findings.** Each workaround that you found for the card, with `file:line`.
4. Add the pull request to the pull request field on each card.
5. Move each card to the "Code Review" column.
6. Send me a notification with the `rune-send-message` skill. Use this text, with one list line for each card. Replace each `<...>` placeholder:

```
- `<card_id>` | `<card_title>`
- `<card_id>` | `<card_title>`

Work is completed on the above cards. PR URL: <pr_url>
```

## Branch name

Format: `{dev}/{iter}_{description}`

| Part | Value |
|---|---|
| `{dev}` | My username on the hosting service of the repository. |
| `{iter}` | The name of the iteration of the cards. If the cards have no iteration, or have more than one iteration, leave out `{iter}` and the underscore after it. |
| `{description}` | A summary of the change in 1 to 5 lowercase words, joined by hyphens. |

Examples:

- `jane/0.2.2_project-rule-checks`
- `jane/project-rule-checks`, for cards with no shared iteration.
