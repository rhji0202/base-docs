---
name: setup
description: tom 플러그인을 사용자 프로젝트에 부트스트랩한다. docs/, .claude/rules/, .claude/scripts/, .claude/settings.json을 현재 작업 디렉토리에 복사한다. 신규 프로젝트 초기 설치, base-docs 템플릿 적용 요청 시 사용.
user-invocable: true
allowed-tools: Read Bash Glob
---

# /setup

tom 플러그인의 문서 템플릿과 자동화 자산을 **현재 프로젝트**에 복사하여 즉시 사용 가능한 상태로 만듭니다.

## 복사 대상

| 소스 (플러그인 루트 기준) | 대상 (프로젝트 루트 기준) | 비고 |
|---|---|---|
| `docs/` | `./docs/` | 문서 템플릿 일괄 복사 |
| `.claude/rules/` | `./.claude/rules/` | 코딩/리뷰/보안 규칙 |
| `.claude/scripts/` | `./.claude/scripts/` | 플러그인 훅·포매터 등 |
| `.claude/settings.json` | `./.claude/settings.json` | hooks/permissions |
| `CLAUDE.md` | `./CLAUDE.md` | 루트 진입점 (있을 때만) |

> 플러그인 루트는 `${CLAUDE_PLUGIN_ROOT}` 환경변수로 접근합니다.

## 실행 절차

### 1. 사전 점검

대상 디렉토리/파일이 이미 존재하는지 검사하고 사용자에게 보고합니다.

```bash
echo "=== 충돌 검사 ==="
for target in docs .claude/rules .claude/scripts .claude/settings.json CLAUDE.md; do
  if [ -e "$target" ]; then
    echo "EXISTS: $target"
  else
    echo "OK    : $target (신규 생성됨)"
  fi
done
```

**충돌 발견 시**: 사용자에게 다음 중 선택을 요청합니다.
- `overwrite` — 모두 덮어쓰기 (백업 자동 생성)
- `merge` — 신규 파일만 추가 (기존 파일 보존)
- `cancel` — 중단

기존 파일이 없으면 바로 다음 단계로 진행합니다.

### 2. 백업 (overwrite 선택 시에만)

```bash
ts=$(date +%Y%m%d-%H%M%S)
backup=".backup-setup-$ts"
mkdir -p "$backup"
for t in docs .claude/rules .claude/scripts .claude/settings.json CLAUDE.md; do
  [ -e "$t" ] && cp -r "$t" "$backup/" 2>/dev/null
done
echo "백업 위치: $backup"
```

### 3. 복사 실행

```bash
SRC="${CLAUDE_PLUGIN_ROOT}"

# .claude 디렉토리 보장
mkdir -p .claude

# docs/ 복사 (디렉토리 전체)
cp -r "$SRC/docs" ./

# .claude/rules/, .claude/scripts/ 복사
cp -r "$SRC/.claude/rules" ./.claude/
cp -r "$SRC/.claude/scripts" ./.claude/

# settings.json 복사
cp "$SRC/.claude/settings.json" ./.claude/settings.json

# CLAUDE.md 복사 (있을 때만, 기존이 없을 때만)
if [ -f "$SRC/CLAUDE.md" ] && [ ! -f "./CLAUDE.md" ]; then
  cp "$SRC/CLAUDE.md" ./CLAUDE.md
fi

# 스크립트 실행 권한 보장
chmod +x .claude/scripts/*.sh 2>/dev/null
chmod +x .claude/scripts/hooks/*.sh 2>/dev/null
```

### 4. 검증

```bash
echo "=== 설치 결과 ==="
ls -la docs/ | head -15
ls .claude/rules/ | wc -l
ls .claude/scripts/*.sh 2>/dev/null | wc -l
[ -f .claude/settings.json ] && echo "settings.json: OK"
```

### 5. 다음 단계 안내

설치 완료 후 사용자에게 다음을 안내합니다.

```
✅ 설치 완료

다음 단계:
  1. CLAUDE.md 의 {UNSET} 항목 채우기
  2. 첫 기획 문서 작성 → docs/1-feat/_template.md 복사
  3. 기획 확정 후 docs/2-web/ → docs/3-api/ 순으로 설계

업데이트는 /update 명령으로 수행하세요 (rules, scripts, settings.json만 갱신).
```

## 주의사항

- `docs/` 안의 사용자 콘텐츠는 setup 시 **덮어쓰기 위험**이 있습니다. 이미 작성된 PRD/ADR이 있다면 `merge` 모드를 사용하거나 setup을 건너뛰세요.
- `settings.local.json`은 사용자 환경별 설정이므로 **복사하지 않습니다**.
- Windows 환경에서도 bash(Git Bash, WSL)에서 실행 가정. cp/chmod가 동작해야 합니다.
