---
status: review
updated: 2026-06-24
---

# 사용자 로그인 백엔드

> 기획: [1-feat/F-001-user-login.md](../1-feat/F-001-user-login.md)
> 프론트 API 요구: [2-web/F-001-user-login.md](../2-web/F-001-user-login.md)

## API 엔드포인트
> 프론트의 "API 연동" 표를 구현 관점에서 확정.

### `POST /api/auth/login`
- **요청:** `{ email: string, password: string, rememberMe?: boolean }`
- **응답:** `{ access_token: string }`
- **검증:** email 형식, password 8자 이상, 5회 실패 잠금 체크
- **권한:** Public (인증 불필요)

## 데이터 모델
```
User
  id: string (PK)
  email: string (unique)
  password_hash: string
  login_attempts: number (default 0)
  locked_until: datetime?
  created_at: datetime
```

## 에러 처리
| 상황 | 코드 | 처리 |
|------|------|------|
| 이메일/비번 불일치 | 401 | 실패 카운트 증가, 5회 도달 시 잠금 |
| 계정 잠금 | 423 | locked_until 반환 |
| 이메일 없음 | 401 | "이메일 또는 비밀번호 불일치" (정보 노출 방지) |
| 서버 오류 | 500 | 로그 기록, 일반 에러 메시지 |
