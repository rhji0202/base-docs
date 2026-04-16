---
completion: skeleton
last_verified: 2026-04-16
---

# Components (C4 Level 3)

> 주요 컨테이너 내부의 모듈/컴포넌트 구조.
> 도메인별 모듈 경계와 의존 관계.

## 컴포넌트 다이어그램

{UNSET: 주요 서비스의 내부 모듈 구조 다이어그램}

## 모듈 구조

```
src/
├── domains/
│   ├── identity/     # 인증·권한 (→ docs/02-domains/identity/)
│   ├── {UNSET}/      # 다음 도메인
│   └── shared/       # 도메인 간 공유 커널
├── infrastructure/   # DB, 캐시, 큐 어댑터
├── api/              # HTTP 라우터, 미들웨어
└── config/           # 환경설정
```

## 도메인 모듈 간 의존 규칙
- 도메인 → 도메인: **이벤트**를 통한 비동기 통신 (기본)
- 도메인 → infrastructure: 인터페이스를 통한 의존 역전
- api → 도메인: 직접 호출 허용

## 관련 문서
- **배포 단위**: [Containers](./containers.md) (C4 Level 2)
- **도메인 상세**: [Domains](../02-domains/)
- **아키텍처 결정**: [ADR-001 Monolith-first](../07-decisions/ADR-001-monolith-first.md)
