# 프로젝트 컨텍스트 (Claude Code 진입점)

> 이 파일은 Claude Code가 자동으로 읽는 최상위 컨텍스트 파일입니다.
> 프로젝트 시작 시 가장 먼저 갱신하세요.

---

## 한 줄 요약
{UNSET: 무엇을, 누구를 위해, 왜 만드는지 한 문장으로}

---

## 프로젝트 현황
- **단계**: {UNSET: MVP / Beta / Production 중 선택}
- **현재 스프린트**: {UNSET}
- **마지막 갱신**: {UNSET: YYYY-MM-DD}

---

## 작업 시작 전 필수 참조

| 작업 유형 | 먼저 읽을 문서 |
|---|---|
| 프로젝트 처음 합류 | `docs/00-overview/vision.md` → `docs/00-overview/glossary.md` |
| 새 기능 구현 | `docs/01-product/features/F-XXX-*.md` |
| API 작업 | `docs/04-api/rest/` 또는 `docs/04-api/events/` |
| DB 스키마 변경 | `docs/05-data/schemas/` → 마이그레이션 정책 확인 |
| 도메인 로직 | `docs/02-domains/{도메인}/CLAUDE.md` |
| 아키텍처 변경 | `docs/03-architecture/` → ADR 작성 필수 |
| 기술 선택 변경 | `docs/07-decisions/` 검토 후 새 ADR 작성 |
| 배포/운영 이슈 | `docs/06-operations/runbooks/` |

---

## 디렉토리 구조

```
docs/
├── 00-overview/      # 프로젝트 비전, 용어, 로드맵
├── 01-product/       # 기능 요구사항 (PRD), 사용자 스토리
├── 02-domains/       # 도메인별 비즈니스 로직 명세
├── 03-architecture/  # 시스템 아키텍처, 다이어그램
├── 04-api/           # API 계약 (REST, GraphQL, 이벤트)
├── 05-data/          # 데이터 모델, 스키마, 마이그레이션
├── 06-operations/    # 배포, 모니터링, 런북
├── 07-decisions/     # ADR (불변 결정 기록)
├── 08-rfcs/          # 진행 중인 제안
├── 09-guides/        # 개발 가이드, 컨벤션
└── 99-templates/     # 모든 문서 템플릿
```

---

## 코드 컨벤션
- **언어**: {UNSET}
- **포맷터**: {UNSET}
- **린터**: {UNSET}
- **테스트**: {UNSET}
- **커밋**: {UNSET}
- **브랜치**: {UNSET}

---

## 핵심 원칙 (절대 어기지 말 것)
- ❌ 환경변수/시크릿을 코드에 하드코딩 금지
- ❌ `src/legacy/` 디렉토리 직접 수정 금지 (별도 마이그레이션 절차 따를 것)
- ❌ 프로덕션 DB 스키마 변경은 마이그레이션 파일을 통해서만
- ✅ 모든 신규 기능은 `docs/01-product/features/`에 PRD 선행 작성
- ✅ 아키텍처 결정은 ADR로 기록
- ✅ Public API 변경은 RFC 절차 필수

---

## ID 체계 (Grep 친화적)
- `F-XXX` : Feature (기능) — `docs/01-product/features/` (`/new-feature`)
- `ADR-XXX` : Architecture Decision Record — `docs/07-decisions/` (`/new-adr`)
- `RFC-XXX` : Request for Comments (제안) — `docs/08-rfcs/` (`/new-rfc`)
- `BUG-XXX` : 버그 추적 — `docs/06-operations/bugs/` (`/new-bug`)
- `EPIC-XX` : 대규모 작업 묶음 (경량 체계, 여러 F-XXX 묶음)

예: `F-001`, `ADR-005`, `RFC-002`, `BUG-001`

---

## 자주 쓰는 명령

```bash
# 새 기능 문서 만들기
cp docs/99-templates/feature-template.md docs/01-product/features/F-XXX-name.md

# 새 ADR 만들기
cp docs/99-templates/adr-template.md docs/07-decisions/ADR-XXX-title.md

# 모든 진행 중인 기능 찾기
grep -l "상태.*진행중" docs/01-product/features/

# 특정 기능 관련 모든 문서 찾기
grep -r "F-001" docs/
```

---

## 팀 / 연락처
- 프로젝트 오너: {UNSET}
- 기술 리드: {UNSET}
- Slack 채널: {UNSET}

---

## Bootstrap Progress
> `{UNSET}`이 있는 항목은 아직 결정/작성되지 않은 것. `grep -r "{UNSET}" docs/`로 전체 현황 파악 가능.
>
> **base-docs를 복제해서 실제 프로젝트를 시작했다면**: 포함된 샘플 문서(F-001, identity 도메인, ADR-001~003, auth.yaml 등)를 먼저 제거하세요.
> ```bash
> bash .claude/scripts/reset-samples.sh          # 미리보기
> bash .claude/scripts/reset-samples.sh --apply  # 실행
> ```
> 실행 후 안내에 따라 INDEX.md / registry.md / 아래 Bootstrap 체크박스를 정리하면 됩니다.

- [x] CLAUDE.md 루트 작성
- [x] 폴더별 CLAUDE.md 가이드 완성
- [x] 99-templates/ 모든 템플릿 작성
- [x] 첫 번째 도메인 (identity) 완성
- [x] 첫 번째 기능 (F-001 user-authentication) 완성
- [x] 첫 번째 ADR 시리즈 (ADR-001~003) 작성
- [ ] 한 줄 요약 작성
- [ ] 프로젝트 현황 갱신
- [ ] tech-stack.md 모든 행 결정
- [ ] vision.md 핵심 내용 작성
- [ ] glossary.md 모든 용어 정의 완료
- [ ] 코드 컨벤션 확정
- [ ] 팀/연락처 정보 입력
- [x] .claude/ 에이전트 시스템 구축 (agents, skills, rules, scripts)
