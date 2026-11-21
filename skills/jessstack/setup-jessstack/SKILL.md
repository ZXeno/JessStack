---
name: setup-jessstack
description: Set up the JessStack for use. 
disable-model-invocation: true
---

# Setup Jess Stack

Set up the `~/.claude/GLOSSARY.md` file.

## Work Tracker Setup
1. Ask the user what tracker they are using. Such as Azure DevOps (ADO), GitHub Issues, Skuld, etc.
2. Define it on the `tracker` line, replacing "<replaced by `setup-jessstack`>" with the tracker of choice.
3. Check if there is an MCP server associated with their choice. If so, add the basic read-only tools to the Tracker MCP tools table in the `GLOSSARY.md` file. The `Example Tool Table` below is the format.

4. Each of the different work tracker services has their own name for a unit of work. Work Item, Issue, Card, etc. Ask the user to define it.
5. Write it on the `work item name` line, replacing "<replaced by `setup-jessstack`>" with the unit of work.

6. Ask if the user has a way they prefer to be notified, such as telegram or a messaging gateway of some sort.
- If they do, on the "notify me with" line, replace <service or tool> with their choice. Ask if they have an MCP or other tool configured and document it in the `Notification Mechanism` section. Use that info when the user asks to be notified.
- If there is no preferred mechanism, remove the section from the file entirely when `GLOSSARY.md` is written.

## Final Setup
1. Add this line to the end of `~/.claude/CLAUDE.md`: `Read @GLOSSARY.md`

Example Tool Table:
---
### Tracker MCP tools
| tool | description |
|---|---|
| `example_get_item` | gets a `work item` |
---
