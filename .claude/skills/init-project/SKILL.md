---
name: init-project
description: 프로젝트 초기 설정을 시작한다. 한 줄 요약, 기술 스택, 코드 컨벤션, 팀 정보, 비전, 페르소나, 핵심 지표 등 모든 {UNSET} 항목을 대화형으로 채운다. 프로젝트 시작, 초기화, 부트스트랩 요청 시 사용.
user-invocable: true
allowed-tools: Read Grep Glob Write Edit
---

# /init-project

프로젝트 초기 설정을 시작합니다. 모든 `{UNSET}` 항목을 대화형으로 채웁니다.

## 현재 상태 확인

스킬 시작 시 아래 작업을 먼저 수행하세요:

1. Grep 도구로 `{UNSET}`을 다음 파일들에서 검색하여 미설정 항목 수를 파악:
   - `CLAUDE.md`
   - `docs/00-overview/vision.md`
   - `docs/03-architecture/tech-stack.md`
   - `docs/01-product/metrics.md`
   - `docs/00-overview/glossary.md`
   - `docs/01-product/personas/README.md`

2. Read 도구로 `CLAUDE.md`의 `## Bootstrap Progress` 섹션을 읽어 현재 진행 상황 파악

## 설정 순서

5개 Phase로 진행합니다. 각 Phase는 독립적이므로 원하는 것만 선택 가능합니다.

### Phase 1: 프로젝트 정체성 (CLAUDE.md, vision.md)
- 한 줄 요약, 프로젝트 단계, 비전, Out of Scope

### Phase 2: 기술 스택 (tech-stack.md)
- Frontend, Backend, Data, Infrastructure, Observability, Dev 도구

### Phase 3: 코드 컨벤션 (CLAUDE.md)
- 언어, 포맷터, 린터, 테스트, 커밋, 브랜치

### Phase 4: 팀 정보 (CLAUDE.md)
- 프로젝트 오너, 기술 리드, 커뮤니케이션 채널

### Phase 5: 제품 정의 (metrics.md, personas, glossary.md)
- North Star Metric, 측정 도구, 페르소나, 용어 정의

---

사용자에게 "어떤 Phase부터 시작할까요? (1~5, 또는 '전체')" 라고 질문하세요.

각 Phase에서:
1. 카테고리별로 질문하며 답변 수집
2. 수집 즉시 해당 파일의 `{UNSET}` 교체
3. Phase 완료 시 `CLAUDE.md` Bootstrap Progress 갱신
4. 남은 `{UNSET}` 개수 리포트

모든 설정 완료 후 `/doc-status`를 실행하도록 안내합니다.
