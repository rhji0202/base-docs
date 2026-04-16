# 문서 템플릿

> 새 문서 작성 시 여기 템플릿을 복사해서 사용.

## 템플릿 목록

| 파일 | 용도 | 사용처 |
|---|---|---|
| [feature-template.md](./feature-template.md) | 기능 PRD | `docs/01-product/features/` |
| [adr-template.md](./adr-template.md) | 아키텍처 결정 | `docs/07-decisions/` |
| [rfc-template.md](./rfc-template.md) | 변경 제안 | `docs/08-rfcs/` |
| [domain-template.md](./domain-template.md) | 도메인 문서 | `docs/02-domains/{domain}/` |
| [runbook-template.md](./runbook-template.md) | 운영 매뉴얼 | `docs/06-operations/runbooks/` |
| [postmortem-template.md](./postmortem-template.md) | 인시던트 사후 분석 | (별도 폴더) |

## 사용법

```bash
# 새 기능 문서 만들기
cp docs/99-templates/feature-template.md docs/01-product/features/F-025-name.md

# 새 ADR 만들기
cp docs/99-templates/adr-template.md docs/07-decisions/ADR-010-title.md
```

## 템플릿 수정
- 템플릿 자체를 개선하는 PR 환영
- 큰 변경은 팀 합의 필요
