---
name: extract-skill
description: Read through the current conversation and/or session and extract a reusable skill from the process that was used. Use this when you want to extract a skill from a session or transcripts to either automate a process, or define a workflow. Don't use this for simple skills, new-from-scratch skills, or to update an existing skill.
disable-model-invocation: true
---


# Extract Skill

A process for collecting information from the current context and session history and any related sessions to generate a new skill. Align with the user to understand the intent and expected flow for the new skill.

Note: The user has asked you to extract a skill, so you should see what you can learn from the user, and the conversation and context directly after.

From this point forward, `unslop` must be applied to all written text.


## Phase 0 - User Request and/or Intent

Ascertain what the user is trying to accomplish. Prefer using the `AskUserQuestion` tool to get direct responses during the use of this skill, unless the instructions in this skill redirect to `grill`.

- If the user didn't provide any specific instruction, goal, or intent, ask the user to define what they want the new skill to do or what its purpose is.
- Ask when the skill should be invoked.
- Ask if model invocation should be disabled.
- If the user doesn't give any limitations or constraints, ask the user what they **do not** want the skill to do and when they **don't** want it to run.

If they're asking to create a new skill from scratch, not based on the current context, `grill` the user on the expected results and pass that information to `skill-creator`.

See if any other skill matches what the user described, either by name, description, or their intent. If you find a skill matching one of those criteria, stop here and tell the user that their intent aligns with the skill `<skill-name>`.


## Phase 1 - Collection and Research

Read the current context first. Then search the session transcripts of the current project:

- Transcripts are in `~/.claude/projects/<project>/`, one `.jsonl` file per session. `<project>` is the project path with each non-alphanumeric character changed to `-`, for example `-home-user-my-repo`.
- To find the current session, `grep` for a phrase from the latest user message. Do not pick a phrase with quotes or backslashes.
- If the conversation was compacted, search the current session's transcript. The summary can drop corrections.
- Search the 10 most recent transcripts for 2 to 4 keywords from the user's request.
- Read only the matching lines and the lines near them. A full transcript can be larger than your context.

Collect these items from the sources:

- **Steps.** Each step of the process, in the order that produced the result.
- **Corrections.** Each place where the user corrected you or your output, or asked for a change. Record what you did and what the user wanted.
- **Failures.** Each tool call or approach that failed, and the one that worked in its place.
- **Delegation.** The work that the user gave to subagents or tools, and the work that the user wanted to approve first.
- **Verification.** The checks that the user expected before they accepted a result.
- **Done.** The condition that ended the work, and how the user confirmed it.
- **Conventions.** The names, file locations, formats, and commands that the user used more than once.
- **Preferences.** How the user wanted questions, answers, and output given to them.

Corrections and failures are the most important items. They show what the skill must prevent.


## Phase 2 - Structuring

Take the collected information and structure it into a rough outline for a skill. Identify the steps that need to be taken and what order those steps need to be performed in for a successful outcome. Genericize the process (replace project names, paths and IDs with placeholders) and ask the user if a highlight of the steps looks correct.

The answers should include:
- "Agree."
- "No, this isn't correct." (if this answer is chosen, stop and `grill` the user)

If the user selects "Other", take user's answer as direction on how to proceed. If the later steps conflict with the instruction, recommend the user to retry using `skill-creator`.

For example, your question should look something like this:
```
Here's what I've identified per your request:
- **Step 1** - Read the source material.
- **Step 2** - Identify the boundaries of the work.
- **Step 3** - Perform an impact analysis.
- **Step 4** - Create a plan outline.
- **Step 5** - Write the file.

Do you agree with these findings or is there something else?
```

Repeat this phase until the user selects "Agree".


## Phase 3 - Draft and Refine

Stick to the `skill-creator`'s structuring and format guidelines for the skill you're writing. Use its `Write the SKILL.md` guidelines for writing the skill draft.

Write the initial draft to the session scratchpad directory. If the session scratchpad isn't available, and the repo is a git repository, create a separate worktree and do your work there. If neither of those are true, use an OS-appropriate temp directory. If none of the prior are valid locations, ask the user where they want the draft to be saved.

Show the draft to the user. Ask the user for feedback. Expect the user to need multiple iterations of feedback. Cut, trim, shorten, and eliminate relentlessly. For each iteration, ask if the user has feedback or if they approve the draft.


## Phase 4 - Write It

Skip `skill-creator`'s automated testing of the skill. Automated iterative testing isn't helpful for skills created this way. If the user asks for you to test the skill, follow `skill-creator`'s automated testing.

Ask the user where to write the skill with `AskUserQuestion`. Give these options:

- `~/.claude/skills/<skill-name>/` (recommended). Claude Code loads the skill in all projects.
- `.claude/skills/<skill-name>/` in the root of the current repository. Claude Code loads the skill only in sessions in this repository.

The "Other" answer lets the user give a different path, for example a skills repository. A skill at that path does not load until the user copies it to a skills folder.

Do not write to `~/.claude/skills/<folder>/<skill-name>/` unless `<folder>` contains `.claude-plugin/plugin.json`. Claude Code does not load a skill at that depth.

Copy the draft from the session scratchpad to the location that the user selected. Put references in the `references/` folder and scripts in the `scripts/` folder of the skill.

Once you've written the file, advise the user to read the contents to ensure they match what they expect. Ask the user if they would like the file opened in their default markdown or code editor. Do so if they agree. Otherwise, stop here.


## Guardrails and Limitations

- For user feedback, avoid one-time corrections as hard-rules.
- Avoid hyper-focusing on a singular detail the user may have provided, clarify if you find yourself leaning on a single mention of something as a rule.
- Keep sections minimal. Only add a section if the user has a specific, non-default rule there. "Communicate clearly" is not a section. "Short paragraphs. Tables when comparing options. Bullets only when items are genuinely parallel." is.
- Keep name conventions generic, do not use the user or author's name, hard-coded paths, project names, hostnames or credentials from the source sessions in a skill file.
- Do not inline things that would better work as a reference. Tables, examples, external doc references.
- Any time you are uncertain, unclear, or find there is ambiguity, ask the user to clarify by using `AskUserQuestion` for simple clarifications, or `grill` if there is a large gap in understanding.
