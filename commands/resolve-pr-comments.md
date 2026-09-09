---
name: resolve-pr-comments
description: Resolve comments on a gitea pull request. References the related Skuld card.
agent: build
model: zai-coding-plan/glm-5.3
---

Usage: /resolve-pr-comments <pr_url> <card_id>

Arguments provided: $ARGUMENTS

Parse the arguments above: the first token is the pull-request URL (`pr_url`), and the remainder is the Skuld card id (`card_id`).

Always apply the `unslop` skill.

Using your Gitea MCP tools, read the open comments on the pr at `pr_url`.

Validate each comment and create a detailed work plan.

Story documentation can be found in Skuld, card id containing the acceptance criteria is `card_id`.

Utilize available skills relevent to the language being worked on and adhere to the style guidelines and requirements in agents.md and in the card. 

Follow the plan and ensure all review comments are addressed appropriately.

Reuse existing components everywhere possible. Use existing implementations for code everywhere possible. 

Validate implementations meet acceptance criteria and address all review comments after implementation. 

Keep all code comments to a **minimum**. No more than 2-3 sentences, no more than 5-10 words per sentence. Refrain from mentioning cards/stories in comments unless it is extremely relevant. The code should be easy enough to read that comments should be rare. If you can reduce existing code comments for code being changes to fit these criteria, do so.

Once you've finished your work, commit your changes and push them up to the repository. Then comment on and resolve the open review comments. 

Once you've finished, notify me using your rune-mcp tools and skills with the following message format `"I have resolve the comments left on pull request <pr_url>."` to notify me you have completed your work.
