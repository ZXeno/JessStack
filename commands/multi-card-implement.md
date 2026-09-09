---
name: multi-card-implement
description: Implement multiple Skuld cards plan end-to-end (plan, code, test, PR, notify)
agent: build
model: zai-coding-plan/glm-5.3
---

Usage: /multi-card-implement <board_name> <additional_instructions>

Arguments provided: $ARGUMENTS

Parse the arguments above: the first token is the name of the Skuld board to get cards from. The remainder is additional instructions for this command. If there are multiple guids, then the additional instructions should include a list of card ids. 

Using your Skuld MCP tools, get the board provided in `board_name`. If the `additional_instructions` value is provided, read and consider its contents. If `additional_instrucstions` is a list of guids, attempt to retrieve each as a card ID.

If no `additional_instructions` value is provided, or the `additional_instructions` does not include a column name or id, then use the board's "To Do" column as the source of the cards.

Move each card to the "In Progress" column in Skuld.

Always apply the `unslop` skill.

Create a detailed work plan for each card. For the items in your TODO list, add them to the "Tasks" on the related card in Skuld.

Begin implementation work according to the acceptance criteria for each card. Each time you complete an item on your todo list, update the same task on the card in Skuld. Update your todo items as you complete them.

Utilize available skills relevent to the language being worked on and adhere to the style guidelines and requirements in agents.md and in the card. Follow the plan and ensure all acceptance criteria are met. Reuse existing components everywhere possible. Use existing implementations for code everywhere possible. Frontend code should be testable by the user once a pull request is created. Validate all implementations meet acceptance criteria after implementation. 

Tests are required for all work.

Keep all code comments to a **minimum**. No more than 2-3 sentences, no more than 5-10 words per sentence. Refrain from mentioning cards/stories in comments unless it is extremely relevant. The code should be easy enough to read that comments should be rare. If you can reduce existing code comments for code being changed to fit these criteria, do so. Follow best practices where possible for implemented code. Stability, reliability, maintainability are key concerns.

If the project has a docker image/docker compose file, ensure that the local dev container is removed, rebuilt, updated, running, and reachable once you've completed implementation.

Update the `agents.md` file with relevant changes. Refrain from mentioning story or card ids/names.

Once you are finished with your work, commit your changes, create a pull request, then move the card in Skuld to the "Code Review" column.

Include in your pull request description a list of each card title and full card id. make your pull request descriptions terse but descriptive. Always apply the `unslop` skill to your descriptions.

Create a bulleted list of each card title and id separated by ` | ` , enclosed in backticks as <`[card_id]` | `[card_title]`> with the url on a separate line after the list, with the singular message separated by a blank line after: "Work is completed on the above cards. PR URL: `pr_url`". Notify me using the `rune-send-message` skill with the message you created with the prior instruction.
