## About
This repo contains the agent skills, commands, and Claude Code tools I use, written by myself and others. Any skill written by someone else has been provided with attribution immediately below. This repo will only contain the skills and commands I specifically use, create, or modify, with attribution/source going back to the ones I have brought in for my own use.

### Attributions
- `unslop` - [poteto](https://github.com/cursor/plugins/tree/main/pstack)
- `rust-skills` - [leonardomso](https://github.com/leonardomso/rust-skills/tree/master)
- `svelte-code-writer` - [sveltejs](https://github.com/sveltejs/ai-tools)
- `svelte-core-bestpractices` - [sveltejs](https://github.com/sveltejs/ai-tools)
- `frontend-design` - [Anthropic](https://github.com/anthropics/skills)
- `skill-creator` - [Anthropic](https://github.com/anthropics/skills)
- `grill` - [Matt Pocock](https://github.com/mattpocock/skills)
- `handoff` - [Matt Pocock](https://github.com/mattpocock/skills)

## Contents

| Directory | Contents |
|---|---|
| `skills/` | Agent skills. Each skill is a directory with a `SKILL.md` file. |
| `commands/` | Slash commands, used to specify workflows and workflow rules. The frontmatter sets effort level. (`effort`). |
| `rules/` | Rule files for `~/.claude/rules/`. |
| `profile.CLAUDE.md` | Instructions for all projects. This file goes in `~/.claude/` with the name `CLAUDE.md`. |
| `claude-specific-additions/` | A Claude Code status line script and its installer. |

### Skills

| Skill | Use |
|---|---|
| `code-writing-helper` | Write code that is safe for the next agent to copy. Fix root causes, keep comments few, verify each change with a run, and turn each correction into a deterministic check. |
| `create-project` | Grill the user to define a new project, then create its board and charter in Skuld. |
| `deep-research` | Research a topic across many sources with subagents, then write a report. |
| `feature-spec-grill` | Grill the user on a Skuld card until the card has a story, settled decisions, and testable acceptance criteria. Then move the card to To Do. |
| `frontend-design` | Give direction on the visual design of a new or changed user interface. |
| `gitea-mcp` | Configure the Gitea MCP server and call its tools. |
| `grill` | Interview the user relentlessly about a plan, decision, or idea until you reach a shared understanding. |
| `handoff` | Write a handoff document from the current conversation for a different agent. |
| `review-pr` | Review a Gitea pull request with one review pass and one filter pass. Post the comments through the Gitea MCP tools. |
| `rune-mcp` | Configure the Rune MCP server, a Telegram bot over stdio, and call its tools. |
| `rune-send-message` | Send a Telegram message or notification through the Rune MCP tools. |
| `rust-skills` | Rust coding guidelines. 265 rules in 26 categories. |
| `rust-unit-testing` | Write and organize Rust unit tests. |
| `skill-creator` | Create skills, change skills, and measure how well a skill works. |
| `svelte-code-writer` | Look up Svelte 5 documentation and analyze Svelte code from the command line. |
| `svelte-core-bestpractices` | Write and analyze Svelte components and modules. |
| `technical-debt-detection` | Find and report technical debt in a codebase. |
| `unslop` | Remove AI writing patterns from text. |

### Commands

| Command | Use |
|---|---|
| `complete-skuld-pr` | Complete the last pull request in the session and move its Skuld card to Done. |
| `impl-skuld-card` | Implement one Skuld card. Plan, code, test, open a pull request, and send a notification. |
| `impl-work-plan` | Begin implementation of a work plan from a plan file. Save and open an implementation report when done. |
| `multi-card-implement` | Implement more than one Skuld card with the same steps. |
| `plan-skuld-card-impl` | Create an implementation plan for a Skuld card. Grill on the acceptance criteria before planning. |
| `resolve-pr-comments` | Resolve the comments on a Gitea pull request. Read the related Skuld card. |
| `review-skuld-pr` | Review a pull request against the acceptance criteria of its Skuld card. |

Refer to [`commands/README.md`](commands/README.md) for the arguments, the steps, and the install procedure of each command.

## Profile and rules

### `profile.CLAUDE.md`

`profile.CLAUDE.md` holds the instructions that apply to all projects. The file is intended to exist in `~/.claude/` with the name `CLAUDE.md`.

Copy the file from the repo root:

```bash
cp profile.CLAUDE.md ~/.claude/CLAUDE.md
```

This command replaces a `~/.claude/CLAUDE.md` that exists. To keep the old file, copy it to a different name first.

The profile tells the agent to apply the `unslop` skill. Install that skill with the profile.

### Rules

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

`claude-specific-additions/statusline.sh` writes this line:

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

Run the installer from the repo root:

```bash
./claude-specific-additions/install-statusline.sh
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
- Don't skip negative cases. (i.e. Think about when a skill should **NOT** fire.
- Always test it before you ship it.
