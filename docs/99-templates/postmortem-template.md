---
incident_id: INC-XXX
title: [장애 한 줄 요약]
severity: P0 | P1 | P2 | P3
status: investigating | resolved | postmortem-complete
date: YYYY-MM-DD
duration: [총 영향 시간]
authors: [작성자]
---

# Postmortem: [장애 제목]

> **Blameless Postmortem**: 사람이 아닌 시스템·프로세스를 본다.

## 요약 (TL;DR)
[3~5줄로 무슨 일이 있었는지]

## 영향 (Impact)

| 항목 | 내용 |
|---|---|
| 영향받은 사용자 | [숫자/비율] |
| 영향받은 기능 | [기능 목록] |
| 데이터 손실 | 있음/없음 |
| 매출 영향 | [추정 금액] |
| 영향 시간 | [시작 ~ 종료, 총 시간] |

## 타임라인 (UTC)

| 시각 | 이벤트 |
|---|---|
| HH:MM | [최초 변경/원인 발생] |
| HH:MM | [최초 알림 발생] |
| HH:MM | [온콜 인지] |
| HH:MM | [원인 식별] |
| HH:MM | [임시 조치 적용] |
| HH:MM | [완전 복구] |

## 근본 원인 (Root Cause)
[기술적 원인을 구체적으로]

## 기여 요인 (Contributing Factors)
- [기여 요인 1]
- [기여 요인 2]
- [기여 요인 3]

## 잘한 점 (What Went Well)
- [감지가 빨랐다]
- [롤백 자동화가 작동했다]
- [팀 협업이 원활했다]

## 개선할 점 (What Went Wrong)
- [감지가 늦었다]
- [수동 대응이 많았다]
- [문서가 부족했다]

## 운이 좋았던 점 (Where We Got Lucky)
- [더 큰 피해가 날 뻔했지만 X 덕분에 막혔다]

## 액션 아이템

| ID | 작업 | 우선순위 | 담당 | 기한 |
|---|---|---|---|---|
| AI-1 | [작업 내용] | P0 | [이름] | YYYY-MM-DD |
| AI-2 | [작업 내용] | P1 | [이름] | YYYY-MM-DD |

## 교훈 (Lessons Learned)
- [향후 모든 결정에 영향을 줄 통찰]

## 관련 문서
- 알림: [링크]
- 채팅 로그: [링크]
- 관련 PR: [링크]
- 영향받은 ADR: [링크]
