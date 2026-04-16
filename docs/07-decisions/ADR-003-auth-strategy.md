---
id: ADR-003
title: JWT 기반 인증 채택
status: accepted
date: 2026-02-01
deciders: [Tech Lead, Security]
---

# ADR-003: JWT 기반 인증 채택

## 맥락
인증 토큰 방식을 결정해야 한다. 후보:
- Server-side Session (Redis 저장)
- JWT (Stateless)
- Hybrid (JWT + Refresh Token)

### 요구사항
- 모바일·웹 다중 클라이언트 지원
- 수평 확장 가능 (서비스 인스턴스 무상태)
- 토큰 즉시 무효화 가능 (보안)

## 결정
**Hybrid 방식 채택**:
- **Access Token**: JWT, 1시간 유효, Stateless 검증
- **Refresh Token**: Opaque token, Redis 저장, 30일 유효
- 로그아웃 시 Refresh Token만 즉시 무효화

## 근거

### Pure Session 대비 장점
- API 서버 무상태 → 수평 확장 자유
- 모든 요청에서 DB/Redis 조회 불필요 (Access Token)

### Pure JWT 대비 장점
- Refresh Token으로 즉시 무효화 가능
- Access Token 짧게 유지 → 탈취 영향 최소화

### 대안 기각
- **Pure Session**: 매 요청 Redis 조회 → 지연·확장성 저하
- **Pure JWT**: 즉시 무효화 어려움 → 보안 사고 시 대응 곤란

## 결과

### 긍정적
- 성능과 보안의 균형
- 표준 프로토콜 (JWT, OAuth2)

### 부정적
- 두 토큰 관리 복잡도 → mitigation: 클라이언트 SDK 제공
- JWT 페이로드 노출 위험 → mitigation: 민감 정보 미포함

## 구현 세부

### Access Token
- 알고리즘: RS256 (asymmetric)
- 페이로드: `sub`, `roles`, `exp`, `iat`
- 저장: 메모리 (XSS 방어)

### Refresh Token
- 형식: 256bit random string
- 저장: httpOnly Secure Cookie
- DB: Redis with TTL

## 후속 조치
- [x] 키 페어 생성·관리 절차
- [x] Refresh Token 회전(rotation) 구현
- [ ] 토큰 모니터링 대시보드

## 참고
- [F-001 사용자 인증](../01-product/features/F-001-user-authentication.md)
- [security.md](../03-architecture/security.md)
