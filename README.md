# default

프로젝트용 **AGENTS.md 기본 템플릿 + Engram 메모리 시스템**을 한 줄 명령으로 설치합니다.

---

## 설치

### Mac / Linux / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr https://raw.githubusercontent.com/aop60003/default/main/install.ps1 | iex
```

---

## 옵션

| 옵션 | 설명 |
|------|------|
| `--force` / `-Force` | 기존 파일 덮어쓰기 |
| `--skip-engram` / `-SkipEngram` | engram 설치 스킵 (AGENTS.md 만 배치) |

예시:
```bash
curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash -s -- --force
curl -fsSL https://raw.githubusercontent.com/aop60003/default/main/install.sh | bash -s -- --skip-engram
```

```powershell
iex "& { $(iwr https://raw.githubusercontent.com/aop60003/default/main/install.ps1) } -Force"
```

---

## 설치 시 수행 작업

1. **사전 확인** — python 3.9+, pip
2. **engram 설치** — `pip install --user memorytrace`
3. **메모리 DB 초기화** — `~/.engram/memory.db`
4. **템플릿 배치**
   - `AGENTS.md` — 프로젝트 기본 에이전트 가이드
   - `CLAUDE.md` — AGENTS.md 참조 포인터
5. **디렉토리 준비** — `.claude/workspace`, `.claude/skills`
6. **.gitignore 업데이트** — `.engram/`, `.claude/workspace/` 추가

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
```

### 3. AI 에이전트에서 사용
Claude Code, Codex, Cursor, Copilot 등이 프로젝트 루트에서 `AGENTS.md` 또는 `CLAUDE.md`를 자동 로드합니다.

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
default/
├── AGENTS.md       # 통합 프로젝트 기본 템플릿 (~260줄)
├── install.sh      # Mac/Linux/WSL 인스톨러
├── install.ps1     # Windows PowerShell 인스톨러
└── README.md       # 이 파일
```

---

## 제거

### Mac / Linux / WSL
```bash
rm -f AGENTS.md CLAUDE.md
rm -rf .claude
pip uninstall memorytrace        # engram 제거 (선택)
rm -rf ~/.engram                  # 메모리 DB 삭제 (선택)
```

### Windows (PowerShell)
```powershell
Remove-Item AGENTS.md, CLAUDE.md -ErrorAction SilentlyContinue
Remove-Item .claude -Recurse -ErrorAction SilentlyContinue
pip uninstall memorytrace                                          # engram 제거 (선택)
Remove-Item "$HOME\.engram" -Recurse -ErrorAction SilentlyContinue # 메모리 DB 삭제 (선택)
```

---

## 라이선스

MIT
