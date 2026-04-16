---
completion: skeleton
last_verified: 2026-04-16
---

# Monitoring & Alerting

> 시스템 모니터링 전략과 알림 정책.

## 모니터링 스택

| 영역 | 도구 | 용도 |
|---|---|---|
| Logs | {UNSET} | 애플리케이션 로그 수집 |
| Metrics | {UNSET} | 시스템/비즈니스 메트릭 |
| Traces | {UNSET} | 분산 추적 |
| Errors | {UNSET} | 에러 수집/알림 |
| Uptime | {UNSET} | 가용성 모니터링 |

## 핵심 메트릭

### 시스템 메트릭
- CPU / Memory / Disk usage
- Request rate / Error rate / Duration (RED)

### 비즈니스 메트릭
- {UNSET: 핵심 비즈니스 지표}

## 알림 정책

| 조건 | 등급 | 채널 | 대응 |
|---|---|---|---|
| Error rate > 5% | P1 | {UNSET} | 온콜 호출 |
| Response p95 > 2s | P2 | {UNSET} | 조사 |
| DB CPU > 80% | P2 | {UNSET} | [런북](./runbooks/high-db-cpu.md) |

## 대시보드

| 대시보드 | URL | 용도 |
|---|---|---|
| System Overview | {UNSET} | 전체 시스템 상태 |
| API Performance | {UNSET} | API 응답 시간/에러율 |

## 관련 문서
- **SLA/SLO**: [SLA](./sla.md)
- **장애 대응**: [Incident Response](./incident-response.md)
- **기술 스택**: [Tech Stack](../03-architecture/tech-stack.md)
