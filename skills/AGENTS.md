# skills/ Developer Notes

This directory holds the **custom skill templates** bundled with the `agent` installer.
These are *not* a project template — for that, see the root `AGENTS.md`.

When the installer runs, every skill here is copied to both locations in the user's project:

- `.agents/skills/<name>/SKILL.md` — canonical (Codex)
- `.claude/skills/<name>/SKILL.md` — Claude Code copy

## Skill File Format

Every skill lives at `skills/<name>/SKILL.md` and MUST begin with YAML frontmatter:

```yaml
---
name: <skill-name>
description: <one-line purpose — the agent uses this to decide when to invoke>
---
```

The rest of the file is the skill body (instructions, examples, rules).

## Rules for Skills in This Repo

- **Platform-agnostic.** Do NOT rely on Claude-Code-only syntax such as `$ARGUMENTS` or slash-command placeholders. Use natural language: *"if the user specified a file path, use it; otherwise check `git diff --staged`"*.
- **One concern per skill.** Split multi-phase workflows into composable skills.
- **Write what the skill does, not how the agent should think.**
- **`description` matters** — the agent picks a skill based on this string, so be specific.

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with frontmatter + body.
2. Register it in both installers:
   - `install.sh` — add `<name>` to `CUSTOM_SKILLS`
   - `install.ps1` — add `<name>` to `$customSkills`
3. Add a row to the "커스텀 스킬" table in `README.md`.
4. Commit with prefix `feat(skills):`.

## Local Testing

```bash
mkdir /tmp/test-agent && cd /tmp/test-agent
bash /path/to/agent/install.sh --force
ls .agents/skills/ .claude/skills/
```

Open Claude Code or Codex in that directory and trigger the skill by name.
