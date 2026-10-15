# Installation and connection

## Point an MCP client at Skuld

The MCP server is part of the Skuld backend and needs no separate install.

1. Run Skuld. Docker is the usual path, `docker compose up -d` from the `docker/` directory of the repo, then confirm with `curl http://localhost:8080/api/health`.
2. Finish first-run setup in the browser and create the first admin account.
3. Create a scoped token from the Tokens page or `POST /api/tokens`, granting the permissions from `references/permissions.md` that cover the intended workflow. The token string shows once.
4. Add the server to an MCP client configuration:

```json
{
  "mcpServers": {
    "skuld": {
      "type": "http",
      "url": "http://localhost:8080/mcp",
      "headers": {
        "Authorization": "Bearer skuld_your_token_here"
      }
    }
  }
}
```

Remote deployments fronted by a reverse proxy should use the public HTTPS URL and may also set `SKULD_MCP_ALLOWED_HOSTS` on the server. Full details, including the host allowlist, live in `docs/mcp-setup.md` in the Skuld repo.

Tool names surface with the client's prefix, commonly `mcp__skuld__list_boards` and similar.

## Install this skill for an agent

The skill lives in the Skuld repository at `skills/skuld-mcp/`. Copy or vendor it wherever the consuming agent keeps skills.

- OpenCode: copy the directory into `.opencode/skills/skuld-mcp/` in the project, or `~/.config/opencode/skills/skuld-mcp/` for all projects. The frontmatter `name` and `description` drive discovery.
- Claude Code and compatible agents: copy it into the project's `.claude/skills/skuld-mcp/`.
- Any agent that reads a skill directory: place `SKILL.md` and `references/` under that agent's skill path; the format is plain markdown with YAML frontmatter and no framework-specific constructs.

Vendoring the directory into the agent project as a git subtree or a plain copy keeps the skill reviewable in one place. The drift test in the Skuld repo keeps the content honest; refresh the copy when the Skuld backend changes its MCP toolset.

Instance-specific facts, board ids, user mappings, hostnames, belong in the agent's own configuration layer and never in this skill.
