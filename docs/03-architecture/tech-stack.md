# 기술 스택

> 사용 중인 모든 기술과 선택 이유.
> 변경 시 반드시 ADR 작성.

## Frontend
| 영역 | 기술 | 버전 | 선택 이유 / ADR |
|---|---|---|---|
| Framework | {UNSET} | - | 결정 필요: ADR 작성 후 갱신 |
| 상태관리 | {UNSET} | - | 결정 필요: ADR 작성 후 갱신 |
| 스타일 | {UNSET} | - | 결정 필요 |
| 테스트 | {UNSET} | - | 결정 필요 |

## Backend
| 영역 | 기술 | 버전 | 선택 이유 / ADR |
|---|---|---|---|
| Language | {UNSET} | - | 결정 필요: ADR 작성 후 갱신 |
| Runtime | {UNSET} | - | 결정 필요 |
| Framework | {UNSET} | - | 결정 필요 |
| ORM | {UNSET} | - | 결정 필요 |

## Data
| 영역 | 기술 | 용도 |
|---|---|---|
| Primary DB | PostgreSQL 15 | OLTP, 도메인 데이터 |
| Cache | Redis 7 | 세션, 핫 데이터 |
| Queue | {UNSET} | 비동기 작업, 이벤트 |
| Object Storage | {UNSET} | 파일, 이미지 |
| Search | {UNSET} (선택사항) | 전문 검색 |

## Infrastructure
| 영역 | 기술 |
|---|---|
| Cloud | {UNSET} |
| Container | Docker |
| Orchestration | {UNSET} |
| IaC | {UNSET} |
| CI/CD | {UNSET} |

## Observability
| 영역 | 기술 |
|---|---|
| Logs | {UNSET} |
| Metrics | {UNSET} |
| Traces | {UNSET} |
| Errors | {UNSET} |
| Uptime | {UNSET} |

## Development
| 영역 | 기술 |
|---|---|
| VCS | Git + GitHub |
| Code Review | GitHub PR |
| Project Mgmt | {UNSET} |
| Docs | Markdown in repo (이 폴더) |
| AI Coding | Claude Code |

## 금지 / Deprecated 기술
- ❌ jQuery (모던 프레임워크 사용)
- ❌ MD5 (해싱은 Argon2id, bcrypt만)
- ❌ Plain HTTP (모든 통신 TLS)

## 검토 주기
- 기술 스택은 분기 1회 검토
- 신규 도입은 RFC 작성 → 결정되면 ADR로 영속화
