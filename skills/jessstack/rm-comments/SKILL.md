---
name: rm-comments
description: Spawn the comment-terminator agent on a file set or diff, audit its report, fix the accepted `MUST KILL` flags at the root cause, and offer checks for constraint comments.
disable-model-invocation: true
---

# Remove comments

Spawn the `comment-terminator` agent. Audit its report. Fix the flags that you accept.

The agent did not write the code, and it has no stake in the comments. Trust its judgment unless a step below tells you to reject it.

## Scope

Use the files or the diff that the caller gives. If the caller gives none, use the current diff against the base branch. Include the uncommitted changes in the working tree.

## 1. Back up

Copy each file in scope to a backup directory in the session scratchpad. Record the path. Step 3 restores files from this backup. Do not use `git checkout` or `git restore` to revert. They remove uncommitted changes that existed before the agent ran.

## 2. Spawn

Spawn the agent with the Agent tool and `subagent_type="jessstack:comment-terminator"`. Give it the scope as a list of absolute paths or as the diff command. Do not repeat the rules of the agent in the prompt. The agent reads its rules from `${CLAUDE_PLUGIN_ROOT}/agents/comment-terminator.md` and `${CLAUDE_PLUGIN_ROOT}/agent-rules/comment-terminator/`.

Wait for the notification that the agent finished.

## 3. Audit

Read the report of the agent. Run `git diff` on the scope and compare it with the backup.

1. Reject the report if the agent did one of these:
   - It changed code other than a comment, a directive, or a suppression attribute.
   - It changed a file outside the scope.
   - It deleted a comment that a keep clause of the agent protects, for example a license header or a public API doc comment.
   - It gave a `MUST KILL` reason that the code does not support.
   - It flagged code as guilty that a keep clause protects.
2. Accept each reshape flag for a surprise in our own code. Do not restore the comment that the agent deleted for that flag.
3. Keep a comment only if you can prove that it is about a thing we cannot change: an external dependency, a platform, a vendor, or a protocol. Delete each kept comment with no proof.
4. Search the scope for lint and type-checker suppressions that the agent did not report. The rules files in `${CLAUDE_PLUGIN_ROOT}/agent-rules/comment-terminator/` list the forms. A suppression of a rule that protects correctness, reliability, accessibility, or security is a `MUST KILL`.
5. Restore a deleted comment only if a keep clause applies to it exactly and you have proof in the scope.
6. A comment that says `IMPORTANT` or `DO NOT REMOVE` and gives a weak reason needs a trace before you accept the kill or the keep. Trace the symbol that it names with the navigator tools for the language: the Roslyn navigator, LSP, or Grep.
7. After the trace:
   - If the kill is still ambiguous, do not restore the comment.
   - If the keep is false or still ambiguous, delete the comment.
8. If you reject the report, restore the scope from the backup. Spawn the agent one more time. Name the failure in the prompt. If you reject the second report, restore the scope from the backup, and go to step 7. Report the failure as open.

## 4. Plan

Invoke the `code-writing-helper` skill. Follow it for each code change in this skill.

1. Fix each simple flag directly. Examples: delete a dead path, remove an unused parameter, or call the real API in place of a wrapper that hides it.
2. If a flag needs a new shape, for example a rename, an extracted function, a new type, or a new module boundary, write one work plan for all of those flags and the code around them. Show the plan to the user.
3. If a root-cause fix is larger than the scope, stop and `/grill` the user. Give the cause, the size of the correct fix, and the workaround that you rejected. If the run is unattended, report the fix as open and continue with the fixes in the scope.

## 5. Fix

1. Make the smallest root-cause fix in the scope for each accepted flag. Follow the "Fix the root cause" rule of `code-writing-helper`.
2. Remove each workaround that the agent named.
3. Do not add a guard that hides a symptom.
4. Do not fix instances outside the scope. Report them as open with `file:line`.
5. Verify the changes as `code-writing-helper` says.

## 6. Constraint comments

A constraint comment says `do not remove`, `do not change wording`, `talk to X before changing`, or a similar instruction.

1. If the constraint is about a thing we cannot change, keep the comment.
2. If not, propose the highest check that can hold the constraint, from the trust order of `code-writing-helper`: a type, a runtime assertion, a test, or a lint rule. Make the error message of a lint rule state the fix. For lint syntax, read `references/enforcement-recipes.md` in the `code-writing-helper` skill.
3. Wait for the user to approve the check. In an unattended run, add the check only if the caller approved checks before the run.
4. If the user approves the check, add it, then delete the comment.
5. If the user does not approve the check, delete the comment. Report the constraint as open. Write a short plan for the work outside the scope.

## 7. Report

Give the user a report with these items. Write "none" for an empty item.

- The number of comments and suppressions that the agent deleted.
- Each comment that you restored, with `file:line` and the keep clause.
- Each rerun of the agent, with the failure that caused it.
- The work plan from step 4, if you wrote one.
- Each fix, with `file:line`.
- Each check that you proposed, and whether the user approved it.
- Each check that you added, with `file:line`.
- Each constraint that has no check.
- Each item of open work, with `file:line`.
