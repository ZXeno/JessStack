---
name: impl-work-plan
description: Implement a saved work plan. Takes the path of the plan file.
disable-model-invocation: true
effort: high
---

Usage: `/impl-work-plan <plan_path>`

Arguments: `$ARGUMENTS`

The argument is the path of an implementation plan (`plan_path`).

If `plan_path` is empty, stop. Tell me: `You did not provide an implementation plan. Please provide a path to the implementation plan I must follow. I cannot do work without a plan.`

Apply the `unslop` skill to the implementation report.

## 1. Read the plan

1. Read the plan at `plan_path`.
2. Find the work item link or ID in the plan. Use it as `work_item_id`.
3. Invoke the `code-writing-helper` skill. Follow it for each code change in this command.
4. Load the skills for each language that the plan touches.

## 2. Implement

1. Follow the plan with no deviation. If a deviation is necessary, stop and `/grill` me.
2. Follow `code-writing-helper` and `agents.md`.
3. Copy only patterns that pass the workaround check in `code-writing-helper`. Record each workaround that you find with `file:line`.
4. If the root-cause fix is larger than the plan, stop and `/grill` me. Give the cause, the size of the correct fix, and the workaround that you rejected.

## 3. Verify

1. Verify the change as `code-writing-helper` says.
2. Verification is complete when each acceptance criterion in the plan has evidence from a run, and a unit test covers each acceptance criterion that a unit test can cover. A clean build is not evidence.

## 4. Report

1. Write the report to `<work_item_id>_implementation_report.md` in the directory of the plan. Include these sections:
   - **Changes.** Each changed file and its changed lines.
   - **Verification.** Each acceptance criterion, its tests, and its evidence.
   - **Findings.** Each workaround that you found, with `file:line`. Each `scan-added-lines.sh` finding that you kept, with the reason.
2. Open the report in the default program for markdown files.

## Limits

- Change only the repositories that the plan names.
- Make no remote requests outside the MCP tools, unless I give the instruction and confirm it.
