# Contributing

> 이 프로젝트에 기여하는 방법.

## 시작하기 전

1. [README.md](../../README.md) 읽기
2. [`CLAUDE.md`](../../CLAUDE.md) 읽기 (프로젝트 컨텍스트)
3. [개발 환경 셋업](./onboarding.md)

## 작업 흐름

### 1. 이슈 생성 / 픽업
- 모든 작업은 이슈 또는 기능 ID로 추적
- 작업 시작 전 담당자 자기 할당

### 2. 브랜치 생성
```bash
git checkout -b feature/F-024-payment-refund
git checkout -b fix/login-token-expiry
git checkout -b docs/update-api-conventions
```

### 3. 문서 먼저
- 새 기능: `docs/01-product/features/F-XXX-*.md` 작성
- 아키텍처 변경: ADR 또는 RFC 작성
- API 변경: `docs/04-api/`의 스펙 갱신

### 4. 구현
- 작은 커밋으로 자주 (Conventional Commits)
- 테스트 함께 작성

### 5. PR 생성
- 제목: `feat(F-024): 결제 환불 기능`
- 본문 템플릿 사용
- 관련 문서 링크
- 리뷰어 지정

### 6. 리뷰
- 최소 1명 승인 필요
- 도메인 오너 승인 권장
- CI 통과 필수

## 커밋 메시지 규칙

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type
- `feat`: 새 기능
- `fix`: 버그 수정
- `docs`: 문서만
- `style`: 포맷 (기능 변화 없음)
- `refactor`: 리팩터링
- `test`: 테스트 추가/수정
- `chore`: 빌드·도구 변경

### Scope
- 기능 ID: `F-024`
- 도메인: `identity`, `payment`
- 영역: `api`, `db`, `infra`

### 예시
```
feat(F-024): 결제 환불 API 추가

- POST /payments/{id}/refunds 구현
- 부분 환불 지원
- 결제 게이트웨이 연동

Closes #123
```

## PR 체크리스트

- [ ] 관련 기능 ID 또는 이슈 링크
- [ ] 문서 갱신 (해당 시)
- [ ] 테스트 추가
- [ ] CI 통과
- [ ] Breaking Change 라벨 (해당 시)
- [ ] 마이그레이션 작성 (스키마 변경 시)
- [ ] 보안 검토 (인증/권한/PII 변경 시)

## 코드 리뷰 원칙
- 사람이 아닌 코드를 본다
- 칭찬도 적극적으로
- "왜?"를 묻기
- 큰 변경은 사전에 RFC

## 도움이 필요할 때
- Slack: `#dev-help`
- 가이드: `docs/09-guides/`
- Claude Code: 프로젝트 어떤 부분이든 질문 가능
