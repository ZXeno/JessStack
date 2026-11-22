---
name: setup-jessstack
description: Set up the JessStack for use. 
disable-model-invocation: true
---

# Setup Jess Stack

Write the JessStack section into `~/.claude/CLAUDE.md`. The section holds the glossary and the Claude rules that the user selects. It sits between the lines `<!-- jessstack:begin -->` and `<!-- jessstack:end -->`. Claude Code strips block-level HTML comments when it loads CLAUDE.md, so the markers cost no context. Do not change text outside the markers.

## Existing Setup
1. Read `~/.claude/CLAUDE.md`. If it has a JessStack section, show the section to the user and ask before you replace it. If the user does not approve, skip to "Status Line Setup".
2. If `~/.claude/JESSSTACK_GLOSSARY.md` or `~/.claude/JESSSTACK_CLAUDE_RULES.md` exists, an older JessStack version wrote it. Read it, and tell the user that this version moves its content into `~/.claude/CLAUDE.md`.
3. In the steps below, offer the values from the existing section or the old files as the default answers.

## Glossary Setup
1. Start the section draft with the text of `${CLAUDE_SKILL_DIR}/resources/jessstack_glossary.md`. The steps below fill in the lines of the draft.

## Work Tracker Setup
1. Ask the user what tracker they are using. Such as Azure DevOps (ADO), GitHub Issues, Skuld, etc.
2. Define it on the `tracker` line, replacing "<replaced by `setup-jessstack`>" with the tracker of choice.
3. Check if there is an MCP server associated with their choice. If so, add the basic read-only tools to the Tracker MCP tools table in the draft. The `Example Tool Table` below is the format.

4. Each of the different work tracker services has their own name for a unit of work. Work Item, Issue, Card, etc. Ask the user to define it.
5. Write it on the `work item name` line, replacing "<replaced by `setup-jessstack`>" with the unit of work.

6. Ask if the user has a way they prefer to be notified, such as telegram or a messaging gateway of some sort.
- If they do, on the "notify me with" line, replace <service or tool> with their choice. Ask if they have an MCP or other tool configured and document it in the `Notification Mechanism` section. Use that info when the user asks to be notified.
- If there is no preferred mechanism, remove the `Notification Mechanism` section from the draft.

## Claude Rules Setup
`${CLAUDE_SKILL_DIR}/resources/jessstack_claude_rules.md` holds optional rules. Each `##` heading in the file starts a section.

1. If the existing JessStack section or `~/.claude/JESSSTACK_CLAUDE_RULES.md` holds rules from a section, tell the user which ones.
2. Ask about all sections in one `AskUserQuestion` call, with one question for each section. Put the section name and its rules in the question. Give the options "Include these rules" and "Do not include these rules". If the user answers "Other", include or exclude the rules that they name. If there are more than 4 sections, use more than one call.
3. Add the included rules to the end of the draft. Copy the text exactly, and keep the `##` heading of each section.

## Write the Section
1. Write the draft to a temporary file. Do not put the marker lines in it; the script adds them.
2. Run `bash "${CLAUDE_SKILL_DIR}/scripts/write-claude-section.sh" <draft file>`. The script backs up `CLAUDE.md`, then replaces the text between the markers, or adds the section to the end of the file. It also removes the old lines `Read @JESSSTACK_GLOSSARY.md` and `Read @JESSSTACK_CLAUDE_RULES.md`.
- If the script reports a marker count error, show the user the marker lines in `~/.claude/CLAUDE.md`. Ask the user to fix them, then run the script again.
3. If `~/.claude/JESSSTACK_GLOSSARY.md` or `~/.claude/JESSSTACK_CLAUDE_RULES.md` exists, ask the user if you can delete it.

## Status Line Setup
The status line scripts need Bash. On Windows, they need Git for Windows. The config directory is `$CLAUDE_CONFIG_DIR`, or `~/.claude` when it is not set.

1. Ask the user if they want the JessStack status line. It shows `<tokens> | Context: <pct>% | Session window: <pct>% | Weekly limit: <pct>% | Effort: <level>`. If they do not, skip this section.
2. Ask the user if you can add the `statusLine` configuration to their `settings.json`. Do not change `settings.json` unless the user approves.
3. If the user approves, run `bash "${CLAUDE_SKILL_DIR}/scripts/install-statusline.sh"`. The script copies `statusline.sh` to the config directory, sets `statusLine` in `settings.json`, and backs up each file that it replaces.
- If the script stops because `statusLine` runs a different command, show the user that command. Run the script again with `--force` only if the user approves the replacement.
- If the script reports that `python3` is not found, add the entry that it prints to `settings.json` yourself. Keep the other keys in the file.
4. If the user does not approve, copy `${CLAUDE_SKILL_DIR}/scripts/statusline.sh` to the config directory. Back up a file that exists there first. Give the user this entry to add to `settings.json`:
```json
"statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh" }
```
If the config directory is not `~/.claude`, put its path in `command`.
5. Tell the user that the status line shows in the next session.

Example Tool Table:
---
### Tracker MCP tools
| tool | description |
|---|---|
| `example_get_item` | gets a `work item` |
---
