# Operations 폴더 가이드

이 폴더는 **운영·배포·장애 대응**을 다룹니다.

## 폴더 구조
```
06-operations/
├── deployment.md         # 배포 절차
├── environments.md       # 환경별 설정 (dev/staging/prod)
├── monitoring.md         # 모니터링·알림 정책
├── sla.md                # SLA, SLO, SLI 정의
├── incident-response.md  # 장애 대응 프로세스
├── on-call.md            # 온콜 정책
└── runbooks/             # 상황별 대응 매뉴얼
    ├── db-failover.md
    ├── high-cpu.md
    └── ...
```

## 운영 원칙

### 1. 자동화 우선
- 수동 작업은 다음 자동화의 백로그
- 같은 작업을 두 번 하면 자동화

### 2. 측정할 수 없으면 운영할 수 없다
- 모든 핵심 지표는 대시보드에 노출
- SLO 위반 시 자동 알림

### 3. 비난 없는 사후 분석 (Blameless Postmortem)
- 사람이 아닌 시스템·프로세스를 본다
- 모든 인시던트는 포스트모템 작성

### 4. 안전한 배포
- Feature Flag 활용
- Canary / Blue-Green 배포
- 항상 롤백 가능 상태 유지

## 환경

| 환경 | 용도 | 데이터 |
|---|---|---|
| `local` | 개인 개발 | 시드 데이터 |
| `dev` | 통합 테스트 | 합성 데이터 |
| `staging` | 프로덕션 검증 | 마스킹된 프로덕션 복제 |
| `production` | 실서비스 | 실제 데이터 |

## 변경 관리
- **Standard**: 사전 승인된 정기 작업 (배포 등)
- **Normal**: 변경 자문 위원회(CAB) 승인 필요
- **Emergency**: 사후 검토, 즉시 조치
