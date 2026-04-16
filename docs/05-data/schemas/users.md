# users 테이블

> 사용자 계정 마스터 테이블.
> 도메인: `identity`

## 스키마

```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(320) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'pending',
    display_name    VARCHAR(100),
    locale          VARCHAR(10) DEFAULT 'ko-KR',
    last_login_at   TIMESTAMPTZ,
    failed_login_count INTEGER DEFAULT 0,
    locked_until    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT users_email_unique UNIQUE (email) WHERE deleted_at IS NULL,
    CONSTRAINT users_status_check CHECK (status IN ('pending','active','suspended','deactivated'))
);

CREATE INDEX idx_users_email_active ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
```

## 컬럼 설명

| 컬럼 | 타입 | 설명 | 분류 |
|---|---|---|---|
| id | UUID | 사용자 식별자 | Internal |
| email | VARCHAR | 로그인 이메일 (유니크) | **PII** |
| password_hash | VARCHAR | Argon2id 해시 | **Restricted** |
| status | VARCHAR | 계정 상태 | Internal |
| display_name | VARCHAR | 표시 이름 | Confidential |
| locale | VARCHAR | 언어 설정 | Public |
| last_login_at | TIMESTAMPTZ | 마지막 로그인 시각 | Internal |
| failed_login_count | INTEGER | 연속 실패 횟수 | Internal |
| locked_until | TIMESTAMPTZ | 잠금 해제 시각 | Internal |
| created_at | TIMESTAMPTZ | 가입 시각 | Internal |
| updated_at | TIMESTAMPTZ | 수정 시각 | Internal |
| deleted_at | TIMESTAMPTZ | Soft delete 시각 | Internal |

## 불변 조건
- `email`은 `deleted_at IS NULL`인 행에서만 유니크
- `failed_login_count >= 5`이면 `locked_until` 설정 필수
- `status = 'pending'`인 사용자는 로그인 불가

## 관련 테이블
- `sessions` : 활성 세션 (1:N)
- `user_roles` : 권한 매핑 (N:M)
- `user_profiles` : 확장 프로필 (1:1)

## 데이터 보존 정책
- `deactivated` 상태 30일 후 PII 마스킹 (이메일 → `deleted-{id}@example.com`)
- 5년 후 완전 삭제 (법적 요구 없을 시)

## 접근 권한
- 일반 서비스: SELECT, INSERT, UPDATE
- 분석 시스템: 마스킹된 뷰만 (`users_anonymized`)
- 운영자: 직접 접근 금지, 관리자 콘솔 경유

## 관련 문서
- 도메인: [identity](../../02-domains/identity/)
- 기능: [F-001 인증](../../01-product/features/F-001-user-authentication.md)
