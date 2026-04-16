# Feature Registry (기능-문서 매핑)

> 각 기능(Feature)이 프로젝트 전체에서 어디에 문서화되어 있는지 추적하는 중앙 레지스트리.
> 분산된 "관련 문서" 섹션의 **SSOT (Single Source of Truth)**.
> 마지막 갱신: 2026-04-16

## 사용법

```bash
# 특정 기능의 모든 관련 문서 확인
grep -r "F-001" docs/

# 이 레지스트리로 한 눈에 확인
# 아래 YAML 블록에서 해당 Feature ID 검색
```

---

## Feature Map

```yaml
F-001:
  title: User Authentication
  status: approved
  domain: identity
  feature_spec: 01-product/features/F-001-user-authentication.md
  domain_docs:
    - 02-domains/identity/CLAUDE.md
    - 02-domains/identity/domain-model.md
    - 02-domains/identity/business-rules.md
    - 02-domains/identity/edge-cases.md
  api_specs:
    - 04-api/rest/auth.yaml
  event_schemas:
    - 04-api/events/identity-events.yaml
  data_schemas:
    - 05-data/schemas/users.md
  adrs:
    - 07-decisions/ADR-001-monolith-first.md
    - 07-decisions/ADR-003-auth-strategy.md
  code_paths:
    - src/domains/identity/

# F-002:
#   title: {UNSET}
#   status: draft
#   domain: {UNSET}
#   feature_spec: 01-product/features/F-002-{UNSET}.md
#   domain_docs: []
#   api_specs: []
#   data_schemas: []
#   adrs: []
#   code_paths: []
```

---

## 도메인별 인덱스

| 도메인 | 관련 Features | 도메인 문서 | 상태 |
|---|---|---|---|
| identity | F-001 | `02-domains/identity/` | complete |
| payment | {UNSET} | `02-domains/payment/` | skeleton |
| catalog | {UNSET} | `02-domains/catalog/` | skeleton |
| order | {UNSET} | `02-domains/order/` | skeleton |
| notification | {UNSET} | `02-domains/notification/` | skeleton |

---

## 관련 문서
- **기능 목록**: [Features INDEX](../01-product/features/INDEX.md)
- **ADR 목록**: [Decisions INDEX](../07-decisions/INDEX.md)
- **도메인 가이드**: [Domains CLAUDE.md](../02-domains/CLAUDE.md)
