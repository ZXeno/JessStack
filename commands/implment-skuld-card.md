---
name: implment-skuld-card
description: Implement a Skuld card plan end-to-end (plan, code, test, PR, notify)
agent: build
---

Using your Skuld MCP tools, read the contents of the card id: `$ARGUMENTS`.

Move the card to the "In Progress" column in Skuld.

Always apply the `unslop` skill.

Create a detailed work plan. For the items in your TODO list, add them to the "Tasks" on the related card in Skuld.

Begin implementation work according to the acceptance criteria. Each time you complete an item on your todo list, update the same task on the card in Skuld. 

Utilize available skills relevent to the language being worked on and adhere to the style guidelines and requirements in agents.md and in the card. Follow the plan and ensure all acceptance criteria are met. Reuse existing components everywhere possible. Use existing implementations for code everywhere possible. Frontend code should be testable by the user once a pull request is created. Validate implementations meet acceptance criteria after implementation. 

Tests are required for all work.

Keep all code comments to a **minimum**. No more than 2-3 sentences, no more than 5-10 words per sentence. Refrain from mentioning cards/stories in comments unless it is extremely relevant. The code should be easy enough to read that comments should be rare. If you can reduce existing code comments for code being changes to fit these criteria, do so.

If the project has a docker image/docker compose file, ensure that the local dev container is removed, rebuilt, updated, running, and reachable once you've completed implementation.

Update the `agents.md` file with relevant changes.

Once you are finished with your work, commit your changes, create a pull request, then move the card in Skuld to the "Code Review" column.

Once the pull request has been created, make this call via terminal:

`hermes send --to telegram "Benimaru has completed task "<card_name>". PR created for $ARGUMENTS at <pr_url_here>"`

Replace `card_name` with the name of the Skuld card. Replace `<pr_url_here>` with the correct url for the pull request.
