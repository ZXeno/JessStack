---
name: impl-work-plan
description: Command to begin implementation of a work plan. Takes in the file path for work plan to implement.
disable-model-invocation: true
effort: high
---

Arguments: $ARGUMENTS

`$ARGUMENTS` containst he following:
- A work-item implementation plan in the `{plan_path}` variable.

Always apply the `unslop` skill.

Read the implementation plan at {plan_path}.

The work plan should contain a work item link or id, place that in `{work_item_id}`

If the user has not provided a directory location for the implementation path, stop immediately and have the user re-run the command and provide a file path. Use the following message: `You did not provide an implementation plan. Please provide a path to the implementation plan I must follow. I cannot do work without a plan.` and stop. 

Follow the implementation plan precisely. Do not deviate from the plan.
If a deviation from the plan is required, immediately stop implementation and /grill user on the correct course of action.

Load any relevant skills to the languages used in the codebase.
Unit tests are required for all work where feasible.

Once you have completed your work, validate your changes against the acceptance criteria. Ensure unit tests include coverage for acceptance criteria.

Create a detailed summary of implementation changes as a markdown document and save it to the same directory as the plan. Use the file name format of `{work_item_id}_implementation_report.md`. List all files changed, what lines were changed, and a summary of tests used to validate acceptance criteria.

Once this report is saved, open it in the user's default program.

You are not permitted to make any changes outside the repositories identified in the work plan.
You are not permitted to make external/remote requests outside the use of MCP tools, unless explicitly instructed by the user and the user confirms the instruction.
