---
name: review-skuld-pr
description: Review a pull request against its Skuld card's acceptance criteria
effort: xhigh
disable-model-invocation: true
---

Usage: `/review-skuld-pr <pr_url> [card_id]`

Arguments: `$ARGUMENTS`

The first token is the pull request URL (`pr_url`). The remainder is one ore more optional Skuld card IDs (`card_id`).

Apply the `unslop` skill to all text that you write: review comments and the notification.

## 1. Read

1. Read the pull request at `pr_url` with the MCP server or CLI for its hosting service. If the service returns a 401, a 403, or another "unauthorized" error, stop and tell me.
2. If `card_id` is empty, read the card IDs from the pull request description. If the description has no card ID, stop. Tell me to run the command again with a card ID.
3. Read each card and its comments with the Skuld MCP tools.

## 2. Review

1. Review the pull request with the `review-pr` skill. If the pull request has more than one card, do one review for each card.
2. Add these review criteria to each review:
   - **Acceptance criteria.** Each acceptance criterion of the card. A criterion that the diff does not implement is a finding.
   - **Code-writing rules.** Each rule of `code-writing-helper`. A high-confidence violation is a finding. Keep it through the filter pass of `review-pr`.
   - **Verification.** The Verification comment on the card, if the card has one. An acceptance criterion with no evidence from a run is a finding.
   - **Findings.** The Findings comment on the card, if the card has one. A kept workaround with no valid reason is a finding.
3. For each finding about an error that can occur again, write a check in the Fix line, as `code-writing-helper` says for corrections. For example, a lint rule, a type, or a test.

## 3. Notify

Send me a notification with the `rune-send-message` skill. Use this text, and replace each `<...>` placeholder.

```
I have completed a review of pull request <pr_url> for card `<card_id>`.
```
