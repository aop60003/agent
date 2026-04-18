#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# agent — 언인스톨러 (Mac / Linux / WSL)
#
# 사용법:
#   bash uninstall.sh              # 대화형 (각 단계 확인)
#   bash uninstall.sh --global     # 유저 레벨 스킬도 제거
#   bash uninstall.sh --yes        # 모든 확인 자동 승인
#   bash uninstall.sh --keep-engram  # engram 패키지/DB 유지
# ---------------------------------------------------------------------------

set -euo pipefail

GLOBAL=0
YES=0
KEEP_ENGRAM=0

for arg in "$@"; do
  case "$arg" in
    --global)       GLOBAL=1 ;;
    --yes|-y)       YES=1 ;;
    --keep-engram)  KEEP_ENGRAM=1 ;;
    -h|--help)      grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
done

c_reset="\033[0m"; c_ok="\033[32m"; c_warn="\033[33m"; c_info="\033[36m"
say()  { printf "${c_info}==>${c_reset} %s\n" "$*"; }
ok()   { printf "${c_ok}✓${c_reset} %s\n" "$*"; }
warn() { printf "${c_warn}!${c_reset} %s\n" "$*"; }

confirm() {
  [ "$YES" -eq 1 ] && return 0
  printf "%s (y/N) " "$1"
  read -r reply </dev/tty || return 1
  [[ "$reply" =~ ^[Yy]$ ]]
}

say "작업 디렉토리: $PWD"

# 1. 프로젝트 레벨 정리
if confirm "AGENTS.md / CLAUDE.md / .claude / .agents 를 이 디렉토리에서 제거합니까?"; then
  rm -f AGENTS.md CLAUDE.md
  rm -rf .claude .agents
  ok "프로젝트 레벨 파일 제거 완료"
else
  warn "프로젝트 레벨 정리 스킵"
fi

# 2. 유저 레벨 정리
if [ "$GLOBAL" -eq 1 ]; then
  if confirm "유저 레벨 스킬(~/.claude/skills, ~/.agents/skills) 도 제거합니까?"; then
    rm -rf "$HOME/.claude/skills" "$HOME/.agents/skills"
    ok "유저 레벨 스킬 제거 완료"
  fi
fi

# 3. engram 정리
if [ "$KEEP_ENGRAM" -eq 0 ]; then
  if confirm "engram 패키지와 ~/.engram/ 도 제거합니까?"; then
    if command -v pip >/dev/null 2>&1; then
      pip uninstall -y engram-ms 2>/dev/null || true
    elif command -v pip3 >/dev/null 2>&1; then
      pip3 uninstall -y engram-ms 2>/dev/null || true
    fi
    rm -rf "$HOME/.engram"
    ok "engram 제거 완료"
  fi
fi

ok "언인스톨 완료"
