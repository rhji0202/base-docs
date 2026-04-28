#!/usr/bin/env bash
# Build a Claude Code plugin zip from this project's .claude/ directory.
#
# Output: dist/base-docs-tools-<version>.zip
#
# Plugin zip layout (required by Claude Code):
#   /.claude-plugin/plugin.json   <- manifest (REQUIRED at zip root)
#   /agents/*.md
#   /commands/*.md
#   /skills/<skill>/SKILL.md
#   /rules/*.md
#   /scripts/...                  (optional helpers)
#   /hooks/hooks.json              (optional, generated from settings.json)
#
# NOTE: Inside the zip, paths must NOT be prefixed with ".claude/".

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

PLUGIN_NAME="base-docs-tools"
VERSION="$(grep -oE '"version"\s*:\s*"[^"]+"' .claude-plugin/plugin.json | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
OUT_DIR="dist"
STAGE="$(mktemp -d -t plugin-build-XXXXXX)"
ZIP_PATH="$ROOT/$OUT_DIR/${PLUGIN_NAME}-${VERSION}.zip"

echo "==> Staging at $STAGE"
mkdir -p "$OUT_DIR"

# 1) Manifest(s) at zip root
mkdir -p "$STAGE/.claude-plugin"
cp .claude-plugin/plugin.json "$STAGE/.claude-plugin/plugin.json"
if [ -f .claude-plugin/marketplace.json ]; then
  cp .claude-plugin/marketplace.json "$STAGE/.claude-plugin/marketplace.json"
fi

# 2) Plugin content (NO .claude/ prefix inside zip)
for d in agents commands skills rules scripts; do
  if [ -d ".claude/$d" ]; then
    echo "==> Copying $d/"
    cp -r ".claude/$d" "$STAGE/$d"
  fi
done

# 3) Settings -> hooks.json (plugins use hooks/hooks.json, not settings.json)
if [ -f ".claude/settings.json" ]; then
  if command -v node >/dev/null 2>&1; then
    echo "==> Extracting hooks from settings.json"
    mkdir -p "$STAGE/hooks"
    node -e '
      const fs = require("fs");
      const s = JSON.parse(fs.readFileSync(".claude/settings.json", "utf8"));
      const out = { hooks: s.hooks || {} };
      fs.writeFileSync(process.argv[1], JSON.stringify(out, null, 2));
    ' "$STAGE/hooks/hooks.json"
  else
    echo "!! node not found; skipping hooks/hooks.json generation"
  fi
fi

# 4) Validate manifest exists at the right place
if [ ! -f "$STAGE/.claude-plugin/plugin.json" ]; then
  echo "ERROR: manifest missing at staging root" >&2
  exit 1
fi

# 5) Zip from staging dir so paths are at zip root
echo "==> Creating $ZIP_PATH"
rm -f "$ZIP_PATH"

if command -v zip >/dev/null 2>&1; then
  ( cd "$STAGE" && zip -rq "$ZIP_PATH" . )
elif command -v powershell >/dev/null 2>&1 || command -v powershell.exe >/dev/null 2>&1; then
  PS=$(command -v powershell.exe || command -v powershell)
  # Convert paths to Windows form for PowerShell
  WIN_STAGE=$(cygpath -w "$STAGE" 2>/dev/null || echo "$STAGE")
  WIN_ZIP=$(cygpath -w "$ZIP_PATH" 2>/dev/null || echo "$ZIP_PATH")
  # Build the zip entry-by-entry so paths use forward slashes.
  # Both Compress-Archive and CreateFromDirectory emit backslashes on Windows,
  # which the Claude Code plugin validator rejects.
  "$PS" -NoProfile -Command "
    Add-Type -AssemblyName System.IO.Compression;
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    \$src = '$WIN_STAGE';
    \$dst = '$WIN_ZIP';
    if (Test-Path \$dst) { Remove-Item \$dst -Force }
    \$zip = [System.IO.Compression.ZipFile]::Open(\$dst, [System.IO.Compression.ZipArchiveMode]::Create);
    try {
      Get-ChildItem -Path \$src -Recurse -File | ForEach-Object {
        \$rel = \$_.FullName.Substring(\$src.Length).TrimStart('\\','/').Replace('\\','/');
        \$entry = \$zip.CreateEntry(\$rel, [System.IO.Compression.CompressionLevel]::Optimal);
        \$es = \$entry.Open();
        \$fs = [System.IO.File]::OpenRead(\$_.FullName);
        try { \$fs.CopyTo(\$es) } finally { \$fs.Dispose(); \$es.Dispose() }
      }
    } finally { \$zip.Dispose() }
  "
else
  echo "ERROR: neither 'zip' nor 'powershell' available" >&2
  exit 1
fi

echo "==> Done: $ZIP_PATH"
echo
echo "Zip contents (top level):"
if command -v unzip >/dev/null 2>&1; then
  unzip -l "$ZIP_PATH" | awk 'NR>3 { print $4 }' | awk -F/ '{print $1"/"$2}' | sort -u | head -20
fi
