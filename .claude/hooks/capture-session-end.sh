#!/bin/bash
# .claude/hooks/capture-session-end.sh
# TEST HOOK: Capture SessionEnd data

CAPTURE_DIR="$HOME/.claude/hook-captures"
mkdir -p "$CAPTURE_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CAPTURE_FILE="$CAPTURE_DIR/session-end-$TIMESTAMP.json"

# Capture stdin
cat > "$CAPTURE_FILE"

# Log the event
echo "[$(date -Iseconds)] SessionEnd triggered, captured to: $CAPTURE_FILE" >> "$CAPTURE_DIR/hook.log"

exit 0
