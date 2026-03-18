# Completeness Audit & Verification

Run this audit after writing every spec, before presenting the final version to the user. The audit has three phases.

## Phase 1: Structural Completeness

Check every section exists and is non-empty:

### 7-Section Specs
- [ ] Overview states what the step does AND what it does NOT do
- [ ] Acceptance Criteria are numbered, each independently verifiable
- [ ] Constraint Architecture has all four quadrants (Must Do, Must Not Do, Prefer, Escalate)
- [ ] Every Must Not Do has a one-line failure mode explanation
- [ ] Task Decomposition has sub-tasks with Input/Output/Acceptance/Dependencies/Scope
- [ ] Evaluation Criteria are specific and measurable
- [ ] Definition of Done has exactly three conditions

### 14-Section Specs (all of the above, plus)
- [ ] Core Intent states what the system optimizes for
- [ ] Priority Hierarchy is explicitly ordered (when X conflicts with Y, X wins)
- [ ] Constraints are organized by failure mode, not by category
- [ ] Decision Authority Map has all three sections (Autonomous / Notify / Escalate)
- [ ] Quality Thresholds define the routine vs. high-stakes line
- [ ] Common Failure Modes have: what happened, root cause, correct approach
- [ ] Klarna Test is applied (optimizing for action, not label)

## Phase 2: Content Quality Audit

For each acceptance criterion:
- [ ] Can an independent observer verify this without asking anyone?
- [ ] Is the language specific (numbers, names, thresholds) or vague ("high quality", "fast")?
- [ ] Does it describe an observable outcome, not an internal state?

For each constraint:
- [ ] Is it traceable to a specific failure mode?
- [ ] Is it measurable/automatically verifiable?
- [ ] Apply the pushback: "If I removed this and let the AI decide, what's the worst case?"

For the Definition of Done:
- [ ] Are all three conditions independently testable?
- [ ] Do they cover correctness (right output), completeness (nothing missing), and auditability (provably happened)?

For [OPEN] items:
- [ ] Is every technology/architecture decision explicitly marked [OPEN]?
- [ ] Is every [OPEN] item assigned to a specific owner?
- [ ] Are there any implicit decisions that should be [OPEN] but aren't?

## Phase 3: Gap Detection (The Deep Dive)

These are the questions that surface hidden gaps. Run each one against the spec:

### Input Completeness
- "What are ALL the input types/channels/sources this step receives?"
- "For each input type: what does a malformed version look like? Is it handled?"
- "What happens when the input is empty, null, or missing required fields?"
- "What happens when the input is valid but unusual (very large, very small, unexpected encoding)?"

### Output Completeness
- "What are ALL the outputs this step produces?"
- "For each output: who consumes it downstream? What happens if it's wrong?"
- "Is there a state where this step produces no output at all? Is that handled?"

### Concurrency & Timing
- "What happens if two identical requests arrive simultaneously?"
- "What happens if a dependency this step relies on is slow or down?"
- "What happens if this step is re-run on an already-processed input?"
- "Is there a race condition between this step and any parallel step?"

### Failure & Recovery
- "For each external dependency: what happens when it returns an error?"
- "What is the retry behavior? Is it explicit or assumed?"
- "After a failure and recovery, is the system in a consistent state?"
- "Is there a failure mode that produces silent data corruption?"

### Scope Boundary Violations
- "Does this step do anything that belongs in the previous or next step?"
- "Is there logic here that duplicates logic in another step?"
- "Are there decisions being made here that should be made elsewhere?"

### The New-Hire Test
- "Could a capable new hire implement this with at most one clarifying question?"
- "What would they ask? That question's answer belongs in the spec."

### The Machine-Verify Test
- "Can every acceptance criterion be verified by an automated check (script, LLM judge, or metric query) without human interpretation?"
- If a criterion requires a human to read output and decide "looks good," rewrite it with a measurable threshold.

### The Bounded Feedback Test
- "If this spec fails a holdout scenario, does the feedback template tell the builder WHAT failed and WHERE, without revealing the expected output?"
- If bounded feedback would leak the answer, restructure into category-level feedback (e.g., "classification accuracy failed" not "expected: urgent, got: routine").

### The Grilling Test (recap)
- Every constraint must trace to a specific failure mode. If removing the constraint doesn't cause real harm, cut it.

## Phase 4: Cross-Step Consistency (Multi-Spec Projects)

When multiple specs exist for the same project:

- [ ] Output of Step N matches expected input of Step N+1
- [ ] No contradictory constraints between steps
- [ ] Entity/field names are consistent across specs
- [ ] State transitions are consistent (a state defined in one step is recognized in all others)
- [ ] [OPEN] items don't create circular dependencies between specs
- [ ] Parallel steps don't have conflicting write targets

## Phase 5: Production Bridge Audit

Run this phase after the production bridge interview (Prompts 5-9). Only check sections that apply to this step (see applicability table in SKILL.md Phase 1b).

### Non-Functional Requirements (Prompt 5)
- [ ] P99 latency target is specified with a number and unit
- [ ] Max concurrent requests is specified (sustained and peak)
- [ ] Cost ceiling per request is specified (or explicitly marked [OPEN])
- [ ] Token budget per LLM call is specified (input, output, model)
- [ ] Availability target has a number, measurement window, and error budget
- [ ] Circuit breaker has threshold, cooldown, and behavior-while-open specified
- [ ] Load shedding policy is explicit (shed/queue/reject with priority order)
- [ ] NFRs are backed by measurement or SLA, not speculation (Measurement Principle applied)

### Scenarios & Satisfaction (Prompt 6)
- [ ] At least 5 end-to-end scenarios exist (not structured test cases)
- [ ] Scenarios are independent (no shared state between runs)
- [ ] Satisfaction threshold is numeric, per-step AND aggregate
- [ ] Holdout set is defined (percentage, rotation schedule)
- [ ] Bounded feedback template specifies what info goes back to the builder
- [ ] At least one gaming detection signal is defined
- [ ] Scenarios trace to real production traffic (not invented test cases)

### Digital Twin Universe (Prompt 7)
- [ ] Every external dependency is listed with purpose, access pattern, and criticality
- [ ] Failure modes to replicate are traced to real production incidents
- [ ] Behavioral fidelity level is specified per dependency (exact fields vs. status codes)
- [ ] Stateful vs. stateless requirement is defined per dependency
- [ ] Volume and latency distribution requirements are specified
- [ ] Speculative failure modes (no production evidence) are explicitly cut or flagged

### Inter-Step Data Contracts (Prompt 8)
- [ ] Output schema has exact field names, types, and required/optional markers
- [ ] Nested object shapes are defined one level deep
- [ ] Naming conventions are documented (camelCase/snake_case, date format, ID format)
- [ ] Missing field behavior is specified (reject, default, skip)
- [ ] Type mismatch behavior is specified (no implicit coercion unless documented)
- [ ] Unknown enum value handling is specified for consumers
- [ ] Versioning strategy is defined (semantic versioning, migration path)
- [ ] Schema validation runs on both producer and consumer sides (or documented why not)

### Observability & Model Selection (Prompt 9)
- [ ] Continuously monitored metrics are listed with collection frequency and sampling rate
- [ ] Operator dashboard has 3-5 panels defined
- [ ] Every alert has: invariant, threshold, severity, who gets paged
- [ ] Every critical alert has a 3-step runbook
- [ ] False positive tolerance is specified per alert type
- [ ] Drift detection has: signal, statistical test, threshold, action
- [ ] Feedback loop from production to spec is documented (who owns it, cadence)
- [ ] Model assignment per step has: model, selection criteria, benchmark data
- [ ] Fallback chain is defined with acceptance criteria per fallback level
- [ ] 3am Test applied to every alert (would someone get out of bed?)

## Phase 6: Comprehensive Coverage Audit (Prompt 10)

Run this phase after the MECE gap interview (Prompt 10). Only check sections that apply to this step (see applicability table in mece-gap-questions.md).

### Security, Access Control & Audit (Group 31)
- [ ] Every role/system with access is listed with specific permission level
- [ ] Audit logging covers who, what, when, which record, and what changed
- [ ] Audit log retention meets HIPAA 6-year minimum (or documented exception)
- [ ] PHI/PII fields are identified with encryption requirements (at rest and in transit)
- [ ] Third-party PHI transmission has BAA documented
- [ ] PII leak remediation procedure is defined with timeline

### Data Lifecycle & Compliance (Group 32)
- [ ] Retention period is specified per data type with regulatory citation
- [ ] Deletion trigger and timeline are defined (auto-delete, manual, or on-request)
- [ ] Right-to-deletion workflow is documented with propagation to downstream systems
- [ ] Archival tiers are defined with retrieval time per tier
- [ ] Retention periods distinguish raw data from derived/aggregated data

### Cross-Step Coordination (Group 33)
- [ ] Every side effect is listed (DB writes, cache mutations, events, external calls)
- [ ] Idempotency is specified for each side effect
- [ ] Concurrency control is defined (optimistic locking, pessimistic, or documented "none")
- [ ] Compensation/rollback behavior is defined for downstream failures

### Gradual Rollout (Group 34)
- [ ] Rollout stages are defined with traffic percentages and durations
- [ ] Gating metrics and thresholds are specified for each stage advancement
- [ ] Automatic rollback triggers are defined with execution time
- [ ] Control group experience is documented

### Incident Response (Group 35)
- [ ] Every critical alert has a runbook with first 3 diagnostic steps
- [ ] Runbook steps are specific enough for an engineer unfamiliar with the step
- [ ] Step-specific rollback procedure is defined (not just generic deploy rollback)
- [ ] Post-incident spec update process is documented with SLA

### Operational Readiness (Group 36)
- [ ] On-call rotation and escalation path are defined
- [ ] Training prerequisites for on-call are documented
- [ ] Shift handoff procedure and documentation location are specified

### Chaos Engineering (Group 37)
- [ ] Failure modes to inject are listed with expected behavior per fault
- [ ] Blast radius controls are defined (traffic scope, kill switch, max duration)
- [ ] Success criteria are measurable (error rates, recovery time, data integrity)

### Deprecation & Migration (Group 38)
- [ ] Expected lifespan and replacement trigger are documented
- [ ] Backward compatibility period is defined with support policy
- [ ] Deprecation communication plan covers advance notice and automated checks

### Documentation (Group 39)
- [ ] Required operational documents are listed with current state (exists/missing/stale)
- [ ] Documentation ownership and freshness policy are defined
- [ ] New-engineer onboarding path is documented

### Data Quality (Group 40)
- [ ] Critical data quality dimensions are identified with justification
- [ ] Thresholds are defined per dimension with action on breach
- [ ] Responsibility boundary between this step and upstream is documented

## Audit Report Format

After running the audit, produce a summary:

```
## Spec Audit: [Step Name]

**Structural:** [PASS/FAIL] — [issues if any]
**Content Quality:** [PASS/FAIL] — [issues if any]
**Gap Detection:** [N gaps found] — [list]
**Cross-Step:** [PASS/FAIL/N/A] — [issues if any]
**Production Bridge:** [PASS/FAIL/N/A] — [N of 5 prompts applied, issues if any]
**Comprehensive Coverage:** [PASS/FAIL/N/A] — [N of 10 groups applied, issues if any]

### Gaps Requiring User Input
1. [Gap description] — needs answer before spec is production-ready
2. ...

### Auto-Fixed Issues
1. [Issue] — [fix applied]
2. ...

### Recommendation
[READY FOR PRODUCTION / NEEDS N ANSWERS BEFORE PRODUCTION]
```
