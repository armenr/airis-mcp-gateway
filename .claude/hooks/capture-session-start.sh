#!/bin/bash
# .claude/hooks/capture-session-start.sh
# Nudge Claude to check for previous session context

CAPTURE_DIR="$HOME/.claude/hook-captures"
mkdir -p "$CAPTURE_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CAPTURE_FILE="$CAPTURE_DIR/session-start-$TIMESTAMP.json"
GATEWAY="http://localhost:9400"

# Capture stdin for debugging
cat > "$CAPTURE_FILE"

# Log the event
TRIGGER=$(jq -r '.trigger // "unknown"' "$CAPTURE_FILE" 2>/dev/null)
echo "[$(date -Iseconds)] SessionStart triggered ($TRIGGER)" >> "$CAPTURE_DIR/hook.log"

# Check if gateway is running
GATEWAY_STATUS=$(curl -sf "$GATEWAY/health" 2>/dev/null | jq -r '.status // "unavailable"')

if [ "$GATEWAY_STATUS" = "healthy" ]; then
  # Gateway is running - nudge Claude to check for previous context
  cat << 'EOF'

<session-context-reminder>
AIRIS MCP Gateway is running. Per CLAUDE.md instructions:

1. Check for previous session context by calling:
   memory_search(query="session context airis-mcp-gateway", limit=1)

2. If found, briefly summarize and ask if user wants to continue that work.

3. Remember: Save context BEFORE compaction events (you'll sense when context is low).
</session-context-reminder>

EOF
else
  # Gateway not running - inform Claude
  cat << 'EOF'

<session-context-reminder>
AIRIS MCP Gateway is not running. Session persistence unavailable.

To enable: task docker:up (or docker compose up -d)
</session-context-reminder>

EOF
fi

exit 0
