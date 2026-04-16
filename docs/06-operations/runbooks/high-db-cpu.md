# Runbook: 높은 DB CPU 사용률

> **언제 사용**: DB CPU가 80% 이상 5분 이상 지속될 때
> **예상 소요**: 15~30분
> **책임자**: 온콜 엔지니어 → 필요 시 DBA 에스컬레이션

## 증상 확인
- [ ] 알림 출처 확인 (Grafana, Datadog 등)
- [ ] 영향 범위 파악: API 응답 시간, 에러율
- [ ] 사용자 영향 확인 (status 페이지 갱신 여부)

## 즉시 조치 (5분 이내)

### 1. 트래픽 확인
```bash
# 최근 1시간 RPS
curl -s monitoring-url | grep request_rate
```
- 비정상 트래픽 폭증인가? → DDoS/봇 의심 → Rate Limit 강화
- 정상 트래픽인가? → 쿼리 문제 의심 → 다음 단계

### 2. 슬로우 쿼리 식별
```sql
SELECT pid, query_start, state, query
FROM pg_stat_activity
WHERE state = 'active'
  AND query_start < NOW() - INTERVAL '10 seconds'
ORDER BY query_start;
```

### 3. 락 확인
```sql
SELECT * FROM pg_locks WHERE NOT granted;
```

## 임시 대응

### 슬로우 쿼리 종료
```sql
SELECT pg_cancel_backend(pid);  -- 부드럽게
SELECT pg_terminate_backend(pid);  -- 강제 (주의)
```

### 신규 연결 차단 (최후 수단)
- 영향: 신규 요청 모두 실패
- 승인: Tech Lead 이상

## 근본 원인 조사

### 새로 배포된 코드?
```bash
git log --since="2 hours ago" --oneline
```
- 의심되는 PR 식별 → 롤백 검토

### 통계 정보 갱신
```sql
ANALYZE table_name;
```

### 인덱스 누락
```sql
EXPLAIN ANALYZE [문제 쿼리];
```

## 사후 작업
- [ ] 인시던트 티켓 생성
- [ ] 포스트모템 일정 잡기
- [ ] 슬로우 쿼리 → 백로그 등록
- [ ] 알림 임계치 적정성 검토

## 에스컬레이션
- 30분 내 해결 안 되면 → DBA
- 사용자 영향 큼 → Tech Lead + Product
- 데이터 손상 의심 → 전원 소집 (P0)

## 관련 문서
- [모니터링](../monitoring.md)
- [장애 대응 프로세스](../incident-response.md)
