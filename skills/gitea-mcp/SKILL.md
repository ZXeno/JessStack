---
name: gitea-mcp
description: Drive the Gitea MCP server (repositories, issues, PRs, files, branches, releases, Actions, wiki, packages, and more). Use when configuring or calling gitea-mcp tools against a Gitea instance.
---

# Gitea MCP

Manage Gitea resources through the gitea-mcp server: repositories, files, branches, tags, commits, releases, issues, pull requests, reviews, Actions, labels, milestones, wiki, packages, notifications, and time tracking.

## Server setup

Run over stdio (typical client config):

```json
{
  "command": ["gitea-mcp", "-t", "stdio", "-H", "https://gitea.com", "-T", "<token>"]
}
```

Key flags (each has an env alternative): `-H`/`GITEA_HOST` (defaults to `https://gitea.com`), `-T`/`GITEA_ACCESS_TOKEN`, `-r`/`GITEA_READONLY` (hides all write tools), `-S`/`GITEA_SCOPES` and `-O`/`GITEA_TOOLS` (filter loaded tools; setting both is a union), `-d` debug, `-k` ignore TLS errors. HTTP mode (`-t http -p 8080`) is stateless and serves `/mcp` plus `/healthz`; pass the token per request as `Authorization: Bearer <token>` or `Authorization: token <token>`.

## Tool inventory (53 tools)

Tools are grouped by scope. Many are consolidated action-based tools: pass a `method` parameter to select the operation. Tool names are stable; the `method` enum values are exact.

| Tool | Scope | Methods / purpose |
|---|---|---|
| `get_gitea_mcp_server_version` | version | Server version |
| `get_me`, `get_user_orgs` | user | Current user, their orgs |
| `search_users`, `search_org_teams`, `search_repos`, `search_issues` | search | Cross-instance search |
| `notification_read`, `notification_write` | notification | `list`/`get`; `mark_read`/`mark_all_read` |
| `label_read`, `label_write` | label | List/get repo or org labels; create/edit/delete |
| `milestone_read`, `milestone_write` | milestone | Get/list; create/update/edit/delete |
| `wiki_read`, `wiki_write` | wiki | `list`/`get`/`get_revisions`; `create`/`update`/`delete` |
| `timetracking_read`, `timetracking_write` | timetracking | Times, stopwatches; `start_stopwatch`, `stop_stopwatch`, `add_time`, ... |
| `package_read`, `package_write` | packages | List/get versions; `delete` (irreversible) |
| `list_issues`, `issue_read`, `issue_write`, `attachment_read` | issue | Read/get comments/get labels; create/update/comments/labels; attachments |
| `list_pull_requests`, `pull_request_read`, `pull_request_write`, `pull_request_review_write` | pull_request | Details/diff/files/status/reviews; create/merge/...; reviews |
| `actions_config_read`, `actions_config_write` | actions | Secrets and variables |
| `actions_run_read`, `actions_run_write` | actions | Workflows, runs, jobs, logs, artifacts; dispatch/cancel/rerun |
| `create_repo`, `fork_repo`, `list_my_repos`, `list_org_repos`, `get_repository_tree` | repository | Repos and file tree |
| `get_file_contents`, `get_dir_contents`, `create_or_update_file`, `delete_file` | file | Files and commits |
| `create_branch`, `delete_branch`, `list_branches`, `rename_branch` | branch | Branches |
| `create_tag`, `delete_tag`, `get_tag`, `list_tags` | tag | Tags |
| `list_commits`, `get_commit` | commit | History and commit details |
| `create_release`, `delete_release`, `get_release`, `get_latest_release`, `list_releases` | release | Releases |

## Conventions

- **Repository addressing:** almost every tool takes `owner` + `repo` (the repo name only, not `owner/repo`).
- **Identifiers are tolerant:** numeric params like `issue_number`, `pull_number`, `per_page` accept JSON numbers or numeric strings.
- **Pagination:** `page` (default 1) and `per_page` (default 30); values above the Gitea server's `[api].MAX_RESPONSE_ITEMS` (default **50**) are silently capped — don't assume a large `per_page` means "everything". Page until a short result.
- **Dates:** ISO 8601 / RFC 3339 (e.g. `2026-09-09T00:00:00Z`). Unparseable dates are silently ignored by filters.
- **`ref` params** (file/dir reads, tree) accept a branch, tag, or commit SHA.

## Common gotchas

1. **`create_or_update_file` takes plain text.** Pass raw file content in `content`; the server base64-encodes it. Do **not** pre-encode. Updating an existing file requires its current `sha` — get it from `get_file_contents` first. Omit `sha` to create. `branch_name` is where the commit lands; `new_branch_name` optionally creates a new branch from it first (a safe no-force-push edit pattern).
2. **`delete_file` requires the file's current `sha`** plus `branch_name` and commit `message`. Fetch the sha with `get_file_contents` immediately before deleting.
3. **`get_file_contents` returns base64** (`encoding: "base64"`) unless you pass `withLines: true`, which returns decoded `{line, content}` pairs. Use `withLines` for reading source.
4. **Label IDs vs label names.** `issue_write` label operations (`add_labels`, `remove_label`, `replace_labels`) take label **IDs** (numbers); `list_issues` filters by label **names**. Resolve names to IDs with `label_read`.
5. **Write tools may not exist.** If the server runs read-only (`-r`) or scope/tool-filtered, write tools are absent from the tool list entirely — don't retry them; tell the user the server config hides them.
6. **`method` must match the enum exactly** (e.g. `pull_request_write` has no `get` — that's `pull_request_read`). An unknown method returns an error, not a fuzzy match.
7. **`replace_labels` wipes all labels** and sets the given list; `add_labels`/`remove_label` are incremental. Prefer incremental ops unless replacing everything.
8. **Merging PRs:** `merge_style` is one of `merge`, `rebase`, `rebase-merge`, `squash`, `fast-forward-only`. Check `pull_request_read` with `method: "get_status"` for mergeability before merging.
9. **Attachments:** `attachment_read` `download` writes to `output_path` on the local filesystem; small images may be inlined instead — check the result.
10. **Secrets:** `actions_config_write` can only upsert (write-only values) and delete — reading returns only metadata, never the secret value.

## Typical flows

- **Inspect a repo:** `search_repos` or `list_my_repos` → `get_repository_tree` → `get_file_contents` (with `withLines: true`).
- **Edit a file safely:** `get_file_contents` (grab `sha`) → `create_or_update_file` with `branch_name` + `new_branch_name` → `pull_request_write` `create` → `merge`.
- **Triage issues:** `list_issues` (filter by state/labels) → `issue_read` `get`/`get_comments` → `issue_write` `add_comment`/`add_labels`.
- **Release:** `list_tags` or `create_tag` → `create_release` with `tag_name`.
- **CI debugging:** `actions_run_read` `list_runs` → `get_job` → `download_job_log`.
