---
completion: skeleton
last_verified: 2026-04-16
---

# Identity Domain - Edge Cases

> 예외 상황과 경계 조건 처리 정책.
> 정상 흐름은 [domain-model.md](./domain-model.md)와 [workflows/](./workflows/)에 정의.

## 가입 관련

| 시나리오 | 처리 정책 |
|---|---|
| 이미 존재하는 이메일로 가입 시도 | 409 Conflict 반환 |
| 탈퇴(deactivated) 이메일로 재가입 | {UNSET: 허용? 새 계정? 복구?} |
| 인증 메일 미도착 | {UNSET: 재발송 정책, 제한} |

## 인증 관련

| 시나리오 | 처리 정책 |
|---|---|
| 5회 연속 로그인 실패 | 계정 잠금 (locked_until 설정) |
| 만료된 JWT로 요청 | 401 Unauthorized |
| Refresh Token 탈취 의심 | {UNSET: Token Rotation / 전체 세션 무효화} |

## 동시성 관련

| 시나리오 | 처리 정책 |
|---|---|
| 동시 비밀번호 변경 요청 | {UNSET: Optimistic Lock / Last-write-wins} |
| 동시 세션 수 초과 | {UNSET: 가장 오래된 세션 종료 / 신규 거부} |

## 관련 문서
- **도메인 모델**: [Domain Model](./domain-model.md)
- **비즈니스 규칙**: [Business Rules](./business-rules.md)
- **API 에러 코드**: [Error Codes](../../04-api/error-codes.md)
