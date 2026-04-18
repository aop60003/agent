# agent

프로젝트용 **AGENTS.md 기본 템플릿 + 스킬 시스템 + Engram 메모리**를 한 줄 명령으로 설치합니다.

---

## 설치

### Mac / Linux / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1 | iex
```

---

## 옵션

| 옵션 | 설명 |
|------|------|
| `--force` / `-Force` | 기존 파일 덮어쓰기 |
| `--skip-engram` / `-SkipEngram` | engram 설치 스킵 (AGENTS.md 만 배치) |
| `--global` / `-Global` | 스킬을 유저 레벨에 설치 (`~/.claude/skills/` + `~/.agents/skills/`) |

예시:
```bash
curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --force
curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --skip-engram
curl -fsSL https://raw.githubusercontent.com/aop60003/agent/main/install.sh | bash -s -- --global
```

```powershell
iex "& { $(iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1) } -Force"
iex "& { $(iwr https://raw.githubusercontent.com/aop60003/agent/main/install.ps1) } -Global"
```

---

## 설치 시 수행 작업

1. **사전 확인** — python 3.9+, pip
2. **engram 설치** — `pip install --user engram-ms` (레거시 별칭 `memorytrace` 도 동일 엔진)
3. **메모리 DB 초기화** — `engram init` → `~/.engram/memory.db`
4. **템플릿 배치**
   - `AGENTS.md` — 프로젝트 기본 에이전트 가이드
   - `CLAUDE.md` — AGENTS.md 참조 포인터
5. **스킬 배치** — `.agents/skills/` (정본) + `.claude/skills/` (복사본)
   - Superpowers 14개 ([obra/superpowers](https://github.com/obra/superpowers)에서 다운로드)
   - 커스텀 3개 (review, sprint, deploy)
6. **디렉토리 준비** — `.claude/workspace`
7. **.gitignore 업데이트** — `.engram/`, `.claude/workspace/` 추가

---

## 설치 후 할 일

### 1. AGENTS.md 편집
파일을 열어서 `<!-- TODO -->` 블록을 프로젝트 정보로 교체하세요.
- `## 1. Project Overview` — 한 줄 설명
- `## 2. Tech Stack` — 프레임워크/버전
- `## 3. Project Structure` — 폴더 트리
- `## 4. Non-Negotiable Constraints` — NEVER 규칙
- `## 5. Commands` — setup / test 명령
- `## 6. Code Style` — 패턴 참조 파일 경로
- `## 10. Architecture Notes` — WHY 기록
- `## 11. Git Conventions` — 브랜치/커밋 규칙

### 2. Engram 시작
```bash
engram save "프로젝트 이름은 X, Next.js 14 + FastAPI 스택"
engram save "팀 규칙: 모든 API는 /api/v1 prefix"

engram find "API 규칙"        # 검색
engram who "팀원 이름"         # 인물 조회
engram status                 # 상태 확인
```

**선택 기능** — 필요한 경우에만 추가 설치:
```bash
pip install "engram-ms[llm]"       # LLM 연동
pip install "engram-ms[semantic]"  # 시맨틱 검색
pip install "engram-ms[mcp]"       # MCP 서버
pip install "engram-ms[full]"      # 전체
```

**고급 CLI / SDK**
- `engram-advanced --db <path> search "..." --max-results 5` / `--json health` — 커스텀 DB 경로나 JSON 출력이 필요할 때
- `from engram.integrations.sdk import EngramSDK` — Python SDK

### 3. AI 에이전트에서 사용

| 에이전트 | 자동 로드 여부 | 비고 |
|---|---|---|
| **Claude Code** | ✅ | `CLAUDE.md` 가 `@AGENTS.md` 로 import — 인스톨러가 자동 생성 |
| **Codex** | ✅ | `AGENTS.md` 네이티브 지원 |
| **Cursor** | ❌ | `.cursorrules` 또는 `.cursor/rules/` 자체 형식 사용 — 별도 설정 필요 |
| **GitHub Copilot** | ❌ | `.github/copilot-instructions.md` 사용 — 별도 설정 필요 |

---

## 템플릿 설계 원칙

통합 템플릿은 다음 세 방향의 장점을 결합합니다:

- **훈육형** (명시적 NEVER/ALWAYS 규칙) — 에이전트가 실수하기 쉬운 영역 차단
- **법전형** (3-Step Verification, Evidence Required) — "완료" 주장에 증거 요구
- **철학형** (Agent Behavior Summary 5원칙) — 규칙이 막히면 원칙으로 복귀

GitHub 2,500+ 저장소 분석의 **필수 6대 섹션**을 모두 충족:
Commands / Testing / Project Structure / Code Style / Git Workflow / Safety Boundaries

**Safety 3-Tier** 채택: `ALWAYS` (자동) / `ASK FIRST` (확인) / `NEVER` (금지)

---

## 파일 구성

```
agent/
├── AGENTS.md            # 통합 프로젝트 기본 템플릿 (~170줄, 영어)
├── install.sh           # Mac/Linux/WSL 인스톨러
├── install.ps1          # Windows PowerShell 인스톨러
├── uninstall.sh         # Mac/Linux/WSL 언인스톨러
├── uninstall.ps1        # Windows 언인스톨러
├── LICENSE              # MIT
├── README.md            # 이 파일
└── skills/              # 커스텀 스킬 템플릿 (superpowers 는 설치 시 다운로드)
    ├── AGENTS.md        # 이 디렉토리에서 스킬을 작성·수정하는 개발자용 가이드
    ├── review/SKILL.md  # 5단계 코드 리뷰
    ├── sprint/SKILL.md  # 전체 개발 사이클
    └── deploy/SKILL.md  # 배포 워크플로우
```

---

## 제거

설치 후 저장소에 포함된 **언인스톨러**를 사용하세요.

### Mac / Linux / WSL
```bash
bash uninstall.sh               # 대화형 (각 단계 y/N 확인)
bash uninstall.sh --global      # 유저 레벨 스킬도 제거
bash uninstall.sh --yes         # 모든 확인 자동 승인
bash uninstall.sh --keep-engram # engram 은 보존
```

### Windows (PowerShell)
```powershell
.\uninstall.ps1                 # 대화형
.\uninstall.ps1 -Global         # 유저 레벨 스킬도 제거
.\uninstall.ps1 -Yes            # 모든 확인 자동 승인
.\uninstall.ps1 -KeepEngram     # engram 은 보존
```

---

## 재현성 / Superpowers 고정

기본값은 `obra/superpowers@main` 최신 상태를 다운로드합니다. 재현성을 위해 특정 태그나 커밋 SHA 로 고정할 수 있습니다:

```bash
SUPERPOWERS_REF=v1.2.3 bash install.sh
SUPERPOWERS_REF=abc1234 bash install.sh
```
```powershell
$env:SUPERPOWERS_REF = "v1.2.3" ; iex "& { $(iwr $RepoRaw/install.ps1) }"
```

---

## 트러블슈팅

| 증상 | 원인 / 해결 |
|---|---|
| `engram: command not found` / 명령을 찾을 수 없음 | `pip install --user` 는 PATH 를 자동 설정하지 않습니다. `python -m engram save "..."` 로 대체하거나, 사용자 site-packages 의 `Scripts` (Win) / `bin` (Unix) 을 PATH 에 추가하세요 |
| `error: externally-managed-environment` (Ubuntu 23.04+, Debian 12+) | PEP 668. install.sh 는 `--break-system-packages` 폴백을 포함. 수동 설치 시 `pipx install engram-ms` 또는 venv 권장 |
| Windows 에서 `python` 실행 시 Microsoft Store 창 오픈 | Windows 의 `python.exe` 리디렉션 스텁. 설정 → 앱 → 앱 실행 별칭 에서 비활성화 후 실제 Python 설치 |
| `The term 'iwr' is not recognized` / 실행 정책 오류 | `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` 후 재실행 |
| 기업 네트워크에서 GitHub 접근 차단 | `raw.githubusercontent.com` 과 `github.com` 의 HTTPS 접근 허용 필요 |
| 스킬이 업데이트되지 않음 | `--force` / `-Force` 플래그로 재실행 |

---

## 라이선스

MIT
