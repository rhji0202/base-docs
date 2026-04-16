---
name: new-adr
description: 새 ADR(Architecture Decision Record) 문서를 생성한다. 다음 ADR-XXX ID를 자동 할당하고, 템플릿 기반으로 ADR을 작성하며, INDEX.md를 갱신한다.
user-invocable: true
argument-hint: "[결정 제목]"
allowed-tools: Read Grep Glob Write Edit
---

# /new-adr $ARGUMENTS

새 Architecture Decision Record를 생성합니다.

## 현재 상태 확인

스킬 시작 시 다음을 수행하세요:
- Glob 도구로 `docs/07-decisions/ADR-*.md` 패턴을 검색하여 기존 ADR 파일 목록을 확인
- 가장 높은 번호의 ADR-XXX에서 +1 하여 다음 ID를 결정 (예: ADR-003이 마지막이면 → ADR-004)

## 절차

1. **다음 ID 확인**: 위에서 결정한 다음 사용 가능한 `ADR-XXX` ID를 사용합니다.

2. **템플릿 로드**: `docs/99-templates/adr-template.md`를 읽습니다.

3. **기존 ADR 확인**: `docs/07-decisions/INDEX.md`를 읽어 관련된 기존 결정을 파악합니다.

4. **컨텍스트 로드**:
   - `docs/03-architecture/overview.md` — 현재 아키텍처
   - `docs/03-architecture/tech-stack.md` — 기술 스택 현황
   - 관련 기존 ADR 파일들

5. **ADR 작성**: 사용자에게 다음을 질문합니다:
   - 어떤 결정이 필요한가? (맥락)
   - 어떤 제약 조건이 있는가?
   - 어떤 대안을 검토했는가?
   - 왜 이 방안을 선택했는가? (근거)

6. **파일 생성**: `docs/07-decisions/ADR-{ID}-{kebab-case}.md`
   - frontmatter: `id`, `title`, `status: proposed`, `date`, `deciders`

7. **INDEX.md 갱신**: `docs/07-decisions/INDEX.md`에 새 항목 추가

## ADR 원칙
- ADR은 **불변** — 결정이 바뀌면 새 ADR을 작성하고 기존 것은 `superseded` 처리
- `proposed` → `accepted` | `rejected` | `deprecated` | `superseded`
- 대안 비교는 반드시 포함 (최소 2개 대안)
