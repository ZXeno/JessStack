## About
This repo contains the agent skills I use and are written by myself and others. Any skill written by someone else has been provided with attribution immediately below. This repo will only contain the skills and commands I specifically use, create, or modify, with attribution/source going back to the ones I have brought in for my own use.

### Attributions
- `unslop` - (poteto)[https://github.com/cursor/plugins/tree/main/pstack]
- `rust-skills` - (leonardomso)[https://github.com/leonardomso/rust-skills/tree/master]
- `svelte-code-writer` - (sveltejs)[https://github.com/sveltejs/ai-tools]
- `svelte-core-bestpractices` - (sveltejs)[https://github.com/sveltejs/ai-tools]

### Tips For Writing Skills
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

