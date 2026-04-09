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

# Apply scenario changes (overwrite base files with modified versions)
cp -r "$CHANGES"/* "$SANDBOX/"

echo ""
echo "=== review-diff scenario ready ==="
echo "Sandbox: $SANDBOX"
echo ""
echo "Changes applied (uncommitted):"
git diff --stat
echo ""
echo "Next steps:"
echo "  1. Open $SANDBOX in Cursor"
echo "  2. Run /review-diff in the AI chat"
echo "  3. After skill completes, run:  bash $(dirname "$0")/validate.sh"
