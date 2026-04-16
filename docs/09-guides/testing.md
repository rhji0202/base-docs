---
completion: skeleton
last_verified: 2026-04-16
---

# Testing Strategy

> 테스트 유형, 커버리지 기준, 실행 방법.

## 테스트 피라미드

| 유형 | 비중 | 도구 | 실행 시점 |
|---|---|---|---|
| Unit | 70% | {UNSET} | 커밋 전 |
| Integration | 20% | {UNSET} | PR |
| E2E | 10% | {UNSET} | 배포 전 |

## 커버리지 기준
- 신규 코드: {UNSET: 최소 커버리지 %}
- 전체: {UNSET: 최소 커버리지 %}

## 테스트 명명
- `should_X_when_Y` 패턴
- 예: `should_return_401_when_token_expired`

## 관련 문서
- **코딩 표준**: [Coding Standards](./coding-standards.md)
- **CI/CD**: [Deployment](../06-operations/deployment.md)
