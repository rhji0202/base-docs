# 문서 디렉토리 가이드

이 문서는 `docs/` 내 모든 문서의 작성·관리 규칙입니다.

## 폴더별 역할

| 폴더 | 책임 영역 | 주요 작성자 |
|---|---|---|
| `00-overview/` | 프로젝트 전체 컨텍스트 | PM, Tech Lead |
| `01-product/` | 무엇을 만들 것인가 (What) | PM, Designer |
| `02-domains/` | 비즈니스 로직 (Why/How) | Domain Expert, Dev |
| `03-architecture/` | 시스템이 어떻게 동작하는가 | Architect, Tech Lead |
| `04-api/` | 외부/내부 인터페이스 계약 | Backend Dev |
| `05-data/` | 데이터 모델·흐름 | Data Engineer, Dev |
| `06-operations/` | 운영·배포·장애 대응 | DevOps, SRE |
| `07-decisions/` | 결정 기록 (불변) | All |
| `08-rfcs/` | 진행 중인 제안 | All |
| `09-guides/` | 개발 컨벤션·가이드 | Tech Lead |
| `99-templates/` | 모든 문서 템플릿 | Tech Lead |

## 문서 작성 5가지 원칙

### 1. 한 파일 = 한 주제
한 파일이 400줄을 넘으면 분할을 고려하세요. Claude Code의 컨텍스트 효율과 직결됩니다.

### 2. 첫 3줄 규칙
모든 문서는 첫 3줄에 다음을 명시:
- 무엇에 관한 문서인가
- 누가 언제 읽어야 하는가
- 마지막 갱신일

### 3. ID 체계 일관성
- Feature: `F-001` ~ `F-999`
- ADR: `ADR-001` ~ `ADR-999`
- RFC: `RFC-001` ~ `RFC-999`
- 파일명: `F-001-user-authentication.md` (ID-kebab-case)

### 4. 상호 참조는 상대 경로
```markdown
관련: [F-002 결제](../01-product/features/F-002-payment.md)
참조: [ADR-005 DB 선택](../07-decisions/ADR-005-database-choice.md)
```

### 5. 다이어그램은 Mermaid/PlantUML
Figma 링크 금지 (Claude가 못 읽음). 텍스트 기반 다이어그램만 사용.

## 문서 수명 주기

```
[작성] → [리뷰] → [승인/머지] → [유지보수] → [Deprecated/Archive]
```

- **상태**: `draft`, `review`, `approved`, `deprecated` 중 하나를 frontmatter에 명시
- **Deprecated**: 삭제하지 말고 `_archive/` 폴더로 이동, 대체 문서 링크 명시

## 검색 친화적으로 쓰기

Claude Code가 grep으로 빠르게 찾을 수 있도록:
- 키워드는 본문에 자연스럽게 포함
- 동의어 함께 명시 (예: "결제 / Payment / Billing")
- 목차(TOC)를 긴 문서에 추가
