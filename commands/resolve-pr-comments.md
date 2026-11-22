---
name: resolve-pr-comments
description: Resolve the open comments on a pull request. Uses the related Skuld card.
effort: high
disable-model-invocation: true
---

Usage: `/resolve-pr-comments <pr_url> <card_id>`

Arguments: `$ARGUMENTS`

The first token is the pull request URL (`pr_url`). The remainder is the Skuld card ID (`card_id`).

Apply the `unslop` skill to all text that you write: commit messages, replies to review comments, and card comments.

## 1. Read

1. Read the open comments on `pr_url` with the MCP server or CLI for its hosting service. If the service returns a 401, a 403, or another "unauthorized" error, stop and tell me.
2. Read the card `card_id` with the Skuld MCP tools. The card has the acceptance criteria.
3. Check out the source branch of the pull request.
4. Invoke the `code-writing-helper` skill. Follow it for each code change in this command.
5. Load the skills for each language that the change touches.
6. Read `agents.md` and the code that the comments refer to.

## 2. Plan

1. Validate each comment. If a comment is not clear, stop and `grill` me.
2. Write a work plan that addresses each valid comment.
3. A review comment is a code correction. For each comment that names an error that can occur again, propose a check as `code-writing-helper` says for corrections.
4. Show me the work plan and each proposed check. Add each check that I approve to the plan.

## 3. Implement

1. Implement the plan. Follow `code-writing-helper`, `agents.md`, and the requirements on the card.
2. Reuse an existing component or implementation when one fits the task. Copy only patterns that pass the workaround check in `code-writing-helper`. Record each workaround that you find with `file:line`.
3. If the root-cause fix is larger than the comment, stop and `grill` me. Give the cause, the size of the correct fix, and the workaround that you rejected.

## 4. Verify

1. Verify the change as `code-writing-helper` says.
2. Verification is complete when each valid comment and each acceptance criterion has evidence from a run. A clean build is not evidence.
3. If a check fails and you cannot fix the cause, stop and `grill` me. Do not push until the check passes or I approve.

## 5. Push and reply

1. Commit the changes and push them.
2. Reply to each open comment. Say what you changed, or why you made no change. Then resolve the comment.
3. Add a comment to the card with these sections:
   - **Verification.** Each acceptance criterion and each valid review comment, with its evidence.
   - **Findings.** Each workaround that you found, with `file:line`.
4. Send me a notification with the `rune-send-message` skill. Use this text, and replace the `<pr_url>` placeholder:

```
I have resolved the comments left on pull request <pr_url>.
```
