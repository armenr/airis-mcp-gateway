#!/bin/bash
# .claude/hooks/capture-precompact.sh
# Nudge Claude to save context before compaction

CAPTURE_DIR="$HOME/.claude/hook-captures"
mkdir -p "$CAPTURE_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CAPTURE_FILE="$CAPTURE_DIR/precompact-$TIMESTAMP.json"
GATEWAY="http://localhost:9400"

# Capture stdin for debugging
cat > "$CAPTURE_FILE"

# Get trigger type
TRIGGER=$(jq -r '.trigger // "unknown"' "$CAPTURE_FILE" 2>/dev/null)
echo "[$(date -Iseconds)] PreCompact triggered ($TRIGGER)" >> "$CAPTURE_DIR/hook.log"

# Check if gateway is running
GATEWAY_STATUS=$(curl -sf "$GATEWAY/health" 2>/dev/null | jq -r '.status // "unavailable"')

if [ "$GATEWAY_STATUS" = "healthy" ]; then
  # Gateway is running - nudge Claude to save context
  cat << EOF

<pre-compact-save-context>
CONTEXT COMPACTION IMMINENT ($TRIGGER). Per CLAUDE.md instructions, SAVE CONTEXT NOW:

1. Identify what you were working on
2. Note key decisions made and their rationale
3. List incomplete items and next steps
4. Call memory_write with:
   - name: "session-airis-mcp-gateway-$TIMESTAMP"
   - category: "note"
   - tags: ["session", "checkpoint", "$TRIGGER"]
   - content: Use the session checkpoint format from CLAUDE.md

5. If significant architecture/design decisions were made, call create_entities

DO THIS NOW before context is lost.
</pre-compact-save-context>

EOF
else
  cat << 'EOF'

<pre-compact-warning>
Context compaction imminent but AIRIS MCP Gateway is not running.
Session context WILL BE LOST. Consider noting important context in your response.
</pre-compact-warning>

EOF
fi

exit 0
