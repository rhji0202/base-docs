# 프로젝트 컨텍스트 (Claude Code 진입점)

> Claude Code가 자동으로 읽는 최상위 컨텍스트. **프로젝트 고유값 + 핵심 원칙**만 둡니다.
> 워크플로우 상세 규칙은 [docs/README.md](docs/README.md) · [.claude/rules/docs-workflow.md](.claude/rules/docs-workflow.md).

---

## 한 줄 요약
{UNSET: 무엇을, 누구를 위해, 왜 만드는지 한 문장으로}

## 프로젝트 현황
- **단계**: {UNSET: MVP / Beta / Production}
- **마지막 갱신**: {UNSET: YYYY-MM-DD}

---

## 작업 방식: 기획 → 프론트 → 백엔드

기능은 **같은 슬러그**의 문서로 세 단계를 순서대로 통과합니다. `docs/0-shared/`는 단계가 아니라 모든 단계가 참조하는 공통 기반입니다.

```
docs/1-feat/user-login.md  →  docs/2-web/user-login.md  →  docs/3-api/user-login.md
      (무엇/왜)                    (어떻게 보이나)               (어떻게 동작하나)
```

| 단계 | 폴더 | 답하는 질문 |
|---|---|---|
| 기획 | `docs/1-feat/` | 무엇을, 누구를 위해, 왜 (요구사항·인수조건) |
| 프론트 설계 | `docs/2-web/` | 어떻게 보이고 동작하나 (+ 필요한 API 정의) |
| 백엔드 설계 | `docs/3-api/` | 데이터·로직·API를 어떻게 |

> 슬러그 규칙·단계 스킵·경량 모드·비-웹 매핑 등 **상세 규칙은 [docs/README.md](docs/README.md)**.

---

## 핵심 원칙 (절대 어기지 말 것)
- ❌ 환경변수/시크릿 하드코딩 금지
- ❌ 기획 없이 구현 시작 금지 — 모든 기능은 `docs/1-feat/` 문서가 선행
- ❌ 테스트 없이 구현/머지 금지 — **기본 TDD** (RED → GREEN → REFACTOR), 인수조건이 테스트의 출발점 (예외·세부 → [common-testing.md](.claude/rules/common-testing.md))
- ✅ 관련 있는 단계만 순서대로 (해당 없는 단계 스킵 가능, 역행 금지)
- ✅ 공통(용어·API 규약·인증)은 `docs/0-shared/`에 한 번만, 기능 문서는 링크 참조
- ✅ 문서가 SSOT — 설계 변경은 문서 먼저, 그다음 구현
- ✅ 다이어그램은 Mermaid만, 미결정 값은 `{UNSET}`

---

## 새 문서 만들기

```bash
# 기획부터 (파일명 = 영문 kebab 슬러그)
cp docs/1-feat/_template.md docs/1-feat/user-login.md
# 이어서 2-web, 3-api 를 같은 슬러그로

find docs -name "user-login.md"   # 한 기능의 단계별 문서 모으기
grep -r "{UNSET}" docs/            # 미결정 현황
```

---

## 기술 스택

| 영역 | 선택 | 비고 |
|---|---|---|
| 언어 | {UNSET} | |
| 프론트엔드 | {UNSET: 프레임워크/라이브러리} | |
| 백엔드 | {UNSET: 프레임워크/런타임} | |
| 데이터베이스 | {UNSET} | |
| 인프라/배포 | {UNSET: 호스팅, CI/CD} | |
| 주요 외부 서비스 | {UNSET: 인증, 결제, 스토리지 등} | |

> 기술 선택 근거는 해당 설계 문서에 함께 적습니다.

## 코드 컨벤션
- **언어**: {UNSET}
- **포맷터**: {UNSET}
- **린터**: {UNSET}
- **테스트**: {UNSET}
- **커밋**: {UNSET}
- **브랜치**: {UNSET}

## 팀 / 연락처
- 프로젝트 오너: {UNSET}
- 기술 리드: {UNSET}
- Slack 채널: {UNSET}

---

## 시작 절차
> base-docs는 **샘플 없는 깨끗한 템플릿**입니다. `grep -r "{UNSET}"`로 현황 파악.

1. 이 파일의 `{UNSET}` 채우기 — 요약·현황·기술 스택·컨벤션·팀
2. `docs/0-shared/`의 용어·공통 규약 초안 작성 (필요해질 때 채워도 됨)
3. `docs/1-feat/_template.md` 복사해 첫 기획 → `2-web` → `3-api`
4. (코드가 생긴 뒤) 실제 코드 디렉토리 구조와 `docs/<단계>/<슬러그>` → 코드 경로 매핑을 여기에 간단히 메모
