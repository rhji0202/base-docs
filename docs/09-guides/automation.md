---
last_verified: 2026-04-25
audience: All Developers
---

# 문서 자동화 가이드

> base-docs의 문서 동기화·검증 자동화 도구 사용 안내.
> 새 팀원 온보딩 시 가장 먼저 읽으세요.
> 마지막 갱신: 2026-04-25

## 자동화 도구 한눈에 보기

| 스크립트 | 역할 | 트리거 |
|---|---|---|
| [`sync-registry.sh`](../../.claude/scripts/sync-registry.sh) | `registry.md` 자동 갱신 | F-XXX·도메인·ADR 변경 후 |
| [`gen-indexes.sh`](../../.claude/scripts/gen-indexes.sh) | 5개 폴더의 `INDEX.md` 갱신 | 해당 폴더 문서 변경 후 |
| [`check-broken-links.sh`](../../.claude/scripts/check-broken-links.sh) | 깨진 마크다운 링크 검사 | 수시·CI |
| [`lint-docs.sh`](../../.claude/scripts/lint-docs.sh) | 종합 문서 건강 검사 | 커밋 전·CI |
| [`reset-samples.sh`](../../.claude/scripts/reset-samples.sh) | 샘플 문서 일괄 제거 | 신규 프로젝트 시작 시 1회 |
| [`next-id.sh`](../../.claude/scripts/next-id.sh) | 다음 사용 가능 ID 출력 | 새 문서 작성 시 |

---

## 핵심 워크플로

### 새 Feature 추가

```bash
# 1. 다음 ID 확인
ID=$(bash .claude/scripts/next-id.sh feature)
echo "$ID"   # 예: F-002

# 2. 템플릿 복사
cp docs/99-templates/feature-template.md \
   "docs/01-product/features/${ID}-payment.md"

# 3. PRD 작성 (편집기로 채움)
# ...

# 4. registry/INDEX 자동 갱신 (Edit/Write 후 PostToolUse 훅이 자동 실행)
#    수동 실행이 필요하면:
bash .claude/scripts/sync-registry.sh
bash .claude/scripts/gen-indexes.sh

# 5. 검증
bash .claude/scripts/lint-docs.sh --quick
```

### 새 ADR 추가

```bash
ID=$(bash .claude/scripts/next-id.sh adr)
cp docs/99-templates/adr-template.md \
   "docs/07-decisions/${ID}-redis-as-cache.md"
# 작성 후
bash .claude/scripts/sync-registry.sh
bash .claude/scripts/lint-docs.sh
```

### 신규 프로젝트 시작 (base-docs 복제 직후 1회)

```bash
# 미리보기
bash .claude/scripts/reset-samples.sh

# 실행
bash .claude/scripts/reset-samples.sh --apply

# 검증
bash .claude/scripts/lint-docs.sh
```

---

## 자동 트리거 (PostToolUse 훅)

`.claude/settings.json`에 다음 훅이 등록되어 있어, Claude Code가 문서를 Edit/Write 할 때마다 자동 실행됩니다:

| 훅 | 실행 조건 | 동작 |
|---|---|---|
| `validate-frontmatter.sh` | F-XXX, ADR-XXX, RFC-XXX 편집 시 | frontmatter 누락 경고 (non-blocking) |
| `auto-sync-registry.sh` | features/domains/decisions 편집 시 | sync-registry, gen-indexes 자동 호출 |

수동으로 동기화를 강제로 막고 싶으면 `.claude/settings.json`의 hooks 섹션을 편집하세요.

---

## CI 통합 (GitHub Actions)

`.github/workflows/docs-lint.yml` 예시:

```yaml
name: Docs Lint

on:
  pull_request:
    paths:
      - 'docs/**'
      - '.claude/scripts/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run lint-docs (strict)
        run: bash .claude/scripts/lint-docs.sh --strict
```

`--strict`는 경고도 실패로 처리. `--quick`은 핵심 검사만 실행 (빠른 피드백).

---

## Git Pre-commit Hook (선택)

로컬 커밋 직전에 자동 검증을 원하면 `.git/hooks/pre-commit`에 추가:

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit
exec bash .claude/scripts/lint-docs.sh --quick
```

```bash
chmod +x .git/hooks/pre-commit
```

> ⚠️ Git hooks는 git에 커밋되지 않습니다. 팀 공유용으로는 `husky` 또는 별도 부트스트랩 스크립트 사용.

---

## 문제 해결

### `sync-registry: marker AUTO:FEATURES not found`
`docs/00-overview/registry.md`에 `<!-- AUTO:FEATURES:START -->` ~ `<!-- AUTO:FEATURES:END -->` 마커가 없습니다. 다음을 추가:
```markdown
<!-- AUTO:FEATURES:START -->
<!-- AUTO:FEATURES:END -->
```

### `gen-indexes: marker AUTO:LIST not found`
INDEX.md에 마커가 없거나 손상되었습니다. INDEX.md 파일을 삭제하고 재실행하면 자동 재생성됩니다:
```bash
rm docs/02-domains/INDEX.md
bash .claude/scripts/gen-indexes.sh
```

### `check-broken-links`가 항상 0 checked
`grep -P` 호환성 이슈는 v2 (현재)에서 해결되었습니다. 그래도 0 나오면:
```bash
ls docs/   # docs/ 디렉토리 존재 확인
bash -x .claude/scripts/check-broken-links.sh 2>&1 | head -30
```

### Hook이 작동 안 함
```bash
# 실행 권한 확인
ls -l .claude/scripts/*.sh
# 모두 -rwxr-xr-x 이어야 함. 아니면:
chmod +x .claude/scripts/*.sh
```

---

## 관련 문서
- [공통 가이드 INDEX](./INDEX.md)
- [기여 가이드](./contributing.md)
- [도메인 우선 워크플로](./domain-first-workflow.md)
- [코드 리뷰 표준](./code-review.md)
