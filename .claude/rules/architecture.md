---
paths:
  - "docs/03-architecture/**"
  - "docs/07-decisions/**"
  - "docs/08-rfcs/**"
---

# 아키텍처 & 결정 기록 규칙

아키텍처, ADR, RFC 문서 작업 시 적용되는 규칙.

## C4 모델
- Level 1 (Context): `system-context.md` — 외부 시스템과의 관계
- Level 2 (Containers): `containers.md` — 배포 단위
- Level 3 (Components): `components.md` — 서비스 내부 모듈
- Level 4 (Code): 필요 시만, 보통 코드로 충분

## 다이어그램 규칙
- 모든 다이어그램은 Mermaid 또는 PlantUML
- 원본은 `docs/03-architecture/diagrams/`에 `.mmd` 저장
- 마크다운에 인라인 임베드
- 이미지 파일 (PNG, JPG) 금지

## ADR 불변성 원칙
- ADR은 한 번 `accepted`되면 **절대 수정하지 않는다**
- 결정이 바뀌면 새 ADR을 작성하고 기존 것은 `superseded by: ADR-XXX` 처리
- 상태: `proposed` → `accepted` | `rejected` | `deprecated` | `superseded`

## ADR 필수 요소
1. **맥락 (Context)** — 왜 이 결정이 필요한가, 제약 조건
2. **결정 (Decision)** — 채택한 방안 한 문장
3. **근거 (Rationale)** — 최소 2개 대안 비교
4. **결과 (Consequences)** — 긍정/부정 + mitigation

## RFC 절차
- `draft` → 토론 → `accepted` → ADR로 변환
- 토론 마감일, 결정 마감일 명시
- 승인 시: ADR 생성 + RFC archive 처리

## tech-stack.md 변경 규칙
- 기술 스택 변경 시 반드시 ADR 선행 작성
- 금지/Deprecated 기술 목록 갱신
- 분기 1회 정기 검토
