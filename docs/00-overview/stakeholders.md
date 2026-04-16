# 이해관계자 (Stakeholders)

> 누가 의사결정에 관여하고, 누구에게 영향을 미치는지.
> 마지막 갱신: YYYY-MM-DD

## 내부 이해관계자

| 역할 | 이름 | 책임 영역 | 연락처 |
|---|---|---|---|
| Product Owner | - | 우선순위 결정, 요구사항 확정 | - |
| Tech Lead | - | 아키텍처, 기술 선택 | - |
| Engineering | - | 구현 | - |
| Design | - | UX/UI | - |
| QA | - | 품질 보증 | - |

## 외부 이해관계자

| 그룹 | 관심사 | 커뮤니케이션 채널 |
|---|---|---|
| End Users | 사용 편의성, 안정성 | 인앱 피드백, 이메일 |
| Customers (B2B) | ROI, SLA, 보안 | 영업팀 경유 |
| Partners | API 안정성 | 개발자 포털 |
| Regulators | 컴플라이언스 | 법무팀 경유 |

## 의사결정 권한 (RACI 요약)

| 결정 유형 | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| 신규 기능 | PM | PO | Tech Lead, Design | All |
| 아키텍처 변경 | Tech Lead | CTO | Senior Devs | All |
| API Breaking Change | Backend Lead | Tech Lead | Frontend, Partners | Customers |
| DB 스키마 변경 | DBA/Backend | Tech Lead | Affected teams | All |

> R: 실제 작업자 / A: 최종 책임자 / C: 사전 협의 / I: 결과 통보
