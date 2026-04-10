#!/bin/bash
# TaskCompleted hook — runs when a teammate marks a task complete.
# Exit 0 = allow completion
# Exit 2 = block completion and send feedback message (stdout) to teammate

TASK_NAME="${1:-}"

# Builder tasks: run tests if they exist
if echo "$TASK_NAME" | grep -qi "implement\|chunk\|build"; then
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || [[ -d "tests" ]]; then
        TEST_OUTPUT=$(python -m pytest --tb=short 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests failed. Fix before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi

    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        TEST_OUTPUT=$(npm test 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests failed. Fix before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi
fi

# Frontend tasks: run linter and tests if they exist
if echo "$TASK_NAME" | grep -qi "frontend\|component\|ui\|page"; then
    if [[ -f "package.json" ]] && grep -q '"lint"' package.json; then
        LINT_OUTPUT=$(npm run lint 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Lint failed. Fix before marking complete:"
            echo "$LINT_OUTPUT" | tail -20
            exit 2
        fi
    fi

    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        TEST_OUTPUT=$(npm test 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests failed. Fix before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi
fi

# Backend tasks: run tests if they exist
if echo "$TASK_NAME" | grep -qi "backend\|service\|api\|endpoint"; then
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || [[ -d "tests" ]]; then
        TEST_OUTPUT=$(python -m pytest --tb=short 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests failed. Fix before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi

    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        TEST_OUTPUT=$(npm test 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests failed. Fix before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi
fi

# Reviewer tasks: check review.md exists and has content
if echo "$TASK_NAME" | grep -qi "review"; then
    if [[ -f ".review/review.md" ]]; then
        LINES=$(wc -l < .review/review.md | tr -d ' ')
        if [[ "$LINES" -lt 10 ]]; then
            echo "review.md is too short ($LINES lines). Add more detail."
            exit 2
        fi
        MERMAID=$(grep -c '```mermaid' .review/review.md 2>/dev/null || echo "0")
        if [[ "$MERMAID" -lt 1 ]]; then
            echo "review.md has no Mermaid diagrams. Add architecture diagrams."
            exit 2
        fi
    fi
fi

# Documenter tasks: check wiki exists
if echo "$TASK_NAME" | grep -qi "wiki\|document\|docs"; then
    if [[ -f ".docs/index.html" ]]; then
        SIZE=$(wc -c < .docs/index.html | tr -d ' ')
        if [[ "$SIZE" -lt 1000 ]]; then
            echo "index.html is too small (${SIZE} bytes). Needs more content."
            exit 2
        fi
    fi
fi

# QA tasks: check quality report exists and has content
if echo "$TASK_NAME" | grep -qi "qa\|test\|quality"; then
    if [[ -f ".qa/report.md" ]]; then
        LINES=$(wc -l < .qa/report.md | tr -d ' ')
        if [[ "$LINES" -lt 10 ]]; then
            echo "report.md is too short ($LINES lines). Add more detail."
            exit 2
        fi
    fi

    # Verify tests actually pass
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || [[ -d "tests" ]]; then
        TEST_OUTPUT=$(python -m pytest --tb=short 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests are failing. Fix or report before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi

    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        TEST_OUTPUT=$(npm test 2>&1)
        if [[ $? -ne 0 ]]; then
            echo "Tests are failing. Fix or report before marking complete:"
            echo "$TEST_OUTPUT" | tail -20
            exit 2
        fi
    fi
fi

# All good
exit 0
