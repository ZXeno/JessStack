---
name: feature-spec-grill
description: Grill the user on a Skuld card until the card has a clear story, settled decisions, and testable acceptance criteria, then move it to To Do. Use whenever the user names a Skuld card, card ID, or board and wants to spec, refine, groom, flesh out, or grill a feature, even if they do not say "grill" or "spec". Requires the Skuld MCP server.
effort: xhigh
---

# Feature spec grill

This skill runs the /grill loop against a Skuld card. Skuld is a kanban board for project management. The result is a card that a developer can build from without more questions, in the To Do column.

## Rules

- Get facts from Skuld, the charter, and the codebase.
- If a Skuld tool returns 401, 403, or any "unauthorized" result, stop all work. Tell the user which call failed and give the error text. Do not try a different tool, account, or route. Only the user can fix access.
- Do not bypass a security control for any reason.
- Write each decision to the card when the user settles it. Then, if the session stops, the card keeps all settled work.
- Change one card at a time. Do not keep decisions to write later with decisions for other cards. A batch write that fails can lose the work of a full session.
- Do not write repository/project-wide rules into a card description, acceptance criteria, or comments. If a new rule is to be written, discuss it with the user and either write it to the project charter, a project rules document to be added to be uploaded to the board, or ask the user where they want the rule to reside.
- If the Skuld MCP server is not connected, tell the user and stop.

### Skuld tool names

This file names four Skuld tools: `list_boards`, `get_board`, `get_charter`, and `get_card`. For other actions, use the Skuld tool that does that action. If no Skuld tool does the action, tell the user. Then give them the text to enter by hand.

## Step 1: Find the board

1. Call `list_boards`.
2. Find the board for this project. Match on the name the user gave, then on the repository name. If more than one board can match, ask the user which one.
3. If the board exists, call `get_board` and `get_charter`. If the board has no charter, tell the user. Ask if they want to continue without it. The charter holds the constraints, tech stack, and architecture that guide each recommendation.
4. If no board exists, hand off to the /create-project skill and stop. If the /create-project skill is not available, tell the user and stop.

## Step 2: Read the card

- If the user gave a card ID, call `get_card` with it.
- If the user gave a card name, find the matching card on the board. If more than one card matches, ask the user which one.
- If the user gave no card, list the cards in the backlog and ask which one to start.

## Step 3: Set the story and intent

- **Title only.** Grill the user on intent. Find who needs the feature, what they need, and why. Write the description to the card when the user agrees to it.
- **Description present.** Give the story back to the user in one or two sentences. Ask the user to agree or correct it. Update the card if the story changes.

Use the "Description" section of the card template below.

## Step 4: Learn the codebase

Do this before the first grill round. Options and recommendations must come from facts, not guesses.

1. Read the code that the card touches: modules, data models, APIs, tests, and docs. For a wide search, send an Explore sub-agent and use its summary.
2. Read each attachment on the card.
3. Read the charter. Its constraints, tech stack, and architecture apply to the card.
4. Record:
   - Patterns in the code that the card must follow.
   - Code the card must change.
   - Conflicts between the card and the charter.
   - Other cards that this card depends on, or that depend on it.

## Step 5: Grill the card

Run the /grill loop with the format below. Ask only the questions that apply to the card. Topics to check:

- Scope: what is in and what is out.
- Behavior, edge cases, and errors.
- Data and schema changes, and migration.
- Interfaces: API, UI, CLI, and events.
- Security and permissions.
- Performance limits.
- Tests.
- Dependencies on other cards or systems.

**Security flags.** If the card or an answer adds a security risk, flag it at the top of the next message. Do not hold it for a later round. Risks include auth, secrets, user input, personal data, permissions, and calls to external services. Give the risk and the control you recommend.

**Split answers.** An answer is split if the user picks more than one option, answers only part of a question, or makes the answer depend on an open question. Settle each split answer with a short follow-up before you open the next frontier. A split answer left open becomes a silent assumption in the next round.

After each round, write the settled decisions to the card (see step 7).

The grill is done when the frontier is empty and the user agrees that you have a shared understanding.

## Step 6: Set the category

1. Get the categories on the board.
2. Pick the category that fits the card. Tell the user your choice and why.
3. If no category fits, recommend a new category name and give the reason. Make the category only if the user agrees.

## Step 7: Lock decisions into the card

Write to the card after each grill round, not at the end. Update these sections:

- **Decisions.** One line for each decision, with the reason.
- **Acceptance criteria.** Each criterion must be testable. Use Given/When/Then.
- **Description.** Update it if the story changed.
- **Dependencies.** Cards and systems this card needs.
- **Schema.** Data model or API contract changes, if any.

## Step 8: Addressing Open Charter Questions

If the result of the grill settles an open charter question, remove the open question from the charter. Tell the user that the grill resolved an open charter question.

If the grill answers no open charter question, skip this step and say nothing.

### Card template

```markdown
## Description
As a <user>, I want <capability>, so that <benefit>.

<Intent: one or two sentences on the problem and the expected result.>

## Decisions
- <Decision>. Reason: <reason>.

## Acceptance criteria
- [ ] Given <state>, when <action>, then <result>.

## Dependencies
- <Card ID or system>: <why>.

## Schema
<Tables, fields, types, or API contract. Write "None" if no change.>
```

## Step 8: Move and assign

1. Move the card to To Do.
2. If the user did not give an assignee, ask who owns the card. Set the assignee.

## Step 9: Ask about the next card

Ask the user which card to grill next. If they name one, go to step 2. You already have the board and charter.

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
The card adds API tokens for webhook delivery. The codebase stores secrets in `config/secrets.yml` with no encryption. The charter lists PostgreSQL as the only datastore.

a. Store tokens in plain text in PostgreSQL. Tradeoff: no new parts, but a database leak exposes all tokens.
b. Store a hash of each token in PostgreSQL. Tradeoff: a leak exposes no tokens, but users cannot see a token again after creation.
c. Store tokens in an external secrets manager. Tradeoff: strong protection, but adds a service the charter does not list.

Recommendation: b. A hash protects tokens with no new service. Users can make a new token if they lose one.

-----
```
