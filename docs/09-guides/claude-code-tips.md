# Claude Code 활용 가이드

> 이 문서 구조를 Claude Code와 함께 효과적으로 사용하는 방법.

## 컨텍스트 효율 극대화

### 1. 작업 시작 시 명시적으로 컨텍스트 지정
```
"docs/01-product/features/F-001-user-authentication.md를 읽고 구현 시작해줘"
"docs/02-domains/identity/CLAUDE.md를 먼저 읽고 작업해줘"
```
이렇게 명시하면 Claude가 불필요한 파일을 탐색하지 않음.

### 2. 작업 유형별 컨텍스트 패턴

**새 기능 구현**
```
1. docs/01-product/features/F-XXX-*.md (요구사항)
2. docs/02-domains/{domain}/CLAUDE.md (도메인)
3. docs/04-api/{관련 API} (계약)
4. docs/05-data/schemas/{관련 테이블} (스키마)
```

**버그 수정**
```
1. 관련 코드 파일
2. docs/02-domains/{domain}/business-rules.md (규칙 위반 여부 확인)
3. docs/02-domains/{domain}/edge-cases.md
```

**아키텍처 변경**
```
1. docs/03-architecture/overview.md
2. docs/07-decisions/INDEX.md (관련 ADR 검색)
3. 영향받는 docs/02-domains/*/
```

## 자주 쓰는 프롬프트 패턴

### 기능 PRD 생성
```
"docs/99-templates/feature-template.md를 사용해서
F-XXX [기능명]에 대한 PRD를 작성해줘.
배경: ...
사용자 스토리: ..."
```

### ADR 작성
```
"우리가 [X 기술]을 [Y 기술] 대신 선택했어.
docs/99-templates/adr-template.md를 써서
ADR-XXX를 작성해줘. 다음 맥락 고려해서: ..."
```

### 도메인 모델 추출
```
"docs/01-product/features/F-XXX.md를 읽고
docs/02-domains/{domain}/domain-model.md에 추가할
엔티티·값객체·애그리게이트를 제안해줘"
```

## Claude Code가 잘 작동하는 문서 작성법

### ✅ 좋은 패턴
- 짧고 명확한 섹션
- 코드 블록에 언어 명시
- Mermaid 다이어그램 사용
- ID 일관성 (F-001, ADR-005)
- 상호 참조 (상대 경로 링크)

### ❌ 피할 패턴
- 한 파일 1000줄+ (분할할 것)
- 이미지로만 표현된 다이어그램
- "여기 참조" 같은 모호한 링크
- 외부 도구 의존 (Notion, Confluence) — repo 안에 두기

## 컨텍스트 오염 방지

### .claudeignore 설정 예시
```
node_modules/
dist/
build/
.next/
*.log
*.lock
coverage/
docs/_archive/
```

### 큰 파일은 분할
- OpenAPI 스펙은 도메인별 분리
- 거대한 README는 섹션별 분리
- 변경 이력은 별도 CHANGELOG.md로

## 자동화 추천

### Pre-commit 훅
- 마크다운 린트
- 깨진 링크 검사
- frontmatter 형식 검증

### CI 검사
- 새 기능 PR에 PRD 파일 존재 여부
- ADR 형식 검증
- OpenAPI 스펙 유효성

## 안티패턴

### ❌ 모든 것을 CLAUDE.md에 넣기
CLAUDE.md는 **인덱스**이지 백과사전이 아님. 상세는 분리.

### ❌ 코드와 문서 동기화 무시
스키마 변경 PR에 docs/05-data/schemas/ 갱신 누락 — 코드 리뷰에서 거부.

### ❌ 외부 링크 의존
Notion 페이지, Figma 링크에 핵심 정보 두기 — Claude가 못 읽음.
