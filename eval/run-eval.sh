#!/bin/bash
set -e

EVAL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL="${1:-}"

if [[ -z "$SKILL" ]]; then
    echo "Usage: ./run-eval.sh <skill-name> [validate]"
    echo ""
    echo "Available scenarios:"
    for dir in "$EVAL_DIR"/scenarios/*/; do
        name=$(basename "$dir")
        echo "  - $name"
    done
    echo ""
    echo "Steps:"
    echo "  1. ./run-eval.sh review-diff          # Set up scenario"
    echo "  2. Open eval/sandbox/ in Cursor        # Run the skill"
    echo "  3. ./run-eval.sh review-diff validate  # Validate output"
    exit 0
fi

SCENARIO_DIR="$EVAL_DIR/scenarios/$SKILL"
ACTION="${2:-setup}"

if [[ ! -d "$SCENARIO_DIR" ]]; then
    echo "Error: Unknown skill '$SKILL'"
    echo "Available: $(ls "$EVAL_DIR/scenarios/" | tr '\n' ' ')"
    exit 1
fi

case "$ACTION" in
    setup)
        bash "$SCENARIO_DIR/setup.sh"
        ;;
    validate)
        bash "$SCENARIO_DIR/validate.sh"
        ;;
    *)
        echo "Unknown action: $ACTION (use 'setup' or 'validate')"
        exit 1
        ;;
esac
