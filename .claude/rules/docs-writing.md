---
paths:
  - "docs/**/*.md"
---

# 문서 작성 규칙

docs/ 내 마크다운 파일을 작성하거나 수정할 때 반드시 따라야 하는 규칙.

## 5대 원칙

### 1. 한 파일 = 한 주제
- 400줄을 넘으면 반드시 분할
- Claude Code 컨텍스트 윈도우 효율과 직결

### 2. 첫 3줄 규칙
모든 문서의 첫 3줄에 명시:
- 무엇에 관한 문서인가
- 누가 언제 읽어야 하는가
- 마지막 갱신일

### 3. ID 체계
- Feature: `F-001` ~ `F-999` (`docs/01-product/features/`)
- ADR: `ADR-001` ~ `ADR-999` (`docs/07-decisions/`)
- RFC: `RFC-001` ~ `RFC-999` (`docs/08-rfcs/`)
- BUG: `BUG-001` ~ `BUG-999` (`docs/06-operations/bugs/`)
- 파일명: `{ID}-{kebab-case}.md`

### 4. 상호 참조
- 상대 경로만 사용 (`../01-product/features/F-001-user-authentication.md`)
- 절대 경로, 외부 링크 (Notion, Confluence) 금지
- 관계 유형 명시: **구현**, **결정 근거**, **제약 조건**, **참조**

### 5. 다이어그램
- Mermaid 또는 PlantUML만 사용
- Figma, draw.io, 이미지 파일 금지 (Claude가 못 읽음)
- 원본은 `diagrams/` 폴더에 `.mmd` 또는 `.puml`로 저장

## {UNSET} 마커 규칙
- 아직 결정되지 않은 값에는 `{UNSET}` 또는 `{UNSET: 설명}` 사용
- `[예: ...]` 패턴 절대 사용 금지 — AI가 실제 값으로 오해
- `grep -r "{UNSET}" docs/`로 미결정 항목 추적 가능

## Frontmatter
- 기능/ADR/RFC 문서에는 frontmatter 필수 (id, status, date)
- skeleton 문서에는 `completion: skeleton | partial | complete` 추가
- `last_verified: YYYY-MM-DD` 추가 권장

## 검색 친화성
- 동의어 함께 명시 (예: "결제 / Payment / Billing")
- 키워드를 본문에 자연스럽게 포함
- 긴 문서에 목차(TOC) 추가
