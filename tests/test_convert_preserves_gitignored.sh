#!/bin/bash
# ABOUTME: Tests that convert-to-worktree preserves gitignored files in the project root.
# ABOUTME: Validates both root-level and nested gitignored files survive conversion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERT="$SCRIPT_DIR/../scripts/convert-to-worktree"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

# --- Setup: create a git repo with tracked and gitignored files ---

REPO="$WORK/test-repo"
mkdir "$REPO"
cd "$REPO"

git init -b main --quiet
git config user.email "test@test.com"
git config user.name "Test"

cat > .gitignore <<'EOF'
*.env
secret/
EOF

echo "tracked content" > file.txt
echo "SECRET=password" > .env
echo "LOCAL=value" > local.env
mkdir -p secret
echo "key=abc" > secret/api.key

git add .gitignore file.txt
git commit -m "initial" --quiet

# --- Run conversion (manual path only, skip copier) ---

# Strip uvx from PATH so the script falls through to manual conversion.
# Keep all other tools available.
ORIG_PATH="$PATH"
TEMP_BIN="$WORK/bin"
mkdir -p "$TEMP_BIN"
# Symlink everything except uvx
for bin_dir in ${PATH//:/ }; do
  [ -d "$bin_dir" ] || continue
  for f in "$bin_dir"/*; do
    name="$(basename "$f")"
    [ "$name" = "uvx" ] && continue
    [ -e "$TEMP_BIN/$name" ] && continue
    ln -sf "$f" "$TEMP_BIN/$name" 2>/dev/null || true
  done
done

PATH="$TEMP_BIN" bash "$CONVERT" "$REPO"

# --- Assertions ---

# Gitignored files preserved in project root
[ -f "$REPO/.env" ] || fail ".env not found in project root"
[ "$(cat "$REPO/.env")" = "SECRET=password" ] || fail ".env content not preserved"

[ -f "$REPO/local.env" ] || fail "local.env not found in project root"
[ "$(cat "$REPO/local.env")" = "LOCAL=value" ] || fail "local.env content not preserved"

[ -f "$REPO/secret/api.key" ] || fail "secret/api.key not found in project root"
[ "$(cat "$REPO/secret/api.key")" = "key=abc" ] || fail "secret/api.key content not preserved"

# Worktree created properly
[ -d "$REPO/main" ] || fail "main worktree not created"
[ -f "$REPO/main/file.txt" ] || fail "tracked file not in worktree"

# Tracked files NOT duplicated in root
[ ! -f "$REPO/file.txt" ] || fail "tracked file should not be in root"

echo "PASS: gitignored files preserved in project root"
