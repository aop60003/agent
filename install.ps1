# ---------------------------------------------------------------------------
# agent — 프로젝트 기본 설정 원스텝 인스톨러 (Windows PowerShell)
#
# 사용법:
#   iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1 | iex
#   iex "& { $(iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1) } -Force"
#   iex "& { $(iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1) } -Global"
#
# 수행 작업:
#   1. 사전 확인: python, pip
#   2. engram 메모리 시스템 설치 (pip)
#   3. %USERPROFILE%\.engram\memory.db 초기화
#   4. AGENTS.md / CLAUDE.md 배치
#   5. 스킬 배치: superpowers + 커스텀 (-Global: 유저 레벨, 기본: 프로젝트 레벨)
#   6. .claude\workspace 디렉토리 생성
#   7. .gitignore 업데이트
# ---------------------------------------------------------------------------

param(
  [switch]$Force,
  [switch]$SkipEngram,
  [switch]$Global
)

$ErrorActionPreference = "Stop"
$RepoRaw = "https://raw.githubusercontent.com/aop60003/agent/main"

function Say($msg)  { Write-Host "==> $msg"  -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[!]  $msg" -ForegroundColor Yellow }
function Die($msg)  { Write-Host "[X]  $msg" -ForegroundColor Red; exit 1 }

# ---------- 1. 사전 확인 ----------
Say "사전 확인"
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $python) { Die "python (3.9+) 이 필요합니다" }
$pyv = & $python.Source -c "import sys;v=sys.version_info;print(str(v[0])+'.'+str(v[1]))"
$pyvParts = $pyv.Split('.')
if ([int]$pyvParts[0] -lt 3 -or ([int]$pyvParts[0] -eq 3 -and [int]$pyvParts[1] -lt 9)) {
  Die "python 3.9+ 가 필요합니다 (현재: $pyv)"
}
Ok "python $pyv 사용 가능"

# Windows 인코딩 대비
$env:PYTHONIOENCODING = "utf-8"

# ---------- 2. engram 설치 ----------
if (-not $SkipEngram) {
  Say "engram 메모리 시스템 설치"
  $engramExists = $null -ne (Get-Command engram -ErrorAction SilentlyContinue)
  if ($engramExists -and -not $Force) {
    Ok "engram 이 이미 설치되어 있음 (-Force 로 재설치)"
  } else {
    & $python.Source -m pip install --user --upgrade memorytrace
    if ($LASTEXITCODE -ne 0) { Die "engram 설치 실패" }
    Ok "engram 설치 완료"
  }

  Say "~/.engram/memory.db 초기화"
  $engramDir = Join-Path $HOME ".engram"
  New-Item -ItemType Directory -Force -Path $engramDir | Out-Null
  $dbPath = Join-Path $engramDir "memory.db"
  & $python.Source -m engram.cli.app --db $dbPath init 2>$null
  if ($LASTEXITCODE -eq 0) { Ok "engram DB 초기화 완료" }
  else { Warn "engram DB 초기화 스킵 (이미 존재하거나 CLI 미지원)" }
} else {
  Warn "engram 설치 건너뜀 (-SkipEngram)"
}

# ---------- 3. AGENTS.md / CLAUDE.md 배치 ----------
Say "AGENTS.md / CLAUDE.md 배치"

function Place-File($target, $url) {
  if ((Test-Path $target) -and -not $Force) {
    Warn "$target 이미 존재 — 스킵 (-Force 로 덮어쓰기)"
    return
  }
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $target
  Ok "$target 생성"
}

Place-File "AGENTS.md" "$RepoRaw/AGENTS.md"

# CLAUDE.md 는 AGENTS.md 를 참조하는 포인터 (Claude Code 호환)
if ((Test-Path "CLAUDE.md") -and -not $Force) {
  Warn "CLAUDE.md 이미 존재 — 스킵"
} else {
  "See AGENTS.md for all project conventions and rules." | Set-Content -Path "CLAUDE.md" -Encoding UTF8
  Ok "CLAUDE.md 생성 (AGENTS.md 참조)"
}

# ---------- 4. 스킬 배치 ----------

# 설치 위치 결정
if ($Global) {
  $agentsSkills = Join-Path $HOME ".agents\skills"
  $claudeSkills = Join-Path $HOME ".claude\skills"
  Say "스킬 설치 위치: 유저 레벨 ($agentsSkills + $claudeSkills)"
} else {
  $agentsSkills = ".agents\skills"
  $claudeSkills = ".claude\skills"
  Say "스킬 설치 위치: 프로젝트 레벨 (.agents\skills + .claude\skills)"
}

# 4a. superpowers 스킬 (github.com/obra/superpowers)
Say "superpowers 스킬 다운로드 (obra/superpowers)"
$spCheck = Join-Path $agentsSkills "brainstorming\SKILL.md"
if ((Test-Path $spCheck) -and -not $Force) {
  Warn "superpowers 스킬 이미 존재 — 스킵 (-Force 로 덮어쓰기)"
} else {
  $spTmp = Join-Path $env:TEMP "superpowers-$(Get-Random)"
  New-Item -ItemType Directory -Force -Path $spTmp | Out-Null
  $spZip = Join-Path $spTmp "superpowers.zip"
  Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/obra/superpowers/archive/refs/heads/main.zip" -OutFile $spZip
  Expand-Archive -Path $spZip -DestinationPath $spTmp -Force
  $spSkillsDir = Join-Path $spTmp "superpowers-main\skills"
  $spCount = 0
  foreach ($skillDir in Get-ChildItem $spSkillsDir -Directory) {
    $skill = $skillDir.Name
    $aTarget = Join-Path $agentsSkills $skill
    $cTarget = Join-Path $claudeSkills $skill
    New-Item -ItemType Directory -Force -Path $aTarget | Out-Null
    New-Item -ItemType Directory -Force -Path $cTarget | Out-Null
    Copy-Item "$($skillDir.FullName)\*" "$aTarget\" -Recurse -Force
    Copy-Item "$($skillDir.FullName)\*" "$cTarget\" -Recurse -Force
    $spCount++
  }
  Remove-Item $spTmp -Recurse -Force
  Ok "superpowers 스킬 배치 완료 ($spCount 개)"
}

# 4b. 커스텀 스킬 (review, sprint, deploy)
Say "커스텀 스킬 배치"
$customSkills = @("review", "sprint", "deploy")
foreach ($skill in $customSkills) {
  $aTarget = Join-Path $agentsSkills $skill
  $cTarget = Join-Path $claudeSkills $skill
  New-Item -ItemType Directory -Force -Path $aTarget | Out-Null
  New-Item -ItemType Directory -Force -Path $cTarget | Out-Null
  $agentSkill = Join-Path $aTarget "SKILL.md"
  $claudeSkill = Join-Path $cTarget "SKILL.md"
  if ((Test-Path $agentSkill) -and -not $Force) {
    Warn "$agentSkill 이미 존재 — 스킵 (-Force 로 덮어쓰기)"
  } else {
    Invoke-WebRequest -UseBasicParsing -Uri "$RepoRaw/skills/$skill/SKILL.md" -OutFile $agentSkill
    Copy-Item $agentSkill $claudeSkill -Force
    Ok "$skill 스킬 배치 완료"
  }
}

# ---------- 5. .claude 워크스페이스 ----------
Say ".claude 디렉토리 준비"
New-Item -ItemType Directory -Force -Path ".claude\workspace" | Out-Null
New-Item -ItemType Directory -Force -Path ".claude\skills"    | Out-Null
if (-not (Test-Path ".claude\workspace\.gitkeep")) {
  New-Item -ItemType File -Path ".claude\workspace\.gitkeep" | Out-Null
}
Ok ".claude\workspace, .claude\skills 준비 완료"

# ---------- 6. .gitignore ----------
if ((Test-Path ".git") -or (Test-Path ".gitignore")) {
  Say ".gitignore 업데이트"
  $entries = @(".engram/", ".claude/workspace/")
  $existing = if (Test-Path ".gitignore") { Get-Content .gitignore } else { @() }
  foreach ($e in $entries) {
    if ($existing -notcontains $e) {
      Add-Content -Path .gitignore -Value $e
      Ok "$e 추가"
    }
  }
}

# ---------- 완료 ----------
Write-Host ""
Ok "설치 완료"
@"

다음 단계:
  1. AGENTS.md 를 열어 <!-- TODO --> 블록을 프로젝트 내용으로 채우세요
  2. Claude Code / Codex / Cursor 에서 이 디렉토리를 열면 자동 로드됩니다
  3. engram 사용:
       engram save "프로젝트 이름은 ..."
       engram find "검색어"
       engram who "이름"

재실행:
  iex "& { `$(iwr $RepoRaw/install.ps1) } -Force"
"@ | Write-Host
