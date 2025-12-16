# AIRIS MCP Gateway - Future Ideas

> Captured from reflection session 2025-12-16
> Status: Discussion/Analysis phase

## The Big 10

### HIGH PRIORITY - Deep Dive Items

#### 1. Cross-Session Learning Journal ⭐
Auto-generated knowledge from memory server tracking:
- What you worked on each session
- Key decisions made and why
- Next steps identified
- Patterns learned

```markdown
# Auto-generated from memory server
## Session 2025-12-16
- Worked on: DNS fixes, cold start improvements
- Key decisions: esbuild bundling, pre-warming
- Next steps: Update PR description
```

**Status:** 🔍 Deep-dive in progress

---

#### 2. Conversation Memory Bridge ⭐
```bash
# Auto-save session context to memory server
airis session:save "Working on auth refactor"
airis session:resume  # → Loads last context into Claude
```
*Why:* The #1 pain point is losing context between Claude Code sessions.

**Status:** 🔍 Deep-dive in progress

---

### MEDIUM PRIORITY - Queued for Discussion

#### 3. Project Profiles with Auto-Switching
```bash
# Detect project type from .git, package.json, pyproject.toml
airis profile:detect   # → "Detected: TypeScript + React"
                       # → Enables: context7, playwright, magic
```
*Why:* Different projects need different tools.

---

#### 4. Tool Usage Analytics + Smart Pruning
```bash
airis stats
# → memory: 847 calls (keep)
# → tavily: 12 calls (keep)
# → morphllm: 0 calls (suggest disable)
```
*Why:* Most people enable everything then wonder why startup is slow.

---

#### 5. Local Web Dashboard (localhost:9401)
- Live server status (running/stopped/error)
- Real-time logs streaming
- One-click enable/disable servers
- Tool call history with timing

*Why:* `docker compose logs` isn't great for quick debugging.

---

#### 6. Hot Config Reload
```bash
# Edit mcp-config.json → changes apply without restart
```
*Why:* Restarting loses all warmed-up servers.

---

#### 7. Smart Pre-warming Based on Usage Patterns
```python
usage_patterns = {
    "research": ["tavily", "fetch", "sequential-thinking"],
    "coding": ["memory", "serena", "context7"]
}
```
*Why:* Reduce cold starts for common workflows.

---

#### 8. Tool Aliases + Shortcuts
```json
{
  "aliases": {
    "remember": "memory_write",
    "recall": "memory_search",
    "search": "tavily_search"
  }
}
```
*Why:* `mcp__airis-mcp-gateway__memory_write` is verbose.

---

#### 9. Offline Mode Detection
```python
# If no internet, auto-disable: tavily, fetch, context7
# Prevents timeout errors on airplane/train
```
*Why:* Fail fast instead of waiting 60s for timeouts.

---

#### 10. One-Command Bootstrap
```bash
curl -fsSL https://airis.dev/install | sh
# → Installs Docker if needed
# → Clones repo, starts gateway, registers with Claude Code
```
*Why:* Even `docker compose up` is friction.

---

## Deep Dive Notes

### Claude Code Lifecycle Hooks Integration

Potential hook points:
- `PreCompact` - Context below threshold, about to summarize
- `PostCompact` - Just finished summarizing
- `SessionStart` - New conversation started
- `SessionEnd` - User exits or closes
- `ManualCompact` - User triggers /compact

Questions to explore:
- [ ] What hooks does Claude Code actually expose?
- [ ] Can we intercept compaction events?
- [ ] How do we trigger tool calls from hooks?
- [ ] What data is available at each hook point?

---

## Priority Matrix

| # | Feature | Effort | Impact | Dependencies |
|---|---------|--------|--------|--------------|
| 1 | Cross-Session Learning Journal | Medium | 🔥 High | Memory server |
| 2 | Conversation Memory Bridge | Medium | 🔥 High | Memory server, hooks |
| 3 | Project Profiles | Low | High | Config system |
| 4 | Usage Analytics | Low | Medium | Metrics endpoint |
| 5 | Web Dashboard | Medium | High | New service |
| 6 | Hot Config Reload | Medium | Medium | File watcher |
| 7 | Smart Pre-warming | Low | Medium | Usage analytics |
| 8 | Tool Aliases | Low | Low | Config extension |
| 9 | Offline Detection | Low | Medium | Network check |
| 10 | One-Command Bootstrap | Medium | High | Installer script |
