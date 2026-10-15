# Pitfalls

Failure modes seen repeatedly against the Skuld MCP server, and the habits that avoid them.

## Novel category names need categories:manage

`create_card` and `update_card` take a `category` name and get-or-create it: a name already in the registry needs only cards:update, a novel name additionally needs `categories:manage`. The denial arrives as bare `permission denied` before the mutation lands. Do not block on tagging: omit the field, finish the cards, and note in the summary that the user can tag them from the web UI in one pass.

## Diagnose the FIRST failure in a batch before issuing the rest

Repeated failing MCP calls trip the client's circuit breaker: after three consecutive failures the error changes to "server unreachable, auto-retry in ~Ns" even though the server is fine. A parallel batch of eight calls all denied for the same missing permission reads as an outage when it is one argument mistake repeated. On the first failure in a batch, stop, read the error, fix the cause, and only then issue the remaining calls — after a breaker trip, wait out the stated cooldown once instead of retrying into it.

## Masked not-found errors

Board-scoped tools map both "no such board" and "your token may not touch this board" to not-found. Symptom: a tool works on one board and returns `board not found` on another the token can list. Check the role gates in `references/permissions.md` before concluding the board is gone. The same masking applies to cards through `get_card`.

## Column ids are per-board

Column ids are UUIDs minted at board creation and unique per board. Never carry a column id from one board to another. Call `get_board` at the start of every session and use the ids from that response.

## board_id on mutations

`get_card` takes only `card_id`, and its response carries `board_id`. Every mutation — `update_card`, `add_comment`, and the task tools `add_task`, `update_task`, `remove_task` — needs that `board_id` passed explicitly. Omitting it fails as a client-side missing-argument refusal before the call runs; nothing inherits from context. Do not infer a mutation's parameters from a sibling tool's schema: describe the exact tool before its first call in a session — `create_card` and `get_card` set up expectations that `update_card` and `add_comment` break.

## Assignee resolution

`assign_card` takes a user id, not a name. Unknown or soft-deleted ids fail with `bad_request`, but a valid id for a real user is accepted with no board-membership check, so a wrong-but-valid id assigns the wrong person silently. Resolve names to ids with `list_board_access_users(board_id)`, which needs only boards:read. `list_users` requires an instance admin and standard agent tokens usually lack it. Never guess an id.

## get_board payload spillover

`get_board` returns the whole board. On boards with many cards the response exceeds the tool output window and the client spills it to disk or truncates it. In the response JSON the flattened board fields come first, then `columns`, then `cards`, so truncation cuts cards from the tail while the columns stay intact near the head. Prefer the filtered listers, `list_cards` with a column or title filter, or the iteration listers, whenever you do not need the full board. When you do need it, read the columns from the head of the spilled response instead of requesting again.

## Positions are opaque

Card and column positions are dense sequential integers renumbered by the server on every insert, move, and delete. Do not compute midpoints or assume gaps. Anchor moves with `after_card_id` or `before_card_id` and let the server renumber.

## Task order and no positions

`add_task` has no position parameter. Tasks land in the order the calls execute. When mirroring a checklist, issue the `add_task` calls in list order, batched in one turn. Verify the result with `get_card`, which returns tasks in order.

## Completed iterations reject assignment

Every assignment surface, `create_card` with `iteration_id`, `update_card` with `iteration_id`, and `assign_card_iteration`, returns a conflict when the target iteration is completed. No MCP tool completes, reopens, or sets iterations current, so a human must reopen it from the web UI before the assignment can be retried.

## update_charter is whole-content replace

`update_charter` replaces the entire charter, there is no append or patch. Read with `get_charter`, edit the content in memory, then write the full new string. An append attempted by sending only the new section deletes the rest of the charter.

## Charters hold conventions, cards hold features

A charter carries project-level context, overview, stack, conventions, decisions. It never lists features; cards represent features. Planning a new capability means a card, not a charter section.

## Bulk mutations

For requests that touch many cards, filter first with the listers, compute the target set, and print the matched ids and titles before mutating. Batch the writes in groups of ten or so per turn. Every mutating tool returns the full affected card, so verify from the echoed responses instead of re-fetching the board, and state the split of changed versus skipped in the summary.

## Verify writes from echoes

Card-returning tools respond with the full card object. Check `column_id`, `assignee_id`, `iteration_id`, `category_id`, and `position` in the echo rather than issuing a fresh `get_board`. All echoes must agree before reporting success.

## acceptance_criteria is one string, not a list

`create_card` and `update_card` type `acceptance_criteria` as a single string; null clears it. An array argument is refused client-side and the whole call is not invoked — no partial write. Pass a multi-criterion set as one newline-joined string with each criterion on its own `- ` line.

## Category membership: assignment is the probe, tags are not the category

Grant `categories:list` at token creation when the workflow ever needs the registry listing; without it, `list_categories` fails with bare `permission denied`, which proves nothing about the registry's contents. Probe by action instead: assigning an existing category name rides `cards:update` alone, and the echoed `category_id`/`category_name` confirm the match. Do not refuse a rename/re-tag because a read-only listing was denied.

A card's `[PREFIX]` title tag is display text, not data. Changing the category leaves the title untouched, so a re-categorized card keeps its stale tag and misleads every future reader. Retitle the card in the same update as the category change.

## Installed skill copies lag the server

A deployed copy of this skill can predate the server it talks to: tools appear in the client listing that the copy's inventory omits, and workflow fields (category, acceptance_criteria) exist in live schemas but not in its reference tables. The client's tool listing is authoritative over any copy. Describe a tool before its first use in a session instead of trusting the inventory, and when a copy is found stale, port the canonical copy from the Skuld repo (`skills/skuld-mcp/`) rather than hand-patching individual sections.
