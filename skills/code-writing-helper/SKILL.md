---
name: code-writing-helper
description: Steps and constraints for writing code that is safe for the next agent to copy or use. Use before the first edit whenever you write, change, fix, or refactor code in any language, including tests, scripts, build files, and lint configuration. Also use when the user corrects code that you wrote, or when you must decide between a root-cause fix and a workaround.
---

# Code writing helper

The codebase is the largest input to each agent that works in it. Agents copy the patterns that they see. Each change that you make becomes a pattern for the next agent. Write each change so that a copy of it is correct.

## Trust order

Put each constraint at the highest layer that can hold it:

1. **Design.** Types, API shape, module boundaries, directory structure. Make the incorrect code impossible to write.
2. **Static check.** Compiler, type checker, lint rule, import-boundary rule, test.
3. **Verification.** Run the code. Property-based tests. A formal model, if the project has one.
4. **Prose.** Comment, doc, rule file, skill. Use prose only for a judgment that no check can express.

A lower layer is a fallback for a higher layer. A comment that says "do not call X here" is layer 4 for a problem that layer 1 or 2 can solve.

## Before you write

- Find the project's check commands: format, lint, type check, test, build, run. Look in the manifest (`package.json`, `Cargo.toml`, `*.csproj`, `pyproject.toml`), the `Makefile` or `justfile`, and the `scripts/` directory. If the project has a verification script, use it.
- Read the code near your change to learn its conventions. Examine each pattern before you copy it. A pattern is a **workaround** when it hides a clash in place of a fix. Workaround signs:
  - a timer, sleep, or retry that waits for a different part of the system,
  - a cast or `any` that silences the type checker,
  - a suppression (`eslint-disable`, `@ts-ignore`, `#[allow(...)]`, `# noqa`, `#pragma warning disable`),
  - a `catch` or `except` that discards the error,
  - a comment that explains why the code above it is acceptable.
- When a pattern is a workaround or uses a deprecated API, write the correct form in your change. Report the pattern to the user with `file:line`.
- Honor the project's banned APIs and import boundaries. The lint and dependency configuration holds the list.

## While you write

- **Fix the root cause.** If your fix needs a timer, a sleep, a retry, a flag, a cast, or a suppression, find the clash that the workaround hides and fix that. If the root-cause fix is larger than the task, stop and tell the user. Give the cause, the size of the correct fix, and the workaround you rejected.
- **Use the API that needs no nuance.** Some APIs are easy to use incorrectly, for example React `useEffect`, raw timers, manual locks, and manual resource cleanup. Use the project's wrapper for them. If no wrapper exists, tell the user that the call site needs one.
- **Keep code on its side of a boundary.** A directory or package split (for example `electron-main` and `electron-renderer`, or `Domain` and `Infrastructure`) is a design decision. An import across the split is a design error. Move shared code to a shared module.
- **Write few comments.** A comment cannot be enforced, and it goes stale. Write a comment only for a fact that the code cannot state: an external constraint, a link to a specification or issue, an invariant that the types cannot express. Keep it to one line. Put names and structure into the code, not into comments. A comment never justifies a workaround and never describes the change. The commit message describes the change.
- **Keep checks on.** Do not disable a lint rule, a test, or a compiler warning to make your change pass. If you think the check is wrong, tell the user.

## After you write: verify

The work is done when each changed behavior has evidence from a run. A clean compile is not evidence of behavior.

1. Run the static checks on the changed files: format, lint, type check, build.
2. Run the tests that cover the change. For new behavior, add a test. For a bug fix, add a regression test, and make sure that it fails without the fix.
3. Run the code the way a user runs it:
   - CLI: run the command and read the output.
   - Server: send a request to the endpoint.
   - UI: open it and operate it with browser automation or the DevTools protocol. Take a screenshot. If a `run` skill is available, use it.
   - Library: call it from a test or a temporary script.
4. If you run the same set of commands more than one time, propose a script in the repository for them.
5. Report: the commands you ran, their results, and the evidence (an output excerpt or a screenshot path). Report failures with their output. Name each step that you did not do, and why.

## When the user corrects you

A correction is data about the codebase, not only about you. Change the codebase so that the error cannot occur again, then fix the error.

1. **Design first.** Can a type, a wrapper API, removal of the dangerous option, or a move behind an import boundary remove the error? If yes, propose it.
2. **Then a check.** Propose a lint rule, a banned-API entry, an import-boundary rule, or an architecture test. Make the error message state the fix: what to use, and where. Example: "Raw useEffect is banned in product code. Use useSubscription from @app/hooks." For the configuration syntax per ecosystem, read `references/enforcement-recipes.md`.
3. **Find the old instances.** Run the check on the full codebase. List each existing violation with `file:line`. Propose a cleanup. Until the cleanup is done, keep the old violations in an explicit allowlist so that only new violations fail.
4. **Prose last.** Propose a prose rule only when no check can express the correction. Ask the user where it goes (project `CLAUDE.md`, a rules file, or a skill).

Do not make a one-time correction into a permanent rule. If you cannot tell whether the correction applies in general, ask.

Propose the check and wait for approval before you add it, unless the user told you to add it.
