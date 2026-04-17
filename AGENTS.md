# AGENTS.md

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
- Use `--force`, `--no-verify` flags
- Run `rm -rf`, `git reset --hard` or destructive commands
- Modify production DB directly
- Delete/skip existing tests

---

## 8. Working Rules

### 8.1 Implementation
- ALWAYS read the target file completely before editing
- NEVER leave TODO, FIXME, stub, or placeholder code
- NEVER use generic catch-all error handling (`catch { return null }`)
- NEVER fabricate API versions, config values, or package names
- NEVER rewrite entire files — use surgical edits unless under 20 lines
- NEVER repeat a failed approach — investigate root cause first
- NEVER self-evaluate as "done" — run tests and show output

### 8.2 Robustness
- ALWAYS handle failure cases — assume external services WILL fail
- ALWAYS add timeout for network/API calls
- ALWAYS clean up resources in finally blocks
- ALWAYS validate inputs at system boundaries
- NEVER suppress errors silently — log with context
- NEVER hardcode config values — use env vars or config files

### 8.3 Edit Safety
- Re-read files before editing if 10+ messages have passed
- When renaming: grep all references, then bulk-rename
- Before deleting files: verify no import/require references
- For 5+ independent files: dispatch parallel subagents

---

## 9. Verification Standard (Evidence Required)

A task is not complete just because code was written. Show evidence.

### 9.1 Design — Consistent with existing architecture? No unnecessary complexity?
### 9.2 Implementation — Build / lint / typecheck pass? Tests pass? No leftover TODO/FIXME?
### 9.3 Integration — No regressions? Adjacent workflows still work?
### 9.4 Evidence — Show test/build/lint output. If verification cannot be run, explain why explicitly.

---

## 10. Architecture Notes (Why, not What)

<!-- TODO: Record decisions not derivable from code, e.g. "API routes are thin controllers — logic in src/services/" -->

---

## 11. Git & Contribution Conventions

<!-- TODO: e.g. "Branch: feat/*, fix/* | Commit: Conventional Commits | PR: 1 review + CI pass" -->

---

## 12. Tooling

### 12.1 Engram Memory

If `command -v engram` succeeds, use Engram (package: `engram-ms`) for cross-session memory: `engram save/find/who/remember/status`. Use `engram-advanced` for `--db <path>` or `--json` output. Ignore if unavailable.

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

## 13. Additional Context

Large docs should be split via `@reference` — loaded on demand to save tokens.
<!-- TODO: e.g. "@docs/api-conventions.md", "@docs/database-guide.md" -->

---

## 14. Agent Behavior Summary

When stuck, return to these 5 principles:

1. **Read first** — read before editing
2. **Change as little as necessary** — only change what's needed
3. **Follow existing patterns** — match the codebase
4. **Verify with evidence** — prove it works
5. **State uncertainty honestly** — say when you don't know

> The goal is not "working code" but **safe, reviewable, repository-consistent changes**.
