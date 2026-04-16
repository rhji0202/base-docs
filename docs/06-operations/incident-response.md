---
completion: skeleton
last_verified: 2026-04-16
---

# Incident Response Process

> 장애 발생 시 대응 절차. 감지 → 분류 → 대응 → 복구 → 사후 분석.

## 장애 등급

| 등급 | 정의 | 대응 시간 |
|---|---|---|
| P0 | 전체 서비스 중단 | {UNSET} |
| P1 | 핵심 기능 장애 | {UNSET} |
| P2 | 부분 기능 장애 | {UNSET} |
| P3 | 경미한 이슈 | {UNSET} |

## 대응 절차

### 1. 감지 (Detection)
{UNSET: 모니터링 알림, 사용자 신고 등}

### 2. 분류 (Triage)
{UNSET: 장애 등급 판단 기준}

### 3. 대응 (Response)
{UNSET: 온콜 담당자 호출, 커뮤니케이션 채널}

### 4. 복구 (Recovery)
{UNSET: 런북 실행, 롤백 절차}

### 5. 사후 분석 (Post-mortem)
- P0/P1: 포스트모템 필수 (48시간 이내)
- 템플릿: [postmortem-template.md](../99-templates/postmortem-template.md)
- 원칙: **Blameless** — 사람이 아닌 시스템을 고친다

## 에스컬레이션

| 조건 | 대상 |
|---|---|
| {UNSET} | {UNSET} |

## 관련 문서
- **SLA/SLO**: [SLA](./sla.md)
- **런북**: [Runbooks](./runbooks/)
- **모니터링**: [Monitoring](./monitoring.md)
- **배포**: [Deployment](./deployment.md)
