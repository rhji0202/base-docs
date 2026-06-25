---
name: setup
description: base-docs 템플릿을 새 프로젝트에 복사하여 문서주도개발 환경을 부트스트랩한다. 신규 프로젝트 초기화 시 사용.
user-invocable: true
disable-model-invocation: true
allowed-tools: Read Bash Glob
---

# /setup

base-docs 템플릿을 **현재 프로젝트**에 복사하여 즉시 문서주도개발을 시작할 수 있게 합니다.

## 복사 대상

| 소스 | 대상 | 비고 |
|------|------|------|
| `docs/` | `./docs/` | 0-shared + 3단계 템플릿 |
| `CLAUDE.md` | `./CLAUDE.md` | 진입점 |
| `.claude/settings.json` | `./.claude/settings.json` | Hooks/Permissions |

> agents, commands, rules, scripts는 복사하지 않습니다. 순수 템플릿만 제공합니다.

## 실행 절차

### 1. 충돌 검사
```bash
echo "=== 충돌 검사 ==="
for target in docs CLAUDE.md .claude/settings.json; do
  if [ -e "$target" ]; then
    echo "⚠ EXISTS: $target"
  else
    echo "✓ NEW: $target"
  fi
done
```

**충돌 발견 시 선택지:**
- `overwrite` — 덮어쓰기 (자동 백업)
- `merge` — 새 파일만 추가, 기존 보존
- `cancel` — 중단

### 2. 백업 (overwrite 시)
```bash
ts=$(date +%Y%m%d-%H%M%S)
backup=".backup-setup-$ts"
mkdir -p "$backup"
for t in docs CLAUDE.md .claude/settings.json; do
  [ -e "$t" ] && cp -r "$t" "$backup/" 2>/dev/null
done
echo "백업: $backup"
```

### 3. 복사
```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

# docs 전체 복사
cp -r "$SRC/docs" ./

# CLAUDE.md 복사 (기존 없을 때만)
if [ ! -f "./CLAUDE.md" ]; then
  cp "$SRC/CLAUDE.md" ./CLAUDE.md
fi

# settings.json 복사
mkdir -p .claude
cp "$SRC/.claude/settings.json" .claude/settings.json 2>/dev/null

echo "복사 완료"
```

### 4. 검증
```bash
echo "=== 설치 결과 ==="
echo "docs/:" && ls docs/
echo ""
echo "템플릿:" && ls docs/*/_template.md
echo ""
[ -f CLAUDE.md ] && echo "✓ CLAUDE.md"
[ -f .claude/settings.json ] && echo "✓ .claude/settings.json"
```

### 5. 다음 단계 안내
```
✅ setup 완료!

다음 단계:
  1. CLAUDE.md 의 {UNSET} 채우기
     grep -r "{UNSET}" CLAUDE.md
  2. docs/0-shared/ 용어·공통 규약 초안
  3. 첫 기능 기획 시작:
     cp docs/1-feat/_template.md docs/1-feat/<슬러그>.md

업데이트는 /update 명령으로 (템플릿만 갱신, 사용자 문서 보존).
```

## 주의사항
- **사용자 문서는 덮어쓰지 않습니다** (merge 모드 권장).
- `docs/1-feat/`, `2-web/`, `3-api/`에 작성한 문서는 `/update` 시에도 보존됩니다.
- Windows는 Git Bash 또는 WSL 환경에서 실행하세요.
