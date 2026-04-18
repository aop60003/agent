#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# agent — 프로젝트 기본 설정 원스텝 인스톨러 (Mac / Linux / WSL)
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --force
#   curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --global
#
# 수행 작업:
#   1. 사전 확인: python3, pip
#   2. engram 메모리 시스템 설치 (pip)
#   3. ~/.engram/memory.db 초기화
#   4. 현재 폴더에 AGENTS.md / CLAUDE.md 생성
#   5. 스킬 배치: superpowers + 커스텀 (--global: 유저 레벨, 기본: 프로젝트 레벨)
#   6. .claude/workspace 디렉토리 생성
#   7. .gitignore 업데이트
# ---------------------------------------------------------------------------

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/aop60003/agent/main"
# obra/superpowers 고정 참조. 재현성을 위해 기본값은 특정 릴리즈 태그로 고정.
# 최신 main 을 원하면:     SUPERPOWERS_REF=main bash install.sh
# 다른 태그 / SHA 로 고정: SUPERPOWERS_REF=v5.0.6 bash install.sh
#                          SUPERPOWERS_REF=abc1234 bash install.sh
SUPERPOWERS_REF="${SUPERPOWERS_REF:-v5.0.7}"
FORCE=0
SKIP_ENGRAM=0
GLOBAL=0

for arg in "$@"; do
  case "$arg" in
    --force)        FORCE=1 ;;
    --skip-engram)  SKIP_ENGRAM=1 ;;
    --global)       GLOBAL=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
done

c_reset="\033[0m"; c_ok="\033[32m"; c_warn="\033[33m"; c_err="\033[31m"; c_info="\033[36m"
say()  { printf "${c_info}==>${c_reset} %s\n" "$*"; }
ok()   { printf "${c_ok}✓${c_reset} %s\n" "$*"; }
warn() { printf "${c_warn}!${c_reset} %s\n" "$*"; }
die()  { printf "${c_err}✗ %s${c_reset}\n" "$*" >&2; exit 1; }

# ---------- 1. 사전 확인 ----------
say "사전 확인"
PYTHON=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON=python
else
  die "python3 (또는 python) 가 필요합니다 (3.9+)"
fi
command -v pip >/dev/null 2>&1 || command -v pip3 >/dev/null 2>&1 || die "pip 가 필요합니다"
PIP=$(command -v pip3 || command -v pip)
PYV=$("$PYTHON" -c 'import sys;print("%d.%d"%sys.version_info[:2])')
PYV_NUM=$("$PYTHON" -c 'import sys;v=sys.version_info;print(v[0]*100+v[1])')
[ "$PYV_NUM" -lt 309 ] && die "python 3.9+ 가 필요합니다 (현재: $PYV)"
ok "$PYTHON $PYV / pip 사용 가능"

# ---------- 2. engram 설치 ----------
if [ "$SKIP_ENGRAM" -eq 0 ]; then
  say "engram 메모리 시스템 설치"
  if command -v engram >/dev/null 2>&1 && [ "$FORCE" -eq 0 ]; then
    ok "engram 이 이미 설치되어 있음 (--force 로 재설치)"
  else
    # PEP 668 환경(Debian/Ubuntu)에서도 동작하도록 --user 우선
    # engram-ms 가 정식 배포명, memorytrace 는 레거시 별칭 (동일 엔진)
    if ! "$PIP" install --user --upgrade engram-ms 2>/dev/null; then
      "$PIP" install --user --upgrade --break-system-packages engram-ms \
        || die "engram 설치 실패"
    fi
    ok "engram 설치 완료"
  fi

  # DB 초기화 — 기본 경로 ~/.engram/memory.db
  say "~/.engram/memory.db 초기화"
  mkdir -p "$HOME/.engram"
  if command -v engram >/dev/null 2>&1; then
    engram init >/dev/null 2>&1 \
      && ok "engram DB 초기화 완료" \
      || warn "engram DB 초기화 스킵 (이미 존재)"
  else
    "$PYTHON" -m engram init >/dev/null 2>&1 \
      && ok "engram DB 초기화 완료" \
      || warn "engram DB 초기화 스킵 (이미 존재하거나 CLI 미지원)"
  fi
else
  warn "engram 설치 건너뜀 (--skip-engram)"
fi

# ---------- 3. AGENTS.md / CLAUDE.md 배치 ----------
say "AGENTS.md / CLAUDE.md 배치"

download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
  else
    die "curl 또는 wget 이 필요합니다"
  fi
}

place_file() {
  local target="$1" source_url="$2"
  if [ -f "$target" ] && [ "$FORCE" -eq 0 ]; then
    warn "$target 이미 존재 — 스킵 (--force 로 덮어쓰기)"
    return
  fi
  download "$source_url" "$target"
  ok "$target 생성"
}

place_file "AGENTS.md" "$REPO_RAW/AGENTS.md"

# CLAUDE.md 는 AGENTS.md 를 실제로 import (Claude Code 의 @<file> 구문)
if [ -f "CLAUDE.md" ] && [ "$FORCE" -eq 0 ]; then
  warn "CLAUDE.md 이미 존재 — 스킵 (--force 로 덮어쓰기)"
else
  echo '@AGENTS.md' > CLAUDE.md
  ok "CLAUDE.md 생성 (@AGENTS.md import)"
fi

# ---------- 4. 스킬 배치 ----------

# 설치 위치 결정
if [ "$GLOBAL" -eq 1 ]; then
  AGENTS_SKILLS="$HOME/.agents/skills"
  CLAUDE_SKILLS="$HOME/.claude/skills"
  say "스킬 설치 위치: 유저 레벨 (~/.agents/skills + ~/.claude/skills)"
else
  AGENTS_SKILLS=".agents/skills"
  CLAUDE_SKILLS=".claude/skills"
  say "스킬 설치 위치: 프로젝트 레벨 (.agents/skills + .claude/skills)"
fi

# 4a. superpowers 스킬 (github.com/obra/superpowers)
say "superpowers 스킬 다운로드 (obra/superpowers @ $SUPERPOWERS_REF)"
SP_URL="https://github.com/obra/superpowers/archive/${SUPERPOWERS_REF}.tar.gz"
if [ -f "$AGENTS_SKILLS/brainstorming/SKILL.md" ] && [ "$FORCE" -eq 0 ]; then
  warn "superpowers 스킬 이미 존재 — 스킵 (--force 로 덮어쓰기)"
else
  SP_TMP=$(mktemp -d)
  # 오류 경로에서도 temp 디렉토리 보장 정리
  trap 'rm -rf "$SP_TMP"' EXIT
  download "$SP_URL" "$SP_TMP/superpowers.tar.gz"
  tar xzf "$SP_TMP/superpowers.tar.gz" -C "$SP_TMP"
  # 압축 해제 결과 디렉토리(main -> superpowers-main, v1.2.3 -> superpowers-1.2.3, SHA -> superpowers-<sha>)
  SP_SRC=$(find "$SP_TMP" -maxdepth 1 -mindepth 1 -type d -name "superpowers-*" | head -n 1)
  [ -z "$SP_SRC" ] && die "superpowers 압축 해제 디렉토리를 찾지 못했습니다"
  SP_COUNT=0
  for skill_dir in "$SP_SRC"/skills/*/; do
    skill=$(basename "$skill_dir")
    mkdir -p "$AGENTS_SKILLS/$skill" "$CLAUDE_SKILLS/$skill"
    cp -r "$skill_dir"* "$AGENTS_SKILLS/$skill/"
    cp -r "$skill_dir"* "$CLAUDE_SKILLS/$skill/"
    SP_COUNT=$((SP_COUNT + 1))
  done
  ok "superpowers 스킬 배치 완료 (${SP_COUNT}개)"
  rm -rf "$SP_TMP"
  trap - EXIT
fi

# 4b. 커스텀 스킬 (review, sprint, deploy)
say "커스텀 스킬 배치"
CUSTOM_SKILLS="review sprint deploy"
for skill in $CUSTOM_SKILLS; do
  mkdir -p "$AGENTS_SKILLS/$skill" "$CLAUDE_SKILLS/$skill"
  if [ -f "$AGENTS_SKILLS/$skill/SKILL.md" ] && [ "$FORCE" -eq 0 ]; then
    warn "$AGENTS_SKILLS/$skill — 이미 존재 — 스킵 (--force 로 덮어쓰기)"
  else
    download "$REPO_RAW/skills/$skill/SKILL.md" "$AGENTS_SKILLS/$skill/SKILL.md"
    cp "$AGENTS_SKILLS/$skill/SKILL.md" "$CLAUDE_SKILLS/$skill/SKILL.md"
    ok "$skill 스킬 배치 완료"
  fi
done

# ---------- 5. .claude 워크스페이스 ----------
say ".claude 디렉토리 준비"
mkdir -p .claude/workspace .claude/skills
touch .claude/workspace/.gitkeep
ok ".claude/workspace, .claude/skills 준비 완료"

# ---------- 6. .gitignore 업데이트 ----------
if [ -d .git ] || [ -f .gitignore ]; then
  say ".gitignore 업데이트"
  for entry in ".engram/" ".claude/workspace/"; do
    if ! grep -qxF "$entry" .gitignore 2>/dev/null; then
      echo "$entry" >> .gitignore
      ok "$entry 추가"
    fi
  done
fi

# ---------- 완료 ----------
echo
ok "설치 완료"
cat <<'NEXT'

다음 단계:
  1. AGENTS.md 를 열어 <!-- TODO --> 블록을 프로젝트 내용으로 채우세요
  2. 에이전트 호환:
       - Claude Code : CLAUDE.md 가 @AGENTS.md 를 import 합니다 (자동)
       - Codex       : AGENTS.md 를 자동 로드 (자동)
       - Cursor      : .cursorrules 또는 .cursor/rules/ 가 필요 — 별도 설정
       - Copilot     : .github/copilot-instructions.md 가 필요 — 별도 설정
  3. engram 사용 (--user 설치 후 PATH 미적용이면 아래 명령도 동일하게 동작):
       engram save "프로젝트 이름은 ..."     #  또는  python -m engram save "..."
       engram find "검색어"                 #  또는  python -m engram find "..."
       engram status                       #  또는  python -m engram status
     (추가 기능) pip install "engram-ms[llm|semantic|mcp|full]"

재실행:
  curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --force

언인스톨:
  bash uninstall.sh            # 대화형
  bash uninstall.sh --yes      # 자동 승인
NEXT
