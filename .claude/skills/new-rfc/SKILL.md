---
name: new-rfc
description: 새 RFC(Request for Comments) 제안 문서를 생성한다. 다음 RFC-XXX ID를 자동 할당하고, 템플릿 기반으로 RFC를 작성하며, INDEX.md를 갱신한다.
user-invocable: true
argument-hint: "[제안 제목]"
allowed-tools: Read Grep Glob Write Edit Bash(.claude/scripts/next-id.sh*)
---

# /new-rfc $ARGUMENTS

새 RFC(Request for Comments) 제안서를 생성합니다.

## 현재 상태 확인

다음 RFC ID: !`.claude/scripts/next-id.sh rfc`

## 절차

1. **다음 ID 확인**: 위 결과에서 다음 사용 가능한 `RFC-XXX` ID를 확인합니다.

2. **템플릿 로드**: `docs/99-templates/rfc-template.md`를 읽습니다.

3. **기존 RFC/ADR 확인**:
   - `docs/08-rfcs/INDEX.md` — 진행 중인 제안
   - `docs/07-decisions/INDEX.md` — 관련 기존 결정

4. **RFC 작성**: 사용자에게 다음을 구조화합니다:
   - 요약 (3~5줄)
   - 동기: 현재 문제와 변경하지 않을 경우의 비용
   - 상세 설계: 변경 범위, 제안 방안, API/스키마 변경
   - 대안: 최소 2개 대안과 기각 사유
   - 마이그레이션 계획 + 롤백 전략
   - 영향도: 사용자, 개발팀, 운영, 비용

5. **파일 생성**: `docs/08-rfcs/RFC-{ID}-{kebab-case}.md`
   - frontmatter: `id`, `title`, `status: draft`, `author`, `created`, `deadline`

6. **INDEX.md 갱신**: `docs/08-rfcs/INDEX.md`에 새 항목 추가

## RFC vs ADR
- **RFC**: "이렇게 하면 어떨까?" — 토론 중, 변경 가능
- **ADR**: "이렇게 하기로 했다" — 결정 완료, 불변
- RFC가 승인되면 ADR로 변환
