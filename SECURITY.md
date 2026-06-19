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

> 이 프로젝트의 보안 모델은 백엔드 설계 단계에서 정의합니다.
> 해당 기능의 `docs/3-api/{기능}.md` "보안 / 권한" 섹션을 참조하세요.

- **인증/인가 방식**: {UNSET}
- **비밀번호/시크릿 해싱**: {UNSET}
- **전송 암호화**: {UNSET}
- **민감 데이터(PII) 처리**: {UNSET}

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

| 등급 | 정의 | 대응 |
|---|---|---|
| P0 | 데이터 유출, 인증 우회 | 즉시 대응, 24시간 내 포스트모템 |
| P1 | 권한 상승, 정보 노출 | 24시간 내 대응 |
| P2 | 잠재적 취약점 발견 | 스프린트 내 수정 |

---

## 관련 문서
- [보안 코딩 규칙](.claude/rules/common-security.md)
- 기능별 보안 설계: `docs/3-api/{기능}.md` 의 "보안 / 권한" 섹션
