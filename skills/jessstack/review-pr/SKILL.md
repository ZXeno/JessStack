---
name: review-pr
description: Use when reviewing a pull request given its URL, on any Git hosting service. Runs one reviewer pass and one follow-up filter pass, then posts comments to the pull request.
---

## Overview

Two-pass review for a pull request. Pass 1 reviews the diff and finds issues. Pass 2 filters those issues down to only the ones worth posting. Built for small session/token budgets. Additional information may be provided such as a reference to a story.

**Core principle:** Post only high-confidence, issues. Target Critical and High severity comments per PR.

## When to Use

- Reviewing a PR given its URL
- Specifically requested to

## When NOT to Use

- Trivial PRs (typo fixes, dependency bumps, package-version bumps, one-line config changes)

## Workflow
### Step 1: Load the PR

Find the hosting service from the PR URL. Use the tools for that service in this order:
1. An MCP server for the service (for example Gitea, GitHub, or GitLab).
2. The CLI for the service (for example `tea`, `gh`, or `glab`).

With those tools:
- Fetch the PR from the given URL (title, description, linked issues)
- Fetch the diff / changed files
- Note the repo and file languages involved

If no tool for the service is available and the repository is in the current directory, ask the user for the base and head branch names. Then get the diff with git:

```bash
git fetch origin <base> <head>
git diff origin/<base>...origin/<head>
```

If the service returns a 401, a 403, or another "unauthorized" error, stop. Tell the user. Do not try a different tool.

### Step 2: Check for relevant skills

Before reviewing, check if a skill exists for the languages/frameworks touched by the diff (e.g. C#, rust, svelte, typescript, etc. skills). If skills apply, use them to inform what "good" looks like for that code — idioms, common pitfalls, conventions, best-practies, etc.

### Step 3: Reviewer pass (single sub-agent)

Review the diff directly. The submitted code likely has bugs, find them. Code reviews are a technical process, don't hedge, don't be polite, don't spare people's feelings. For each issue found, record:
- **Category**: bug | security | performance | logic | style | acceptance criteria
- **Confidence**: high | medium | low
- **Priority**: high | medium | low
- **Location**: file + line range
- **Issue**: one sentence
- **Fix**: concrete suggestion
Only keep issues at medium+ confidence. Cover all five categories. Don't skip a category just because nothing obvious jumped out; check each deliberately.
We do want to include dead-code comments only when they are high confidence. Advise the author to validate the code is dead before removing it.
If additional context is provided for acceptance criteria, consider these to be high-priority items.

### Step 4: Follow-up pass (filter agent)

Re-read findings from Step 3 as if you were a second, skeptical reviewer. Validate the claims made yourself. Drop anything that is:
- Speculative or low-confidence
- A nitpick, not a real bug/security/perf/logic/acceptance-criteria issue
- Not clearly actionable
- Not verifiable
Keep only high-confidence issues. If nothing survives, say the PR looks fine — don't invent filler comments, do not leave compliments.

### Step 5: Post comments

For each surviving issue, use the tool from Step 1 to leave a PR comment at the relevant file/line. If no tool can post to the service, give the comments to the user. Comment format:

```
**[category] priority: X, confidence: Y**
Issue: <one sentence>
Fix: <concrete suggestion>
```

If no issues survived, post a single summary comment stating the PR looks good, no blocking issues found. Do not include extraneous information for a "PR looks good." comment.

## Quick Reference
 
| Item | Details |
|---|---|
| Categories | bug, security, performance, logic, style |
| Reviewer pass | Single agent, primed to assume bugs exist |
| Follow-up pass | Same/second agent, filters to high-confidence |
| Target output | 1-3 comments per PR |
| Skills | Check for a skill matching the code's language/framework before reviewing |
| Delivery | Post to the PR with the service's MCP server or CLI. If neither can post, give the comments to the user |

