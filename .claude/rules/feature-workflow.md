---
paths:
  - "docs/01-product/**"
  - "docs/01-product/features/**"
---

# 기능(Feature) 워크플로우 규칙

docs/01-product/ 내 기능 문서 작업 시 적용되는 규칙.

## PRD 작성 워크플로우

```
1. ID 할당     → next-id.sh feature 또는 INDEX.md 확인
2. 템플릿 복사 → docs/99-templates/feature-template.md 기반
3. PRD 작성    → status: draft
4. 리뷰        → status: review
5. 승인        → status: approved
6. 구현 시작   → status: in-progress, 커밋에 F-XXX prefix
7. 출시        → status: shipped
8. 회고        → lessons learned 추가
```

## 필수 Frontmatter

```yaml
---
id: F-XXX
title: [기능명]
status: draft | review | approved | in-progress | shipped | deprecated
priority: P0 | P1 | P2 | P3
owner: [담당자]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## 필수 섹션
1. 배경 (Why) — 문제와 비즈니스 가치
2. 사용자 스토리 — "~로서, ~하고 싶다, ~를 위해"
3. 핵심 동작 — Mermaid 시퀀스 다이어그램 포함
4. 인수 조건 — 체크리스트 형식
5. Out of Scope — 하지 않을 것 명시
6. 엣지 케이스 — 테이블 형식
7. 성공 지표 — 측정 가능한 KPI
8. 관련 문서 — 관계 유형 명시

## INDEX.md 갱신
새 기능 추가/상태 변경 시 반드시 `docs/01-product/features/INDEX.md` 갱신.

## Registry 연동
새 기능 생성 시 `docs/00-overview/registry.md`에 매핑 추가.
