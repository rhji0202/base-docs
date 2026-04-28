---
name: new-domain
description: 새 DDD 도메인 폴더 구조를 일괄 생성한다. CLAUDE.md, domain-model.md, business-rules.md, edge-cases.md, workflows/ 디렉토리를 한 번에 스캐폴딩한다.
user-invocable: true
argument-hint: "[도메인명]"
allowed-tools: Read Grep Glob Write Edit Bash(mkdir *)
---

# /new-domain $ARGUMENTS

새 DDD 도메인의 전체 폴더 구조를 생성합니다.

## 절차

1. **중복 확인**: `docs/02-domains/` 하위에 동일 이름의 도메인이 이미 있는지 확인합니다.

2. **추천 도메인 대조**: `docs/02-domains/CLAUDE.md`의 추천 도메인 목록과 대조하여, 기존 추천에 해당하는지 확인합니다.

3. **worked example 로드**: `docs/02-domains/identity/` 전체를 읽어 패턴을 파악합니다.

4. **폴더 구조 생성**:
```
docs/02-domains/$1/
├── CLAUDE.md             ← 도메인 개요 (docs/99-templates/domain-template.md 기반)
├── domain-model.md       ← completion: skeleton
├── business-rules.md     ← completion: skeleton
├── edge-cases.md         ← completion: skeleton
└── workflows/            ← .gitkeep
```

5. **CLAUDE.md 작성**: 사용자에게 다음을 질문합니다:
   - 이 도메인의 책임 범위는?
   - 핵심 개념 (Aggregate, Entity, Value Object)은?
   - 다른 도메인과의 의존성은?
   - 발행할 도메인 이벤트는?

6. **skeleton 파일 생성**: `domain-model.md`, `business-rules.md`, `edge-cases.md`는 기본 구조만 생성하고 `completion: skeleton` 마커를 설정합니다.

7. **레지스트리 갱신**: `docs/00-overview/registry.md` 도메인별 인덱스에 새 도메인 추가합니다.

## 명명 규칙
- 도메인 폴더명: lowercase, 하이픈 구분 (`payment`, `order-management`)
- 파일명: 고정 (`CLAUDE.md`, `domain-model.md`, `business-rules.md`, `edge-cases.md`)
