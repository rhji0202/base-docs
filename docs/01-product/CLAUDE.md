# Product 폴더 가이드

이 폴더는 **무엇을 만들 것인가**(What)를 다룹니다.
**어떻게 만들 것인가**(How)는 `02-domains/`, `03-architecture/`에서 다룹니다.

## 폴더 구조
```
01-product/
├── personas/         # 타겟 사용자 정의
├── features/         # 기능별 PRD (F-XXX)
└── metrics.md        # KPI, 성공 지표
```

## 기능(Feature) 작성 워크플로

```
1. ID 할당     → 다음 번호 (예: F-024)
2. 템플릿 복사 → cp 99-templates/feature-template.md features/F-024-name.md
3. PRD 작성    → status: draft
4. 리뷰        → PM, Tech Lead, Design
5. 승인        → status: approved
6. 구현 시작   → 코드 커밋에 F-024 prefix
7. 출시        → status: shipped
8. 회고        → 별도 섹션에 lessons learned 추가
```

## 상태 라이프사이클
- `draft` : 작성 중
- `review` : 리뷰 요청
- `approved` : 구현 가능
- `in-progress` : 구현 중
- `shipped` : 출시 완료
- `deprecated` : 지원 중단

## 좋은 PRD의 조건
1. **사용자 관점**: 기능이 아닌 사용자 가치로 시작
2. **측정 가능한 성공 기준**: "빠르게"가 아닌 "p95 응답시간 200ms 이하"
3. **Out of Scope 명시**: 무엇을 안 할지가 무엇을 할지보다 중요
4. **엣지 케이스**: 정상 흐름은 누구나 쓰지만, 예외 처리가 품질을 만든다
