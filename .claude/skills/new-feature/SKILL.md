---
name: new-feature
description: 새 기능 PRD 문서를 생성한다. 다음 F-XXX ID를 자동 할당하고, 템플릿 기반으로 PRD를 작성하며, INDEX.md와 registry.md를 갱신한다.
user-invocable: true
argument-hint: "[기능명]"
allowed-tools: Read Grep Glob Write Edit Bash(.claude/scripts/next-id.sh*)
---

# /new-feature $ARGUMENTS

새 기능 PRD 문서를 생성합니다.

## 현재 상태 확인

다음 Feature ID: !`.claude/scripts/next-id.sh feature`

## 절차

1. **다음 ID 확인**: 위 결과에서 다음 사용 가능한 `F-XXX` ID를 확인합니다.

2. **템플릿 로드**: `docs/99-templates/feature-template.md`를 읽습니다.

3. **참고 예시 확인**: `docs/01-product/features/F-001-user-authentication.md`를 읽어 작성 패턴을 파악합니다.

4. **기존 컨텍스트 확인**:
   - `docs/00-overview/glossary.md` — 기존 용어
   - `docs/03-architecture/overview.md` — 아키텍처 맥락
   - 관련 도메인이 있다면 `docs/02-domains/{domain}/CLAUDE.md`

5. **PRD 작성**: 사용자에게 다음을 질문하며 PRD를 채웁니다:
   - 어떤 문제를 해결하는가? (배경)
   - 주요 사용자는 누구인가? (사용자 스토리)
   - 핵심 동작은 무엇인가? (Mermaid 다이어그램)
   - 성공 기준은? (인수 조건)
   - 하지 않을 것은? (Out of Scope)

6. **파일 생성**: `docs/01-product/features/F-{ID}-{kebab-case}.md`

7. **INDEX.md 갱신**: `docs/01-product/features/INDEX.md`에 새 항목 추가

8. **Registry 갱신**: `docs/00-overview/registry.md`에 매핑 추가

## 작성 규칙
- frontmatter 필수: `id`, `title`, `status: draft`, `priority`, `owner`, `created`
- 관련 문서 섹션에 관계 유형 명시 (**구현**, **결정 근거**, **제약 조건**)
- 미결정 사항은 `{UNSET}` 마커
- 400줄 이내
