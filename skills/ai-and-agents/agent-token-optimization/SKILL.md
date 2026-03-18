---
name: agent-token-optimization
description: >
  Reduce token consumption in AI agent systems without reducing capability or
  task quality. Use when designing agent prompts, optimizing heartbeat loops,
  debugging high token usage, or architecting multi-agent systems where cost
  matters. Covers the four root causes of token waste and systematic fixes.
  Derived from production analysis of 11,000+ agent runs in the Paperclip
  control plane.
---

# Agent Token Optimization

Systematic approach to reducing token consumption in AI agent systems. Based on analysis of 11,000+ production heartbeat runs that revealed four distinct causes of token waste.

## The Four Root Causes

### 1. Measurement Inflation

**Problem:** Token counters may report cumulative session totals instead of per-invocation deltas. One reused session spanning 3,600 runs reported input tokens growing to 1.1 billion, which is not credible for prompts averaging 193 characters.

**Fix:**
- Normalize token telemetry to per-invocation deltas, not cumulative session totals.
- Record `inputTokens`, `outputTokens`, and `cachedInputTokens` as deltas.
- If your runtime reports cumulative usage, compute `delta = current - previous` at each invocation.
- Trust your numbers before optimizing. Bad telemetry leads to bad decisions.

**Validation:** Compare reported token counts against actual prompt sizes. If a 200-char prompt reports millions of input tokens, your measurement is broken.

### 2. Avoidable Session Resets

**Problem:** Destroying and recreating sessions between agent invocations kills prompt cache locality. Every reset forces the model to re-process the full system prompt, skills, and context from scratch.

**Fix:**
- Reuse sessions across heartbeats for the same task when safe.
- Only reset sessions on: task change, security boundary crossing, or context corruption.
- For timer-based wakes on the same task, continue the existing session.
- For event-triggered wakes (new comment, approval), continue the session and append the new context.

**When session reset IS correct:**
- Agent is switching to a completely different task.
- Session context has drifted or become confused.
- Security boundary requires fresh context (different company, different permission level).

### 3. Repeated Context Reacquisition

**Problem:** Agent skills tell the agent to re-fetch assignments, task details, ancestor chains, and full comment threads on every heartbeat. This is safe but expensive.

**Fix: Incremental context loading.**

```
# BAD: Full reload every heartbeat
GET /tasks/{id}           # Full task object
GET /tasks/{id}/comments  # Entire comment thread

# GOOD: Incremental loading
GET /tasks/{id}/heartbeat-context   # Compact summary with cursor metadata
GET /tasks/{id}/comments?after={lastSeenCommentId}&order=asc  # Only new comments
```

Build API endpoints that support incremental access:
- **Heartbeat context endpoint:** Returns compact task state, ancestor summaries, goal/project info, and comment cursor metadata without full thread replay.
- **Comment cursor:** Track the last-seen comment ID. On subsequent heartbeats, fetch only comments posted after that cursor.
- **Event-specific loading:** If woken by a specific comment, fetch just that comment first, not the whole thread.

### 4. Large Static Instruction Surfaces

**Problem:** Agent instruction files and globally injected skills are reintroduced at startup even when most content is unchanged and irrelevant to the current task.

**Fix: Separate bootstrap from heartbeat prompts.**

| Layer | When Loaded | Content | Caching |
|-------|------------|---------|---------|
| **Bootstrap prompt** | Session start only | Identity, core rules, skills, safety invariants | Prompt-cached across heartbeats |
| **Heartbeat prompt** | Every invocation | Dynamic context: current task, new comments, trigger info | Small, changes each time |

The bootstrap prompt should be:
- Stable across heartbeats (maximizes prompt cache hits).
- Front-loaded in the message array (prompt caching works on prefixes).
- Comprehensive but not exhaustive. Move rare workflows to on-demand reference.

**Skill splitting pattern:**
- **Always-loaded core:** The common heartbeat loop, auth, checkout, status updates.
- **On-demand reference:** Rare workflows (approval handling, escalation paths, edge cases). Load only when the current task requires them.

## Optimization Checklist

### Quick Wins (do first)

- [ ] Normalize token telemetry to per-invocation deltas.
- [ ] Reuse sessions across heartbeats for the same task.
- [ ] Add incremental comment loading with cursor.
- [ ] Separate bootstrap prompt from heartbeat prompt.

### Medium Effort

- [ ] Build a compact heartbeat-context API endpoint.
- [ ] Split skills into always-loaded core + on-demand reference.
- [ ] Add session compaction/rotation for long-lived sessions.
- [ ] Track prompt cache hit rates as a first-class metric.

### Requires Evals First

- [ ] Tighten skill instructions (remove redundancy, compress language).
- [ ] Switch to smaller models for specific agent roles.
- [ ] Remove skill sections that agents rarely use.

Do NOT tighten skills without evals. Skill instructions are part of the safety surface. Reducing them may save tokens but introduce behavioral regressions that are hard to detect without automated testing.

## Measuring Success

Track these metrics per agent, per task type:

| Metric | What It Tells You |
|--------|-------------------|
| `input_tokens_per_heartbeat` | Total context cost per invocation |
| `cached_input_ratio` | How much prompt caching is helping (target: >80%) |
| `output_tokens_per_heartbeat` | How verbose the agent is being |
| `context_reload_rate` | How often full context reloads happen vs incremental |
| `session_reuse_rate` | How often sessions survive across heartbeats |
| `task_completion_rate` | Must not degrade when optimizing tokens |

The goal is reducing `input_tokens_per_heartbeat` while keeping `task_completion_rate` constant or improving. If completion rate drops, you've cut too deep.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|-------------|---------------|
| Optimizing before measuring | You might optimize the wrong thing |
| Tightening prompts without evals | Behavioral regressions are silent |
| Session reset on every wake | Destroys prompt cache locality |
| Full context reload every heartbeat | Scales linearly with conversation length |
| Treating all skills as always-needed | Most heartbeats use 20% of skill content |
| Using the same model for every agent | Some tasks need GPT-4, some need Haiku |
