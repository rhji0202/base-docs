---
name: plan-impl
description: 기획 문서(PRD, 도메인, API, 스키마)를 읽고 코드 구현 계획을 수립한다. 파일 구조, 구현 순서, 패키지 의존성, 테스트 전략, PR 분할을 포함하는 impl-plan.md를 생성한다. /plan-feature 완료 후 구현 시작 전에 사용.
user-invocable: true
argument-hint: "[F-XXX]"
allowed-tools: Read Grep Glob
---

# /plan-impl $ARGUMENTS

Feature `$1`의 기획 문서를 읽고 구현 계획을 수립합니다.

## 현재 상태

스킬 시작 시 다음을 수행하세요:
1. Glob 도구로 `docs/01-product/features/$1-*.md` 패턴을 검색하여 해당 Feature PRD 파일 존재 여부 확인
2. Grep 도구로 `docs/00-overview/registry.md`에서 `$1` 패턴을 검색하여 Registry 매핑 확인

## 절차

### 1. 기획 문서 로드
registry.md에서 `$1`의 매핑을 확인하고, 관련 문서를 모두 읽습니다:
- PRD → 인수 조건 추출
- 도메인 모델 → 엔티티/이벤트 목록
- API 스펙 → 엔드포인트/스키마
- DB 스키마 → 테이블/제약조건

### 2. 아키텍처 맥락 로드
- `docs/03-architecture/overview.md` → Modular Monolith 패턴
- `docs/03-architecture/tech-stack.md` → 기술 스택 (프레임워크, ORM, 테스트 도구)
- `docs/09-guides/coding-standards.md` → 코딩 컨벤션
- `docs/09-guides/testing.md` → 테스트 전략

### 3. 구현 계획 수립
- 인수 조건 → 구현 항목 매핑
- 파일 구조 설계
- 레이어별 구현 순서 (엔티티 → 서비스 → API → 이벤트 → 테스트)
- 패키지 의존성
- PR 분할 계획

### 4. 산출물 생성
`docs/01-product/features/impl-plans/$1-impl-plan.md` 파일 생성
(PRD 폴더와 분리하여 ID 검증/INDEX.md 규칙 충돌 방지)

## /plan-impl → 구현 시작 흐름

```
/plan-impl F-002                                      ← 구현 계획 수립
    ↓
impl-plans/F-002-impl-plan.md 생성                     ← 구현 로드맵
    ↓
Claude Code plan mode                                  ← impl-plan.md를 참조하여 코드 작성
    "impl-plans/F-002-impl-plan.md를 읽고 Layer 1부터 구현 시작해줘"
```

## 구현 브리지 (산출 직후 출력할 것)

스킬 종료 시 사용자에게 **다음 단계 실행 가능한 프롬프트**를 복사용 코드 블록으로 제공:

```
다음 명령을 plan mode에서 실행하세요:

  @docs/01-product/features/impl-plans/{F-XXX}-impl-plan.md 를 읽고
  Layer 1(엔티티 + 마이그레이션)부터 순서대로 구현을 시작해주세요.
  각 Layer 완료 시 검증 후 다음 Layer로 진행합니다.
  PR 분할 계획을 따라 Layer별로 커밋을 분리하세요.
```

이렇게 하면 사용자가 그대로 복사해서 plan mode를 킥오프할 수 있습니다.
