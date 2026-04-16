# SLA / SLO / SLI

> 서비스 수준 목표·지표·합의.
> 모든 기능은 어떤 SLO에 영향을 주는지 인지해야 함.

## 용어
- **SLI** (Service Level Indicator): 측정 가능한 지표
- **SLO** (Service Level Objective): 내부 목표
- **SLA** (Service Level Agreement): 외부와의 계약

## 가용성 (Availability)

| 등급 | SLO | 월간 허용 다운타임 |
|---|---|---|
| Critical (인증, 결제) | 99.95% | 21분 |
| Standard (핵심 API) | 99.9% | 43분 |
| Best-effort (분석, 리포트) | 99.5% | 3시간 36분 |

## 응답 시간 (Latency)

| API 카테고리 | p50 | p95 | p99 |
|---|---|---|---|
| 인증 | 50ms | 200ms | 500ms |
| 조회 | 100ms | 300ms | 1s |
| 쓰기 | 200ms | 500ms | 2s |
| 검색 | 300ms | 1s | 3s |

## 에러율 (Error Rate)
- 5xx 에러: < 0.1%
- 4xx 에러: 모니터링하되 SLO 아님 (클라이언트 책임)

## 데이터 내구성
- RPO (Recovery Point Objective): 1시간
- RTO (Recovery Time Objective): 4시간

## Error Budget
- 99.9% SLO → 월 0.1% (43분) 다운타임 허용
- Budget 초과 시: 신규 기능 배포 동결, 안정화 우선

## 측정
- 모니터링 도구에서 자동 계산
- 월간 리포트로 공유
- SLO 위반 시 자동 알림 + 포스트모템

## 관련 문서
- [모니터링](./monitoring.md)
- [장애 대응](./incident-response.md)
