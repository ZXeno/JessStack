---
name: rune-send-message
description: Send a Telegram message or notification through the Rune MCP tools. Use when the user asks you to notify them, send a notification, or "message me".
version: 0.1.0
---

# Send a Telegram message

Rune delivers text to chats on its allowlist. Two tools send messages.

- `rune-mcp_notify` sends to every allowlisted chat. It needs only `text`.
- `rune-mcp_send_message` sends to one chat or broadcasts. It also supports replies and formatting.

## Choose a tool

The user says "notify me", "message me", "send me a notification", or names no chat. Call `rune-mcp_notify` with `text`. This is the default path.

The user gives a chat ID, or one appears in the conversation, for example from an earlier `rune-mcp_read_updates` result. Call `rune-mcp_send_message` with `chat_id` and `text`.

Do not read config files or MCP setup output to find a chat ID. `rune-mcp_notify` needs no chat ID, so a plain notification request never needs one.

## Calling the tool

Call `rune-mcp_notify` with `text` set to the message. Keep the message short and factual. State what happened, and name the repo, branch, or task when one applies.

Plain text is correct. Set `parse_mode` to `"MarkdownV2"` or `"HTML"` only when the user asks for that formatting.

To thread a reply, call `rune-mcp_send_message` with `chat_id`, `text`, and `reply_to_message_id`. Both IDs must come from the conversation, such as a receipt or a `read_updates` result.

## Results

Both tools return a JSON array with one entry per chat. `{"chat_id": N, "message_id": M}` means that send worked. `{"chat_id": N, "error": "..."}` means that send failed, and the tool still sends to the remaining chats. The tool reports an error only when every send fails.

Confirm the result to the user in one line, for example "Sent to 2 chats". Show the raw receipt only when the user asks for it or a send failed.
