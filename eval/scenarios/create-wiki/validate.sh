#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Validating create-wiki output ==="
echo ""

# 1. Artifact exists
echo "--- Artifact ---"
if [[ -f "$SANDBOX/.docs/index.html" ]]; then
    pass ".docs/index.html exists"
else
    fail ".docs/index.html not found"
    echo ""
    echo "Result: $PASS passed, $FAIL failed"
    exit 1
fi

WIKI="$SANDBOX/.docs/index.html"
WIKI_SIZE=$(wc -c < "$WIKI" | tr -d ' ')

if [[ "$WIKI_SIZE" -gt 1000 ]]; then
    pass "File size is ${WIKI_SIZE} bytes (> 1000 expected)"
else
    fail "File size is ${WIKI_SIZE} bytes — seems too small"
fi

# 2. HTML structure
echo "--- HTML Structure ---"
if grep -q '<html' "$WIKI"; then
    pass "Contains <html> tag"
else
    fail "Missing <html> tag"
fi

if grep -q '<nav\|sidebar\|navigation' "$WIKI"; then
    pass "Contains navigation/sidebar element"
else
    fail "Missing navigation/sidebar"
fi

if grep -qi 'task\|tracker\|api' "$WIKI"; then
    pass "References the project (task/tracker/API)"
else
    fail "Doesn't reference the project name"
fi

# 3. Content sections — the wiki should cover key aspects
echo "--- Content Coverage ---"
for keyword in "endpoint\|route\|api" "model\|task\|store" "test\|pytest" "valid"; do
    if grep -qi "$keyword" "$WIKI"; then
        pass "Covers topic matching: $keyword"
    else
        fail "Missing topic matching: $keyword"
    fi
done

# 4. Styling
echo "--- Styling ---"
if grep -q '<style\|\.css' "$WIKI"; then
    pass "Contains CSS styling"
else
    fail "Missing CSS — page will be unstyled"
fi

if grep -qi 'theme\|dark\|light' "$WIKI"; then
    pass "Has theme support"
else
    fail "No theme toggle found (optional but expected)"
fi

# Summary
echo ""
echo "=== Result: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && echo "All structural checks passed." || echo "Some checks failed. See checklist.md for quality review."
