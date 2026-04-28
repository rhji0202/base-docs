---
name: doc-status
description: 문서 프로젝트의 전체 건강 상태를 리포트한다. {UNSET} 개수, completion 분포, 깨진 링크, 파일 크기 경고, Bootstrap Progress 현황을 한 눈에 보여준다.
user-invocable: true
allowed-tools: Bash Read
---

# /doc-status

문서 프로젝트의 건강 상태를 종합 리포트합니다.

## 실행

프로젝트 루트에서 다음 스크립트를 실행하세요:

```bash
bash .claude/scripts/analyze-status.sh
```

스크립트가 아래 항목을 한 번에 수집하여 Markdown 리포트로 출력합니다:

- 전체 문서 수 (`docs/**/*.md`)
- Completion 분포 (`complete` / `partial` / `skeleton` frontmatter 기준)
- `{UNSET}` 마커: 총 개수 및 포함 파일 수 (상위 10개 파일)
- 400줄 초과 대형 파일
- 루트 `CLAUDE.md`의 Bootstrap Progress 체크리스트
- 조치 권고 (Recommendations)

## 후속 조치

스크립트 출력을 그대로 사용자에게 전달한 뒤, `Recommendations` 섹션의 항목이 있으면 다음 단계로 안내합니다:

- `{UNSET}` 마커가 남아있으면 → `/init-project` 또는 해당 파일을 열어 값 채우기
- `skeleton` 문서가 많으면 → 우선순위가 높은 문서부터 `completion: partial` 이상으로 승격
- 400줄 초과 파일이 있으면 → 섹션 분할 검토

## 참고

- 스크립트는 크로스플랫폼(Windows Git Bash / macOS / Linux)에서 동일하게 동작합니다.
- 출력을 커스터마이즈하려면 `.claude/scripts/analyze-status.sh`를 직접 수정하세요.
