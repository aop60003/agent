# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
