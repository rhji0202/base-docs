---
name: update
description: tom 플러그인 자산을 최신 버전으로 갱신한다. .claude/rules/, .claude/scripts/, .claude/settings.json 만 업데이트하고 docs/ 사용자 콘텐츠는 건드리지 않는다. 플러그인 업그레이드 후 룰/스크립트/설정 동기화 요청 시 사용.
user-invocable: true
allowed-tools: Read Bash Glob
---

# /update

tom 플러그인의 **자동화 자산만** 현재 프로젝트로 동기화합니다. 사용자 문서(`docs/`)는 절대 건드리지 않습니다.

## 갱신 대상 (3가지만)

| 소스 (플러그인 루트) | 대상 (프로젝트 루트) |
|---|---|
| `.claude/rules/` | `./.claude/rules/` |
| `.claude/scripts/` | `./.claude/scripts/` |
| `.claude/settings.json` | `./.claude/settings.json` |

> `docs/`, `CLAUDE.md`, `settings.local.json`, 사용자 작성 PRD/ADR은 **변경하지 않습니다**.

## 실행 절차

### 1. 설치 여부 확인

```bash
if [ ! -d ".claude" ]; then
  echo "❌ .claude 디렉토리가 없습니다. 먼저 /setup 을 실행하세요."
  exit 1
fi
```

### 2. 변경 사항 미리보기

업데이트 전 사용자에게 어떤 파일이 바뀌는지 보여줍니다.

```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

echo "=== rules/ 변경 사항 ==="
diff -rq "$SRC/.claude/rules" ./.claude/rules 2>/dev/null || echo "(신규 또는 누락 파일 있음)"

echo ""
echo "=== scripts/ 변경 사항 ==="
diff -rq "$SRC/.claude/scripts" ./.claude/scripts 2>/dev/null || echo "(신규 또는 누락 파일 있음)"

echo ""
echo "=== settings.json 변경 사항 ==="
diff "$SRC/.claude/settings.json" ./.claude/settings.json 2>/dev/null | head -40 || echo "(차이 있음)"
```

차이가 없으면 "최신 상태입니다"라고 보고하고 종료합니다.

### 3. 사용자 확인

```
다음 항목을 갱신합니다:
  - .claude/rules/         (덮어쓰기)
  - .claude/scripts/       (덮어쓰기)
  - .claude/settings.json  (덮어쓰기, 백업 생성)

진행할까요? [y/N]
```

> `settings.json`은 사용자가 수정했을 가능성이 있으므로 **반드시 백업**합니다.

### 4. 백업

```bash
ts=$(date +%Y%m%d-%H%M%S)
backup=".backup-update-$ts"
mkdir -p "$backup"
cp -r .claude/rules "$backup/" 2>/dev/null
cp -r .claude/scripts "$backup/" 2>/dev/null
cp .claude/settings.json "$backup/" 2>/dev/null
echo "백업 위치: $backup"
```

### 5. 갱신 실행

```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

# rules: 디렉토리 통째로 교체 (구버전 룰 잔존 방지)
rm -rf .claude/rules
cp -r "$SRC/.claude/rules" ./.claude/

# scripts: 디렉토리 통째로 교체
rm -rf .claude/scripts
cp -r "$SRC/.claude/scripts" ./.claude/

# settings.json: 단순 덮어쓰기
cp "$SRC/.claude/settings.json" ./.claude/settings.json

# 실행 권한 복원
chmod +x .claude/scripts/*.sh 2>/dev/null
chmod +x .claude/scripts/hooks/*.sh 2>/dev/null
```

### 6. 검증 및 안내

```bash
echo "=== 갱신 결과 ==="
echo "rules:    $(ls .claude/rules/ | wc -l) 파일"
echo "scripts:  $(ls .claude/scripts/*.sh 2>/dev/null | wc -l) 스크립트"
echo "settings: $([ -f .claude/settings.json ] && echo OK || echo MISSING)"
```

```
✅ 업데이트 완료

settings.json을 직접 수정한 적이 있다면 백업($backup/settings.json)과
비교하여 커스텀 설정을 다시 적용하세요.

검증: grep -r "{UNSET}" docs/   (미결정 항목 현황 확인)
```

## 주의사항

- **settings.local.json은 절대 건드리지 않습니다** — 사용자 로컬 환경 설정 보존.
- **docs/ 디렉토리는 절대 건드리지 않습니다** — 사용자 콘텐츠 보존.
- settings.json 커스터마이징을 자주 한다면 `.claude/settings.local.json`으로 분리해두는 것을 권장합니다.
- 변경 사항 미리보기에서 diff가 너무 크면 사용자에게 진행 여부를 한 번 더 확인합니다.
