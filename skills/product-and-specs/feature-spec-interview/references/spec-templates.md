# Spec Output Templates

## Table of Contents
1. [7-Section Format (Structural Steps)](#7-section)
2. [14-Section Format (Judgment Steps)](#14-section)
3. [NLSpec Writing Rules](#nlspec)

---

## 7-Section Format — Structural Steps <a id="7-section"></a>

Use for steps where the AI executes structural operations with minimal judgment calls. The step receives input, transforms or stores it, and passes output to the next step.

```
=== PROJECT SPECIFICATION ===
Project: [Project Name] — Step N: [Step Name]
Date: [date]
Status: Draft — review before execution

---

## 1. Overview

2-3 sentences: what this step does and why it matters.
One sentence: what it explicitly does NOT do (scope boundary).

## 2. Acceptance Criteria

Numbered list of verifiable conditions.
Each criterion checkable by an independent observer.
No vague criteria ("high quality"). Only observable outcomes.
Every criterion uses WHAT/WHEN/WHY/VERIFY format.
VERIFY = the executing agent's self-check before advancing.

## 3. Constraint Architecture

### Must Do
Non-negotiable requirements. Each uses WHAT/WHEN/WHY/VERIFY format.

### Must Not Do
Explicit prohibitions. Each with a one-line failure mode explanation:
- Must not [action].
  Prevents: [specific failure scenario]

### Prefer
Judgment guidance when multiple approaches are valid.

### Escalate (Do Not Decide — Surface to [Owner])
Technology/architecture decisions for engineering.
Mark each: [OPEN — Engineering] or [OPEN — PM + Engineering]

## 4. Task Decomposition

Sub-tasks, each with:
- Input / Output / Acceptance Criteria / Dependencies / Scope
Technology scope questions: [OPEN — Engineering]

## 5. Evaluation Criteria

How to assess whether the step is working correctly in production.
Specific and measurable where possible.

## 6. Context and Reference

Background the executor needs.
Why specific decisions were made (the "why" that prevents
"smart but wrong" execution).
Constraints from external factors (compliance, channel behavior, etc.)

## 7. Definition of Done

Exactly three conditions that must all be true.
"Step is complete when ALL of the following are true..."

## --- Production Bridge Sections (add when applicable) ---

## 8. Non-Functional Requirements (Prompt 5)
P99 latency target, max concurrent requests, throughput.
Resource budgets: token limits, cost ceiling, memory/CPU.
Availability target (SLO/SLA) and error budget.
Graceful degradation behavior. Circuit breaker spec.
Load shedding policy under resource exhaustion.

## 9. Scenarios & Satisfaction (Prompt 6)
End-to-end user story scenarios (not structured test cases).
Satisfaction scoring: per-step thresholds, aggregate threshold.
Holdout set design: percentage, rotation schedule, feedback template.
Gaming detection signals.

## 10. Digital Twin Requirements (Prompt 7)
Dependency inventory: system, purpose, read/write, critical path?
Failure modes to replicate per dependency.
Behavioral fidelity level per dependency.
Volume and latency distribution requirements.

## 11. Inter-Step Data Contracts (Prompt 8)
Output schema: exact fields, types, required/optional.
Input validation: what the consuming step expects.
Contract enforcement: producer-side, consumer-side, or both.
Versioning strategy and migration rules.

## 12. Observability & Model Assignment (Prompt 9)
Continuous monitoring: which criteria, metrics, sampling rate.
Alerts: invariant violations, severity, runbooks.
Drift detection: signals, thresholds, feedback loop to spec.
Model assignment: which model, fallback chain, consensus rules.

## 13. Security, Access Control & Audit (Prompt 10)
Access control: roles, permissions, service accounts.
Audit logging: what's logged, retention, tamper-proofing.
PHI/PII handling: encryption, BAAs, remediation for leaks.

## 14. Data Lifecycle & Compliance (Prompt 10)
Retention periods per data type with regulatory basis.
Deletion/anonymization policy and right-to-deletion handling.
Archival strategy: hot/warm/cold tiers, retrieval times.

## 15. Operational Readiness (Prompt 10)
Cross-step coordination: side effects, concurrency, compensation.
Rollout plan: stages, gating metrics, rollback triggers.
Incident response: runbooks, on-call, post-incident spec updates.
Chaos engineering: fault injection targets, blast radius, success criteria.
Deprecation plan: expected lifespan, migration path, communication.
Documentation requirements: what docs exist alongside the spec.
Data quality: dimensions, thresholds, responsibility boundaries.
```

---

## 14-Section Format — Judgment Steps <a id="14-section"></a>

Use for steps where the AI exercises judgment: classification, delegation, routing, escalation, communication decisions. This format uses all three prompts.

```
=== PROJECT SPECIFICATION ===
Project: [Project Name] — Step N: [Step Name]
Date: [date]
Status: Draft — review before execution

Note: This spec applies Prompt 1 (Specification Engineer) +
Prompt 2 (Intent & Delegation Framework Builder) +
Prompt 3 (Constraint Architecture Designer).
Constraints are derived from failure modes, not from speculative guardrails.

---

## 1. Overview
What this step does, why it matters, scope boundary.

## 2. Core Intent (Prompt 2)
What the system optimizes for that a reasonable alternative would not.
What the decision-maker's version of "step failed" looks like.

## 3. Priority Hierarchy (Prompt 2)
Ordered conflict resolution. When these values conflict, resolve
in this order: [1] ... [2] ... etc.

## 4. Acceptance Criteria (Prompt 1)
Independently verifiable conditions. Same rules as 7-section format.
Every criterion uses WHAT/WHEN/WHY/VERIFY format.
VERIFY = the executing agent's self-check before advancing.

## 5. Constraint Architecture (Prompt 3 — failure-mode-driven)

### Failure Mode [Name]: [description]
[Constraints derived from this specific failure mode]

Must Do
Must Not Do (each tied to a specific failure mode)
Prefer
Escalate [OPEN — Engineering] or [OPEN — PM + Engineering]

## 6. Decision Authority Map (Prompt 2)
### Decide Autonomously
### Decide with Notification (flag and proceed)
### Escalate Before Acting (do not act without human)

## 7. Quality Thresholds (Prompt 2)
Routine vs. high-stakes definition for this step.
The explicit line between them.

## 8. Common Failure Modes (Prompt 2 + Prompt 3)
Numbered failures with: what happened, root cause, correct approach.

## 9. Special Handling Rules (Prompt 2)
Exceptions to normal rules. Specific situations that need
different behavior.

## 10. Klarna Test (Prompt 2)
Self-check before finalizing. "Am I optimizing for the
label/rule, or for the action it triggers?"
Specific check questions for this step.

## 11. Task Decomposition (Prompt 1)
Same sub-task format as 7-section. Input/Output/Acceptance/
Dependencies/Scope.

## 12. Evaluation Criteria (Prompt 1)
How to know this step is working in production.

## 13. Context and Reference (Prompt 1)
The WHY behind key decisions. Same as section 6 in 7-section format.

## 14. Definition of Done (Prompt 1)
Conditions that must all be true. Same rigor as 7-section format.

## --- Production Bridge Sections (add when applicable) ---

## 15. Security, Access Control & Audit (Prompt 10)
Access control: roles, permissions, service accounts.
Audit logging: what's logged, retention, tamper-proofing.
PHI/PII handling: encryption, BAAs, remediation for leaks.

## 16. Data Lifecycle & Compliance (Prompt 10)
Retention periods per data type with regulatory basis.
Deletion/anonymization policy and right-to-deletion handling.
Archival strategy: hot/warm/cold tiers, retrieval times.

## 17. Operational Readiness (Prompt 10)
Cross-step coordination: side effects, concurrency, compensation.
Rollout plan: stages, gating metrics, rollback triggers.
Incident response: runbooks, on-call, post-incident spec updates.
Chaos engineering: fault injection targets, blast radius, success criteria.
Deprecation plan: expected lifespan, migration path, communication.
Documentation requirements: what docs exist alongside the spec.
Data quality: dimensions, thresholds, responsibility boundaries.
```

---

## NLSpec Writing Rules <a id="nlspec"></a>

Every behavioral statement in the spec must have four components:

```
WHAT:   The system must do X
WHEN:   Under condition Y
WHY:    Because Z
VERIFY: By checking V
```

The "why" is the most important part. When an agent encounters an edge case the spec didn't anticipate, the "why" allows it to make the correct decision. The "verify" closes the loop: it defines how to confirm the behavior is correct in production, not just at deploy time.

**Bad:** "The system must validate the patient record."

**Good:** "WHAT: The system must verify that a record exists for the identified entity before proceeding to task creation. WHEN: After entity resolution succeeds (Step 3). WHY: Downstream steps (scheduling, task routing, assignment) all require a canonical record. Proceeding without one causes silent failures that are impossible to trace post-hoc. VERIFY: Monitor the ratio of 'record not found' errors to total requests. Baseline: <0.5%. Alert if >2% over any 1-hour window."

### The New-Hire Test

A spec is complete when a capable new hire with no context could implement it with at most one clarifying question. If you would need to explain something verbally, that explanation belongs in the spec.

### Constraint Writing Rules

A constraint is a measurable invariant, not a policy statement.

| Not a constraint | A constraint |
|---|---|
| "The system must be fast." | "P99 latency must not exceed 800ms under 100 concurrent requests." |
| "Handle errors gracefully." | "On 5xx: retry with exponential backoff, base 2s, max 30s, max 3 attempts. Surface structured error." |
| "Protect user data." | "PII fields must not appear in application logs at any level. Audit entries must include user_id, action, timestamp, resource_id." |

If a constraint cannot be automatically verified, rewrite it until it can.

### [OPEN] Item Markers

In **PM-first mode**:
- `[OPEN — Engineering]` for technology decisions skipped (ENG-tagged groups)
- `[OPEN — PM + Engineering]` for joint decisions requiring both sides

In **Eng-first mode**:
- `[OPEN — PM]` for product decisions skipped (PM-tagged groups)
- `[OPEN — PM + Engineering]` for joint decisions requiring both sides

In **All mode**:
- `[OPEN]` for any decision not yet made, with a note on what's needed to resolve it

In **Quick mode**:
- `[QUICK — expand with full interview if needed]` for all skipped sections (production bridge, MECE groups 33-40)

In **Fill-gaps mode**:
- No new markers. Parse existing `[OPEN]` items and resolve them via interview.
