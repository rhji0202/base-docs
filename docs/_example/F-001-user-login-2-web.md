---
status: review
updated: 2026-06-24
---

# 사용자 로그인 프론트엔드

> 기획: [1-feat/F-001-user-login.md](../1-feat/F-001-user-login.md)

## 화면
| 화면 | 경로 | 핵심 요소 |
|------|------|-----------|
| 로그인 | `/login` | 이메일 input, 비밀번호 input, 로그인 버튼, Remember Me 체크박스 |

## API 연동
> 이 표가 곧 백엔드 설계의 입력입니다.

| 동작 | 메서드/경로 | 요청 | 응답 |
|------|------------|------|------|
| 로그인 | `POST /api/auth/login` | `{ email, password, rememberMe }` | `{ access_token }` |

## 상태별 UI
- **로딩:** 버튼에 스피너 + "로그인 중..."
- **빈 상태:** 해당 없음
- **에러:** 입력창 아래 빨간색 메시지 (이메일/비번 불일치, 계정 잠금)

## 다음 단계
- 백엔드 설계: [3-api/F-001-user-login.md](../3-api/F-001-user-login.md)
