---
name: trace-feature
description: 특정 Feature ID(F-XXX)의 모든 관련 문서를 추적하여 문서 간 관계를 시각화한다. 기능의 전체 문서 매핑을 한 눈에 파악할 수 있다.
user-invocable: true
argument-hint: "[F-XXX]"
allowed-tools: Read Grep Glob
---

# /trace-feature $ARGUMENTS

Feature `$1`의 전체 문서 추적 맵을 출력합니다.

## 절차

1. **Registry 확인**: `docs/00-overview/registry.md`를 읽어 해당 Feature의 매핑 정보를 확인합니다.

2. **Grep 보완**: Registry에 없는 참조도 있을 수 있으므로 추가 검색합니다:
```bash
grep -rl "$1" docs/
```

3. **각 문서 상태 확인**: 발견된 모든 파일의 frontmatter에서 `completion` 또는 `status` 필드를 읽습니다.

4. **관계 맵 출력**:

```
Feature Trace: $1
================================================

[PRD] docs/01-product/features/$1-*.md
  status: approved | completion: complete
  │
  ├─ [Domain] docs/02-domains/{domain}/
  │   ├── CLAUDE.md .............. complete
  │   ├── domain-model.md ....... complete
  │   ├── business-rules.md ..... skeleton
  │   └── edge-cases.md ......... skeleton
  │
  ├─ [API] docs/04-api/rest/{spec}.yaml
  │   └── completion: complete
  │
  ├─ [Events] docs/04-api/events/{events}.yaml
  │   └── completion: partial
  │
  ├─ [Schema] docs/05-data/schemas/{table}.md
  │   └── completion: complete
  │
  └─ [Decisions]
      ├── ADR-001 ............... accepted
      └── ADR-003 ............... accepted

Summary: 9 docs | 4 complete | 2 skeleton | 3 partial
```

5. **누락 감지**: PRD의 "관련 문서" 섹션에 있지만 실제 파일이 없는 경우 경고를 출력합니다.
