#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Validating incremental-implementation output ==="
echo ""

# 1. Progress log exists
echo "--- Progress Log ---"
if [[ -f "$SANDBOX/progress.md" ]]; then
    pass "progress.md exists"
else
    fail "progress.md not found"
fi

if [[ -f "$SANDBOX/progress.md" ]]; then
    CHUNKS=$(grep -ci 'chunk\|step\|phase' "$SANDBOX/progress.md" 2>/dev/null || echo "0")
    if [[ "$CHUNKS" -ge 2 ]]; then
        pass "progress.md references $CHUNKS chunks/steps"
    else
        fail "progress.md has only $CHUNKS chunk/step references (>= 2 expected)"
    fi
fi

# 2. Code changes were made
echo "--- Code Changes ---"
cd "$SANDBOX"

if git diff HEAD --name-only | grep -q "routes/tasks.py\|models/task.py"; then
    pass "Source files were modified"
else
    # Check if changes were committed instead
    if git log --oneline | wc -l | tr -d ' ' | grep -qv '^1$'; then
        pass "Changes were committed (multiple commits found)"
    else
        fail "No code changes detected in routes or models"
    fi
fi

# 3. Search functionality implemented
echo "--- Feature: Search ---"
if grep -rq "search\|query\|filter" "$SANDBOX/src/" 2>/dev/null; then
    pass "Search/filter code found in src/"
else
    fail "No search/filter implementation found in src/"
fi

if grep -q "args.get\|request.args\|query" "$SANDBOX/src/routes/tasks.py" 2>/dev/null; then
    pass "Query parameter handling found in routes"
else
    fail "No query parameter handling in routes"
fi

# 4. Tests added
echo "--- Tests ---"
ORIGINAL_TEST_COUNT=4
CURRENT_TEST_COUNT=$(grep -c "def test_" "$SANDBOX/tests/test_tasks.py" 2>/dev/null || echo "0")
if [[ "$CURRENT_TEST_COUNT" -gt "$ORIGINAL_TEST_COUNT" ]]; then
    pass "New tests added ($CURRENT_TEST_COUNT total, was $ORIGINAL_TEST_COUNT)"
else
    fail "No new tests added (still $CURRENT_TEST_COUNT, was $ORIGINAL_TEST_COUNT)"
fi

# 5. Plan completeness — all 3 sections should be addressed
echo "--- Plan Coverage ---"
if grep -q "def search\|def filter" "$SANDBOX/src/models/task.py" 2>/dev/null; then
    pass "TaskStore has search/filter methods"
else
    fail "TaskStore missing search/filter methods"
fi

# Summary
echo ""
echo "=== Result: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && echo "All structural checks passed." || echo "Some checks failed. See checklist.md for quality review."
