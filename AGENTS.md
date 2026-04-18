# AGENTS.md

<!-- agent-template v0.2.0 · https://github.com/aop60003/agent -->

This file defines how AI coding agents (Claude Code, Codex, Cursor, Copilot, etc.) should operate in this repository.
It is a **project-wide default guide**. Replace `<!-- TODO -->` blocks with repo-specific details.

> If repository code, tests, configs, or maintainer instructions conflict with this file, follow the **more specific source of truth**.

---

## 1. Project Overview

<!-- TODO: One-line description, e.g. "Real-time chat platform (Next.js 14 + FastAPI + PostgreSQL)" -->

---

## 2. Tech Stack

<!-- TODO: Frameworks and versions only, e.g. "Frontend: Next.js 14, Backend: FastAPI 0.110+, DB: PostgreSQL 16" -->

---

## 3. Project Structure

<!-- TODO: Folder tree, e.g. "src/app/ (routes), src/services/ (business logic), src/lib/ (utilities)" -->

---

## 4. Non-Negotiable Constraints

<!-- TODO: Project-specific NEVER rules, e.g. "NEVER use `any` type", "NEVER commit .env files" -->

---

## 5. Commands

### 5.1 Setup / Build
<!-- TODO: e.g. "`pnpm install` — deps, `pnpm dev` — dev server, `pnpm build` — prod build" -->

### 5.2 Testing
<!-- TODO: Include single-test execution. e.g. "`pnpm test -- path/to/file.test.ts`" -->

---

## 6. Code Style

- Follow surrounding code style — do not introduce new patterns
- Pattern reference files <!-- TODO: e.g. `src/components/ui/Button.tsx`, `src/services/user.service.ts` -->
- Legacy to avoid <!-- TODO: e.g. `src/legacy/**` — do not reference -->

---

## 7. Safety Boundaries (3-Tier)

### ALWAYS (auto-execute)
- Read files, search code (grep, glob)
- Run type checks, linting, tests
- Check surrounding code context

### ASK FIRST (require user confirmation)
- Install packages / add dependencies
- Create/run DB migrations
- Delete files/directories
- Git push, branch merge
- Run full builds (time-consuming)

### NEVER (forbidden)
- Commit .env, credentials, secrets
- Use `--force` (without `--force-with-lease`), `--no-verify`, or `--no-gpg-sign` without explicit approval
- Run `rm -rf`, `git reset --hard`, or other destructive commands
- Modify production DB directly
- Delete or skip tests without approval (legitimate removal when a feature is genuinely gone — flag the intent, don't silently remove)

---

## 8. Working Rules

### 8.1 Implementation
- ALWAYS read the target file completely before editing
- NEVER leave TODO, FIXME, stub, or placeholder code
- NEVER use generic catch-all error handling (`catch { return null }`)
- NEVER fabricate API versions, config values, or package names
- NEVER rewrite entire files without cause — prefer surgical edits; if a full rewrite is genuinely simpler, state why
- NEVER repeat a failed approach — investigate root cause first
- NEVER self-evaluate as "done" — run tests and show output

### 8.2 Robustness
- ALWAYS handle failure cases — assume external services WILL fail
- ALWAYS set timeouts on network/API calls unless the pattern is intentionally unbounded (e.g. streaming, long-poll)
- ALWAYS clean up resources in finally blocks
- ALWAYS validate inputs at system boundaries
- NEVER suppress errors silently — log with context
- NEVER hardcode config values — use env vars or config files

### 8.3 Edit Safety
- Re-read files before editing if significant time or many edits have passed
- When renaming: grep all references, then bulk-rename
- Before deleting files: verify no import/require references
- For 5+ independent files: batch via parallel tool calls or subagents (if the agent supports them)

---

## 9. Verification Standard (Evidence Required)

A task is not complete just because code was written. Show evidence.

### 9.1 Design — Consistent with existing architecture? No unnecessary complexity?
### 9.2 Implementation — Build / lint / typecheck pass? Tests pass? No leftover TODO/FIXME?
### 9.3 Integration — No regressions? Adjacent workflows still work?
### 9.4 Evidence — Show test/build/lint output. If verification cannot be run, explain why explicitly.
### 9.5 On Failure — If verification fails, do NOT mark the task done. Report what failed, what was tried, and whether a root cause is known, then request direction.

---

## 10. Architecture Notes (Why, not What)

<!-- TODO: Record decisions not derivable from code, e.g. "API routes are thin controllers — logic in src/services/" -->

---

## 11. Git & Contribution Conventions

Defaults (override any that do not match your team):
- Branches: `feat/*`, `fix/*`, `chore/*`, `docs/*`
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`)
- PRs: at least 1 review, CI pass, linear history preferred
<!-- TODO: Adjust any default above or add team-specific rules -->

---

## 12. Tooling

### 12.1 Engram Memory

If `engram` is available (Unix: `command -v engram`; Windows: `Get-Command engram`), use it for cross-session memory: `engram save/find/who/remember/status`. Use `engram-advanced` for `--db <path>` or `--json` output. Ignore if unavailable.

- **Save** — decisions, deadlines, unusual conventions, names/roles — facts that outlive a session
- **Find** — before answering about prior decisions or project state
- **Skip** — transient task state (use tasks/plans instead)

### 12.2 Skills

Skills are placed in two locations (Claude Code + Codex compatible):
- `.agents/skills/<name>/SKILL.md` — canonical (edit here)
- `.claude/skills/<name>/SKILL.md` — Claude Code copy

Superpowers skills from [obra/superpowers](https://github.com/obra/superpowers) + custom skills (`review`, `sprint`, `deploy`).
Browse `.agents/skills/` for the full list and descriptions.

To add a skill: create `.agents/skills/<name>/SKILL.md` with `name` + `description` frontmatter, copy to `.claude/skills/`.
<!-- TODO: Add project-specific custom skills -->

### 12.3 Long-Running Tasks

For large features, use checkpoints. If context exceeds 70%, save state to `.claude/workspace/progress.md` and `/clear`.

---

## 13. Operational Notes

### 13.1 Secrets
- NEVER log, commit, or echo secret values. Reference via env vars or a secret manager only.
- Storage location <!-- TODO: e.g. `.env` (git-ignored), 1Password vault "X", AWS Secrets Manager -->
- If a secret is accidentally committed: rotate immediately, then scrub history (`git filter-repo`).

### 13.2 Dependencies (gate detail for §7 ASK FIRST)
Before proposing a new dependency, verify: (a) license is compatible, (b) last release within ~12 months OR widely used, (c) no lighter alternative in the current stack. State these in the request.

### 13.3 Communication
- Match the user's working language (e.g. Korean ↔ English).
- Short, concrete answers; skip preamble. State uncertainty when present.

### 13.4 Onboarding (first actions in this repo)
1. Read `AGENTS.md` (this file), then `README.md`.
2. Scan <!-- TODO: e.g. `src/services/*`, key entry points -->.
3. Run <!-- TODO: test command --> to confirm the environment is wired up.

---

## 14. Additional Context

Large docs should be split and referenced. Claude Code: `@path/to/file.md` (on-demand load). Other agents: standard markdown links — readers open as needed.
<!-- TODO: e.g. `@docs/api-conventions.md`, `@docs/database-guide.md` -->

---

## 15. Agent Behavior Summary

These 5 principles apply always — return to them especially when stuck:

1. **Read first** — read before editing
2. **Change as little as necessary** — only change what's needed
3. **Follow existing patterns** — match the codebase
4. **Verify with evidence** — prove it works
5. **State uncertainty honestly** — say when you don't know

> The goal is not "working code" but **safe, reviewable, repository-consistent changes**.
