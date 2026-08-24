---
name: resolve-pr-comments
description: Resolve comments on a gitea pull request. References the related Skuld card.
---

Usage: /resolve-pr-comments <card_name>

Arguments provided: $ARGUMENTS

Parse the arguments above: the first token is the Skuld board name (`board_name`), and the remainder is the Skuld card title (`card_name`).

Read the review comments on the open PR. Validate each comment and create a detailed work plan.

Story documentation can be found in Skuld, card title containing the acceptance criteria is `card_name`.

Utilize available skills relevent to the language being worked on and adhere to the style guidelines and requirements in agents.md and in the card. Always apply the `unslop` skill.

Follow the plan and ensure all review comments are addressed appropriately.

Reuse existing components everywhere possible. Use existing implementations for code everywhere possible. 

Validate implementations meet acceptance criteria and address all review comments after implementation. 

Keep all code comments to a **minimum**. No more than 2-3 sentences, no more than 5-10 words per sentence. Refrain from mentioning cards/stories in comments unless it is extremely relevant. The code should be easy enough to read that comments should be rare. If you can reduce existing code comments for code being changes to fit these criteria, do so.

Once you've finished your work, commit your changes and push them up to the repository. Then comment on and resolve the open review comments. 

Once you've finished, use the command `hermes send --to telegram "Benimaru has completed work on the current pull-request review for <card_name>."` to notify you have completed your work.
