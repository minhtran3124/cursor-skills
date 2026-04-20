#!/bin/bash
# Walkthrough produces conversational output, not file artifacts.
# This script validates what we CAN check; the rest is in the checklist.

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Validating walkthrough scenario state ==="
echo ""

# 1. Verify scenario was set up correctly
echo "--- Scenario Setup ---"
cd "$SANDBOX"

if git branch | grep -q "feature/add-auth"; then
    pass "feature/add-auth branch exists"
else
    fail "feature/add-auth branch missing"
fi

DIFF_FILES=$(git diff main --name-only 2>/dev/null | wc -l | tr -d ' ')
if [[ "$DIFF_FILES" -ge 3 ]]; then
    pass "Branch has $DIFF_FILES changed files (>= 3 expected)"
else
    fail "Branch has $DIFF_FILES changed files (>= 3 expected)"
fi

if git diff main --name-only | grep -q "middleware/auth.py"; then
    pass "New file: middleware/auth.py present in diff"
else
    fail "middleware/auth.py not in branch diff"
fi

# 2. Walkthrough output is conversational (displayed in Cursor chat)
# Cannot be validated automatically — use checklist.md
echo ""
echo "--- Output Validation ---"
echo "  INFO: Walkthrough output is conversational (in Cursor chat)."
echo "  INFO: Use checklist.md for quality evaluation."

echo ""
echo "=== Result: $PASS passed, $FAIL failed ==="
echo "Scenario setup verified. Review chat output against checklist.md."
