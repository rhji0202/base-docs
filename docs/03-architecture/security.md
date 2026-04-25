---
completion: skeleton
last_verified: 2026-04-16
---

# Security Model

> 시스템의 보안 아키텍처. 인증, 인가, 데이터 보호, 네트워크 보안.

## 인증 (Authentication)
- 방식: JWT (Access Token + Refresh Token)
- 결정 근거: _(관련 ADR 작성 필요)_
- 상세: _(관련 도메인)_

## 인가 (Authorization)
- 모델: {UNSET: RBAC / ABAC / 기타}
- 역할 목록: {UNSET}
- 권한 체계: {UNSET}

## 데이터 보호
- 비밀번호 해싱: Argon2id
- 전송 암호화: TLS 필수 (Plain HTTP 금지)
- 저장 암호화: {UNSET}
- PII 분류: _(관련 스키마)_

## 네트워크 보안
- {UNSET: 방화벽, VPC, WAF 등}

## OWASP Top 10 대응
| 위협 | 대응 |
|---|---|
| Injection | {UNSET} |
| Broken Auth | JWT + Refresh Token Rotation |
| XSS | {UNSET} |
| CSRF | {UNSET} |

## 관련 문서
- **인증 결정**: _(관련 ADR 작성 필요)_
- **사용자 데이터**: _(관련 스키마)_
- **인프라 보안**: [Infrastructure](./infrastructure.md)
