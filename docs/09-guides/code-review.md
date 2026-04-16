---
completion: skeleton
last_verified: 2026-04-16
---

# Code Review Guide

> 코드 리뷰 절차, 기준, 에티켓.

## 리뷰 절차
1. PR 생성 → 리뷰어 자동 지정
2. 리뷰어: {UNSET: 최소 승인 수}명 이상 Approve
3. CI 통과 확인
4. 머지

## 리뷰 체크리스트
- [ ] 요구사항 충족 (PRD 대조)
- [ ] 테스트 포함
- [ ] 문서 갱신 (API/스키마 변경 시)
- [ ] 보안 이슈 없음
- [ ] 성능 영향 확인

## 리뷰 에티켓
- 코드를 비판하지, 사람을 비판하지 말 것
- "왜?"보다 "이렇게 하면 어떨까?" 형태로
- 사소한 것은 nit: 접두사

## 관련 문서
- **기여 가이드**: [Contributing](./contributing.md)
- **코딩 표준**: [Coding Standards](./coding-standards.md)
