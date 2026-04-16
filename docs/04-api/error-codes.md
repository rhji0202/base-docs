# 표준 에러 코드

> 모든 API에서 공통으로 사용하는 에러 코드 카탈로그.
> 새 에러 코드 추가 시 이 문서에 등록 필수.

## 형식
- 코드: `SCREAMING_SNAKE_CASE`
- 도메인 prefix: `AUTH_`, `PAYMENT_`, `USER_` 등

## 공통 에러

| 코드 | HTTP | 설명 |
|---|---|---|
| `INVALID_REQUEST` | 400 | 요청 형식 오류 |
| `VALIDATION_FAILED` | 422 | 입력값 검증 실패 |
| `UNAUTHORIZED` | 401 | 인증 토큰 없음/무효 |
| `FORBIDDEN` | 403 | 권한 부족 |
| `NOT_FOUND` | 404 | 리소스 없음 |
| `CONFLICT` | 409 | 리소스 상태 충돌 |
| `RATE_LIMITED` | 429 | 요청 한도 초과 |
| `INTERNAL_ERROR` | 500 | 서버 내부 오류 |
| `SERVICE_UNAVAILABLE` | 503 | 일시적 장애 |

## 인증 도메인 (AUTH_*)

| 코드 | HTTP | 설명 |
|---|---|---|
| `AUTH_INVALID_CREDENTIALS` | 401 | 이메일/비밀번호 불일치 |
| `AUTH_TOKEN_EXPIRED` | 401 | 토큰 만료 |
| `AUTH_TOKEN_INVALID` | 401 | 토큰 형식 오류 |
| `AUTH_ACCOUNT_LOCKED` | 423 | 계정 잠금 (5회 실패) |
| `AUTH_EMAIL_NOT_VERIFIED` | 403 | 이메일 미인증 |

## 사용자 도메인 (USER_*)

| 코드 | HTTP | 설명 |
|---|---|---|
| `USER_NOT_FOUND` | 404 | 사용자 없음 |
| `USER_ALREADY_EXISTS` | 409 | 이메일 중복 |
| `USER_DEACTIVATED` | 403 | 탈퇴 계정 |
| `USER_WEAK_PASSWORD` | 422 | 비밀번호 강도 부족 |

## 결제 도메인 (PAYMENT_*)

| 코드 | HTTP | 설명 |
|---|---|---|
| `PAYMENT_DECLINED` | 402 | 결제 거절 |
| `PAYMENT_INSUFFICIENT_FUNDS` | 402 | 잔액 부족 |
| `PAYMENT_GATEWAY_ERROR` | 502 | PG사 오류 |
| `PAYMENT_DUPLICATE` | 409 | 중복 결제 시도 |

## 클라이언트 처리 가이드
- `4xx`: 사용자에게 메시지 표시, 재시도 무의미
- `429`: `Retry-After` 헤더 따라 백오프 후 재시도
- `5xx`: 지수 백오프로 재시도 (멱등 API만)
- `502/503/504`: 자동 재시도 권장 (3회 한도)
