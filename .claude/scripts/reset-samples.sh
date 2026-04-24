#!/usr/bin/env bash
#
# reset-samples.sh
#
# base-docs는 템플릿 저장소입니다. 이 저장소를 복제하여 실제 프로젝트를
# 시작할 때, 참고용으로 포함된 샘플 문서(F-001 user-authentication,
# identity 도메인, 관련 ADR 및 API/스키마 예시)를 일괄 제거합니다.
#
# 제거 대상:
#   - docs/01-product/features/F-001-user-authentication.md
#   - docs/02-domains/identity/ (디렉토리 전체)
#   - docs/07-decisions/ADR-001-monolith-first.md
#   - docs/07-decisions/ADR-002-postgresql.md
#   - docs/07-decisions/ADR-003-auth-strategy.md
#   - docs/04-api/rest/auth.yaml
#   - docs/04-api/events/identity-events.yaml
#   - docs/05-data/schemas/users.md
#
# 추가로 INDEX.md / registry.md / CLAUDE.md의 샘플 참조 라인도
# 복구 가능한 초기 상태로 되돌려야 하므로, 이 스크립트는 파일 삭제만
# 수행하고 인덱스 정리는 사용자에게 안내합니다.
#
# 사용법:
#   bash .claude/scripts/reset-samples.sh          # 삭제 대상 미리보기 (dry-run)
#   bash .claude/scripts/reset-samples.sh --apply  # 실제 삭제 실행

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

SAMPLES=(
  "docs/01-product/features/F-001-user-authentication.md"
  "docs/02-domains/identity"
  "docs/07-decisions/ADR-001-monolith-first.md"
  "docs/07-decisions/ADR-002-postgresql.md"
  "docs/07-decisions/ADR-003-auth-strategy.md"
  "docs/04-api/rest/auth.yaml"
  "docs/04-api/events/identity-events.yaml"
  "docs/05-data/schemas/users.md"
)

APPLY=false
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

echo "=== 샘플 문서 제거 ==="
echo "저장소: $REPO_ROOT"
echo

MISSING=0
FOUND=0
for path in "${SAMPLES[@]}"; do
  if [[ -e "$path" ]]; then
    echo "  [제거 예정] $path"
    FOUND=$((FOUND + 1))
  else
    echo "  [이미 없음] $path"
    MISSING=$((MISSING + 1))
  fi
done

echo
echo "발견: $FOUND, 이미 없음: $MISSING"
echo

if ! $APPLY; then
  echo "[dry-run] 실제로 삭제하려면 --apply 옵션을 붙여 다시 실행하세요:"
  echo "  bash .claude/scripts/reset-samples.sh --apply"
  exit 0
fi

if [[ $FOUND -eq 0 ]]; then
  echo "삭제할 파일이 없습니다. 종료합니다."
  exit 0
fi

echo "=== 삭제 실행 ==="
for path in "${SAMPLES[@]}"; do
  if [[ -e "$path" ]]; then
    rm -rf "$path"
    echo "  [삭제됨] $path"
  fi
done

echo
echo "=== 완료 ==="
echo
echo "다음 인덱스/레지스트리도 수동으로 정리해야 합니다:"
echo
echo "  1. docs/01-product/features/INDEX.md"
echo "     → 'approved' 섹션의 F-001 행 제거"
echo "     → '다음 사용 가능 ID'를 F-001로 되돌림"
echo
echo "  2. docs/07-decisions/INDEX.md"
echo "     → Active 테이블의 ADR-001~003 행 제거"
echo "     → '카테고리별' 섹션 비움"
echo
echo "  3. docs/00-overview/registry.md"
echo "     → Feature Map의 F-001 블록 제거"
echo "     → '도메인별 인덱스'에서 identity 상태를 skeleton으로"
echo
echo "  4. CLAUDE.md (루트)"
echo "     → Bootstrap Progress에서 아래 항목 체크 해제:"
echo "       - 첫 번째 도메인 (identity) 완성"
echo "       - 첫 번째 기능 (F-001 user-authentication) 완성"
echo "       - 첫 번째 ADR 시리즈 (ADR-001~003) 작성"
echo
echo "정리 후 링크 검증:"
echo "  bash .claude/scripts/check-broken-links.sh"
