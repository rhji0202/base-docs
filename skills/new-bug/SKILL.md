---
name: new-bug
description: 새 버그 리포트를 생성한다. 다음 BUG-XXX ID를 자동 할당하고, 템플릿 기반으로 증상/재현/영향/해결을 기록한다. 관련 Feature/ADR과 상호 링크한다.
user-invocable: true
argument-hint: "[버그 한 줄 요약]"
allowed-tools: Read Grep Glob Write Edit Bash(.claude/scripts/next-id.sh*)
---

# /new-bug $ARGUMENTS

새 버그 리포트 "$1"을 생성합니다.

## 절차

### 1. ID 할당
Bash로 `.claude/scripts/next-id.sh bug` 실행하여 다음 BUG-XXX ID 획득.
(예: 기존이 BUG-002면 → BUG-003)

### 2. 템플릿 로드
`docs/99-templates/bug-template.md`를 읽습니다.

### 3. 관련 맥락 확인
- Glob으로 `docs/01-product/features/F-*.md` 검색 → 어떤 Feature와 연관되는지 확인
- Grep으로 `docs/06-operations/bugs/`에서 유사 증상이 이미 리포트됐는지 체크

### 4. 사용자에게 질문
- **증상**: 무엇이 잘못됐는가?
- **재현 절차**: 어떻게 재현하는가?
- **심각도**: P0 (서비스 중단) / P1 (핵심 기능) / P2 (부분 기능) / P3 (UI/UX)
- **영향받은 Feature**: F-XXX (registry.md로 확인)
- **환경**: OS, 버전 등

### 5. 파일 생성
`docs/06-operations/bugs/BUG-{ID}-{kebab-case}.md`

frontmatter 필수:
- `id: BUG-XXX`
- `status: open`
- `severity`
- `affected_feature: F-XXX`
- `created: {오늘}`

### 6. 교차 링크
- 해당 Feature PRD의 "관련 문서" 섹션에 BUG 링크 추가
- P0/P1인 경우 postmortem 작성 안내

### 7. 후속 조치 안내
- P0/P1 → incident-response 프로세스 연결 (`docs/06-operations/incident-response.md`)
- 수정 후 → `status: resolved`로 갱신 + 리그레션 테스트 추가 권장
