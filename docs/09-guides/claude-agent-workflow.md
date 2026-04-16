# Claude Agent Workflow Guide

> `.claude/` 에이전트 시스템의 전체 워크플로우.
> 프로젝트 초기화부터 코드 구현까지 4단계(Stage 0~4)로 구성.
> 마지막 갱신: 2026-04-16

---

## 시스템 구성 요약

```
.claude/
├── agents/    9개  (전략가, 오케스트레이터, 전문가, 검증자)
├── skills/   16개  (슬래시 커맨드 11 + 자동 활성화 5)
├── rules/     4개  (경로별 자동 규칙)
├── scripts/   3개  (ID 생성, 링크 검사, frontmatter 검증)
└── settings.json   (권한, PostToolUse 훅)
```

---

## 전체 흐름 한 눈에

```
┌─────────────────────────────────────────────────────────┐
│                    STAGE 0 (최초 1회)                     │
│  /init-project                                           │
│  프로젝트 정체성 → 기술 스택 → 컨벤션 → 팀 → 제품 정의  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    STAGE 1 (기능별)                       │
│  /analyze-docs "기능명"                                  │
│  vision, ADR, 도메인, 기존 기능, tech-stack, security    │
│  → Execution Plan (타당성, 블로커, 리스크)               │
└────────────────────────┬────────────────────────────────┘
                         │ 블로커 해소 후
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    STAGE 2 (기능별)                       │
│  /plan-feature "기능명"                                  │
│  Phase 1 [PRD] → Phase 2 [Domain] → Phase 3 [API]      │
│  → Phase 4 [Schema] → Phase 5 [Verify] → Phase 6 [Reg] │
│  (각 Phase 사이 사용자 확인)                              │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    STAGE 3 (기능별)                       │
│  /plan-impl F-XXX                                       │
│  인수 조건 → 파일 구조 → 구현 순서 → 패키지 → 테스트    │
│  → PR 분할 → F-XXX-impl-plan.md 생성                    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    STAGE 4 (구현)                         │
│  Claude Code plan mode                                   │
│  "F-XXX-impl-plan.md 읽고 Layer 1부터 구현해줘"         │
│  → 실제 코드 작성                                        │
└─────────────────────────────────────────────────────────┘
```

---

## Stage 0: 프로젝트 초기 설정 (최초 1회)

```
/init-project
```

| 항목 | 내용 |
|---|---|
| **에이전트** | `project-bootstrapper` |
| **목적** | 프로젝트의 모든 `{UNSET}` 기초 항목을 대화형으로 채우기 |
| **입력** | 없음 (사용자와 대화) |
| **산출물** | CLAUDE.md, vision.md, tech-stack.md, metrics.md, glossary.md, personas 갱신 |

### 5개 Phase

```
Phase 1: 프로젝트 정체성
  │  질문: 한 줄 요약, 단계(MVP/Beta/Prod), 비전, Out of Scope
  │  갱신: CLAUDE.md, docs/00-overview/vision.md
  │
Phase 2: 기술 스택
  │  질문: Frontend(4), Backend(4), Data(3), Infra(4), Observability(5), Dev(1)
  │  갱신: docs/03-architecture/tech-stack.md ({UNSET} 21개 해소)
  │
Phase 3: 코드 컨벤션
  │  질문: 언어, 포맷터, 린터, 테스트, 커밋, 브랜치
  │  갱신: CLAUDE.md 코드 컨벤션 섹션
  │
Phase 4: 팀 정보
  │  질문: 프로젝트 오너, 기술 리드, 커뮤니케이션 채널
  │  갱신: CLAUDE.md 팀/연락처 섹션
  │
Phase 5: 제품 정의
     질문: North Star Metric, 측정 도구, 페르소나, 미정의 용어
     갱신: metrics.md, personas/README.md, glossary.md
```

완료 후 Bootstrap Progress 체크리스트 갱신, 남은 `{UNSET}` 개수 리포트.

---

## Stage 1: 기능 타당성 분석

```
/analyze-docs "결제 시스템"
```

| 항목 | 내용 |
|---|---|
| **에이전트** | `docs-planner` |
| **목적** | 기존 docs/ **전체**를 읽고 이 기능의 실행 계획 수립 |
| **입력** | 기능 요청 (자연어) |
| **산출물** | Execution Plan (텍스트 리포트, 파일 생성 없음) |

### 6단계 분석

```
Step 1: 프로젝트 현황 파악
  │  읽는 파일: CLAUDE.md, vision.md, roadmap.md, glossary.md, registry.md
  │  확인: Out of Scope 충돌 여부, 기존 매핑 현황
  │
Step 2: 아키텍처 제약 조건 수집
  │  읽는 파일: overview.md, tech-stack.md, security.md, data-flow.md
  │  확인: {UNSET} 블로커, 보안 추가 요구사항
  │
Step 3: 기존 결정 검토
  │  읽는 파일: docs/07-decisions/ADR-* 전체
  │  확인: 설계 영향, 새 ADR 필요 여부, 충돌 감지
  │
Step 4: 도메인 경계 분석
  │  읽는 파일: docs/02-domains/ 모든 CLAUDE.md
  │  확인: 속할 도메인(기존/신규), 의존성, 이벤트 흐름
  │
Step 5: 기존 기능 관계
  │  읽는 파일: docs/01-product/features/ 모든 PRD
  │  확인: 범위 중복, 의존 기능, 인수 조건 영향
  │
Step 6: 실행 계획 출력
     산출물:
     ├── 타당성 판단 (Go / 조건부 / 블로커)
     ├── 영향받는 기존 문서 목록
     ├── 선행 작업 체크리스트
     ├── Phase별 주의사항
     └── 리스크 테이블
```

다음 단계: 선행 작업 해결 (예: `/new-adr`, tech-stack 결정) → Stage 2로 이동.

---

## Stage 2: 기획 문서 생성 (6-Phase)

```
/plan-feature "결제 시스템"
```

| 항목 | 내용 |
|---|---|
| **에이전트** | `phase-conductor` |
| **목적** | PRD부터 DB 스키마까지 end-to-end 기획 문서 생성 |
| **입력** | 기능명 (자연어) |
| **산출물** | PRD, 도메인 모델, API 스펙, DB 스키마, registry 갱신 |

### 시작 시 범위 선택

> 1. PRD만 (Phase 1)
> 2. PRD + 도메인 (Phase 1~2)
> 3. 설계 전체 (Phase 1~4)
> 4. 전체 + 검증 (Phase 1~6) ← 추천

### 6개 Phase

```
Phase 1: PRD 작성
  │  에이전트 로직: planner
  │  절차:
  │    1. next-id.sh feature → 다음 ID (예: F-002)
  │    2. 템플릿 + worked example (F-001) 로드
  │    3. 사용자와 대화 → 배경, 사용자 스토리, 핵심 동작, 인수 조건
  │    4. docs/01-product/features/F-002-payment.md 생성
  │    5. INDEX.md 갱신
  │  산출물: PRD 파일 1개
  │  확인: "Phase 1 완료. 수정할 부분이 있나요?"
  │
Phase 2: 도메인 모델
  │  에이전트 로직: domain-modeler
  │  절차:
  │    1. PRD 사용자 스토리 → 엔티티/값 객체/이벤트 추출
  │    2. 기존 도메인 확인 (docs/02-domains/)
  │    3. 새 도메인이면 폴더 구조 생성
  │    4. Mermaid classDiagram + stateDiagram 작성
  │    5. glossary.md 용어 등록
  │  산출물: 도메인 폴더 (4~5 파일)
  │  확인: "Phase 2 완료. 엔티티/이벤트 구성이 맞나요?"
  │
Phase 3: API 설계
  │  에이전트 로직: api-designer
  │  절차:
  │    1. PRD 사용자 스토리 → 엔드포인트 도출
  │    2. 도메인 모델 → Request/Response 스키마
  │    3. conventions.md 규칙 적용
  │    4. OpenAPI 3.1 YAML 생성
  │    5. error-codes.md 갱신
  │  산출물: docs/04-api/rest/{domain}.yaml
  │  확인: "Phase 3 완료. API 설계를 확인해주세요."
  │
Phase 4: DB 스키마
  │  에이전트 로직: schema-designer
  │  절차:
  │    1. 도메인 엔티티 → 테이블 매핑
  │    2. 기존 스키마 중복 확인
  │    3. SQL DDL + 제약조건 + 인덱스 작성
  │    4. 데이터 분류 (PII/Restricted/Internal/Public)
  │  산출물: docs/05-data/schemas/{table}.md
  │  확인: "Phase 4 완료. 테이블 구조를 확인해주세요."
  │
Phase 5: 문서 검증
  │  에이전트 로직: doc-reviewer
  │  절차:
  │    1. {UNSET} 잔존 확인
  │    2. 상호참조 링크 존재 확인
  │    3. frontmatter 필수 필드 검증
  │    4. glossary ↔ domain-model 용어 일치
  │    5. PRD "관련 문서"에 Phase 2~4 링크 추가
  │  산출물: 검증 리포트 + 이슈 즉시 수정
  │  확인: "Phase 5 완료. 검증 결과를 확인해주세요."
  │
Phase 6: 레지스트리 동기화
     절차:
       1. registry.md에 새 Feature 매핑 추가
       2. 도메인별 인덱스 갱신
     산출물: registry.md 갱신
```

### 완료 리포트

```
══════════════════════════════════════
  Feature Planning Complete: F-002
══════════════════════════════════════
  Phase 1 [PRD]      ✓
  Phase 2 [Domain]   ✓
  Phase 3 [API]      ✓
  Phase 4 [Schema]   ✓
  Phase 5 [Verify]   ✓
  Phase 6 [Registry] ✓

  Next: /plan-impl F-002
══════════════════════════════════════
```

---

## Stage 3: 구현 계획

```
/plan-impl F-002
```

| 항목 | 내용 |
|---|---|
| **에이전트** | `impl-planner` |
| **목적** | 기획 문서를 코드 구현 로드맵으로 변환 |
| **입력** | Feature ID (F-XXX) |
| **산출물** | `docs/01-product/features/F-002-impl-plan.md` |

### 6단계 분석

```
Step 1: 인수 조건 → 구현 항목 매핑
  │  PRD의 각 인수 조건에서 코드로 구현할 항목을 도출
  │
Step 2: 파일 구조 설계
  │  tech-stack + architecture 기반으로 생성할 파일 목록
  │  src/domains/{domain}/ 하위 구조
  │
Step 3: 구현 순서 결정
  │  Layer 1 (기반):  엔티티, 마이그레이션
  │  Layer 2 (도메인): 서비스, 비즈니스 규칙, 이벤트
  │  Layer 3 (API):   컨트롤러, DTO, 가드
  │  Layer 4 (통합):  이벤트 핸들러, 외부 연동
  │  Layer 5 (검증):  테스트
  │
Step 4: 패키지 의존성
  │  새로 필요한 패키지와 사유
  │
Step 5: 테스트 전략
  │  Unit (70%) / Integration (20%) / E2E (10%)
  │  인수 조건 → E2E 시나리오 매핑
  │
Step 6: PR 분할 계획
     PR 1: DB 마이그레이션 + 엔티티 (S)
     PR 2: 도메인 서비스 (M)
     PR 3: API 컨트롤러 (M)
     PR 4: 이벤트 핸들러 (S)
     PR 5: E2E 테스트 (S)
```

---

## Stage 4: 코드 구현

```
"F-002-impl-plan.md를 읽고 Layer 1부터 구현 시작해줘"
```

| 항목 | 내용 |
|---|---|
| **도구** | Claude Code 본체 (plan mode) |
| **입력** | impl-plan.md |
| **산출물** | 실제 코드 파일들 |

Claude Code가 `impl-plan.md`를 참조하여 Layer별로 코드를 작성합니다.

---

## 유틸리티 커맨드 (언제든 사용)

| 커맨드 | 용도 | 산출물 |
|---|---|---|
| `/doc-status` | 프로젝트 문서 건강 리포트 | {UNSET} 수, completion 분포, Bootstrap 현황 |
| `/trace-feature F-XXX` | 특정 기능 전체 문서 추적 맵 | 관련 문서 트리 + completion 상태 |
| `/sync-registry` | registry.md 자동 갱신 | 새 기능 감지, 누락 매핑 보고 |
| `/new-adr "제목"` | ADR 단독 생성 | ADR-XXX 파일 + INDEX.md 갱신 |
| `/new-rfc "제목"` | RFC 단독 생성 | RFC-XXX 파일 + INDEX.md 갱신 |
| `/new-domain "이름"` | 도메인 폴더 단독 스캐폴딩 | CLAUDE.md + domain-model.md + business-rules.md + edge-cases.md |
| `/new-feature "이름"` | PRD 단독 생성 (Phase 1만) | F-XXX 파일 + INDEX.md + registry 갱신 |

---

## 자동 활성화 스킬 (컨텍스트 매칭)

| 스킬 | 활성화 조건 |
|---|---|
| `frontend-design` | UI 컴포넌트, 페이지, 비주얼 디자인 작업 시 |
| `nestjs-patterns` | NestJS 코드 작성/수정 시 |
| `nextjs-turbopack` | Next.js 16+ 개발/디버깅 시 |
| `nodejs-keccak256` | Ethereum 해싱 코드 작업 시 |
| `ui-ux-pro-max` | UI/UX 설계, 색상/폰트/레이아웃 작업 시 |

---

## 자동 적용 Rules (경로 매칭)

| Rule | 활성 경로 | 핵심 규칙 |
|---|---|---|
| `docs-writing` | `docs/**/*.md` | 400줄 제한, {UNSET} 마커, Mermaid만 |
| `feature-workflow` | `docs/01-product/**` | PRD frontmatter 필수, INDEX 갱신 |
| `architecture` | `docs/03-architecture/**`, `07-decisions/**`, `08-rfcs/**` | C4 모델, ADR 불변성 |
| `api-design` | `docs/04-api/**` | OpenAPI 3.1, REST 규칙 |

---

## PostToolUse 훅

| 트리거 | 스크립트 | 동작 |
|---|---|---|
| `docs/**/*.md` Write/Edit | `validate-frontmatter.sh` | F-XXX, ADR-XXX, RFC-XXX의 frontmatter 필수 필드 경고 |

---

## 에이전트 목록

| 에이전트 | 역할 | 대응 스킬 |
|---|---|---|
| `project-bootstrapper` | 프로젝트 초기 설정 (최초 1회) | `/init-project` |
| `docs-planner` | 기존 docs 전체 분석 → 실행 계획 | `/analyze-docs` |
| `phase-conductor` | 6-Phase 기획 오케스트레이션 | `/plan-feature` |
| `planner` | PRD 단독 작성 | `/new-feature` |
| `domain-modeler` | DDD 도메인 모델 설계 | `/new-domain` |
| `api-designer` | OpenAPI 스펙 설계 | (Phase 3에서 사용) |
| `schema-designer` | DB 스키마 설계 | (Phase 4에서 사용) |
| `doc-reviewer` | 문서 품질 감사 (읽기 전용) | `/doc-status` |
| `impl-planner` | 기획 → 구현 계획 변환 | `/plan-impl` |

---

## 관련 문서

- [Claude Code 활용 가이드](./claude-code-tips.md)
- [기여 가이드](./contributing.md)
- [코딩 표준](./coding-standards.md)
