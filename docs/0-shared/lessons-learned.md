---
status: draft
updated: {UNSET: YYYY-MM-DD}
---

# 자가개선 기록 (Lessons Learned)

프로젝트 진행 중 발견한 패턴, 반복된 실수, 교훈을 기록합니다.

## 작성 규칙
- **날짜 + 컨텍스트 포함** (어떤 기능/상황에서)
- **원인 → 교훈 → 액션** 형식
- 반복되면 템플릿이나 `conventions.md`에 반영

## 기록

> 트리거: ① 같은 실수 2회 반복 ② 새로운 패턴 발견 ③ 예상 못한 장애/버그

| 날짜 | 기능 | 교훈 | 액션 |
|------|------|------|------|
| 2026-06-25 | user-login | 401에 "이메일 불일치"만 있고 비번 불일치 구분 없음 | `conventions.md` 에러 코드에 `WRONG_PASSWORD` 추가 |
| {UNSET} | {UNSET} | {UNSET} | {UNSET} |
