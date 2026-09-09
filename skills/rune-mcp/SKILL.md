---
name: rune-mcp
description: Configure and drive the Rune MCP server (Telegram bot over stdio). Use when setting up Rune as an MCP server or calling its tools.
version: 0.1.0
---

# Rune MCP server

Rune exposes one Telegram bot as an MCP stdio server. One process serves one agent, one bot token per process, and every chat (inbound and outbound) must be on an allowlist. Anything off the allowlist is refused.

## Configuration

Rune reads only environment variables and fails fast at startup, naming the bad variable:

| Variable | Required | Meaning |
|---|---|---|
| `RUNE_BOT_TOKEN` | yes | Bot API token from @BotFather |
| `RUNE_ALLOWED_CHAT_IDS` | yes | Comma-separated i64 chat IDs, e.g. `"123456789,-100987654321"`. Missing, empty, or non-numeric entries abort startup |
| `RUNE_TELEGRAM_API_BASE` | no | Bot API base URL, default `https://api.telegram.org` |
| `RUST_LOG` | no | tracing filter, default `info`. Logs go to stderr only |

The allowlist is deny-by-default in both directions. Denial errors are generic on purpose: they never confirm whether a chat exists.

## Invocation

Rune speaks MCP over stdio. Point the client's stdio transport at the binary with the env vars above injected:

```json
{
  "mcpServers": {
    "rune": {
      "command": "/path/to/rune-mcp",
      "env": {
        "RUNE_BOT_TOKEN": "123456:ABC-your-bot-token",
        "RUNE_ALLOWED_CHAT_IDS": "123456789,-100987654321"
      }
    }
  }
}
```

stdout carries MCP frames only. Logs go to stderr, so piping stdout is safe.

## Tools

### read_updates

Fetches pending messages addressed to the bot via getUpdates. Takes no parameters. Returns allowlisted messages in arrival order, each as `{message_id, chat_id, sender_name, text, date}` with `date` in unix seconds. Media messages return their caption, or `[non-text message]` when there is none. Messages from non-allowlisted senders are dropped without a trace in output or logs. Fetch failures return a tool error.

### send_message

Sends a text message to an allowlisted chat.

- `chat_id` (i64, required)
- `text` (string, required)
- `reply_to_message_id` (i64, optional) threads a reply
- `parse_mode` (`"MarkdownV2"` or `"HTML"`, optional)

Returns `{"message_id": N}`. A non-allowlisted `chat_id` is refused locally with a generic error before any network I/O. Telegram API errors surface as tool errors with the token and URL stripped.

### send_document

Uploads a local file to an allowlisted chat as a document.

- `chat_id` (i64, required)
- `file_path` (string, required, local filesystem path)
- `caption` (string, optional)

The Telegram filename is the file's basename. Returns `{"message_id": N}`. Files over Telegram's 50 MiB upload limit, and missing or unreadable paths, fail with a clear tool error before any upload attempt. Uploads get a size-scaled deadline assuming at least 0.5 MiB/s upstream; slower links time out. Non-allowlisted chats are refused locally and generically before any file or network I/O.

## Error behavior

- Non-allowlisted chats: local, generic refusal. No confirmation the chat exists, no network traffic.
- Telegram API errors: surfaced as tool errors, token never included.
- Startup: missing or invalid env vars abort with the variable name on stderr.
