---
name: agent-heartbeat-pattern
description: >
  Structured heartbeat loop for AI agents that wake periodically, check assignments,
  do work, and exit. Use when designing agent execution loops, task pickup patterns,
  blocked-task handling, incremental context loading, or any agent that runs in
  short execution windows rather than continuously. Derived from production patterns
  in the Paperclip control plane.
---

# Agent Heartbeat Pattern

A reusable execution pattern for AI agents that run in short windows (heartbeats) rather than continuously. Each heartbeat: wake, orient, work, communicate, exit.

## The Core Loop

Every heartbeat follows this sequence. Skip steps that don't apply, but preserve the order.

### Step 1: Identity

Confirm who you are. Load your agent ID, company/org context, role, permissions, and budget from the control plane or environment.

```
GET /agents/me -> { id, orgId, role, permissions, budget }
```

If identity is already in session context from a prior heartbeat, skip.

### Step 2: Check Triggers

If this heartbeat was triggered by a specific event (a comment mention, an approval resolution, a webhook), handle that trigger first before checking the general inbox.

Common triggers:
- **Comment mention:** Read the specific comment thread. Respond if asked for input. Only self-assign if explicitly asked to take ownership.
- **Approval resolution:** Check the approval status. Close linked tasks if resolved, or comment explaining what happens next.
- **Scheduled wake:** No specific trigger. Proceed to inbox.

### Step 3: Get Assignments

Fetch your current task list. Prefer a lightweight inbox endpoint over full task objects.

```
GET /agents/me/inbox -> [{ id, title, status, priority }]
```

Prioritize: `in_progress` first, then `todo`. Skip `blocked` unless you can unblock it.

### Step 4: Blocked-Task Dedup

Before re-engaging a blocked task, check its comment thread. If your most recent comment was a blocked-status update AND no new comments from other agents or users have been posted since, **skip it entirely**. Do not checkout, do not post another comment. Exit the heartbeat or move to the next task.

Only re-engage with a blocked task when new context exists.

This prevents the "agent spam" problem where agents repeatedly comment on stuck tasks without new information.

### Step 5: Checkout

Acquire exclusive ownership before doing any work. Include a run/trace ID for audit.

```
POST /tasks/{id}/checkout
{ "agentId": "{your-id}", "expectedStatuses": ["todo", "backlog", "blocked"] }
```

If already checked out by you, proceed. If owned by another agent (409 Conflict), pick a different task. **Never retry a 409.**

### Step 6: Load Context Incrementally

Do not reload the entire task history on every heartbeat. Use incremental strategies:

1. **First contact:** Load full context (task details, ancestor summaries, comment thread).
2. **Subsequent heartbeats:** Load only new comments since your last seen comment ID.
3. **Event-triggered:** Load the specific comment or event that triggered this wake.

```
# Full context (first time)
GET /tasks/{id}/context -> { task, ancestors, comments, metadata }

# Incremental (subsequent)
GET /tasks/{id}/comments?after={lastSeenId}&order=asc
```

Read enough ancestor/comment context to understand WHY the task exists and what changed. Do not reflexively reload everything.

### Step 7: Do the Work

Use your tools and capabilities. This is domain-specific.

### Step 8: Update Status and Communicate

Always update task status before exiting. If blocked, mark as blocked with a comment explaining:
- What the blocker is
- Who needs to act
- What you tried

```
PATCH /tasks/{id}
{ "status": "done", "comment": "What was done and why." }
```

### Step 9: Exit

Release the heartbeat. The next wake will pick up where you left off.

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Reloading full context every heartbeat | Use incremental comment loading with cursor |
| Commenting on blocked tasks with no new info | Blocked-task dedup check before engaging |
| Retrying 409 checkout conflicts | Pick a different task immediately |
| Running without checkout | Always checkout before work. No exceptions. |
| Ignoring trigger context | If woken by a specific event, handle that first |
| Holding session state across heartbeats | Write durable state to files or API. Sessions reset. |

## Adapting This Pattern

This pattern works for any agent runtime:
- **Paperclip/control plane agents:** Direct API calls as shown.
- **LangGraph agents:** Map each step to a node in the graph. The checkout and dedup steps become conditional edges.
- **Cron-based agents:** The heartbeat IS the cron job. Each invocation follows the full loop.
- **Event-driven agents:** Steps 1-2 are the event handler. Steps 3-8 are the processing logic.

The key insight: agents that run in short windows need explicit state management between runs. The heartbeat loop makes that state management systematic rather than ad-hoc.
