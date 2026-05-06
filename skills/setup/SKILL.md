---
name: setup
description: tom 플러그인을 사용자 프로젝트 또는 user 전역에 부트스트랩한다. --scope=project(기본) 시 현재 작업 디렉토리에, --scope=user 시 ~/.claude/ 에 rules/scripts/settings.json을 복사한다. 신규 프로젝트 초기 설치, base-docs 템플릿 적용, 전역 룰셋 설치 요청 시 사용.
user-invocable: true
allowed-tools: Read Bash Glob
---

# /setup

tom 플러그인의 문서 템플릿과 자동화 자산을 **현재 프로젝트** 또는 **user 전역(`~/.claude/`)**에 복사합니다.

## Scope 옵션

| Scope | 대상 경로 | 복사 항목 |
|---|---|---|
| `project` (기본) | `./` (현재 작업 디렉토리) | `docs/`, `.claude/rules/`, `.claude/scripts/`, `.claude/settings.json`, `CLAUDE.md` |
| `user` | `~/.claude/` | `rules/`, `scripts/`, `settings.json` 만 (docs/CLAUDE.md 제외) |

> **사용법**:
> - `/setup` 또는 `/setup --scope=project` → 프로젝트 부트스트랩
> - `/setup --scope=user` → 전역 룰셋 설치 (모든 프로젝트에 공통 적용)

> `docs/`와 `CLAUDE.md`는 프로젝트별 콘텐츠이므로 user scope에서는 복사하지 않습니다.

## 인자 파싱

스킬 호출 시 인자에서 `--scope=<value>`를 추출합니다.

```bash
SCOPE="project"  # 기본값
for arg in "$@"; do
  case "$arg" in
    --scope=user)    SCOPE="user" ;;
    --scope=project) SCOPE="project" ;;
    --scope=*)       echo "❌ Invalid scope: ${arg#--scope=} (use 'user' or 'project')"; exit 1 ;;
  esac
done

if [ "$SCOPE" = "user" ]; then
  TARGET_ROOT="$HOME/.claude"
  CLAUDE_DIR="$HOME/.claude"
  TARGETS="rules scripts settings.json"
else
  TARGET_ROOT="."
  CLAUDE_DIR="./.claude"
  TARGETS="docs .claude/rules .claude/scripts .claude/settings.json CLAUDE.md"
fi

echo "Scope: $SCOPE  →  $TARGET_ROOT"
```

## 복사 대상

### Project scope (`--scope=project`, 기본)

| 소스 (플러그인 루트 기준) | 대상 (프로젝트 루트 기준) | 비고 |
|---|---|---|
| `docs/` | `./docs/` | 문서 템플릿 일괄 복사 |
| `.claude/rules/` | `./.claude/rules/` | 코딩/리뷰/보안 규칙 |
| `.claude/scripts/` | `./.claude/scripts/` | lint, sync-registry 등 |
| `.claude/settings.json` | `./.claude/settings.json` | hooks/permissions |
| `CLAUDE.md` | `./CLAUDE.md` | 루트 진입점 (있을 때만) |

### User scope (`--scope=user`)

| 소스 (플러그인 루트 기준) | 대상 (`~/.claude/` 기준) | 비고 |
|---|---|---|
| `.claude/rules/` | `~/.claude/rules/` | 모든 프로젝트 공통 규칙 |
| `.claude/scripts/` | `~/.claude/scripts/` | 전역 자동화 스크립트 |
| `.claude/settings.json` | `~/.claude/settings.json` | 전역 hooks/permissions |

> 플러그인 루트는 `${CLAUDE_PLUGIN_ROOT}` 환경변수로 접근합니다.

## 실행 절차

### 1. 사전 점검

대상 경로에 이미 파일이 있는지 검사합니다.

**Project scope**:
```bash
echo "=== 충돌 검사 (project) ==="
for target in docs .claude/rules .claude/scripts .claude/settings.json CLAUDE.md; do
  if [ -e "$target" ]; then
    echo "EXISTS: $target"
  else
    echo "OK    : $target (신규 생성됨)"
  fi
done
```

**User scope**:
```bash
echo "=== 충돌 검사 (user: $HOME/.claude) ==="
for target in rules scripts settings.json; do
  if [ -e "$HOME/.claude/$target" ]; then
    echo "EXISTS: ~/.claude/$target"
  else
    echo "OK    : ~/.claude/$target (신규 생성됨)"
  fi
done
```

**충돌 발견 시**: 사용자에게 다음 중 선택을 요청합니다.
- `overwrite` — 모두 덮어쓰기 (백업 자동 생성)
- `merge` — 신규 파일만 추가 (기존 파일 보존)
- `cancel` — 중단

### 2. 백업 (overwrite 선택 시에만)

**Project scope**:
```bash
ts=$(date +%Y%m%d-%H%M%S)
backup=".backup-setup-$ts"
mkdir -p "$backup"
for t in docs .claude/rules .claude/scripts .claude/settings.json CLAUDE.md; do
  [ -e "$t" ] && cp -r "$t" "$backup/" 2>/dev/null
done
echo "백업 위치: $backup"
```

**User scope**:
```bash
ts=$(date +%Y%m%d-%H%M%S)
backup="$HOME/.claude/.backup-setup-$ts"
mkdir -p "$backup"
for t in rules scripts settings.json; do
  [ -e "$HOME/.claude/$t" ] && cp -r "$HOME/.claude/$t" "$backup/" 2>/dev/null
done
echo "백업 위치: $backup"
```

### 3. 복사 실행

**Project scope**:
```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

mkdir -p .claude

cp -r "$SRC/docs" ./
cp -r "$SRC/.claude/rules" ./.claude/
cp -r "$SRC/.claude/scripts" ./.claude/
cp "$SRC/.claude/settings.json" ./.claude/settings.json

if [ -f "$SRC/CLAUDE.md" ] && [ ! -f "./CLAUDE.md" ]; then
  cp "$SRC/CLAUDE.md" ./CLAUDE.md
fi

chmod +x .claude/scripts/*.sh 2>/dev/null
chmod +x .claude/scripts/hooks/*.sh 2>/dev/null
```

**User scope**:
```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

mkdir -p "$HOME/.claude"

cp -r "$SRC/.claude/rules" "$HOME/.claude/"
cp -r "$SRC/.claude/scripts" "$HOME/.claude/"

# settings.json: hook 경로를 $CLAUDE_PROJECT_DIR → 실제 ~/.claude 절대경로로 치환
# user scope hook은 모든 프로젝트에서 동작해야 하므로 setup 시점에 절대경로로 박아넣음
# (런타임 $HOME 확장에 의존하지 않음 — hook 러너가 셸 확장을 보장하지 않을 수 있음)
# sed 구분자는 |, 치환 대상 경로의 sed 메타문자(& \ |)만 이스케이프
HOME_CLAUDE_ESC=$(printf '%s' "$HOME/.claude" | sed 's|[&\\|]|\\&|g')
sed "s|\$CLAUDE_PROJECT_DIR/\.claude|$HOME_CLAUDE_ESC|g" \
  "$SRC/.claude/settings.json" > "$HOME/.claude/settings.json"

chmod +x "$HOME/.claude/scripts"/*.sh 2>/dev/null
chmod +x "$HOME/.claude/scripts/hooks"/*.sh 2>/dev/null
```

> **왜 치환이 필요한가**: `$CLAUDE_PROJECT_DIR`은 현재 작업 중인 프로젝트 루트로 해석됩니다. user-level settings의 hook은 모든 프로젝트에서 공통 동작해야 하므로 `$HOME/.claude/scripts/...` 절대경로로 바꿔야 합니다.

### 4. 검증

**Project scope**:
```bash
echo "=== 설치 결과 (project) ==="
ls -la docs/ | head -15
ls .claude/rules/ | wc -l
ls .claude/scripts/*.sh 2>/dev/null | wc -l
[ -f .claude/settings.json ] && echo "settings.json: OK"
```

**User scope**:
```bash
echo "=== 설치 결과 (user) ==="
ls "$HOME/.claude/rules/" | wc -l
ls "$HOME/.claude/scripts"/*.sh 2>/dev/null | wc -l
[ -f "$HOME/.claude/settings.json" ] && echo "~/.claude/settings.json: OK"

# hook 경로 치환 검증 — $CLAUDE_PROJECT_DIR 잔존 시 user scope에서 hook 동작 안 함
if grep -q 'CLAUDE_PROJECT_DIR' "$HOME/.claude/settings.json" 2>/dev/null; then
  echo "⚠️  hook에 \$CLAUDE_PROJECT_DIR 잔존 — 치환 실패. 수동 점검 필요."
elif grep -qF "$HOME/.claude" "$HOME/.claude/settings.json" 2>/dev/null; then
  echo "hook paths: OK (절대경로 $HOME/.claude 기준)"
else
  echo "⚠️  settings.json에 ~/.claude 경로가 없음 — 원본 settings.json에 hook이 정의됐는지 확인 필요."
fi
```

### 5. 다음 단계 안내

**Project scope**:
```
✅ 설치 완료 (project)

다음 단계:
  1. CLAUDE.md 의 {UNSET} 항목 채우기 → /init-project
  2. 첫 PRD 작성 → /new-feature
  3. 검증 → bash .claude/scripts/lint-docs.sh

업데이트는 /update 명령으로 수행하세요 (rules, scripts, settings.json만 갱신).
```

**User scope**:
```
✅ 설치 완료 (user, ~/.claude/)

전역 룰셋이 모든 프로젝트에 공통 적용됩니다.
프로젝트별 settings.json이 있으면 user 설정을 오버라이드합니다.

업데이트는 /update --scope=user 로 수행하세요.
```

## 주의사항

- `docs/` 안의 사용자 콘텐츠는 project setup 시 **덮어쓰기 위험**이 있습니다. 이미 작성된 PRD/ADR이 있다면 `merge` 모드를 사용하거나 setup을 건너뛰세요.
- `settings.local.json`은 사용자 환경별 설정이므로 **복사하지 않습니다** (project/user 모두).
- User scope의 `~/.claude/settings.json`은 모든 프로젝트의 기본값으로 동작합니다. 기존 전역 설정을 커스텀했다면 백업 비교 후 병합하세요.
- User scope 설치 시 hook 경로의 `$CLAUDE_PROJECT_DIR/.claude`는 setup 시점에 **실제 절대경로**(예: `/c/Users/foo/.claude` 또는 `/Users/foo/.claude`)로 치환됩니다. 런타임 셸 확장에 의존하지 않으므로 어떤 환경에서도 일관 동작합니다. 플러그인이 새로 추가하는 hook도 `$CLAUDE_PROJECT_DIR/.claude/...` 패턴을 따라야 치환이 정상 작동합니다.
- User scope에서 settings.json은 단일 파일이라 **merge 모드가 의미 없습니다**. EXISTS 발견 시 `overwrite`(백업 후 교체) 또는 `cancel`만 선택 가능합니다. 기존 커스텀 hook/permission이 있다면 백업과 비교하여 수동 병합하세요.
- Windows 환경에서도 bash(Git Bash, WSL)에서 실행 가정. cp/chmod가 동작해야 합니다. `$HOME`은 Git Bash 환경에서 `/c/Users/<name>` 형태로 해석됩니다.
