# Session Memory Schema Design

> How we persist and retrieve context across Claude Code sessions

## Goals

1. **Claude-driven** - Claude decides what to save, not scripts
2. **Queryable** - Easy to search and retrieve relevant context
3. **Structured** - Consistent format for learning patterns
4. **Lightweight** - Don't bloat the knowledge graph

---

## Memory Types

### 1. Session Snapshots (memory_write)

Quick captures of "what was I working on?"

```json
{
  "name": "session-{project}-{timestamp}",
  "content": "## Session: {project}\n\n### Working On\n{task_description}\n\n### Key Decisions\n- {decision_1}\n- {decision_2}\n\n### Blockers/Questions\n- {blocker_1}\n\n### Next Steps\n- [ ] {todo_1}\n- [ ] {todo_2}",
  "category": "note",
  "project": "{project_name}",
  "tags": ["session", "checkpoint", "{trigger_type}"]
}
```

**When to create:**
- PreCompact (auto or manual)
- Explicit user request ("save this context")
- Major milestone completion

---

### 2. Learning Journal Entries (memory_write)

Longer-term insights and patterns learned.

```json
{
  "name": "learning-{project}-{topic}",
  "content": "## Learning: {topic}\n\n### Context\n{what_led_to_this}\n\n### Insight\n{what_we_learned}\n\n### Application\n{how_to_apply_this}\n\n### Related Sessions\n- session-{project}-{timestamp_1}\n- session-{project}-{timestamp_2}",
  "category": "decision",
  "project": "{project_name}",
  "tags": ["learning", "insight", "{domain}"]
}
```

**When to create:**
- After solving a non-trivial problem
- When a pattern emerges across sessions
- Architecture decisions with rationale

---

### 3. Knowledge Graph Entities (create_entities)

Structured relationships for complex projects.

```json
{
  "entities": [
    {
      "name": "{project_name}",
      "entityType": "project",
      "observations": [
        "Tech stack: {stack}",
        "Main purpose: {purpose}",
        "Current phase: {phase}"
      ]
    },
    {
      "name": "session-{timestamp}",
      "entityType": "session",
      "observations": [
        "Worked on: {task}",
        "Duration: {duration}",
        "Outcome: {outcome}"
      ]
    },
    {
      "name": "{decision_name}",
      "entityType": "decision",
      "observations": [
        "Choice: {what_we_chose}",
        "Alternatives: {what_we_rejected}",
        "Rationale: {why}"
      ]
    }
  ]
}
```

**Relations to create:**
```json
{
  "relations": [
    {
      "from": "session-{timestamp}",
      "to": "{project_name}",
      "relationType": "part_of"
    },
    {
      "from": "{decision_name}",
      "to": "session-{timestamp}",
      "relationType": "made_during"
    }
  ]
}
```

---

## Query Patterns

### Find recent sessions for a project
```
memory_search(query="session context", project="{project}", limit=3)
```

### Find decisions about a topic
```
memory_search(query="{topic} decision rationale", category="decision")
```

### Get full project context
```
read_graph()  # Then filter by project entity and relations
```

### Find related learnings
```
memory_search(query="learning {domain}", tags=["insight"])
```

---

## Claude Behavior Model

### On Session Start (triggered by hook output)

```
1. Check if gateway is running (health check)
2. If running, call memory_search("session context {project}", limit=1)
3. If found, summarize: "Last session: {summary}. Continue where we left off?"
4. If not found, proceed normally
```

### Before Compaction (Claude detects low context OR hook nudges)

```
1. Identify current task from conversation
2. Extract key decisions made
3. Note any incomplete work
4. Call memory_write with session snapshot
5. Optionally update knowledge graph if significant
```

### After Significant Work

```
1. If a problem was solved, create learning entry
2. If architecture decision was made, create decision entity
3. Link to current session
```

---

## Example Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ SESSION START                                                │
│                                                              │
│ Hook outputs: "Session persistence enabled..."               │
│ Claude sees this, calls memory_search                        │
│ Claude: "Found previous session. You were working on X..."   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ WORKING                                                      │
│                                                              │
│ User and Claude collaborate                                  │
│ Decisions are made, code is written                         │
│ Context window fills up                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ PRE-COMPACT (auto or manual)                                 │
│                                                              │
│ Hook fires, Claude is nudged                                 │
│ Claude: "Context is being compacted. Let me save state..."   │
│ Claude calls memory_write with session snapshot              │
│ Claude calls create_entities if significant decisions        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ POST-COMPACT                                                 │
│                                                              │
│ Context is summarized                                        │
│ Session continues with reduced context                       │
│ Memory server has the detailed checkpoint                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ SESSION END                                                  │
│                                                              │
│ Hook fires                                                   │
│ Final checkpoint saved (if not already done)                │
│ Learning journal updated with session insights              │
└─────────────────────────────────────────────────────────────┘
```

---

## Open Questions

1. **How much context can SessionStart hook inject?**
   - Need to test: does Claude see the full output?

2. **Can Claude detect compaction is imminent?**
   - Or does it only know after the hook fires?

3. **Token budget for restored context?**
   - Don't want to burn 10K tokens on session restore

4. **Conflict resolution?**
   - What if knowledge graph has stale data?
