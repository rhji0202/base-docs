---
name: sync-registry
description: docs/00-overview/registry.md를 docs/ 실제 파일과 자동 동기화한다. F-XXX 추가/수정·도메인 변경 시 호출하여 Feature Map과 도메인 인덱스를 갱신한다.
user-invocable: true
allowed-tools: Bash(.claude/scripts/sync-registry.sh*) Read
---

# /sync-registry

`docs/00-overview/registry.md`의 자동 생성 영역을 실제 파일 시스템과 동기화합니다.

## 실행

```bash
# 갱신 (Feature 추가/수정 후)
bash .claude/scripts/sync-registry.sh

# CI 검증 (등록 누락이 있으면 exit 1)
bash .claude/scripts/sync-registry.sh --check
```

## 동작

스크립트가 다음 영역을 재생성합니다:

1. **`<!-- AUTO:FEATURES -->`** — `docs/01-product/features/F-XXX-*.md`를 모두 스캔하여 YAML Feature Map 생성
   - frontmatter (`id`, `title`, `status`)에서 메타 추출
   - PRD의 "관련 문서" 섹션의 마크다운 링크에서 도메인/API/스키마/ADR 경로 추출
   - 추가로 `docs/07-decisions/`에서 F-XXX를 grep하여 역방향 ADR 참조 보강
2. **`<!-- AUTO:DOMAINS -->`** — `docs/02-domains/*/` 폴더 상태 테이블
   - completion 상태: `skeleton` (CLAUDE.md만) / `partial` ({UNSET} 잔존) / `complete`
   - 해당 도메인을 참조하는 Feature ID 자동 매핑
3. **`<!-- AUTO:UPDATED -->`** — 마지막 갱신 타임스탬프

## 사용 시점

- **새 Feature 추가 후**: `/new-feature` 또는 직접 F-XXX 파일 생성
- **Feature 상태 변경 후**: status `draft → approved → shipped`
- **도메인 폴더 변경 후**: 새 도메인 추가, 도메인 문서 보완
- **CI 단계**: `--check`로 PR이 registry를 업데이트했는지 검증

## 마커가 없을 때

`registry.md`에 `<!-- AUTO:* -->` 마커가 없으면 스크립트가 종료됩니다. 다음을 추가하세요:

```markdown
<!-- AUTO:FEATURES:START -->
<!-- AUTO:FEATURES:END -->

<!-- AUTO:DOMAINS:START -->
<!-- AUTO:DOMAINS:END -->

<!-- AUTO:UPDATED:START -->
<!-- AUTO:UPDATED:END -->
```

## 자동 실행

`PostToolUse` 훅이 설정되어 있으면, `docs/01-product/features/F-*.md` 또는 `docs/02-domains/*/*.md` Edit/Write 후 자동 실행됩니다 (`.claude/settings.json` 참조).
