---
name: plan-skuld-card-impl
description: Create an implementation plan for a skuld card. Takes a card id, and option the name of the relevant repository.
effort: high
---

Arguments: $ARGUMENTS

`$ARGUMENTS` contains the following:
- A work-item URL or numeric work item ID. This will be retrieved using Skuld MCP tools.
- An optional list of repositories by name and the file path root of the provided respositories. May contain one or more repositories.
- Additional clarifying or expounding instructions.

Parse the `$ARGUMENTS` into the following:
- The skuld card id or other work item id in `{work_item}`.
- The optional list of repository urls/directory paths should grouped in `{repositories}`.
- Any additional instructions should be grouped in `{additional_instructions}`.

If no work item was provided, stop and instruct the user to rerun the command with the following message: `You did not provide a work item to plan. Please provide a work item for us to review.` and stop.

Read the work item `{work_item}` with your skuld-mcp tools.

The following repositories are relevant: {repositories}. If the user did not provide at least one repository, and the PWD is not a repository, ask the user for a repository path (or paths) before continuing. If none is provided after request, stop.

Ground yourself in the codebase of the repositories. Load any relevant skills to the languages used in the codebase. Identify where in the repositories changes need to be made to meet the acceptance criteria defined in the work item.
/grill the user on the accaptenace criteria and changes until you are both aligned and agree on the changes.
If something is not clear, continue the grill until no questions remain. **DO NOT make any assumptions.**

Make a detailed plan for implementation.
Show and explain each suggested change, citing file names and line numbers and impact of changes.
Use any relevant language skills to the code in the repositories.
You are not permitted to make any changes unless the user explicitly says so.

Ask if the user would like to save the plan and where. If they would like to save it, generate a /handoff document and save it to the location the user specified. Afterwards, open the file in the default program for markdown files.
