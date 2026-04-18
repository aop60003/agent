# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `AGENTS.md §9.5 On Failure` — explicit protocol when verification fails
  (do not mark done, report what failed, request direction).
- `AGENTS.md §13 Operational Notes` — new section with four subsections:
  `13.1 Secrets`, `13.2 Dependencies` (gate detail for §7 ASK FIRST),
  `13.3 Communication`, `13.4 Onboarding`.
- `CLAUDE.md` now extends `@AGENTS.md` with repository-specific §1–4 overrides
  so this repo has actionable project context without polluting the downstream
  template.

### Changed
- `AGENTS.md` version stamp `v0.1.0` → `v0.2.0`.
- Softened rules that conflicted with real workflows:
  - §7 NEVER `--force` — now distinguishes from `--force-with-lease`;
    also names `--no-gpg-sign` alongside `--no-verify`.
  - §7 NEVER test deletion — legitimate removal allowed when a feature is
    genuinely gone, as long as the intent is flagged (not silent).
  - §8.1 arbitrary "under 20 lines" rewrite threshold removed — a full
    rewrite is gated on stated justification, not line count.
  - §8.2 timeout rule — explicit carve-out for intentionally unbounded
    patterns (streaming, long-poll).
  - §8.3 "10+ messages" → agent-agnostic "significant time or many edits".
  - §8.3 "dispatch parallel subagents" (Claude-specific) → "parallel tool
    calls or subagents (if the agent supports them)".
- `AGENTS.md §11 Git & Contribution Conventions` now ships with sane
  defaults (Conventional Commits, `feat/*`/`fix/*` branches, 1 review + CI)
  instead of a pure TODO block.
- `AGENTS.md §12.1 Engram Memory` — added when-to-save / when-to-find /
  skip guidance and a Windows `Get-Command` detection note.
- `AGENTS.md §14 Additional Context` (was §13) — `@reference` import now
  explicitly labeled as Claude-Code-specific; other agents use standard
  markdown links.
- `AGENTS.md §15 Agent Behavior Summary` (was §14) — 5 principles now
  framed as "apply always", not only "when stuck".

### Removed
- GitHub Actions workflow (`.github/workflows/ci.yml`). The repository is a
  small solo-maintained template; CI coverage was shallow (no Windows or macOS
  smoke test, no Python matrix) and blocked runs from account-level billing
  issues created noise rather than signal. Local validation via
  `shellcheck install.sh uninstall.sh` and
  `Invoke-ScriptAnalyzer install.ps1,uninstall.ps1` before release is
  sufficient at this scale.

## [0.1.0] — 2026-04-18

First versioned release. Substantial reliability and UX pass over the installer
and template surface.

### Added
- `LICENSE` (MIT) — file was missing despite the README claiming MIT.
- `.gitignore` — was not present at repository root.
- `uninstall.sh` / `uninstall.ps1` — interactive uninstallers
  (`--global`/`-Global`, `--yes`/`-Yes`, `--keep-engram`/`-KeepEngram`).
- `SUPERPOWERS_REF` environment variable on both installers — lets callers
  pin `obra/superpowers` to a specific tag, branch, or commit SHA.
- README: multi-agent compatibility table, troubleshooting section,
  `SUPERPOWERS_REF` usage, and up-to-date file tree.
- `CHANGELOG.md` (this file).
- CI: GitHub Actions workflow running `shellcheck` on the bash scripts and
  `PSScriptAnalyzer` on the PowerShell scripts.

### Changed
- **CLAUDE.md contents** now use Claude Code's `@AGENTS.md` import syntax
  instead of the prose sentence `"See AGENTS.md for all project conventions…"`.
  The old pointer was a single literal line — Claude Code read just that line
  and never saw AGENTS.md. The `@<file>` form actually inlines AGENTS.md.
- **obra/superpowers default reference** pinned to `v5.0.7`
  (was unpinned `main`). Users get reproducible installs; opt into
  bleeding-edge with `SUPERPOWERS_REF=main`.
- **`skills/AGENTS.md`** reduced from 301 lines of duplicated project template
  to 53 lines of focused skill-authoring guide. The repository now has a single
  canonical project template (root `AGENTS.md`).
- **Installer temp dir cleanup** now runs even on failure:
  bash `trap '… EXIT'` and PowerShell `try/finally`.
- **Completion message** on both installers now explains the
  `python -m engram …` fallback for when `pip install --user` did not update
  PATH, and documents per-agent compatibility (Claude Code, Codex, Cursor,
  Copilot).
- **README multi-agent claim** corrected — Cursor and Copilot do NOT read
  `AGENTS.md`; they use their own formats and require separate setup.
- `AGENTS.md` now carries a version stamp header for future update detection.

### Fixed
- `install.sh` had an inconsistent CLAUDE.md overwrite guard
  (`[ ! -L "CLAUDE.md" ]`) that would silently overwrite symlinks while
  guarding regular files. Removed.
- `skills/review/SKILL.md` used `$ARGUMENTS`, a Claude-Code-only slash-command
  placeholder. Replaced with platform-agnostic natural language so the skill
  works under Codex as well.
- Installers now detect the superpowers extraction directory by glob
  (`superpowers-*`) instead of hardcoded `superpowers-main`, so tag/SHA
  archives (`superpowers-5.0.7`, `superpowers-<sha>`) resolve correctly.

### Known / Deferred
- No `--dry-run` flag on the installers yet.
- No `--venv` option — `engram` is still `pip install --user` only.
- No first-class Cursor / Copilot adapter generation (users configure those
  manually). Could be added as a future `--all-agents` flag.
