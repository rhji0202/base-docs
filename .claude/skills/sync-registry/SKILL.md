---
name: sync-registry
description: docs/ 전체를 스캔하여 registry.md를 자동 갱신한다. 새로 추가된 F-XXX 파일을 감지하고, 누락된 매핑을 보고하며, 도메인별 인덱스를 업데이트한다.
user-invocable: true
allowed-tools: Read Grep Glob Write Edit
---

# /sync-registry

`docs/00-overview/registry.md`를 실제 파일 시스템과 동기화합니다.

## 절차

### 1. 현재 Feature 파일 스캔
`docs/01-product/features/` 내 모든 `F-XXX-*.md` 파일을 찾습니다.

### 2. Registry 비교
`docs/00-overview/registry.md`를 읽어 등록된 Feature 목록과 실제 파일을 비교합니다.

### 3. 누락 감지
각 Feature에 대해 다음을 grep으로 확인합니다:
- 도메인 문서: `grep -rl "F-XXX" docs/02-domains/`
- API 스펙: `grep -rl "F-XXX" docs/04-api/`
- 데이터 스키마: Feature PRD의 "관련 문서" 섹션에서 schema 링크 추출
- ADR: `grep -rl "F-XXX" docs/07-decisions/`

### 4. 도메인 인덱스 갱신
`docs/02-domains/` 하위 폴더를 스캔하여 도메인별 인덱스 테이블을 업데이트합니다.
- 각 도메인의 completion 상태 (skeleton / partial / complete)
- 관련 Feature 매핑

### 5. Registry 갱신
발견된 새 매핑을 `docs/00-overview/registry.md`에 추가합니다.

### 6. 리포트 출력
```
## Registry Sync Report

### New Features Found
- F-002: {title} — added to registry

### Updated Mappings
- F-001: added data_schemas entry

### Missing Documents
- F-002: no domain docs found
- F-002: no API spec found

### Domain Index Updated
| 도메인 | Features | 상태 |
|---|---|---|
| identity | F-001 | complete |
| payment | F-002 | skeleton |
```
