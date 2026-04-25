#!/usr/bin/env bash
#
# sync-registry.sh
#
# docs/00-overview/registry.md의 자동 생성 영역을 갱신한다.
# - Feature Map (YAML)         : docs/01-product/features/F-XXX-*.md 스캔
# - 도메인별 인덱스 (table)    : docs/02-domains/*/ 스캔
# - 마지막 갱신 (timestamp)    : 오늘 날짜
#
# 자동 생성 영역은 다음 마커로 감싼다:
#   <!-- AUTO:FEATURES:START --> ... <!-- AUTO:FEATURES:END -->
#   <!-- AUTO:DOMAINS:START -->  ... <!-- AUTO:DOMAINS:END -->
#   <!-- AUTO:UPDATED:START -->  ... <!-- AUTO:UPDATED:END -->
#
# 사용법:
#   bash .claude/scripts/sync-registry.sh           # registry.md 갱신
#   bash .claude/scripts/sync-registry.sh --check   # 갱신이 필요하면 exit 1 (CI용)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

REGISTRY="docs/00-overview/registry.md"
FEATURES_DIR="docs/01-product/features"
DOMAINS_DIR="docs/02-domains"
TODAY=$(date +%Y-%m-%d)

MODE="apply"
[[ "${1:-}" == "--check" ]] && MODE="check"

# ---------- helpers ----------

# Read a frontmatter field from a markdown file.
frontmatter_field() {
  local file="$1" field="$2"
  awk -v field="$field" '
    BEGIN { in_fm = 0 }
    /^---[[:space:]]*$/ {
      if (in_fm == 1) exit
      in_fm = 1
      next
    }
    in_fm == 1 && $0 ~ "^"field":" {
      sub("^"field":[[:space:]]*", "")
      sub(/[[:space:]]*$/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      print
      exit
    }
  ' "$file"
}

# Extract relative paths from markdown links in a file.
# Returns: paths like 02-domains/identity/, 04-api/rest/auth.yaml
extract_linked_paths() {
  local file="$1"
  # Match [text](../../02-domains/...) or (../02-domains/...)
  grep -oE '\((\.\./)+(0[0-9]-[a-z-]+/[^)#]*)' "$file" 2>/dev/null \
    | sed -E 's|^\((\.\./)+||; s|/$||' \
    | sort -u
}

# Categorize a path under docs/ by its top folder prefix.
path_category() {
  case "$1" in
    02-domains/*) echo "domain_docs" ;;
    04-api/rest/*) echo "api_specs" ;;
    04-api/events/*) echo "event_schemas" ;;
    05-data/schemas/*|05-data/migrations/*) echo "data_schemas" ;;
    07-decisions/*) echo "adrs" ;;
    *) echo "" ;;
  esac
}

# Render a YAML list field. Pass key + newline-delimited items.
emit_yaml_list() {
  local key="$1" items="$2"
  if [[ -z "$items" ]]; then
    echo "  $key: []"
    return
  fi
  echo "  $key:"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    echo "    - $line"
  done <<<"$items"
}

# Determine domain completion status.
domain_status() {
  local dir="$1"
  [[ ! -d "$dir" ]] && echo "missing" && return
  local md_count
  md_count=$(find "$dir" -maxdepth 1 -name "*.md" -not -name "CLAUDE.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$md_count" -eq 0 ]]; then
    echo "skeleton"
    return
  fi
  if [[ -f "$dir/domain-model.md" && -f "$dir/business-rules.md" ]]; then
    if grep -q '{UNSET}' "$dir/domain-model.md" "$dir/business-rules.md" 2>/dev/null; then
      echo "partial"
    else
      echo "complete"
    fi
  else
    echo "partial"
  fi
}

# Get the primary domain for a feature by inspecting its linked paths.
feature_domain() {
  local file="$1"
  extract_linked_paths "$file" \
    | grep -oE '^02-domains/[^/]+' \
    | head -1 \
    | sed 's|02-domains/||'
}

# Given a feature ID, list F-XXX features that reference a given domain folder.
features_for_domain() {
  local domain="$1"
  local result=()
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if extract_linked_paths "$f" | grep -q "^02-domains/$domain\b"; then
      local id
      id=$(frontmatter_field "$f" "id")
      [[ -n "$id" ]] && result+=("$id")
    fi
  done < <(find "$FEATURES_DIR" -maxdepth 1 -name 'F-*.md' 2>/dev/null | sort)
  if [[ ${#result[@]} -eq 0 ]]; then
    echo ""
  else
    (IFS=, ; echo "${result[*]}") | sed 's/,/, /g'
  fi
}

# ---------- generators ----------

gen_features_yaml() {
  echo '```yaml'
  local found_any=0
  local feature_files
  feature_files=$(find "$FEATURES_DIR" -maxdepth 1 -name 'F-*.md' 2>/dev/null | sort || true)
  if [[ -z "$feature_files" ]]; then
    echo "# (등록된 Feature 없음. docs/01-product/features/F-XXX-*.md 추가 후 재실행)"
    echo '```'
    return
  fi

  while IFS= read -r f; do
    local id title status domain
    id=$(frontmatter_field "$f" "id")
    [[ -z "$id" ]] && continue
    title=$(frontmatter_field "$f" "title")
    status=$(frontmatter_field "$f" "status")
    domain=$(feature_domain "$f")
    found_any=1

    # Collect linked paths and categorize
    local linked
    linked=$(extract_linked_paths "$f")
    local domain_docs="" api_specs="" event_schemas="" data_schemas="" adrs=""
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      local cat
      cat=$(path_category "$p")
      case "$cat" in
        domain_docs) domain_docs+="$p"$'\n' ;;
        api_specs) api_specs+="$p"$'\n' ;;
        event_schemas) event_schemas+="$p"$'\n' ;;
        data_schemas) data_schemas+="$p"$'\n' ;;
        adrs) adrs+="$p"$'\n' ;;
      esac
    done <<<"$linked"

    # Also pick up backward references (files that grep "F-XXX")
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      # strip docs/ prefix for comparison consistency
      local rel="${p#docs/}"
      local cat
      cat=$(path_category "$rel")
      case "$cat" in
        adrs)
          if ! grep -qF "$rel" <<<"$adrs"; then adrs+="$rel"$'\n'; fi ;;
      esac
    done < <(grep -rl "$id" docs/07-decisions 2>/dev/null || true)

    # Sort+uniq each list
    domain_docs=$(printf '%s' "$domain_docs" | awk 'NF' | sort -u)
    api_specs=$(printf '%s' "$api_specs" | awk 'NF' | sort -u)
    event_schemas=$(printf '%s' "$event_schemas" | awk 'NF' | sort -u)
    data_schemas=$(printf '%s' "$data_schemas" | awk 'NF' | sort -u)
    adrs=$(printf '%s' "$adrs" | awk 'NF' | sort -u)

    # Render (default `{UNSET}` for missing fields; avoid bash brace conflict)
    [[ -z "$title" ]] && title='{UNSET}'
    [[ -z "$status" ]] && status='draft'
    [[ -z "$domain" ]] && domain='{UNSET}'
    echo "${id}:"
    echo "  title: ${title}"
    echo "  status: ${status}"
    echo "  domain: ${domain}"
    echo "  feature_spec: ${f#./}"
    emit_yaml_list "domain_docs" "$domain_docs"
    emit_yaml_list "api_specs" "$api_specs"
    emit_yaml_list "event_schemas" "$event_schemas"
    emit_yaml_list "data_schemas" "$data_schemas"
    emit_yaml_list "adrs" "$adrs"
    echo "  code_paths: []"
    echo
  done <<<"$feature_files"

  if [[ "$found_any" -eq 0 ]]; then
    echo "# (등록된 Feature 없음. docs/01-product/features/F-XXX-*.md 추가 후 재실행)"
  fi
  echo '```'
}

gen_domain_table() {
  echo "| 도메인 | 관련 Features | 도메인 문서 | 상태 |"
  echo "|---|---|---|---|"
  local has_domain=0
  for d in "$DOMAINS_DIR"/*/; do
    [[ ! -d "$d" ]] && continue
    has_domain=1
    local name status features
    name=$(basename "$d")
    status=$(domain_status "$d")
    features=$(features_for_domain "$name")
    [[ -z "$features" ]] && features='{UNSET}'
    echo "| $name | $features | \`02-domains/$name/\` | $status |"
  done
  if [[ "$has_domain" -eq 0 ]]; then
    echo "| (도메인 없음) | — | — | — |"
  fi
}

gen_updated_block() {
  echo "> 마지막 갱신: ${TODAY} _(자동 생성)_"
}

# ---------- splicer ----------

# Replace content between AUTO markers in a file.
splice_section() {
  local marker="$1" target="$2" content_file="$3"
  local start="<!-- AUTO:${marker}:START -->"
  local end="<!-- AUTO:${marker}:END -->"

  if ! grep -qF "$start" "$target" || ! grep -qF "$end" "$target"; then
    echo "ERROR: marker AUTO:${marker} not found in $target" >&2
    echo "       Add the following markers around the auto-generated section:" >&2
    echo "         $start" >&2
    echo "         $end" >&2
    exit 2
  fi

  awk -v start="$start" -v end="$end" -v content_file="$content_file" '
    BEGIN { skipping = 0 }
    {
      if ($0 == start) {
        print
        while ((getline line < content_file) > 0) print line
        close(content_file)
        skipping = 1
        next
      }
      if ($0 == end) {
        skipping = 0
        print
        next
      }
      if (!skipping) print
    }
  ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
}

# ---------- main ----------

if [[ ! -f "$REGISTRY" ]]; then
  echo "ERROR: $REGISTRY not found" >&2
  exit 2
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

gen_features_yaml > "$TMPDIR/features.txt"
gen_domain_table > "$TMPDIR/domains.txt"
gen_updated_block > "$TMPDIR/updated.txt"

# Build candidate registry in tmp (never mutate live file until apply step succeeds).
CANDIDATE="$TMPDIR/registry.candidate"
cp "$REGISTRY" "$CANDIDATE"
splice_section "FEATURES" "$CANDIDATE" "$TMPDIR/features.txt"
splice_section "DOMAINS"  "$CANDIDATE" "$TMPDIR/domains.txt"
splice_section "UPDATED"  "$CANDIDATE" "$TMPDIR/updated.txt"

if [[ "$MODE" == "check" ]]; then
  if ! diff -q "$REGISTRY" "$CANDIDATE" >/dev/null 2>&1; then
    echo "ERROR: registry.md is out of sync." >&2
    echo "       Run: bash .claude/scripts/sync-registry.sh" >&2
    echo "" >&2
    diff -u "$REGISTRY" "$CANDIDATE" | head -60 >&2
    exit 1
  fi
  echo "OK: registry.md is up to date."
  exit 0
fi

# Apply mode: copy candidate over live file, then report.
CHANGED=1
if diff -q "$REGISTRY" "$CANDIDATE" >/dev/null 2>&1; then
  CHANGED=0
fi
cp "$CANDIDATE" "$REGISTRY"

echo "=== Registry Sync Report ==="
echo "갱신 대상: $REGISTRY"
echo
echo "Features:"
feature_count=$(find "$FEATURES_DIR" -maxdepth 1 -name 'F-*.md' 2>/dev/null | wc -l | tr -d ' ')
echo "  총 ${feature_count}개 등록"
echo
echo "Domains:"
for d in "$DOMAINS_DIR"/*/; do
  [[ ! -d "$d" ]] && continue
  echo "  $(basename "$d"): $(domain_status "$d")"
done
echo
if [[ "$CHANGED" -eq 0 ]]; then
  echo "변경 없음 (registry.md is already up to date)."
else
  echo "registry.md 갱신 완료."
fi
