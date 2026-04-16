---
name: doc-status
description: 문서 프로젝트의 전체 건강 상태를 리포트한다. {UNSET} 개수, completion 분포, 깨진 링크, 파일 크기 경고, Bootstrap Progress 현황을 한 눈에 보여준다.
user-invocable: true
allowed-tools: Read Grep Glob
---

# /doc-status

문서 프로젝트의 건강 상태를 종합 리포트합니다.

## 수집할 데이터

### 1. {UNSET} 현황
Grep 도구로 `docs/` 디렉토리에서 `{UNSET}` 패턴을 검색하세요 (output_mode: "count" 사용).

### 2. Completion 분포
Grep 도구로 `docs/` 디렉토리에서 각각 검색:
- `completion: skeleton` → skeleton 수
- `completion: partial` → partial 수
- `completion: complete` → complete 수

### 3. 전체 문서 수
Glob 도구로 `docs/**/*.md` 패턴을 검색하여 전체 문서 수를 파악하세요.

### 4. 대형 파일 (400줄 초과)
Glob으로 찾은 md 파일들 중 주요 파일을 Read 도구로 확인하여 400줄 초과 파일을 식별하세요.

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
