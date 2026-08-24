# artc-skills

Agent skills for the [artc](https://github.com/sapien-io) document workspace (MCP server).

The repo currently ships one skill:

| Skill | What it does |
|---|---|
| [`artc-artifacts`](skills/artc-artifacts/SKILL.md) | Makes the agent publish **every** artifact/document deliverable through the artc MCP server (`upload_doc` + `get_design_system`), and **never** through host-native artifact surfaces — Claude Artifacts, OpenAI/ChatGPT Canvas, Gemini Canvas, or equivalents. |

## Prerequisite

The agent must have the **artc MCP server** connected (tools like `upload_doc`, `get_design_system`, `list_comments`). The skill routes artifact creation to those tools; it does not provide the server itself.

## Install

### Claude Code (plugin, recommended)

This repo is both a plugin and its own marketplace:

```
/plugin marketplace add sapien-io/artc-skills
/plugin install artc-skills@artc-skills
```

The skill loads automatically whenever the agent is about to create an artifact or document deliverable.

### Any Agent Skills-compatible runtime (manual)

Copy the skill folder into your runtime's skills directory:

```bash
# Claude Code (personal skills)
git clone https://github.com/sapien-io/artc-skills.git
cp -r artc-skills/skills/artc-artifacts ~/.claude/skills/

# Cross-runtime alias recognized by Codex, Copilot CLI, and Gemini CLI
cp -r artc-skills/skills/artc-artifacts ~/.agents/skills/
```

Or add it per-project under `.claude/skills/`.

### Runtimes without skill support

Paste the body of [`skills/artc-artifacts/SKILL.md`](skills/artc-artifacts/SKILL.md) into the agent's system prompt or custom instructions.

## Enforcement hook (Claude Code)

The skill is advice the model weighs; skill discovery can also fail silently in some sessions. So the plugin additionally ships a `PreToolUse` hook that the harness enforces on every call to the built-in `Artifact` tool:

- Read-only actions (`list`, `read`, `comments`, …) pass through.
- Publishes are **denied**, with a reason that routes the model to `upload_doc` — so even a session that never loaded the skill gets redirected.
- Deliberate bypass: when the user has explicitly asked, in their own words, for a native claude.ai artifact instead of artc, the model is instructed to `touch /tmp/allow-native-artifact` and retry. The flag is single-use — one publish per explicit request — so the exception never becomes the default.

This makes artc a strong default rather than an absolute wall: a person who really wants a native artifact says so and gets one; the model can never drift there on its own in a single reflexive call.

## Skill layout

```
.claude-plugin/
  plugin.json        # plugin manifest
  marketplace.json   # marketplace listing (this repo serves as its own marketplace)
hooks/
  hooks.json                 # PreToolUse hook wiring
  native-artifact-guard.sh   # denies native Artifact publishes; single-use explicit override
skills/
  artc-artifacts/
    SKILL.md         # the skill (Agent Skills format: agentskills.io/specification)
```

## Contributing

Add a new skill as `skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter. Test it against a baseline (agent behavior without the skill) before opening a PR.
