---
completion: skeleton
last_verified: 2026-04-16
---

# Git Workflow

> 브랜치 전략, 머지 정책, 릴리스 관리.

## 브랜치 전략

| 브랜치 | 용도 | 보호 |
|---|---|---|
| `main` | 프로덕션 배포 가능 상태 | Protected |
| `develop` | 개발 통합 | {UNSET} |
| `feature/F-XXX-*` | 기능 개발 | - |
| `fix/issue-*` | 버그 수정 | - |
| `docs/*` | 문서 작업 | - |

## 머지 정책
{UNSET: Squash merge / Rebase merge / Merge commit}

## 릴리스 절차
{UNSET: 태깅, 체인지로그, 배포 트리거}

## 관련 문서
- **기여 가이드**: [Contributing](./contributing.md)
- **코딩 표준**: [Coding Standards](./coding-standards.md)
- **배포**: [Deployment](../06-operations/deployment.md)
