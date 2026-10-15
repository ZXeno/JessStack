## About
This repo contains the agent skills, commands, and Claude Code tools I use, written by myself and others. Any skill written by someone else has been provided with attribution immediately below. This repo will only contain the skills and commands I specifically use, create, or modify, with attribution/source going back to the ones I have brought in for my own use.

### Attributions
- `unslop` - [poteto](https://github.com/cursor/plugins/tree/main/pstack)
- `rust-skills` - [leonardomso](https://github.com/leonardomso/rust-skills/tree/master)
- `svelte-code-writer` - [sveltejs](https://github.com/sveltejs/ai-tools)
- `svelte-core-bestpractices` - [sveltejs](https://github.com/sveltejs/ai-tools)

## Contents

| Directory | Contents |
|---|---|
| `skills/` | Agent skills. Each skill is a directory with a `SKILL.md` file. |
| `commands/` | Slash commands. The frontmatter sets OpenCode fields (`agent`, `model`). |
| `claude-specific/` | A Claude Code status line script and its installer. |

### Skills

| Skill | Use |
|---|---|
| `gitea-mcp` | Configure the Gitea MCP server and call its tools. |
| `grill` | Interview the user relentlessly about a plan, decision, or idea until you reach a shared understanding. |
| `review-pr` | Review a Gitea pull request with one review pass and one filter pass. Post the comments through the Gitea MCP tools. |
| `rune-mcp` | Configure the Rune MCP server, a Telegram bot over stdio, and call its tools. |
| `rune-send-message` | Send a Telegram message or notification through the Rune MCP tools. |
| `rust-skills` | Rust coding guidelines. 265 rules in 26 categories. |
| `rust-unit-testing` | Write and organize Rust unit tests. |
| `skuld-mcp` | Manage Skuld boards, cards, tasks, and charters through the Skuld MCP tools. |
| `svelte-code-writer` | Look up Svelte 5 documentation and analyze Svelte code from the command line. |
| `svelte-core-bestpractices` | Write and analyze Svelte components and modules. |
| `technical-debt-detection` | Find and report technical debt in a codebase. |
| `unslop` | Remove AI writing patterns from text. |

### Commands

| Command | Use |
|---|---|
| `impl-work-plan` | Begin implementation of a work plan from a plan file. Save and open an implementation report when done. |
| `implment-skuld-card` | Implement one Skuld card. Plan, code, test, open a pull request, and send a notification. |
| `multi-card-implement` | Implement more than one Skuld card with the same steps. |
| `plan-skuld-card-impl` | Create an implementation plan for a Skuld card. Grill on the acceptance criteria before planning. |
| `resolve-pr-comments` | Resolve the comments on a Gitea pull request. Read the related Skuld card. |
| `review-skuld-pr` | Review a pull request against the acceptance criteria of its Skuld card. |

## Claude Code status line

`claude-specific/statusline.sh` writes this line:

```
<tokens> | Context: <pct>% | Session window: <pct>% | Weekly limit: <pct>% | Effort: <level> | <honcho>
```

| Segment | Value |
|---|---|
| `<tokens>` | `context_window.total_input_tokens` |
| `Context` | `context_window.used_percentage` |
| `Session window` | `rate_limits.five_hour.used_percentage`. The script shows `--` when Claude Code sends no value. |
| `Weekly limit` | `rate_limits.seven_day.used_percentage`. The script shows `--` when Claude Code sends no value. |
| `Effort` | `effort.level`. The script omits this segment when the model has no effort setting. |
| `<honcho>` | The output of the Honcho memory renderer. Refer to [Honcho segment](#honcho-segment). |

The percentages change color along a gradient: green at 0%, yellow at 50%, and red at 100%.

The script uses bash, grep, sed, and tr. The Honcho segment also uses python3.

### Install

Run the installer from the repo root:

```bash
./claude-specific/install-statusline.sh
```

The installer does these steps:

1. It copies `statusline.sh` to `~/.claude/statusline.sh`.
2. It sets `statusLine` in `~/.claude/settings.json` to run that script, with `refreshInterval` set to `1`.

If you set `CLAUDE_CONFIG_DIR`, the installer uses that directory in place of `~/.claude`.

Before the installer replaces a file, it copies the old file to `<file>.bak-<timestamp>`.

If `statusLine` runs a different command, the installer makes no change to `settings.json` and exits with status 1. To replace that entry, run the installer with `--force`.

If `statusLine` runs this script, the installer keeps the other fields of the entry, for example `padding`. It also keeps a `refreshInterval` that you set.

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
| `STATUSLINE_HONCHO_SYNCED_COLOR` | ◆ when Honcho has synced memory context | `#82C8E1` |
| `STATUSLINE_HONCHO_UNSYNCED_COLOR` | ◇ when Honcho has no synced memory context | `#787880` |
| `STATUSLINE_HONCHO_ACTIVE_COLOR` | Honcho glyph and status text during a memory operation | `#E6AF6E` |
| `STATUSLINE_HONCHO_LABEL_COLOR` | `honcho` text and its `·` separator | `#787880` |

Example:

```json
{
  "env": {
    "STATUSLINE_TOKEN_COUNT_COLOR": "#FF69B4",
    "STATUSLINE_HONCHO_SYNCED_COLOR": "#08A357"
  }
}
```

### Honcho segment

The `<honcho>` segment shows the state of the Honcho memory plugin for Claude Code. The script shows the segment only when all of these conditions are true:

- `~/.honcho/honcho-statusline.sh` exists. The `/honcho:setup` command of the Honcho plugin installs this file.
- python3 is available.
- `statusline` is not `"off"` in `~/.honcho/config.json`.

If a condition is false, the script omits the segment. The other segments do not change.

| Glyph | State |
|---|---|
| ◇ | Honcho has no synced memory context. |
| ◆ | Honcho has synced memory context. |
| ◐ ◓ ◑ ◒ or ✦ ✧, with status text | Honcho loads, recalls, or queries memory. |

With `refreshInterval` set to `1`, Claude Code runs the script every second. This lets the glyph move during a memory operation.

The Honcho renderer sets fixed colors. The `recolor_honcho` function in `statusline.sh` replaces them with the `STATUSLINE_HONCHO_*` colors. If a Honcho update changes the renderer colors, the changed parts show the renderer colors until you update `recolor_honcho`.

`/honcho:setup` writes over `~/.honcho/honcho-statusline.sh`. After a Honcho plugin update, run `/honcho:setup` again to get the new renderer.

## Tips for writing skills
A few tips I've picked up along the way for writing useful skills:
- The description section of the frontmatter should really be called the "trigger". It's for telling the agent when to use the skill.
- Keep it lean, don't write fluff. Extraneous sentences and comments become commands for the LLM.
- Be clear, explicit, and direct with what the agent needs to do.
- Write instructions, not essays.
- Keep skill files under 500 lines
- Tell the agent what to achieve.
- Provide constraints, not procedures.
- Don't skip negative cases. (i.e. Think about when a skill should **NOT** fire.
- Always test it before you ship it.
