---
name: complete-skuld-pr
description: Complete the PR and move the card referenced in the current session.
effort: medium
---

Find the last mentioned pull request in this session.

If no PR is mentioned or linked in this session, inform the user they need to provide the pull request they wish the complete and stop immediately.

Complete the current pull request mentioned in this chat session.

Check the PR description for a Skuld card id. If no card Id is present in the pull request description, stop and say nothing. 

Before you complete the pull request, read each Skuld card that the PR description names with `mcp__skuld__get_card`. If a card has a task with `is_completed: false`, do not complete the pull request. List each open task with its card id, task id, and content, and stop.

Once the PR is completed, move the related Skuld card to the "Done" column. Leave a comment that the pull request was completed. Ensure the pull request is linked on the card in the appropriate field.
