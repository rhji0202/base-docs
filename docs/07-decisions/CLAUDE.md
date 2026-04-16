# Decisions 폴더 가이드 (ADR)

이 폴더는 **아키텍처/기술 결정의 영구 기록**입니다.

## ADR이란?
Architecture Decision Record. **"왜 이렇게 결정했는가"** 를 미래의 자신·동료에게 남기는 기록.

## 작성 시점
다음 중 하나라도 해당하면 ADR 작성:
- 기술 스택 선택/변경
- 아키텍처 패턴 채택 (예: CQRS, 이벤트 소싱)
- 외부 시스템 연동 방식 결정
- DB 선택, 캐시 전략
- 보안 정책
- 되돌리기 어려운 결정 전반

## 핵심 원칙

### 1. 불변(Immutable)
한 번 승인된 ADR은 **수정하지 않는다**. 결정이 바뀌면 새 ADR을 작성하고, 기존 ADR의 상태를 `superseded`로 변경 + 새 ADR 링크.

### 2. 결정의 맥락 포함
- 그 시점의 제약 조건
- 검토한 대안들
- 트레이드오프

### 3. 짧고 구체적
- 1~2 페이지 권장
- "결정"과 "이유"가 명확해야 함

## 상태값
- `proposed` : 제안됨, 결정 전
- `accepted` : 승인됨
- `deprecated` : 더 이상 권장 안 함 (대체 없음)
- `superseded` : 다른 ADR로 대체됨

## 명명
```
ADR-001-monolith-first.md
ADR-002-postgresql-as-primary-db.md
ADR-003-jwt-vs-session.md
```

## 검색·인덱싱
- 모든 ADR은 [INDEX.md](./INDEX.md)에 등록
- 코드 주석에서 ADR 참조: `// See ADR-005`
