---
completion: skeleton
last_verified: 2026-04-16
---

# Identity Domain - Business Rules

> 비즈니스 규칙과 불변 조건의 상세 명세.
> 개념적 불변 조건은 [domain-model.md](./domain-model.md)에, 여기는 **실행 규칙** 상세.

## 가입 규칙
- {UNSET: 이메일 중복 검증 정책}
- {UNSET: 비밀번호 복잡도 요구사항}
- {UNSET: 가입 제한 (rate limit, 블랙리스트 등)}

## 인증 규칙
- {UNSET: 로그인 실패 잠금 정책 (횟수, 기간)}
- {UNSET: 세션 만료 정책}
- {UNSET: 동시 세션 제한}

## 비밀번호 정책
- 해싱: Argon2id
- {UNSET: 최소 길이, 복잡도}
- {UNSET: 변경 주기}
- {UNSET: 재사용 금지 히스토리}

## 관련 문서
- **도메인 모델**: [Domain Model](./domain-model.md)
- **엣지 케이스**: [Edge Cases](./edge-cases.md)
- **API 스펙**: [Auth API](../../04-api/rest/auth.yaml)
