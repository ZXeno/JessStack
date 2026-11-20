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

1. Read the pull request at `pr_url` with the Gitea MCP tools.
2. If `card_id` is empty, read the card IDs from the pull request description. If the description has no card ID, stop. Tell me to run the command again with a card ID.
3. Read each card and its comments with the Skuld MCP tools.

## 2. Scan

1. If the current directory is a clone of the pull request repository and its working tree is clean, check out the source branch of the pull request. If not, skip this section and record the reason for the notification.
2. Run `scan-added-lines.sh` from the `code-writing-helper` skill directory. Give the target branch of the pull request as the argument.
3. Use each scan finding as an input to the review.

## 3. Review

1. Review the pull request with the `review-pr` skill. If the pull request has more than one card, do one review for each card.
2. Add these review criteria to each review:
   - **Acceptance criteria.** Each acceptance criterion of the card. A criterion that the diff does not implement is a finding.
   - **Code-writing rules.** Each rule of `code-writing-helper`. A high-confidence violation is a finding. Keep it through the filter pass of `review-pr`.
   - **Verification.** The Verification comment on the card, if the card has one. An acceptance criterion with no evidence from a run is a finding.
   - **Findings.** The Findings comment on the card, if the card has one. A kept workaround or scan finding with no valid reason is a finding.
3. For each finding about an error that can occur again, write a check in the Fix line, as `code-writing-helper` says for corrections. For example, a lint rule, a type, or a test.

## 4. Notify

Send me a notification with the `rune-send-message` skill. Use this text, and replace each `<...>` placeholder. Add the reason for a skipped scan on a new line, if the scan did not run.

```
I have completed a review of pull request <pr_url> for card `<card_id>`.
```
