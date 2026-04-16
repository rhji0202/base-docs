# API 설계 컨벤션

> 모든 REST API가 따라야 할 공통 규칙.
> 새 API 작성 전 반드시 숙지.

## URL 규칙

### 리소스 명명
- 복수형 명사: `/users`, `/orders` (단수형 금지)
- kebab-case: `/payment-methods` (snake_case, camelCase 금지)
- 동사 금지: `/getUsers` ❌ → `GET /users` ✅
- 깊이 최대 2단계: `/users/{id}/orders` ✅, `/users/{id}/orders/{id}/items` ❌

### 액션이 필요한 경우
RESTful로 표현이 어려우면 sub-resource로:
- ❌ `POST /users/{id}/activate`
- ✅ `POST /users/{id}/activations`

### 검색·필터링
```
GET /users?status=active&role=admin&sort=-created_at&page=1&limit=20
```

## HTTP 메서드

| 메서드 | 용도 | 멱등성 |
|---|---|---|
| GET | 조회 | ✅ |
| POST | 생성, 비멱등 액션 | ❌ |
| PUT | 전체 교체 | ✅ |
| PATCH | 부분 수정 | ❌ |
| DELETE | 삭제 (Soft) | ✅ |

## 상태 코드

### 성공
- `200 OK` : 일반 성공
- `201 Created` : 리소스 생성됨 (Location 헤더 포함)
- `202 Accepted` : 비동기 작업 접수
- `204 No Content` : 성공, 응답 본문 없음

### 클라이언트 오류
- `400 Bad Request` : 입력값 오류
- `401 Unauthorized` : 인증 필요
- `403 Forbidden` : 권한 없음
- `404 Not Found` : 리소스 없음
- `409 Conflict` : 중복, 상태 충돌
- `422 Unprocessable Entity` : 검증 실패
- `429 Too Many Requests` : Rate Limit

### 서버 오류
- `500 Internal Server Error` : 서버 에러
- `502 Bad Gateway` : 업스트림 에러
- `503 Service Unavailable` : 일시 장애
- `504 Gateway Timeout` : 업스트림 타임아웃

## 요청 / 응답 형식

### Content-Type
- 요청·응답 모두 `application/json`
- 파일 업로드는 `multipart/form-data`

### 명명 규칙
- JSON 키: `snake_case` (대안: 팀 합의 시 camelCase 가능, **둘 중 하나로 통일**)
- 날짜: ISO 8601 UTC (`2026-04-16T10:30:00Z`)
- ID: 문자열로 (숫자라도 string으로 직렬화)

### 응답 envelope
```json
{
  "data": { ... },
  "meta": { "pagination": { ... } }
}
```

리스트 응답:
```json
{
  "data": [ ... ],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 156,
      "total_pages": 8
    }
  }
}
```

### 에러 응답 (RFC 7807 기반)
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "입력값이 유효하지 않습니다.",
    "details": [
      { "field": "email", "reason": "이미 사용 중인 이메일" }
    ],
    "trace_id": "abc-123-def"
  }
}
```

표준 에러 코드는 [error-codes.md](./error-codes.md) 참조.

## 헤더

### 요청 헤더
- `Authorization: Bearer {token}` : 인증
- `X-Request-Id: {uuid}` : 요청 추적 (없으면 서버가 생성)
- `Idempotency-Key: {uuid}` : 멱등성 보장 (POST에 권장)
- `Accept-Language: ko-KR` : 언어

### 응답 헤더
- `X-Request-Id` : 요청 추적용 (항상 반환)
- `X-RateLimit-*` : Rate Limit 정보
- `Cache-Control` : 캐싱 정책

## 페이지네이션

### Offset 기반 (기본)
```
GET /users?page=2&limit=20
```

### Cursor 기반 (대용량)
```
GET /events?cursor=eyJpZCI6MTAwfQ&limit=50
```
- 무한 스크롤
- 데이터가 자주 추가되는 리스트

## Rate Limiting
- 인증된 사용자: 1000 req/min
- 미인증: 60 req/min
- 초과 시: `429` + `Retry-After` 헤더

## 보안

### 필수
- 모든 통신 HTTPS
- 인증 토큰은 헤더로만 (URL 쿼리 금지)
- CORS 화이트리스트 명시
- SQL Injection / XSS 방어

### 민감 정보
- 비밀번호, 토큰, 카드번호 등은 응답·로그에서 마스킹
- PII는 별도 암호화 컬럼

## 멱등성
다음 API는 반드시 멱등 보장:
- 결제 (`Idempotency-Key` 필수)
- 이메일 발송
- 외부 시스템 호출

## 버전 관리
- URL 경로: `/v1/users`, `/v2/users`
- Major 버전만 URL에 명시
- Minor 변경은 하위 호환 보장
- 자세한 정책: [versioning.md](./versioning.md)

## 좋은 API 체크리스트
- [ ] OpenAPI 스펙 작성됨
- [ ] 에러 응답 모든 시나리오 정의됨
- [ ] 인증·권한 명시됨
- [ ] Rate Limit 정의됨
- [ ] 페이지네이션 정의됨 (리스트인 경우)
- [ ] 예시 요청·응답 포함
- [ ] 멱등성 명시됨 (POST)
- [ ] Breaking Change 여부 검토됨
