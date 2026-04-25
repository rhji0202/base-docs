# [Domain Name] Domain

> [이 도메인이 무엇을 책임지는가, 한두 문장]
> 새 도메인 스캐폴딩은 `/new-domain` 명령을 사용하세요.

## 도메인 폴더 생성 가이드

이 템플릿은 **CLAUDE.md** (이 파일)만 제공합니다.
실제 도메인 폴더는 아래 파일을 모두 생성해야 합니다:

```
02-domains/{domain-name}/
├── CLAUDE.md             # ← 이 템플릿으로 생성
├── domain-model.md       # 엔티티, 값 객체, 애그리게이트, 상태 전이
├── business-rules.md     # 비즈니스 규칙, 불변 조건 상세
├── edge-cases.md         # 예외 상황 처리 정책
└── workflows/            # 주요 유스케이스의 흐름 (필요 시)
    └── *.md
```

각 파일 작성 시 frontmatter에 `completion: skeleton` 추가 후 점진적으로 `partial` → `complete`로 갱신.

---

## 책임 범위 (In Scope)
- [핵심 책임 1]
- [핵심 책임 2]

## 책임 외 (Out of Scope)
- [다른 도메인이 처리하는 것 → 어느 도메인]

## 핵심 개념
- **[Aggregate Root]**: [설명]
- **[Entity]**: [설명]
- **[Value Object]**: [설명]

## 외부 의존성
- [의존하는 다른 도메인/외부 시스템]

## 발행하는 도메인 이벤트
- `[EventName]` : [언제 발행되는가]

## 구독하는 이벤트
- `[EventName]` ([from-domain]): [어떻게 반응하는가]

## 데이터 저장
- 주요 테이블: [테이블 목록]
- 스키마 문서: [link]

## 문서 인덱스
- [도메인 모델](./domain-model.md)
- [비즈니스 규칙](./business-rules.md)
- [엣지 케이스](./edge-cases.md)
- [워크플로](./workflows/)

## 관련 문서
- **구현**: [Feature spec link]
- **결정 근거**: [ADR link]
- **API 계약**: [API spec link]
- **데이터 스키마**: [Schema link]
