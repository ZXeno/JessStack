## About

This repo holds the agent skills, commands, agents, and Claude Code tools that I use. I wrote some of them. Other people wrote the others. The list below gives the source of each skill that another person wrote. The repo holds only the items that I use, create, or change.

### Attributions

- `unslop`, `architect`, `why` - [poteto](https://github.com/cursor/plugins/tree/main/pstack)
- `svelte-code-writer` - [sveltejs](https://github.com/sveltejs/ai-tools)
- `svelte-core-bestpractices` - [sveltejs](https://github.com/sveltejs/ai-tools)
- `frontend-design` - [Anthropic](https://github.com/anthropics/skills)
- `skill-creator` - [Anthropic](https://github.com/anthropics/skills)
- `grill` - [Matt Pocock](https://github.com/mattpocock/skills)
- `handoff` - [Matt Pocock](https://github.com/mattpocock/skills)

## Contents

| Path | Contents |
|---|---|
| `.claude-plugin/` | The plugin manifest (`plugin.json`) and the marketplace file (`marketplace.json`). |
| `skills/` | Agent skills. Each skill is a directory with a `SKILL.md` file. A parent directory groups the skills by source. |
| `commands/` | Slash commands that define workflows and workflow rules. The `effort` field in the frontmatter sets the effort level. |
| `agents/` | Subagent definitions. |
| `agent-rules/` | Rule files that agents read. Each subdirectory has the name of its agent. |
| `rules/` | Rule files for `~/.claude/rules/`. The plugin does not install these. |

## Install

The repo is a Claude Code plugin named `jessstack`. The plugin holds all skills, agents, agent rules, and commands in the repo. The repo is also a marketplace named `jessstack` that lists the plugin.

Add the marketplace from your clone of the repo, then install the plugin:

```bash
claude plugin marketplace add /path/to/agent-skills
claude plugin install jessstack@jessstack
```

Claude Code loads the plugin from your clone and does not copy it. A change to a file in the clone takes effect at the next session start, or when you run `/reload-plugins` in a session.

The plugin adds the prefix `jessstack:` to each name. Run a skill as `/jessstack:<skill>`, for example `/jessstack:review-pr`, and a command as `/jessstack:<command>`. The agents are `jessstack:comment-terminator` and `jessstack:test-guy`.

If you copied skills, commands, or agents from this repo to `~/.claude/` before, delete those copies. Claude Code loads the copies and the plugin, so each item shows two times.

After you install the plugin, run `/jessstack:setup-jessstack` once. It writes the JessStack glossary and the Claude rules that you select into `~/.claude/CLAUDE.md`, and it can install the status line.

The status line scripts and some skills run Bash commands. On native Windows, install Git for Windows.

## Skills

### JessStack skills

`skills/jessstack/` holds my skills for Claude Code and other LLM agents.

Some JessStack skills read the JessStack glossary in `~/.claude/CLAUDE.md`. The glossary names the tracker, the name of a work item in that tracker, and the notification tool. Run `setup-jessstack` once to write it.

| Skill | Use |
|---|---|
| `code-writing-helper` | Write code that is safe for the next agent to copy. Fix root causes, keep comments few, verify each change with a run, and turn each correction into a deterministic check. |
| `create-project` | Grill the user to define a new project, then create its project and charter in the tracker. |
| `deep-research` | Research a topic across many sources with subagents, then write a report. |
| `documentation-writing-guidelines` | Write technical documents in ADS-STE100 Simplified Technical English. Gives rules for how-to articles, spec sheets, technical references, and tutorials. |
| `feature-spec-grill` | Grill the user on a work item until the work item has a story, settled decisions, and testable acceptance criteria. Then move the work item to To Do. |
| `review-pr` | Review a pull request on any Git hosting service with one review pass and one filter pass. Post the comments to the pull request. |
| `rm-comments` | Spawn the `comment-terminator` agent, audit its report, fix the accepted `MUST KILL` flags at the root cause, and offer checks for constraint comments. |
| `setup-jessstack` | Ask the user for the tracker, the work item name, and the notification tool. Write the glossary and the Claude rules that the user selects into `~/.claude/CLAUDE.md`, between the `<!-- jessstack:begin -->` and `<!-- jessstack:end -->` markers. Install the status line if the user wants it. |
| `technical-debt-detection` | Find and report technical debt in a codebase. |

### Matt Pocock skills

| Skill | Use |
|---|---|
| `grill` | Interview the user relentlessly about a plan, decision, or idea until you reach a shared understanding. |
| `handoff` | Write a handoff document from the current conversation for a different agent. |

### Pstack skills

| Skill | Use |
|---|---|
| `unslop` | Remove AI writing patterns from text. |
| `architect` | Before you write code, find each system that the change touches. Sketch two designs of the types, signatures, and module boundaries, and pick one. |
| `why` | Find why code works as it does, or why a decision was made. Read the commits and pull request discussions, and cite them. |

### Anthropic skills

| Skill | Use |
|---|---|
| `frontend-design` | Give direction on the visual design of a new or changed user interface. |
| `skill-creator` | Create skills, change skills, and measure how well a skill works. |

### Language skills

`skills/lang-skills/` holds skills for one programming language.

| Skill | Use |
|---|---|
| `rust-unit-testing` | Write and organize Rust unit tests. |
| `svelte-code-writer` | Look up Svelte 5 documentation and analyze Svelte code from the command line. |
| `svelte-core-bestpractices` | Write and analyze Svelte components and modules. |

### Other skills

| Skill | Use |
|---|---|
| `gitea-mcp` | Configure the Gitea MCP server and call its tools. |

## Commands

| Command | Use |
|---|---|
| `complete-skuld-pr` | Complete the last pull request in the session and move its Skuld card to Done. |
| `impl-skuld-card` | Implement one Skuld card. Plan, code, test, open a pull request, and send a notification. |
| `impl-work-plan` | Begin implementation of a work plan from a plan file. Save and open an implementation report when done. |
| `multi-card-implement` | Implement more than one Skuld card with the same steps. |
| `plan-skuld-card-impl` | Create an implementation plan for a Skuld card. Grill on the acceptance criteria before planning. |
| `resolve-pr-comments` | Resolve the comments on a pull request. Read the related Skuld card. |
| `review-skuld-pr` | Review a pull request against the acceptance criteria of its Skuld card. |

Refer to [`commands/README.md`](commands/README.md) for the arguments and the steps of each command.

## Agents

`agents/` holds subagent definitions. The plugin installs them.

| Agent | Use |
|---|---|
| `comment-terminator` | Find comments and lint suppressions in C#, TypeScript, Rust, Svelte, Razor, and Python code, and flag workaround code. The `rm-comments` skill spawns this agent. |
| `test-guy` | Run the test suite of the project and report each failed test with its file, line, error message, and stack trace. |

`comment-terminator` reads its language rules from `agent-rules/comment-terminator/` in the plugin, one file for each language.

## Rules

`rules/` holds rule files. Each file is intended to exist in `~/.claude/rules/`.

| File | Use |
|---|---|
| `csharp_coding_style.md` | C# coding style. The `paths` field in the frontmatter limits the rule to `.cs`, `.razor`, and `.csproj` files. |

Copy the files from the repo root:

```bash
mkdir -p ~/.claude/rules
cp rules/*.md ~/.claude/rules/
```

## Claude Code status line

`skills/jessstack/setup-jessstack/scripts/statusline.sh` writes this line:

```
<tokens> | Context: <pct>% | Session window: <pct>% | Weekly limit: <pct>% | Effort: <level>
```

| Segment | Value |
|---|---|
| `<tokens>` | `context_window.total_input_tokens` |
| `Context` | `context_window.used_percentage` |
| `Session window` | `rate_limits.five_hour.used_percentage`. The script shows `--` when Claude Code sends no value. |
| `Weekly limit` | `rate_limits.seven_day.used_percentage`. The script shows `--` when Claude Code sends no value. |
| `Effort` | `effort.level`. The script omits this segment when the model has no effort setting. |

The percentages change color along a gradient: green at 0%, yellow at 50%, and red at 100%.

The script uses bash, grep, sed, and tr.

### Install

Run `/jessstack:setup-jessstack` and accept the status line. The skill asks before it changes `settings.json`.

To install without the skill, run the installer from the repo root:

```bash
./skills/jessstack/setup-jessstack/scripts/install-statusline.sh
```

The installer does these steps:

1. It copies `statusline.sh` to `~/.claude/statusline.sh`.
2. It sets `statusLine` in `~/.claude/settings.json` to run that script.

If you set `CLAUDE_CONFIG_DIR`, the installer uses that directory in place of `~/.claude`.

Before the installer replaces a file, it copies the old file to `<file>.bak-<timestamp>`.

If `statusLine` runs a different command, the installer makes no change to `settings.json` and exits with status 1. To replace that entry, run the installer with `--force`.

If `statusLine` runs this script, the installer keeps the other fields of the entry, for example `padding`.

The installer uses python3 to edit `settings.json`. If python3 is not available, the installer copies the script, prints the `statusLine` entry for you to add, and exits with status 1.

### Colors

Set the colors in the `env` block of `settings.json`. Write each color as a `#RRGGBB` value, for example `"#FCEE54"`. The `#` is optional. If a variable is missing, is empty, or does not hold a `#RRGGBB` value, the script uses the default. A default of "terminal" means the default text color of the terminal.

| Variable | Item | Default |
|---|---|---|
| `STATUSLINE_TOKEN_COUNT_COLOR` | Token count | terminal |
| `STATUSLINE_CONTEXT_LABEL_COLOR` | `Context:` label | terminal |
| `STATUSLINE_SESSION_WINDOW_LABEL_COLOR` | `Session window:` label | terminal |
| `STATUSLINE_SEPARATOR_COLOR` | `\|` separators | terminal |
| `STATUSLINE_NO_SESSION_DATA_COLOR` | `--` when Claude Code sends no session window value | terminal |
| `STATUSLINE_WEEKLY_LIMIT_LABEL_COLOR` | `Weekly limit:` label | terminal |
| `STATUSLINE_NO_WEEKLY_DATA_COLOR` | `--` when Claude Code sends no weekly limit value | terminal |
| `STATUSLINE_EFFORT_LABEL_COLOR` | `Effort:` label | terminal |
| `STATUSLINE_EFFORT_LEVEL_COLOR` | Effort level | terminal |
| `STATUSLINE_PERCENT_COLOR_AT_0` | Percentage at 0% | `#08A357` |
| `STATUSLINE_PERCENT_COLOR_AT_50` | Percentage at 50% | `#D8B400` |
| `STATUSLINE_PERCENT_COLOR_AT_100` | Percentage at 100% | `#EA0000` |

Example:

```json
{
  "env": {
    "STATUSLINE_TOKEN_COUNT_COLOR": "#FF69B4",
    "STATUSLINE_PERCENT_COLOR_AT_0": "#08A357"
  }
}
```

## Tips for writing skills
A few tips I've picked up along the way for writing useful skills:
- The description section of the frontmatter should really be called the "trigger". It's for telling the agent when to use the skill.
- Keep it lean, don't write fluff. Extraneous sentences and comments become commands for the LLM.
- Be clear, explicit, and direct with what the agent needs to do.
- Write instructions, not essays.
- Keep skill files under 400 lines, less than 200 lines is ideal.
- Don't make prose that which you can script or reference.
- Keep scripts and reference files in the `skill-name/resources/` directory.
- Tell the agent what to achieve.
- Provide constraints, not procedures.
- Don't skip negative cases. Think about when a skill should **NOT** fire.
- Always test it before you ship it.
