---
name: create-project
description: Grill the user to define a new project, then create its tracker project and charter in the tracker. Use whenever the user wants to start, set up, kick off, or charter a new project, or when another skill such as feature-spec-grill finds no tracker project for the project. Use it even if the user does not say "charter". GLOSSARY.md defines the tracker and the work item name.
effort: xhigh
---

# Create project

This skill defines a new project with the user, then creates its tracker project and writes its charter. GLOSSARY.md defines the `tracker` and the `work item name`. Use the work item name from GLOSSARY.md when you talk to the user. The charter holds the purpose, goals, constraints, risks, and technical baseline. Later skills, such as /feature-spec-grill, read the charter to guide each work item.

A tracker project is the board, repository, or project in the tracker that holds the work items for this project.

## Rules

- Get facts from the tracker and the codebase. Ask the user only for decisions.
- Use the tools in the "Tracker MCP tools" table of GLOSSARY.md. For an action that the table does not list, use the tracker tool that does that action. If no tracker tool does the action, tell the user. Then give them the text to enter by hand.
- If GLOSSARY.md names no tracker, tell the user to run /setup-jessstack and stop.
- If no tool for the tracker is available, ask the user where they want the project to exist. Stop and wait for further instruction.
- If a tracker tool returns 401, 403, or any "unauthorized" result, stop all work. Tell the user which call failed and give the error text. Do not try a different tool, account, or route. Only the user can fix access.
- Do not bypass a security control for any reason.
- Do not create the tracker project until the user agrees to the charter. A tracker project with no charter gives later skills nothing to work from.

## Step 1: Check for a tracker project

1. List the projects in the tracker.
2. Look for a tracker project that matches the project name or the repository name.
3. Do one of these:
   - **No match.** Go to step 2.
   - **Match with a charter.** Tell the user the tracker project exists. Recommend /feature-spec-grill to work on work items. Stop.
   - **Match with no charter.** Tell the user. Use the tracker project that exists, and go to step 2 to write its charter.
   - **More than one possible match.** Ask the user which tracker project, or if this is a different project.

## Step 2: Learn what exists

Do this before the first grill round. If a codebase, README, or design document exists, read it. Use what you find to give recommendations in each grill round, so the user confirms facts and does not type them.

For a large codebase, send an Explore sub-agent and use its summary.

## Step 3: Grill the project

Settle the items below with grill rounds (see "Grill format"). An item can depend on another item. For example, the purpose comes before the goals, and the tech stack comes before the architecture. The frontier rules in /grill set the order.

1. **Project information.** Name, owner, users, and repository.
2. **Purpose.** The problem the project solves, and for whom. Use one or two sentences.
3. **Goals and objectives.** A goal is an outcome. An objective is a measurable step toward a goal. Each objective needs a number or a date, so the team can tell when it is done.
4. **Assumptions and constraints.** Assumptions are facts the team accepts without proof. Constraints are limits on time, budget, platform, compliance, or team size.
5. **Risks.** For each risk, record the likelihood, the impact, and the mitigation.
6. **Tech stack.** Languages, frontend frameworks, backend and backend frameworks, datastores, and I/O. I/O includes APIs, queues, file formats, and external services. Add hosting, build, and test tools if they apply.
7. **Architecture.** The main components and how they connect.
8. **Documentation requirements.** The documents the project must keep, where they live, and who owns each one.
9. **Open questions.** The decisions that stay open after the grill. Record them so that later work items can settle them.

**Security flags.** If an answer adds a security risk, flag it at the top of the next message. Do not hold it for a later round. Risks include auth, secrets, personal data, compliance, and external services. Give the risk and the control you recommend.

**Split answers.** An answer is split if the user picks more than one option, answers only part of a question, or makes the answer depend on an open question. Settle each split answer with a short follow-up before you open the next frontier. A split answer left open becomes a silent assumption in the charter.

**Unknown answers.** If the user does not know an answer, record the item as an open question. Do not guess for them.

The grill is done when the frontier is empty and the user agrees that you have a shared understanding.

## Step 4: Confirm the charter

Show the user the full charter with the template below. Make the changes the user asks for. Continue only when the user agrees to the charter.

## Step 5: Create the tracker project and write the charter

1. Create the tracker project with the project name. Skip this if step 1 found a tracker project with no charter.
2. Write the charter to the tracker project. If the tracker has no charter field, ask the user where to put the charter, such as a wiki page, a pinned work item, or a file in the repository.
3. Tell the user the tracker project name and where the charter is.

## Step 6: Hand off

Tell the user to start a new session and run /feature-spec-grill on the first work item. The project grill fills the context window. A new session starts work item work with only the charter loaded. Stop here.

## Charter template

```markdown
# <Project name> charter

## Project information
- Owner:
- Users:
- Repository:

## Purpose
<One or two sentences.>

## Goals and objectives
| Goal | Objectives (measurable) |
|------|-------------------------|

## Assumptions
- 

## Constraints
- 

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## Tech stack
- Languages:
- Frontend:
- Backend:
- Datastores:
- I/O:
- Hosting, build, test:

## Architecture
<Components and connections.>

## Documentation requirements
| Document | Location | Owner |
|----------|----------|-------|

## Open questions
- 
```

## Grill format

Number each question. Letter each option. Give a tradeoff for each option and a recommendation for each question.

```markdown
**Q1. <Question title>**
<Question. Include the facts from the codebase or documents that apply.>

a. <Option>. Tradeoff: <cost and benefit>.
b. <Option>. Tradeoff: <cost and benefit>.
c. <Option>. Tradeoff: <cost and benefit>.

Recommendation: <letter>. <Reason.>

---

**Q2. <Question title>**
...
```

Security flag format, at the top of the message:

```markdown
**Security flag:** <Risk>. Recommended control: <control>.
```

### Example round

```markdown
**Q1. Primary datastore**
The purpose is a booking tool for one clinic with about 50 bookings each day. The repository has no database code yet. The constraints list one developer and a $20 monthly hosting budget.

a. SQLite. Tradeoff: no server to run and no cost, but only one process can write at a time.
b. PostgreSQL on a managed host. Tradeoff: supports growth and many writers, but costs about $15 each month and adds a service to manage.
c. A hosted document store. Tradeoff: fast setup, but bookings are relational data and need joins.

Recommendation: a. One clinic at 50 bookings each day is far below the SQLite write limit, and it fits the budget. Record "move to PostgreSQL" as an open question for more clinics.
```
