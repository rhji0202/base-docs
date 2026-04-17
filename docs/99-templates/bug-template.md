---
id: BUG-XXX
title: [한 줄 요약 — 재현 가능한 형태]
severity: P0 | P1 | P2 | P3
status: open | in-progress | resolved | wontfix | duplicate
reporter: [발견자]
assignee: {UNSET}
affected_feature: F-XXX | N/A
affected_version: [버전 또는 커밋 SHA]
created: YYYY-MM-DD
resolved: YYYY-MM-DD
---

# BUG-XXX: [제목]

## 증상 (What went wrong)
[사용자가 무엇을 경험했는가 — 한 문단]

## 재현 절차 (Steps to Reproduce)
1. [단계 1]
2. [단계 2]
3. [단계 3]

**기대 동작**: [정상 상태]
**실제 동작**: [현재 잘못된 상태]

## 환경
- OS / Browser / Runtime:
- 버전 / 커밋:
- 재현율: [항상 / 가끔 (N/10) / 1회]

## 영향 범위 (Impact)
| 항목 | 내용 |
|---|---|
| 영향받은 기능 | F-XXX |
| 영향받은 사용자 | [규모] |
| 데이터 손상 | 있음/없음 |
| 우회 경로 | 있음/없음 |

## 진단 (Diagnosis)
- **근본 원인**: [기술적 원인, 확인되면 작성]
- **관련 코드**: [파일:라인]
- **관련 PR/커밋**: [링크]

## 해결 (Resolution)
- [어떻게 고쳤는지]
- **수정 PR**: [링크]
- **검증**: [어떻게 확인했는지]

## 관련 문서
- **관련 기능**: [F-XXX](../../01-product/features/F-XXX-*.md)
- **관련 ADR**: [ADR-XXX](../../07-decisions/ADR-XXX-*.md)
- **Postmortem (P0/P1인 경우)**: [INC-XXX](./postmortems/INC-XXX.md)

## 후속 조치
- [ ] 리그레션 테스트 추가
- [ ] 문서 갱신 (관련 PRD, 엣지케이스)
- [ ] 동일 패턴의 타 영역 점검
