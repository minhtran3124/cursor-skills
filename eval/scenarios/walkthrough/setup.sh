#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
FIXTURE="$EVAL_DIR/fixture-app"
CHANGES="$(cd "$(dirname "$0")" && pwd)/changes"

# Reset sandbox
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"

# Copy base fixture and init git
cp -r "$FIXTURE"/* "$FIXTURE"/.[!.]* "$SANDBOX/" 2>/dev/null || cp -r "$FIXTURE"/* "$SANDBOX/"
cd "$SANDBOX"

git init -b main
git add -A
git commit -m "Initial commit: task tracker API"

# Create feature branch with auth changes
git checkout -b feature/add-auth

# Apply changes
cp -r "$CHANGES"/* "$SANDBOX/"

git add -A
git commit -m "Add API key authentication to mutation endpoints"

echo ""
echo "=== walkthrough scenario ready ==="
echo "Sandbox: $SANDBOX"
echo ""
echo "Branch diff (feature/add-auth vs main):"
git diff main --stat
echo ""
echo "Next steps:"
echo "  1. Open $SANDBOX in Cursor"
echo "  2. Run /walkthrough in the AI chat"
echo "     (ask it to walk through changes between main and feature/add-auth)"
echo "  3. After skill completes, run:  bash $(dirname "$0")/validate.sh"
