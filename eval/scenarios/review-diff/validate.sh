#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SANDBOX="$EVAL_DIR/sandbox"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Validating review-diff output ==="
echo ""

# 1. Artifact exists
echo "--- Artifact ---"
if [[ -f "$SANDBOX/.review/review.md" ]]; then
    pass ".review/review.md exists"
else
    fail ".review/review.md not found"
    echo ""
    echo "Result: $PASS passed, $FAIL failed"
    exit 1
fi

REVIEW="$SANDBOX/.review/review.md"

# 2. Required sections
echo "--- Sections ---"
for section in "Architecture" "Component" "Walkthrough"; do
    if grep -qi "$section" "$REVIEW"; then
        pass "Found section matching '$section'"
    else
        fail "Missing section matching '$section'"
    fi
done

# 3. Mermaid diagrams
echo "--- Diagrams ---"
MERMAID_COUNT=$(grep -c '```mermaid' "$REVIEW" 2>/dev/null || echo "0")
if [[ "$MERMAID_COUNT" -ge 2 ]]; then
    pass "Contains $MERMAID_COUNT mermaid diagrams (>= 2 expected)"
else
    fail "Contains $MERMAID_COUNT mermaid diagrams (>= 2 expected)"
fi

# 4. References actual changed files
echo "--- File Coverage ---"
for file in "tasks.py" "validators.py" "task.py"; do
    if grep -q "$file" "$REVIEW"; then
        pass "References changed file: $file"
    else
        fail "Missing reference to changed file: $file"
    fi
done

# 5. Content mentions the key changes
echo "--- Change Coverage ---"
if grep -qi "delete\|DELETE\|removal" "$REVIEW"; then
    pass "Mentions DELETE endpoint addition"
else
    fail "Doesn't mention DELETE endpoint"
fi

if grep -qi "validat\|description" "$REVIEW"; then
    pass "Mentions validation changes"
else
    fail "Doesn't mention validation changes"
fi

# Summary
echo ""
echo "=== Result: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && echo "All structural checks passed." || echo "Some checks failed. See checklist.md for quality review."
