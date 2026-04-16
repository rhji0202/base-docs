---
paths:
  - "docs/04-api/**"
---

# API 설계 규칙

docs/04-api/ 내 API 스펙 작업 시 적용되는 규칙.

## API-First 원칙
- API 스펙(OpenAPI YAML)이 **구현보다 먼저** 작성되어야 한다
- 스펙이 SSOT(Single Source of Truth) — 코드가 스펙에 맞춰야 함
- 스펙 변경 → PR 리뷰 필수

## OpenAPI 3.1 형식
- 파일: `docs/04-api/rest/{domain}.yaml`
- 도메인별 분리 (하나의 거대한 swagger.yaml 금지)
- 서버: production + staging 항상 포함

## 엔드포인트 규칙
- 리소스명: 복수형, kebab-case (`/users`, `/payment-methods`)
- 중첩: 최대 2단계 (`/users/{id}/sessions`)
- 동사 금지 (`/getUser` ❌ → `GET /users/{id}` ✅)
- 버전: URL path (`/v1/`)

## 응답 형식
```json
{
  "data": { ... },
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "사용자를 찾을 수 없습니다"
  },
  "meta": {
    "cursor": "...",
    "has_more": true
  }
}
```

## 인증/보안
- Bearer JWT (Authorization 헤더)
- 부작용 있는 POST에 `Idempotency-Key` 헤더 필수

## 에러 코드
- `docs/04-api/error-codes.md`에 등록된 코드만 사용
- 새 에러 코드 추가 시 해당 파일 갱신

## 페이지네이션
- Cursor 기반 (`?cursor=xxx&limit=20`)
- Offset 기반 금지 (대규모 데이터에서 성능 이슈)

## 날짜/시간
- ISO 8601 (UTC): `2026-04-16T09:30:00Z`
- 타임존은 클라이언트 책임
