---
name: plan-feature
description: 기능 하나를 PRD부터 DB 스키마까지 6단계 Phase로 end-to-end 기획한다. 각 Phase 사이에 사용자 확인을 받으며, 원하는 Phase까지만 선택적으로 실행할 수 있다.
user-invocable: true
argument-hint: "[기능명]"
allowed-tools: Read Grep Glob Write Edit
---

# /plan-feature $ARGUMENTS

기능 "$1"을 6단계 Phase로 end-to-end 기획합니다.

## Stage 0: 선행 조건 검증 (Bootstrap Gate)

**Phase 1 시작 전 반드시 수행:**

1. Read로 `CLAUDE.md`를 읽고 "Bootstrap Progress" 섹션에서 미완료(`[ ]`) 항목을 카운트
2. Grep으로 `docs/03-architecture/tech-stack.md`에서 `{UNSET}` 개수 확인
3. Grep으로 `docs/00-overview/vision.md`에서 `{UNSET}` 개수 확인

**판정:**
- Bootstrap 미완료 항목이 3개 이상이거나 tech-stack {UNSET}이 5개 이상이면 → **경고 후 사용자에게 진행 의사 재확인**
  > "⚠️ 프로젝트 부트스트랩이 충분치 않습니다. `/init-project`를 먼저 실행하는 것을 권장합니다. 그래도 진행할까요? (y/n)"
- vision.md의 "Out of Scope"가 `{UNSET}`이면 → **CRITICAL 경고**: 타당성 판단 불가
- 위 조건에 모두 해당 없으면 → 통과, Phase 1 진행

## 현재 상태

Glob 도구로 `docs/01-product/features/F-*.md`를 검색하여 기존 Feature 목록을 확인하고, 가장 높은 번호 +1로 다음 Feature ID를 결정하세요.

## Phase 구성

```
Phase 1: PRD 작성         → 기능 명세서 (F-XXX)
Phase 2: 도메인 모델       → DDD 엔티티/이벤트 설계
Phase 3: API 설계          → OpenAPI 3.1 스펙
Phase 4: DB 스키마         → 테이블 DDL + 데이터 분류
Phase 5: 문서 검증         → 깨진 링크, {UNSET}, 용어 일관성
Phase 6: 레지스트리 동기화  → registry.md 갱신
```

## 실행 방법

사용자에게 먼저 질문합니다:

> **어디까지 진행할까요?**
> 1. PRD만 (Phase 1)
> 2. PRD + 도메인 모델 (Phase 1~2)
> 3. 설계 전체 (Phase 1~4)
> 4. 전체 + 검증 (Phase 1~6) ← 추천

선택에 따라 해당 Phase까지 순차 실행합니다.

## 각 Phase 진행 규칙

1. Phase 시작 시: "**Phase N: {제목}**을 시작합니다" 안내
2. Phase 완료 시: 산출물 요약 → "계속 진행할까요?" 확인
3. 수정 요청: 해당 Phase 내에서 수정 후 재확인
4. 건너뛰기: "Phase 3 건너뛰기" 가능

## 참조 문서

- worked example: `docs/01-product/features/F-001-user-authentication.md`
- 도메인 example: `docs/02-domains/identity/`
- API example: `docs/04-api/rest/auth.yaml`
- 스키마 example: `docs/05-data/schemas/users.md`
- 레지스트리: `docs/00-overview/registry.md`
