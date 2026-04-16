---
name: doc-status
description: 문서 프로젝트의 전체 건강 상태를 리포트한다. {UNSET} 개수, completion 분포, 깨진 링크, 파일 크기 경고, Bootstrap Progress 현황을 한 눈에 보여준다.
user-invocable: true
allowed-tools: Read Grep Glob Bash(grep *) Bash(find docs/ *) Bash(wc *) Bash(.claude/scripts/check-broken-links.sh)
---

# /doc-status

문서 프로젝트의 건강 상태를 종합 리포트합니다.

## 수집할 데이터

### 1. {UNSET} 현황
```!
grep -rc "{UNSET}" docs/ 2>/dev/null | grep -v ":0$" | sort -t: -k2 -rn
```

### 2. Completion 분포
```!
echo "=== skeleton ===" && grep -rl "completion: skeleton" docs/ 2>/dev/null | wc -l
echo "=== partial ===" && grep -rl "completion: partial" docs/ 2>/dev/null | wc -l
echo "=== complete ===" && grep -rl "completion: complete" docs/ 2>/dev/null | wc -l
```

### 3. 전체 문서 수
```!
find docs/ -name "*.md" -type f 2>/dev/null | wc -l
```

### 4. 대형 파일 (400줄 초과)
```!
find docs/ -name "*.md" -type f -exec wc -l {} + 2>/dev/null | sort -rn | head -10
```

## 리포트 형식

위 데이터를 수집한 후 다음 형식으로 리포트를 출력합니다:

```
## Documentation Health Report
- Date: {today}

### Summary
| 항목 | 수치 |
|---|---|
| 전체 문서 | X files |
| Complete | X |
| Partial | X |
| Skeleton | X |
| {UNSET} 마커 | X (Y files) |
| 400줄 초과 | X files |

### Top {UNSET} Files
1. file.md — N개
2. ...

### Bootstrap Progress
(CLAUDE.md의 Bootstrap Progress 체크리스트를 읽어서 출력)

### Recommendations
- [ACTION] ...
```

추가로 `CLAUDE.md`의 Bootstrap Progress 섹션을 읽어 현황을 포함합니다.
