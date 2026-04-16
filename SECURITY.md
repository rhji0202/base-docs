# Security Policy

## Reporting a Vulnerability

이 프로젝트에서 보안 취약점을 발견하셨다면, **공개 이슈로 등록하지 마세요.**

### 신고 방법

| 방법 | 연락처 |
|---|---|
| 이메일 | {UNSET: security@your-domain.com} |
| GitHub Private Vulnerability | 이 저장소의 "Security" 탭 → "Report a vulnerability" |

### 신고 포함 정보
- 취약점 유형 (예: SQL Injection, XSS, 인증 우회)
- 영향받는 파일/경로/엔드포인트
- 재현 단계 (가능한 상세하게)
- 잠재적 영향 범위
- (선택) 수정 제안

### 응답 기한

| 항목 | SLA |
|---|---|
| 접수 확인 | 24시간 이내 |
| 초기 평가 | 72시간 이내 |
| 수정 배포 (Critical) | 7일 이내 |
| 수정 배포 (High) | 30일 이내 |

---

## Supported Versions

| 버전 | 지원 상태 |
|---|---|
| latest (main branch) | 보안 업데이트 지원 |
| 이전 버전 | 지원 종료 |

---

## Security Architecture

상세 보안 모델은 [docs/03-architecture/security.md](docs/03-architecture/security.md)를 참조하세요.

### 인증 (Authentication)
- **방식**: JWT Access Token + Opaque Refresh Token (Hybrid)
- **Access Token**: RS256, 1시간 유효, Stateless 검증
- **Refresh Token**: 256bit random, httpOnly Secure Cookie, Redis 저장, 30일 유효
- **결정 근거**: [ADR-003](docs/07-decisions/ADR-003-auth-strategy.md)

### 데이터 보호
- **비밀번호 해싱**: Argon2id (MD5, bcrypt 외 사용 금지)
- **전송 암호화**: TLS 필수 (Plain HTTP 금지)
- **PII 분류**: 모든 데이터 컬럼에 분류 태그 (PII / Restricted / Confidential / Internal / Public)
- **Soft Delete**: 물리 삭제 대신 `deleted_at` 컬럼 사용, 탈퇴 후 30일 PII 마스킹, 5년 후 완전 삭제

### 금지 기술
- MD5 (해싱은 Argon2id만)
- Plain HTTP (모든 통신 TLS)
- 환경변수/시크릿 코드 하드코딩

---

## Development Security Practices

### 코드 작성 시
- 환경변수/시크릿을 코드에 하드코딩 금지
- SQL은 prepared statement만 사용
- 입력은 검증, 출력은 escape
- 부작용 있는 API에 `Idempotency-Key` 헤더 필수

### 의존성 관리
- 정기적으로 `npm audit` / `pip audit` 실행
- Critical/High 취약점은 즉시 패치
- 사용하지 않는 의존성 제거

### 시크릿 관리
- `.env`, `.env.local`, `.env.*.local` 파일은 `.gitignore`에 포함
- `.claude/settings.local.json`은 `.gitignore`에 포함
- API 키, 토큰, 비밀번호는 절대 커밋하지 않음
- 실수로 커밋한 시크릿은 즉시 로테이션

### 코드 리뷰
- 보안 관련 변경은 반드시 리뷰어 1명 이상 승인
- OWASP Top 10 체크리스트 확인
- 새 API 엔드포인트는 인증/인가 검증 필수

---

## Incident Response

보안 인시던트 발생 시 [docs/06-operations/incident-response.md](docs/06-operations/incident-response.md)의 절차를 따릅니다.

| 등급 | 정의 | 대응 |
|---|---|---|
| P0 | 데이터 유출, 인증 우회 | 즉시 대응, 24시간 내 포스트모템 |
| P1 | 권한 상승, 정보 노출 | 24시간 내 대응 |
| P2 | 잠재적 취약점 발견 | 스프린트 내 수정 |

---

## 관련 문서
- [Security Model](docs/03-architecture/security.md) — 보안 아키텍처 상세
- [ADR-003 JWT Auth](docs/07-decisions/ADR-003-auth-strategy.md) — 인증 결정
- [Users Schema](docs/05-data/schemas/users.md) — 데이터 분류 및 보존 정책
- [Incident Response](docs/06-operations/incident-response.md) — 장애 대응
- [Coding Standards](docs/09-guides/coding-standards.md) — 보안 코딩 규칙
