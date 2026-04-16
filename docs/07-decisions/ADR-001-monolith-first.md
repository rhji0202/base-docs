---
id: ADR-001
title: Modular Monolith로 시작
status: accepted
date: 2026-01-15
deciders: [Tech Lead, CTO]
---

# ADR-001: Modular Monolith로 시작

## 맥락 (Context)

프로젝트 초기 단계에서 시스템 아키텍처 스타일을 결정해야 한다.
주요 선택지는 다음과 같다:
- Monolith (단일 코드베이스, 단일 배포 단위)
- Modular Monolith (단일 배포, 도메인 모듈 분리)
- Microservices (도메인별 독립 배포)

### 제약 조건
- 팀 규모: 3명
- 기간: MVP 6개월 내 출시
- 도메인: 안정화되지 않음 (5개 도메인 후보 중 경계 불확실)
- 운영 인력: 별도 SRE 없음

## 결정 (Decision)

**Modular Monolith를 채택한다.**

구체적으로:
- 단일 코드베이스, 단일 배포 단위
- 코드는 도메인별 모듈로 엄격히 분리 (`src/domains/{domain}/`)
- 도메인 간 직접 호출 금지, **인터페이스 통한 호출만** 허용
- 도메인별로 자체 DB 스키마 분리 (`schema_identity`, `schema_payment` 등)
- 향후 마이크로서비스로 분리 가능한 구조 유지

## 근거 (Rationale)

### Monolith 대비 장점
- 도메인 경계가 코드에 명시됨 → 미래 분리 용이
- 도메인별 책임이 명확 → 신규 멤버 온보딩 빠름

### Microservices 대비 장점
- 운영 복잡도 낮음 (단일 배포, 단일 모니터링)
- 트랜잭션 일관성 보장 용이
- 분산 시스템 디버깅 비용 없음
- 인프라 비용 낮음
- 3명 팀에 적합

## 결과 (Consequences)

### 긍정적
- 빠른 MVP 출시
- 도메인 경계 실험 자유
- 운영 단순

### 부정적
- 한 도메인의 장애가 전체에 영향 가능
- 도메인별 독립 확장 불가
- 모듈 경계가 흐려질 위험 → **mitigation**: 모듈 의존성 린트 도구 도입

## 마이크로서비스 분리 트리거
다음 중 하나 충족 시 분리 검토:
- 팀 규모 15명 초과
- 특정 도메인의 배포 빈도가 다른 도메인의 10배 이상
- 도메인별 확장 요구가 크게 다름

## 대안과 기각 사유
- **Pure Monolith**: 도메인 경계 없음 → 6개월 후 빅볼오브머드 위험
- **Microservices**: 운영 오버헤드 > 이점, 팀 규모 부적합

## 참고
- [Modular Monoliths - Simon Brown](https://www.youtube.com/watch?v=5OjqD-ow8GE)
- 관련 ADR: [ADR-002 PostgreSQL 단일 DB](./ADR-002-postgresql.md)
