---
status: draft
updated: {UNSET: YYYY-MM-DD}
---

# 공통 API 규약

모든 `3-api` 설계가 따르는 전역 규약. 기능 문서는 이 규약을 **링크로 참조**하고, 예외만 따로 명시한다.

## 1. 응답 포맷 (Envelope)
> 성공/실패를 일관된 형태로. (`common-patterns.md`의 API Response Format 참조)
```
{UNSET: 예 — { "success": true, "data": ..., "error": null, "meta": {...} }}
```

## 2. 에러 코드 체계
| 코드 | 의미 | HTTP |
|---|---|---|
| {UNSET} | {UNSET} | {UNSET} |

## 3. 인증 / 인가 모델
- **인증 방식**: {UNSET: 예 — JWT, 세션}
- **토큰 수명/갱신**: {UNSET}
- **권한 모델**: {UNSET: 예 — 역할(RBAC), 리소스 소유권}

<!-- 필요해지면 추가: 페이지네이션/정렬/필터, 공통 헤더, 멱등성, 레이트리밋. 처음부터 채우지 말 것(YAGNI). -->

<!-- 공유 데이터 모델(여러 기능이 쓰는 핵심 엔티티)도 실제로 둘 이상 기능이 같은 엔티티를 쓰게 될 때
     이 폴더에 data-model.md 를 만들어 추출한다. 그 전에는 각 3-api/<슬러그>.md 에 기능 전용으로 둔다. -->

