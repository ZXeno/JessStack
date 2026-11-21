---
name: feature-spec-grill
description: Grill the user on a work item in the tracker until the work item has a clear story, settled decisions, and testable acceptance criteria, then move it to To Do. Use whenever the user names a work item, work item ID, or tracker project and wants to spec, refine, groom, flesh out, or grill a feature, even if they do not say "grill" or "spec". GLOSSARY.md defines the tracker and the work item name.
---

# Feature spec grill

This skill runs the /grill loop against one work item in the tracker. GLOSSARY.md defines the `tracker` and the `work item name`. Use the work item name from GLOSSARY.md when you talk to the user. The result is a work item that a developer can build from without more questions, in the To Do state.

A tracker project is the board, repository, or project in the tracker that holds the work items for this project.

## Rules

- Get facts from the tracker, the charter, and the codebase.
- Use the tools in the "Tracker MCP tools" table of GLOSSARY.md. For an action that the table does not list, use the tracker tool that does that action. If no tracker tool does the action, tell the user. Then give them the text to enter by hand.
- If GLOSSARY.md names no tracker, tell the user to run /setup-jessstack and stop.
- If no tool for the tracker is available, tell the user and stop.
- If a tracker tool returns 401, 403, or any "unauthorized" result, stop all work. Tell the user which call failed and give the error text. Do not try a different tool, account, or route. Only the user can fix access.
- Do not bypass a security control for any reason.
- Write each decision to the work item when the user settles it. Then, if the session stops, the work item keeps all settled work.
- Change one work item at a time. Do not keep decisions to write later with decisions for other work items. A batch write that fails can lose the work of a full session.
- Do not write repository/project-wide rules into a work item description, acceptance criteria, or comments. If a new rule is to be written, discuss it with the user and either write it to the project charter, a project rules document to be added to the tracker project, or ask the user where they want the rule to reside.

## Step 1: Find the tracker project

1. List the projects in the tracker.
2. Find the tracker project for this project. Match on the name the user gave, then on the repository name. If more than one tracker project can match, ask the user which one.
3. If the tracker project exists, read it and its charter. The charter holds the constraints, tech stack, and architecture that guide each recommendation. If the tracker project has no charter, tell the user. Ask if they want to continue without it.
4. If no tracker project exists, hand off to the /create-project skill and stop. If the /create-project skill is not available, tell the user and stop.

## Step 2: Read the work item

- If the user gave a work item ID, read the work item with that ID.
- If the user gave a work item name, find the matching work item in the tracker project. If more than one work item matches, ask the user which one.
- If the user gave no work item, list the work items in the backlog and ask which one to start.

## Step 3: Set the story and intent

- **Title only.** Grill the user on intent. Find who needs the feature, what they need, and why. Write the description to the work item when the user agrees to it.
- **Description present.** Give the story back to the user in one or two sentences. Ask the user to agree or correct it. Update the work item if the story changes.

Use the "Description" section of the work item template below.

## Step 4: Learn the codebase

Do this before the first grill round. Options and recommendations must come from facts, not guesses.

1. Read the code that the work item touches: modules, data models, APIs, tests, and docs. For a wide search, send an Explore sub-agent and use its summary.
2. Read each attachment on the work item.
3. Read the charter. Its constraints, tech stack, and architecture apply to the work item.
4. Record:
   - Patterns in the code that the work item must follow.
   - Code the work item must change.
   - Conflicts between the work item and the charter.
   - Other work items that this work item depends on, or that depend on it.

## Step 5: Grill the work item

Run the /grill loop with the format below. Ask only the questions that apply to the work item. Topics to check:

- Scope: what is in and what is out.
- Behavior, edge cases, and errors.
- Data and schema changes, and migration.
- Interfaces: API, UI, CLI, and events.
- Security and permissions.
- Performance limits.
- Tests.
- Dependencies on other work items or systems.

**Security flags.** If the work item or an answer adds a security risk, flag it at the top of the next message. Do not hold it for a later round. Risks include auth, secrets, user input, personal data, permissions, and calls to external services. Give the risk and the control you recommend.

**Split answers.** An answer is split if the user picks more than one option, answers only part of a question, or makes the answer depend on an open question. Settle each split answer with a short follow-up before you open the next frontier. A split answer left open becomes a silent assumption in the next round.

After each round, write the settled decisions to the work item (see step 7).

The grill is done when the frontier is empty and the user agrees that you have a shared understanding.

## Step 6: Set the category

The category is the field that the tracker uses to group work items, such as a category, label, or tag.

1. Get the categories in the tracker project.
2. Pick the category that fits the work item. Tell the user your choice and why.
3. If no category fits, recommend a new category name and give the reason. Make the category only if the user agrees.

## Step 7: Lock decisions into the work item

Write to the work item after each grill round, not at the end. Update these sections:

- **Decisions.** One line for each decision, with the reason.
- **Acceptance criteria.** Each criterion must be testable. Use Given/When/Then.
- **Description.** Update it if the story changed.
- **Dependencies.** Work items and systems this work item needs.
- **Schema.** Data model or API contract changes, if any.

## Step 8: Addressing Open Charter Questions

If the result of the grill settles an open charter question, remove the open question from the charter. Tell the user that the grill resolved an open charter question.

If the grill answers no open charter question, skip this step and say nothing.

### Work item template

```markdown
## Description
As a <user>, I want <capability>, so that <benefit>.

<Intent: one or two sentences on the problem and the expected result.>

## Decisions
- <Decision>. Reason: <reason>.

## Acceptance criteria
- [ ] Given <state>, when <action>, then <result>.

## Dependencies
- <Work item ID or system>: <why>.

## Schema
<Tables, fields, types, or API contract. Write "None" if no change.>
```

## Step 9: Move and assign

1. Move the work item to To Do. If the tracker has no To Do state, use the state that means "ready to start". If more than one state can match, ask the user which one.
2. If the user did not give an assignee, ask who owns the work item. Set the assignee.

## Step 10: Ask about the next work item

Ask the user which work item to grill next. If they name one, go to step 2. You already have the tracker project and charter.

## Grill format

Number each question. Letter each option. Give a tradeoff for each option and a recommendation for each question.

```markdown
-----

**Q1. <Question title>**
<Question. Include the facts from the codebase or charter that apply.>

a. <Option>. Tradeoff: <cost and benefit>.
b. <Option>. Tradeoff: <cost and benefit>.
c. <Option>. Tradeoff: <cost and benefit>.

Recommendation: <letter>. <Reason.>

-----

**Q2. <Question title>**
...
```

Security flag format, at the top of the message:

```markdown
**Security flag:** <Risk>. Recommended control: <control>.
```

### Example round

```markdown
-----

**Q1. Token storage**
The work item adds API tokens for webhook delivery. The codebase stores secrets in `config/secrets.yml` with no encryption. The charter lists PostgreSQL as the only datastore.

a. Store tokens in plain text in PostgreSQL. Tradeoff: no new parts, but a database leak exposes all tokens.
b. Store a hash of each token in PostgreSQL. Tradeoff: a leak exposes no tokens, but users cannot see a token again after creation.
c. Store tokens in an external secrets manager. Tradeoff: strong protection, but adds a service the charter does not list.

Recommendation: b. A hash protects tokens with no new service. Users can make a new token if they lose one.

-----
```
