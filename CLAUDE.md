@AGENTS.md

---

## This repository (overrides of template §1–4)

### Project Overview
Install-script template that scaffolds `AGENTS.md`, `CLAUDE.md`, skills, and engram for downstream projects.

### Tech Stack
- Shell: bash (`install.sh`), PowerShell 5+ (`install.ps1`)
- Python 3.9+ runtime for `engram-ms`
- Target platforms: macOS, Linux, WSL, Windows

### Project Structure
- `install.sh`, `install.ps1` — installers (keep feature-parity on every change)
- `uninstall.sh`, `uninstall.ps1` — uninstallers
- `AGENTS.md` — USER-FACING TEMPLATE. Do NOT fill its `<!-- TODO -->` blocks here (they are meant for downstream projects).
- `skills/{review,sprint,deploy}/SKILL.md` — custom skills bundled by the installer
- `skills/AGENTS.md` — skill-author notes (not the project template)
- `README.md`, `CHANGELOG.md`, `LICENSE`

### Repo-specific constraints (extend §4)
- Do NOT fill `<!-- TODO -->` blocks in the root `AGENTS.md` — it ships verbatim to downstream projects.
- Keep `install.sh` and `install.ps1` feature-parity on every change.
- No `Co-Authored-By: Claude` trailers on commits (user preference).
