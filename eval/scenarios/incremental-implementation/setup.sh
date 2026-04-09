#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
FIXTURE="$EVAL_DIR/fixture-app"
SCENARIO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Reset sandbox
rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"

# Copy base fixture and init git
cp -r "$FIXTURE"/* "$FIXTURE"/.[!.]* "$SANDBOX/" 2>/dev/null || cp -r "$FIXTURE"/* "$SANDBOX/"
cd "$SANDBOX"

git init -b main
git add -A
git commit -m "Initial commit: task tracker API"

# Add the implementation plan
cp "$SCENARIO_DIR/plan.md" "$SANDBOX/plan.md"

echo ""
echo "=== incremental-implementation scenario ready ==="
echo "Sandbox: $SANDBOX"
echo ""
echo "Plan file added: plan.md"
echo ""
echo "Next steps:"
echo "  1. Open $SANDBOX in Cursor"
echo "  2. Run /incremental-implementation in the AI chat"
echo "     (point it to plan.md when asked)"
echo "  3. After skill completes, run:  bash $(dirname "$0")/validate.sh"
