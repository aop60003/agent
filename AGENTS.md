# AGENTS.md

This file defines how AI coding agents (Claude Code, Codex, Cursor, Copilot, etc.) should operate in this repository.
It is a **project-wide default guide**. Replace `<!-- TODO -->` blocks with repo-specific details.

> If repository code, tests, configs, or maintainer instructions conflict with this file, follow the **more specific source of truth**.

---

## 1. Project Overview

<!-- TODO: 한 줄 설명으로 교체 -->
<!-- 예: 실시간 채팅 기반 협업 플랫폼 (Next.js 14 + FastAPI + PostgreSQL) -->

---

## 2. Tech Stack

<!-- TODO: 실제 스택으로 교체. 프레임워크와 버전만 기재 -->
<!-- 예:
- Frontend: Next.js 14 (App Router), TypeScript 5.x strict
- Backend: FastAPI 0.110+, Python 3.12
- Database: PostgreSQL 16 + Prisma 6.x
- Testing: Jest (unit), Playwright (e2e)
- Package Manager: pnpm
-->

---

## 3. Project Structure

<!-- TODO: 실제 구조로 교체 -->
<!-- 예:
src/
├── app/          # Next.js 라우트
├── components/   # 재사용 UI
├── services/     # 비즈니스 로직 (API 라우트는 thin)
├── lib/          # 유틸리티
└── repositories/ # DB 접근 레이어
-->

---

## 4. Non-Negotiable Constraints

<!-- TODO: 프로젝트 금지사항으로 교체 -->
<!-- 예:
- NEVER use `any` type — `unknown` + type guard 사용
- NEVER call database directly from components or API routes
- NEVER commit .env files, API keys, credentials
- NEVER introduce new dependencies without justification
- NEVER bypass validation at API boundaries
-->

---

## 5. Commands

### 5.1 Setup / Build
<!-- TODO: 프로젝트 명령어로 교체 -->
<!-- 예:
- `pnpm install` — 의존성 설치
- `pnpm dev` — 로컬 개발 서버
- `pnpm build` — 프로덕션 빌드
-->

### 5.2 Testing
<!-- TODO: 단일 테스트 실행법 포함 (모호한 "run tests" 금지) -->
<!-- 예:
- `pnpm test` — 전체 테스트
- `pnpm test -- path/to/file.test.ts` — 단일 테스트
- `pnpm test:e2e` — E2E
- `pnpm typecheck` — 타입 체크 (코드 변경 후 필수)
- `pnpm lint` — 커밋 전 실행
-->

---

## 6. Code Style

- 주변 코드 스타일을 따른다 — 새로운 패턴을 도입하지 않는다
- 패턴 참조 파일 <!-- TODO: 실제 모범 파일 경로 -->
  - 예: UI 컴포넌트 패턴: `src/components/ui/Button.tsx`
  - 예: 서비스 레이어 패턴: `src/services/user.service.ts`
  - 예: 테스트 패턴: `src/services/__tests__/user.service.test.ts`
- 피해야 할 레거시 <!-- TODO: -->
  - 예: `src/legacy/**` — 참조 금지, 신규 코드 작성 시 무시

---

## 7. Safety Boundaries (3-Tier)

### ALWAYS (자동 수행 가능)
- 파일 읽기, 코드 탐색 (grep, glob)
- 타입 체크, 린트 실행
- 테스트 실행, 단일 테스트 실행
- 주변 코드 문맥 확인

### ASK FIRST (반드시 사용자 확인)
- 새 패키지 설치 / 의존성 추가
- DB 마이그레이션 생성/실행
- 파일/디렉토리 삭제
- Git push, 브랜치 머지
- 전체 빌드 실행 (시간 소요)
- 외부 API 호출을 포함하는 테스트

### NEVER (절대 금지)
- .env, credentials, secret 커밋
- `--force`, `--no-verify` 플래그 사용
- `rm -rf`, `git reset --hard` 계열 파괴적 명령
- 프로덕션 DB 직접 수정
- 기존 테스트 삭제/스킵 (실패한다고 지우지 않음)

---

## 8. Working Rules

### 8.1 Implementation Rules
- ALWAYS read the target file completely before editing — blind edits break surrounding code
- NEVER leave TODO, FIXME, stub, or placeholder code — implement fully or don't start
- NEVER use generic catch-all error handling (`catch { return null }`) — handle specific error types
- NEVER fabricate API versions, config values, or package names — look them up first
- NEVER rewrite entire files — use surgical edits unless the file is under 20 lines
- NEVER repeat a failed approach — investigate the root cause before retrying
- NEVER self-evaluate as "done" — run tests and show output as proof

### 8.2 Robustness Rules
- ALWAYS handle failure cases, not just the happy path — assume external services WILL fail
- ALWAYS add timeout for network/API calls — no infinite waits
- ALWAYS clean up resources in finally blocks — connections, file handles, listeners
- ALWAYS validate inputs at system boundaries — type, range, format, length
- NEVER suppress errors silently — log with context (userId, requestId, timestamp)
- NEVER hardcode config values — use environment variables or config files
- When implementing a feature, FIRST list 3-5 ways it could fail, THEN implement handling for each

### 8.3 Edit Safety
- 10+ 메시지 경과 시 파일 편집 전 반드시 재읽기
- 함수/타입/변수 이름 변경 시: 모든 참조를 grep 후 일괄 변경
- 파일 삭제 전: import/require 참조가 없음을 확인
- 5개 이상 독립 파일 작업 시: 서브에이전트 병렬 분배

---

## 9. Verification Standard (3-Step + Evidence)

A task is not complete just because code was written. Show evidence.

### 9.1 Design Verification
- 기존 아키텍처와 일관성이 있는가?
- 불필요한 복잡도를 추가하지 않는가?
- 더 단순한 안전한 해법을 놓치지 않았는가?

### 9.2 Implementation Verification
- 빌드 / 린트 / 타입체크 통과
- 관련 단위/통합 테스트 통과
- `grep -rn "TODO\|FIXME\|console.log" src/` 빈 결과 확인 <!-- TODO: 실제 소스 경로로 교체 -->

### 9.3 Integration Verification
- 기존 기능에 영향을 주지 않음
- 인접 워크플로우 정상 동작
- 관련 파일이 일관성 유지

### 9.4 Evidence Requirement
증거를 보여야 "완료"로 간주한다:
- 테스트 출력 / 빌드 출력 / 린트 출력
- 검증을 실행할 수 없는 경우 **명시적으로 이유를 설명**
- 스킵된 검증 단계를 숨기고 "완료"라고 주장하지 않음

---

## 10. Architecture Notes (Why, not What)

<!-- TODO: 코드만 읽어서는 알 수 없는 "왜"만 기재 -->
<!-- 예:
- API 라우트는 thin controller: 비즈니스 로직은 반드시 `src/services/`
- DB 쿼리는 반드시 Repository 레이어 경유
- 상태관리는 Zustand. Redux 금지 (팀 합의)
- 공용 UI 프리미티브는 `src/components/ui`
-->

---

## 11. Git & Contribution Conventions

<!-- TODO: 프로젝트에 맞게 교체 -->
<!-- 예:
- Branch: `feat/*`, `fix/*`, `chore/*`
- Commit: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- PR: 최소 1인 리뷰 승인 + CI 통과 필수
- 커밋 전 `pnpm lint && pnpm typecheck` 실행
-->

---

## 12. Optional Tooling

### 12.1 Engram Memory (설치된 경우에만)

`command -v engram` 이 성공하면 Engram 메모리 시스템이 활성화된다.
대화 간 지속 메모리 — SQLite + FTS5 기반, 제로 의존성.

**저장 시점**
- 사용자가 새로운 사실을 공유할 때 (인물, 조직, 기술 결정, 프로젝트 배경)
- 중요한 설계 결정이 내려졌을 때
- 디버깅 과정에서 원인을 발견했을 때
- 사용자가 "기억해" / "저장해" 라고 요청할 때

**검색 시점**
- 세션 시작 시 프로젝트 컨텍스트 로드
- 이전 대화에서 논의한 내용이 필요할 때
- 특정 인물/조직 배경이 필요할 때

**명령어**
```bash
engram save "저장할 정보"      # 자동 엔티티 추출과 함께 저장
engram find "검색어"           # 메모리 검색
engram who "이름"              # 인물/조직 조회
engram remember "이름" "사실"  # 수동 사실 기록
```

Engram이 없는 환경에서는 이 섹션을 무시할 것.

### 12.2 Skills

프로젝트 스킬은 두 곳에 배치된다 (Claude Code + Codex 호환):
- `.agents/skills/<name>/SKILL.md` — 정본 (편집은 여기서)
- `.claude/skills/<name>/SKILL.md` — Claude Code용 복사본

**Superpowers 스킬** (출처: [obra/superpowers](https://github.com/obra/superpowers)):

| 스킬 | 용도 |
|------|------|
| `brainstorming` | 설계 탐색 (코드 작성 전) |
| `writing-plans` | 구현 계획 작성 |
| `executing-plans` | 계획 단계별 실행 |
| `test-driven-development` | Red-Green-Refactor TDD |
| `systematic-debugging` | 체계적 근본 원인 추적 |
| `verification-before-completion` | 증거 기반 완료 선언 |
| `dispatching-parallel-agents` | 병렬 에이전트 배치 |
| `subagent-driven-development` | 태스크별 서브에이전트 |
| `using-git-worktrees` | 격리 워크스페이스 |
| `requesting-code-review` | 리뷰 요청 |
| `receiving-code-review` | 리뷰 피드백 처리 |
| `finishing-a-development-branch` | 브랜치 통합/정리 |
| `using-superpowers` | 세션 시작 시 스킬 활용 설정 |
| `writing-skills` | 커스텀 스킬 생성/편집 |

**커스텀 스킬:**

| 스킬 | 용도 |
|------|------|
| `review` | 5단계 구조화 코드 리뷰 |
| `sprint` | 전체 개발 사이클 관리 |
| `deploy` | 배포 워크플로우 |

**스킬 추가 방법:**
1. `.agents/skills/<name>/SKILL.md` 생성 (YAML frontmatter: `name`, `description` 필수)
2. `.claude/skills/<name>/`에 동일 파일 복사
<!-- TODO: 프로젝트 커스텀 스킬 추가 -->

### 12.3 Long-Running Tasks
- 대규모 기능 구현 시 체크포인트 활용
- 컨텍스트가 70% 이상 차면 `.claude/workspace/progress.md`에 상태 저장 후 `/clear`

---

## 13. Additional Context

대용량 문서는 `@참조`로 분리 — 필요할 때만 로드되어 토큰 절약.

<!-- 예:
- API 설계 규칙: @docs/api-conventions.md
- DB 스키마 가이드: @docs/database-guide.md
- 배포 런북: @docs/deployment.md
- 보안 정책: @docs/security.md
-->

---

## 14. Agent Behavior Summary

막힐 때 이 5개 원칙으로 돌아온다:

1. **Read first** — 편집 전 먼저 읽는다
2. **Change as little as necessary** — 필요한 만큼만 바꾼다
3. **Follow existing patterns** — 기존 패턴을 따른다
4. **Verify with evidence** — 증거로 검증한다
5. **State uncertainty honestly** — 불확실성을 정직하게 말한다

> 목표는 "동작하는 코드"가 아니라 **안전하고 리뷰 가능하며 리포지토리와 일관된 변경**이다.
