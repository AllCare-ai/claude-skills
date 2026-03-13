# Interview Question Banks

## Table of Contents
1. [Prompt 1 - Specification Engineer (All Steps)](#prompt-1)
2. [Prompt 2 - Intent & Delegation (Judgment Steps)](#prompt-2)
3. [Prompt 3 - Constraint Architecture (High-Consequence Steps)](#prompt-3)
4. [Pushback Questions (AI Agent Filter)](#pushback)
5. [Review Questions (Post-Draft)](#review)

---

## Prompt 1 — Specification Engineer (All Steps) <a id="prompt-1"></a>

Use for every step. This is the primary interview tool.

### Phase 1 — Project Intake (run once per project)

Ask these three questions before writing any specs:

1. "Give me a 2-sentence elevator pitch for this project. What does it do and who does it serve?"
2. "Who executes against these specs: AI agents, human engineers, or both?"
3. "What's the scope: full system at once, or one step at a time?"

### Phase 2 — Deep Interview (run once per step)

**Group 1 — Desired Output** `[PM]`
- "What exists at the end of this step that didn't before?"
- "What is this step's one job? Say it in one sentence."
- "What does this step explicitly NOT do? What's the scope boundary?"

**Group 2 — Hard Constraints** `[BOTH]`
- "What must NEVER happen at this step?"
- "What is the worst-case failure mode? What would trigger an audit, a safety incident, or a compliance violation?"
- "What data must never appear in logs, error messages, or debug output?"

**Group 3 — Hidden Context** `[BOTH]`
- "What does the executor need to know about the environment that isn't obvious?"
- "What's true about this channel, workflow, or system that would surprise a new engineer?"
- "What upstream dependencies or behaviors does this step rely on that aren't documented?"

**Group 4 — Edge Cases** `[BOTH]`
- "Which scenarios are most dangerous and must be explicitly handled?"
- "Which inputs are valid but unusual? What happens with them?"
- "Which failure modes require specific recovery behavior vs. generic error handling?"

**Group 5 — Tradeoffs** `[PM]`
- "Where can quality be sacrificed for speed when forced to choose?"
- "What is sacred and cannot be traded under any circumstance?"
- "If latency vs. correctness, which wins? Where is the line?"

**Group 6 — Definition of Done** `[PM]`
- "How do you know this step succeeded for a specific request?"
- "Name exactly three conditions that must ALL be true for this step to be complete."

---

## Prompt 2 — Intent & Delegation Framework (Judgment Steps) <a id="prompt-2"></a>

Add these question groups starting from whichever step involves AI judgment calls.

**Group 7 — Core Value (Prompt 2 Group A)** `[PM]`
- "What does this system optimize for that a reasonable alternative would not?"
- "What's the decision-maker's version of 'this step failed'? Not a technical failure, a business failure."

**Group 8 — Decision Authority (Prompt 2 Group B)** `[PM]`
- "What can the AI decide completely on its own with zero human involvement?"
- "What must escalate to a human before the AI acts?"
- "What does the AI do but notifies someone after the fact?"
- "Where exactly is the delegation boundary? What makes one decision autonomous and another escalated?"

**Group 9 — Quality Thresholds (Prompt 2)** `[PM]`
- "What is the line between a routine decision and a high-stakes decision at this step?"
- "What makes a specific input high-stakes vs. routine? Give me the specific signals."

**Group 10 — Special Handling (Prompt 2)** `[PM]`
- "What stakeholder, situation, or input type requires completely different handling from the normal rules?"
- "What are the true exceptions, not edge cases, but situations where the normal rules don't apply at all?"

**Group 11 — Pushback Question (constructed per step)** `[BOTH]`
- Format: "You said we're building for AI agents. [Restate their constraint]. Why does [action] require [limitation]? Is that a real safety constraint or defensive thinking?"

---

## Prompt 3 — Constraint Architecture Designer (High-Consequence Steps) <a id="prompt-3"></a>

Add these starting from whichever step has high-consequence constraints.

**Group 12 — Failure Mode Extraction** `[BOTH]`
- "What is the WORST thing that can go wrong at this step? Give me a specific scenario, not a category."
- "If that failure happened, what would the audit trail show? What would the customer or end user see?"
- Push for 3-5 specific failure modes before writing any constraints.
- For each failure mode: "What constraint prevents THIS specific failure?"

**The filter:** After extracting constraints, ask for each one:
- "Is this constraint derived from a specific failure, or from general caution?"
- If the user can't name the failure, cut the constraint.

---

## Pushback Questions — The AI Agent Filter <a id="pushback"></a>

Before finalizing any constraint, run this check:

"If I removed this constraint and let the AI decide, what's the worst thing that happens?"

- If the answer is real harm or compliance failure → keep the constraint
- If the answer is "the AI might do it differently than I would" → remove the constraint

For every HITL gate: "What happens if the AI makes this decision autonomously? Is the worst case real harm, or just 'the AI might choose differently'?"

**The Klarna Test (from Prompt 2):** "Am I optimizing for the label/rule, or for the action it triggers?" Catches rules that look right but produce wrong downstream behavior.

---

## Post-Draft Review Questions <a id="review"></a>

After generating the spec draft, ask the user:

1. "Is anything here that would surprise you to see in production?"
2. "Is anything here that would cause you to call a customer to explain?"
3. "Are any of the OPEN items actually already decided?"
4. "Did I miss any channel, input type, or stakeholder that exists in your real system?"
5. "Are the acceptance criteria specific enough that someone with no context could verify each one independently?"

---

## Production Bridge Question Banks (Prompts 5-9) <a id="production-bridge"></a>

Production bridge questions are in a separate file due to size. See [production-bridge-questions.md](production-bridge-questions.md) for:

- **Prompt 5** - Non-Functional Requirements (Groups 13-16): Latency, resource constraints, availability, load behavior
- **Prompt 6** - Scenarios & Satisfaction (Groups 17-19): Scenario design, satisfaction metrics, holdout sets
- **Prompt 7** - Digital Twin Universe (Groups 20-23): Dependency inventory, failure modes, behavioral fidelity, volume testing
- **Prompt 8** - Inter-Step Data Contracts (Groups 24-26): Schema definition, enforcement, versioning
- **Prompt 9** - Observability & Model Selection (Groups 27-30): Monitoring, alerting, drift detection, model assignment

## MECE Gap Question Banks (Prompt 10) <a id="mece-gaps"></a>

MECE gap questions are in a separate file. See [mece-gap-questions.md](mece-gap-questions.md) for:

- **Prompt 10** - Comprehensive Coverage (Groups 31-40): Security & audit, data lifecycle, cross-step coordination, gradual rollout, incident response, operational readiness, chaos engineering, deprecation & migration, documentation, data quality
- **Extensions** - Cost allocation (Q14.4-14.5) and capacity planning (Q16.5-16.6)
