---
description: Review a pull request against its Skuld card's acceptance criteria
model: zai-coding-plan/glm-5.3-flash
---

Usage: /review-skuld-pr <pr_url> <card_name>

Arguments provided: $ARGUMENTS

Parse the arguments above: the first token is the pull request URL (`pr_url`), and the remainder, if present, is the Skuld card id (`card_id`). The `card_id` value is optional.

Always apply the `unslop` skill.

Review the pull request at `pr_url` using your `review-pr` skill. If `card_id` is missing from the arguments provided, look in the PR description for the card id.

The story and its acceptance criteria can be found in Skuld using your Skuld MCP tools for the card with id `card_id`.

Some pull requests may have multiple cards referenced in the PR description. In those scenarios, pull all relevant cards and perform the `review-pr` on each.

Once you've finished, notify me using the `rune-send-message` skill with the following message format `"I have completed a review of the current pull-request for <card_id>."` to notify you have completed your work.
