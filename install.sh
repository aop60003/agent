#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# default — 프로젝트 기본 설정 원스텝 인스톨러 (Mac / Linux / WSL)
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash -s -- --force
#
# 수행 작업:
#   1. 사전 확인: python3, pip, git
#   2. engram 메모리 시스템 설치 (pip)
#   3. ~/.engram/memory.db 초기화
#   4. 현재 폴더에 AGENTS.md / CLAUDE.md 생성
#   5. .claude/workspace 디렉토리 생성
#   6. .gitignore에 .engram 추가 (선택)
# ---------------------------------------------------------------------------

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/aop60003/default/main"
FORCE=0
SKIP_ENGRAM=0

for arg in "$@"; do
  case "$arg" in
    --force)        FORCE=1 ;;
    --skip-engram)  SKIP_ENGRAM=1 ;;
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
command -v python3 >/dev/null 2>&1 || die "python3 가 필요합니다 (3.9+)"
command -v pip >/dev/null 2>&1 || command -v pip3 >/dev/null 2>&1 || die "pip 가 필요합니다"
PIP=$(command -v pip3 || command -v pip)
PYV=$(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])')
PYV_NUM=$(python3 -c 'import sys;v=sys.version_info;print(v[0]*100+v[1])')
[ "$PYV_NUM" -lt 309 ] && die "python 3.9+ 가 필요합니다 (현재: $PYV)"
ok "python3 $PYV / pip 사용 가능"

# ---------- 2. engram 설치 ----------
if [ "$SKIP_ENGRAM" -eq 0 ]; then
  say "engram 메모리 시스템 설치"
  if command -v engram >/dev/null 2>&1 && [ "$FORCE" -eq 0 ]; then
    ok "engram 이 이미 설치되어 있음 (--force 로 재설치)"
  else
    # PEP 668 환경(Debian/Ubuntu)에서도 동작하도록 --user 우선
    if ! "$PIP" install --user --upgrade memorytrace 2>/dev/null; then
      "$PIP" install --user --upgrade --break-system-packages memorytrace \
        || die "engram 설치 실패"
    fi
    ok "engram 설치 완료"
  fi

  # DB 초기화
  say "~/.engram/memory.db 초기화"
  mkdir -p "$HOME/.engram"
  python3 -m engram.cli.app --db "$HOME/.engram/memory.db" init >/dev/null 2>&1 \
    && ok "engram DB 초기화 완료" \
    || warn "engram DB 초기화 스킵 (이미 존재하거나 CLI 미지원)"
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

# CLAUDE.md 는 AGENTS.md 를 참조하는 포인터 (Claude Code 호환)
if [ -f "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ] && [ "$FORCE" -eq 0 ]; then
  warn "CLAUDE.md 이미 존재 — 스킵 (--force 로 덮어쓰기)"
else
  echo 'See AGENTS.md for all project conventions and rules.' > CLAUDE.md
  ok "CLAUDE.md 생성 (AGENTS.md 참조)"
fi

# ---------- 4. .claude 워크스페이스 ----------
say ".claude 디렉토리 준비"
mkdir -p .claude/workspace .claude/skills
touch .claude/workspace/.gitkeep
ok ".claude/workspace, .claude/skills 준비 완료"

# ---------- 5. .gitignore 업데이트 ----------
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
  2. Claude Code / Codex / Cursor 에서 이 디렉토리를 열면 자동 로드됩니다
  3. engram 사용:
       engram save "프로젝트 이름은 ..."
       engram find "검색어"
       engram who "이름"

재실행:
  curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash -s -- --force
NEXT
