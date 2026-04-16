# Data 폴더 가이드

이 폴더는 **데이터 모델·스키마·흐름**을 다룹니다.
도메인 로직 관점은 `02-domains/`, 물리적 인프라는 `03-architecture/infrastructure.md`에 있습니다.

## 폴더 구조
```
05-data/
├── erd.md                # 전체 ER 다이어그램
├── data-governance.md    # 데이터 분류·보존·삭제 정책
├── migrations-policy.md  # 마이그레이션 규칙
├── backup-recovery.md    # 백업·복구 정책
├── schemas/              # 테이블별 상세 스키마
│   ├── users.md
│   ├── orders.md
│   └── ...
└── migrations/           # 마이그레이션 이력 (선택, 코드와 중복이면 생략)
```

## 데이터 분류 (Classification)

| 분류 | 예시 | 처리 |
|---|---|---|
| **Public** | 공개 콘텐츠 | 제약 없음 |
| **Internal** | 내부 통계 | 사내만 접근 |
| **Confidential** | 사용자 프로필 | 인증 필요 |
| **Restricted** | PII, 결제정보 | 암호화 + 접근 감사 |

## 핵심 원칙
1. **단일 진실의 원천**: 같은 데이터를 여러 곳에 저장하지 않는다
2. **Soft Delete 기본**: 물리 삭제는 GDPR 등 법적 요구 시만
3. **마이그레이션은 단방향**: rollback보다 forward fix
4. **PII 최소 수집**: 필요 없으면 안 받는다
5. **암호화 컬럼 명시**: 어떤 컬럼이 암호화되는지 스키마 문서에 명시

## 스키마 변경 절차
```
1. 영향 분석 (어떤 도메인·서비스가 영향받는가)
2. Backward-compatible 여부 판단
3. 마이그레이션 작성 (Up + Down)
4. 스키마 문서 갱신
5. PR 리뷰 (DBA + 도메인 오너)
6. 스테이징 적용 → 검증 → 프로덕션
```

Breaking 스키마 변경은 [migrations-policy.md](./migrations-policy.md) 참조.
