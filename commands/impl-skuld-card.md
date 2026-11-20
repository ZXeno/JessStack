---
name: impl-skuld-card
description: Implement a Skuld card end-to-end (plan, code, test, PR, notify)
effort: high
disable-model-invocation: true
---

Card ID: `$ARGUMENTS`

Apply the `unslop` skill to all text that you write: card tasks, card comments, commit messages, and the pull request description.

## 1. Read the card

1. Read the card with the Skuld MCP tools, including the description, acceptance criteria field, and comments.
2. If the card has no acceptance criteria, stop. Tell me to run `/feature-spec-grill` on the card.
3. Move the card to the "In Progress" column.

## 2. Plan

1. Invoke the `code-writing-helper` skill. Follow it for each code change in this command.
2. Load the skills for each language that the change touches.
3. Read `agents.md` and the code that the change touches.
4. Write an implementation plan. Map each acceptance criterion to one or more plan items, and to the evidence that will prove it: a test name, a command and its expected output, or a screenshot.
5. If an acceptance criterion or a plan item is not clear, stop and `/grill` me until we agree.
6. Add each plan item as a task on the card. When you complete an item, mark its task complete.

## 3. Implement

1. Create a branch from the default branch. Use the format in "Branch name".
2. Implement the plan. Follow `code-writing-helper`, `agents.md`, and the requirements on the card.
3. Reuse an existing component or implementation when one fits the task. Copy only patterns that pass the workaround check in `code-writing-helper`. Record each workaround that you find with `file:line`.
4. If the root-cause fix is larger than the card, stop and `/grill` me. Give the cause, the size of the correct fix, and the workaround that you rejected.

## 4. Verify

1. If the project has a Dockerfile or a Docker Compose file, remove the local dev container, rebuild it, and start it. Send a request to it and confirm that it responds.
2. Verify the change as `code-writing-helper` says. If a dev container exists, run the code against it.
3. Verification is complete when each acceptance criterion has evidence from a run. A clean build is not evidence.
4. For a frontend change, write the steps that I use to test the change by hand.
5. If a check fails and you cannot fix the cause, stop and `/grill` me. Do not create the pull request until the check passes or I approve.

## 5. Record facts

Add a fact to `agents.md` only when a future agent needs it and no check can enforce it. Write facts about the codebase only. Do not name cards or stories.

## 6. Pull request

1. Commit the changes.
2. Create a pull request. Write a terse description with these parts:
   - The card title and the full card ID.
   - What the change does.
   - The manual test steps, for a frontend change.
3. Add a comment to the card with these sections:
   - **Verification.** Each acceptance criterion and its evidence.
   - **Findings.** Each workaround that you found, with `file:line`. Each `scan-added-lines.sh` finding that you kept, with the reason.
4. Add the pull request to the pull request field on the card.
5. Move the card to the "Code Review" column.
6. Send me a notification with the `rune-send-message` skill. Use this text, and replace each `<...>` placeholder:

```
I have completed task `<card_name>` - card id `<card_id>`. PR created at <pr_url>
```

## Branch name

Format: `{dev}/{iter}_{card_id}_{description}`

| Part | Value |
|---|---|
| `{dev}` | My Gitea username. |
| `{iter}` | The name of the iteration of the card. If the card has no iteration, leave out `{iter}` and the underscore after it. |
| `{card_id}` | The first 8 characters of the card ID. |
| `{description}` | 1 to 5 lowercase words from the card name, joined by hyphens. |

Examples:

- `jane/0.2.2_6df742c7_project-rule-checks`
- `jane/6df742c7_project-rule-checks`, for a card with no iteration.
