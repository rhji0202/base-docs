---
completion: skeleton
last_verified: 2026-04-16
---

# Data Flow

> 시스템 내 데이터의 이동 경로. 동기/비동기 흐름 모두 포함.

## 동기 흐름 (Request-Response)

{UNSET: 주요 API 요청의 데이터 흐름 다이어그램}

## 비동기 흐름 (Event-Driven)

{UNSET: 이벤트 기반 데이터 흐름 다이어그램}

## 데이터 흐름 요약

| 출발점 | 도착점 | 방식 | 데이터 |
|---|---|---|---|
| Client | API Gateway | HTTPS | 요청 |
| API | Database | TCP | 쿼리/커맨드 |
| API | Cache | TCP | 세션/핫 데이터 |
| Domain | Queue | {UNSET} | 도메인 이벤트 |

## 관련 문서
- **아키텍처 개요**: [Overview](./overview.md)
- **이벤트 스키마**: [Events](../04-api/events/)
- **보안 고려사항**: [Security](./security.md)
