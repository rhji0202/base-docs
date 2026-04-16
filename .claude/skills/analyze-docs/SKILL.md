---
name: analyze-docs
description: 기능 요청을 받으면 기존 docs/ 전체를 분석하여 실행 계획을 수립한다. vision, roadmap, ADR, 기존 도메인, tech-stack, security를 교차 검토하여 타당성, 블로커, 선행 작업, 리스크를 리포트한다. /plan-feature 실행 전 사전 분석 용도.
user-invocable: true
argument-hint: "[기능 요청]"
allowed-tools: Read Grep Glob
---

# /analyze-docs $ARGUMENTS

기능 "$1"에 대해 기존 docs/ 전체를 분석하고 실행 계획을 수립합니다.

## 분석 범위

스킬 시작 시 다음 도구들로 프로젝트 현황을 파악하세요:
- Glob으로 `docs/01-product/features/F-*.md` 검색 → Feature 수 파악 + 다음 ID 결정
- Glob으로 `docs/02-domains/*/CLAUDE.md` 검색 → Domain 수 파악
- Glob으로 `docs/07-decisions/ADR-*.md` 검색 → ADR 수 파악
- Grep으로 `docs/03-architecture/tech-stack.md`에서 `{UNSET}` 검색 → 미결정 기술 스택 파악

## 분석 절차

### 1. 타당성 확인
다음을 읽고 이 기능이 범위 안인지 확인:
- `docs/00-overview/vision.md` — Out of Scope 목록
- `docs/00-overview/roadmap.md` — 로드맵 맥락

### 2. 제약 조건 수집
다음을 읽고 설계에 영향을 미치는 결정/제약을 수집:
- `docs/07-decisions/` — 모든 ADR 파일
- `docs/03-architecture/overview.md` — 아키텍처 원칙
- `docs/03-architecture/tech-stack.md` — {UNSET} 블로커
- `docs/03-architecture/security.md` — 보안 요구사항

### 3. 도메인 경계 분석
다음을 읽고 이 기능이 속할 도메인을 결정:
- `docs/02-domains/` — 모든 도메인의 CLAUDE.md
- `docs/00-overview/glossary.md` — 용어 충돌 확인

### 4. 기존 기능 관계
다음을 읽고 겹치는 범위/의존성을 식별:
- `docs/01-product/features/` — 모든 기존 기능 PRD
- `docs/00-overview/registry.md` — 매핑 현황

### 5. 실행 계획 출력
분석 결과를 다음 형식으로 출력:
- 타당성 판단 (Go / 조건부 Go / 블로커 있음)
- 영향받는 기존 문서 목록
- 선행 작업 체크리스트
- Phase별 주의사항
- 리스크 테이블
- 다음 단계 안내

## /analyze-docs → /plan-feature 흐름

```
/analyze-docs "결제 시스템"     ← 지금 실행: 분석 + 계획
    ↓ 선행 작업 완료 후
/plan-feature "결제 시스템"     ← 다음 실행: PRD~스키마 생성
```
