---
completion: skeleton
last_verified: 2026-04-16
---

# System Context (C4 Level 1)

> 우리 시스템과 외부 세계의 관계. 사용자, 외부 시스템과의 상호작용 범위.
> 작성 가이드: C4 Context Diagram + 설명.

## 시스템 컨텍스트 다이어그램

{UNSET: Mermaid C4 Context 다이어그램}

```mermaid
C4Context
    title System Context Diagram

    %% {UNSET: 아래 항목을 실제 시스템에 맞게 교체}
    Person(user, "사용자", "{UNSET: 사용자 설명}")
    System(system, "{UNSET: 시스템명}", "{UNSET: 시스템 설명}")
    System_Ext(extSystem, "{UNSET: 외부 시스템}", "{UNSET: 설명}")

    Rel(user, system, "Uses")
    Rel(system, extSystem, "Calls")
```

## 외부 시스템 목록

| 시스템 | 역할 | 통신 방식 | 의존도 |
|---|---|---|---|
| {UNSET} | {UNSET} | {UNSET} | {UNSET} |

## 관련 문서
- **상세 구조**: [Containers](./containers.md) (C4 Level 2)
- **아키텍처 개요**: [Overview](./overview.md)
