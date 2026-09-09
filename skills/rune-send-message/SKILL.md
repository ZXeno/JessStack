---
name: rune-send-message
description: Send a Telegram message via the Rune MCP bot to an allowlisted chat ID using ruen-mcp_send_message. Use when the user asks to send, message, notify, or reply on Telegram, or to ping an allowed chat.
---

# Skill: rune-send-message

Send text messages to Rune's allowlisted Telegram chats through the
`rune-mcp_send_message` MCP tool.

## 1. Find the allowed chat IDs

Rune refuses every chat that is not on its allowlist, so resolve the IDs first.
Read the rune MCP server config under the `mcp` key of the opencode config
(check `~/.config/opencode/opencode.json`, `~/.config/opencode/opencode.jsonc`,
or the project's `.opencode/opencode.json`):

```
"rune": {
  "type": "local",
  "command": ["..."],
  "environment": {
    "RUNE_ALLOWED_CHAT_IDS": "541888012,-100987654321"
  }
}
```

`RUNE_ALLOWED_CHAT_IDS` is a comma-separated list of i64 chat IDs. Parse each
entry as an integer (group chats are negative).

- If the user names or implies a recipient, pick the matching ID.
- If there is exactly one ID, use it.
- If there are several and the recipient is ambiguous, ask the user which one.

## 2. Send with rune-mcp_send_message

Parameters:

| Parameter | Type | Required | Notes |
|---|---|---|---|
| `chat_id` | i64 | yes | Must be on the allowlist; refused locally otherwise |
| `text` | string | yes | Message body |
| `reply_to_message_id` | i64 | no | Threads the reply to a prior message |
| `parse_mode` | string | no | `"MarkdownV2"` or `"HTML"` |

Returns `{"message_id": N}` on success.

Rules:

- Omit `parse_mode` for plain text. Only set it when the message is meant to
  use that formatting; MarkdownV2 requires escaping reserved characters
  (`_ * [ ] ( ) ~ \`` > # + - = | { } . !`), so prefer plain text unless
  formatting is requested.
- Telegram caps a message at 4096 characters. If the content is longer, split
  it into multiple sends and label the parts (e.g. "part 1/2").
- Non-allowlisted chat IDs fail generically without network I/O; Telegram API
  errors surface as tool errors. Report the error to the user instead of
  retrying blindly.
- Never send secrets, tokens, or credentials to a chat.

## Examples

Send a plain message:

```
rune-mcp_send_message(chat_id=541888012, text="Build finished, 42 tests passed")
```

Reply in a thread:

```
rune-mcp_send_message(chat_id=541888012, text="On it", reply_to_message_id=3)
```

Base directory for this skill: /home/jessie/.config/opencode/skills/rune-send-message
