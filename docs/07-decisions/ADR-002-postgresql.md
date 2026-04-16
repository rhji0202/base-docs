---
id: ADR-002
title: PostgreSQL을 주 데이터베이스로 채택
status: accepted
date: 2026-01-15
deciders: [Tech Lead]
---

# ADR-002: PostgreSQL을 주 데이터베이스로 채택

## 맥락
주 데이터베이스를 선택해야 한다. 후보:
- PostgreSQL
- MySQL
- MongoDB
- DynamoDB

### 요구사항
- ACID 트랜잭션 (결제 도메인)
- 복잡한 조인·집계 쿼리
- JSON 컬럼 지원 (반정형 데이터)
- 풀텍스트 검색
- 매니지드 서비스로 운영 부담 감소

## 결정
**PostgreSQL 15를 주 DB로 채택한다.**
- 매니지드: AWS RDS / Aurora PostgreSQL
- 도메인별 스키마 분리 (`schema_identity`, `schema_payment`)

## 근거
- 강력한 ACID 보장
- JSONB로 NoSQL 유연성도 확보
- pg_trgm, tsvector로 검색 충분 (별도 검색엔진 불필요한 단계)
- 풍부한 확장 (PostGIS, pgvector 등)
- 팀 친숙도 높음

### 대안 기각 사유
- **MySQL**: 기능 차이 (CTE, JSON 지원), JSON 처리 약함
- **MongoDB**: 트랜잭션 보장 약함, 결제 도메인에 부적합
- **DynamoDB**: 복잡한 쿼리·집계 어려움, vendor lock-in

## 결과

### 긍정적
- 검증된 기술, 풍부한 자료
- 단일 DB로 운영 단순

### 부정적
- 수평 확장 어려움 → mitigation: 읽기 복제본, 향후 샤딩 검토
- 한 DB 장애가 전체 영향 → mitigation: Multi-AZ, 자동 failover

## 후속 조치
- [x] RDS 인스턴스 프로비저닝
- [x] 백업·복구 정책 수립 ([backup-recovery.md](../05-data/backup-recovery.md))
- [ ] 읽기 복제본 추가 (트래픽 증가 시)

## 참고
- [관련 ADR-001 Modular Monolith](./ADR-001-monolith-first.md)
