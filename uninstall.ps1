# ---------------------------------------------------------------------------
# agent — 언인스톨러 (Windows PowerShell)
#
# 사용법:
#   .\uninstall.ps1              # 대화형 (각 단계 확인)
#   .\uninstall.ps1 -Global      # 유저 레벨 스킬도 제거
#   .\uninstall.ps1 -Yes         # 모든 확인 자동 승인
#   .\uninstall.ps1 -KeepEngram  # engram 패키지/DB 유지
# ---------------------------------------------------------------------------

param(
  [switch]$Global,
  [switch]$Yes,
  [switch]$KeepEngram
)

$ErrorActionPreference = "Stop"

function Say($msg)  { Write-Host "==> $msg"  -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!]  $msg" -ForegroundColor Yellow }

function Confirm($msg) {
  if ($Yes) { return $true }
  $reply = Read-Host "$msg (y/N)"
  return $reply -match '^[Yy]$'
}

Say "작업 디렉토리: $(Get-Location)"

# 1. 프로젝트 레벨 정리
if (Confirm "AGENTS.md / CLAUDE.md / .claude / .agents 를 이 디렉토리에서 제거합니까?") {
  Remove-Item AGENTS.md, CLAUDE.md -Force -ErrorAction SilentlyContinue
  Remove-Item .claude, .agents -Recurse -Force -ErrorAction SilentlyContinue
  Ok "프로젝트 레벨 파일 제거 완료"
} else {
  Warn "프로젝트 레벨 정리 스킵"
}

# 2. 유저 레벨 정리
if ($Global) {
  if (Confirm "유저 레벨 스킬(~/.claude/skills, ~/.agents/skills) 도 제거합니까?") {
    Remove-Item (Join-Path $HOME ".claude\skills"), (Join-Path $HOME ".agents\skills") `
      -Recurse -Force -ErrorAction SilentlyContinue
    Ok "유저 레벨 스킬 제거 완료"
  }
}

# 3. engram 정리
if (-not $KeepEngram) {
  if (Confirm "engram 패키지와 ~/.engram/ 도 제거합니까?") {
    $pipCmd = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCmd) {
      & $pipCmd.Source uninstall -y engram-ms 2>$null
    }
    Remove-Item (Join-Path $HOME ".engram") -Recurse -Force -ErrorAction SilentlyContinue
    Ok "engram 제거 완료"
  }
}

Ok "언인스톨 완료"
