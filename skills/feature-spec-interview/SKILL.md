---
name: feature-spec-interview
description: "Interactive interview that produces AI-agent-executable feature specifications (NLSpec). Use when the user says 'write a feature spec', 'spec interview', 'dark factory spec', 'NLSpec', 'feature-spec-interview', or needs to create detailed behavioral contracts for any feature, pipeline step, or system component. Supports four modes: (1) All mode where one person covers product + engineering, (2) PM-first mode where PM writes behavioral spec and Eng fills tech later, (3) Eng-first mode where engineer fills tech decisions on an existing spec, (4) Fill-gaps mode to complete a partially-written spec. Always uses AskUserQuestion for interactive interviewing. Produces specs precise enough that an AI agent or capable new hire could implement with at most one clarifying question."
---

# Feature Spec Interview

Interactive interview process that produces AI-agent-executable feature specifications. Based on the Dark Factory Framework's NLSpec methodology.

## Core Principle

Specs are behavioral contracts for AI agents, not delivery plans for humans. Every behavior requires four components: WHAT the system must do, WHEN (under what conditions), WHY (the rationale that guides edge case decisions), and VERIFY (how to confirm the behavior is correct in production). Constraints are measurable invariants, not policy statements.

## References

- **Question banks (behavioral)**: See [references/question-banks.md](references/question-banks.md) for Prompts 1-3 interview questions (behavioral contracts)
- **Question banks (production bridge)**: See [references/production-bridge-questions.md](references/production-bridge-questions.md) for Prompts 5-9 interview questions (production readiness)
- **Spec templates**: See [references/spec-templates.md](references/spec-templates.md) for 7-section and 14-section output formats plus NLSpec writing rules
- **Completeness audit**: See [references/completeness-audit.md](references/completeness-audit.md) for the 5-phase verification checklist
- **Question banks (MECE gaps)**: See [references/mece-gap-questions.md](references/mece-gap-questions.md) for Prompt 10 interview questions (comprehensive coverage Groups 31-40)

## Workflow Overview

```
Phase 0:  Setup                  → Mode selection, project intake, step identification
Phase 1a: Behavioral Interview   → Prompts 1-3 via AskUserQuestion (behavioral contracts)
Phase 1b: Production Bridge      → Prompts 5-9 via AskUserQuestion (production readiness)
Phase 1c: Comprehensive Coverage → Prompt 10 via AskUserQuestion (MECE gap closure)
Phase 2:  Draft                  → Generate spec using appropriate template
Phase 3:  Review                 → User reviews draft, corrections applied
Phase 4:  Audit                  → Completeness audit + gap detection + production bridge audit
Phase 5:  Finalize               → Production-ready spec with audit report
```

---

## Phase 0: Setup

### Step 0.1 — Determine Interview Mode

Use AskUserQuestion to ask: **"What's your role in this interview?"**

| Mode | When to Use | Behavior |
|------|-------------|----------|
| **All** | One person covers product + engineering | Ask all `[PM]`, `[ENG]`, and `[BOTH]` questions. Mark undecided items `[OPEN]`. |
| **PM-first** | PM writes behavioral spec, Eng fills tech later | Ask `[PM]` and `[BOTH]` questions. Skip `[ENG]` questions. Mark skipped items `[OPEN — Engineering]`. |
| **Eng-first** | Engineer fills tech decisions on an existing spec | Ask `[ENG]` and `[BOTH]` questions. Skip `[PM]` questions. Mark skipped items `[OPEN — PM]`. |
| **Fill-gaps** | Complete a partially-written spec | Load existing spec. Show only `[OPEN]` items. User answers the unanswered questions. |

**Mode selection shortcut:** If the user says "solo" or "I'm doing everything," map to **All**. If they say "I'm the PM" or "product side," map to **PM-first**. If they say "engineering" or "tech decisions," map to **Eng-first**. If they reference an existing spec with gaps, map to **Fill-gaps**.

### Step 0.2 — Project Intake (first spec only)

If this is the first spec in a project, ask the three Phase 1 intake questions from the question bank:
1. Elevator pitch (2 sentences)
2. Who executes: AI agents, human engineers, or both?
3. Scope: full system or one step at a time?

Store the answers. Reference them in every subsequent spec.

If the user has already done project intake (previous specs exist), skip this step.

### Step 0.3 — Step Identification

Use AskUserQuestion to ask:
- "What step or feature are we speccing? Give me the name and a one-sentence description."
- "Does this step involve AI judgment calls (classification, routing, delegation, escalation)?"

Based on the answer, determine:
- **Structural step** (no AI judgment) → Use Prompt 1 only → 7-section format
- **Judgment step** (AI makes decisions) → Use Prompts 1+2+3 → 14-section format

If the user uploaded or referenced an existing document (PRD, feature doc, requirements), read it first. Extract what you can, then interview to fill gaps. Never generate a spec purely from a document without interviewing.

### Mode Filtering Rules

Every question group in the question banks has a tag: `[PM]`, `[ENG]`, or `[BOTH]`.

**During the interview:**
- **All mode**: Ask every question group regardless of tag.
- **PM-first mode**: Ask groups tagged `[PM]` or `[BOTH]`. For `[ENG]` groups, generate placeholder `[OPEN — Engineering]` items in the spec draft with a one-sentence description of what the engineer needs to decide.
- **Eng-first mode**: Ask groups tagged `[ENG]` or `[BOTH]`. For `[PM]` groups, generate placeholder `[OPEN — PM]` items in the spec draft.
- **Fill-gaps mode**: Parse the existing spec for `[OPEN]` markers. Present each as an interview question. After answering, remove the `[OPEN]` marker and write the answer into the spec.

**Tag reference (Groups 1-30):**

| Group | Tag | Group | Tag |
|-------|-----|-------|-----|
| 1 Desired Output | PM | 16 Load Behavior | ENG |
| 2 Hard Constraints | BOTH | 17 Scenario Design | PM |
| 3 Hidden Context | BOTH | 18 Satisfaction Definition | PM |
| 4 Edge Cases | BOTH | 19 Holdout & Regression | ENG |
| 5 Tradeoffs | PM | 20 Dependency Inventory | BOTH |
| 6 Definition of Done | PM | 21 Failure Mode Replication | ENG |
| 7 Core Value | PM | 22 Behavioral Fidelity | ENG |
| 8 Decision Authority | PM | 23 Volume & Rate Testing | ENG |
| 9 Quality Thresholds | PM | 24 Schema Definition | BOTH |
| 10 Special Handling | PM | 25 Contract Enforcement | ENG |
| 11 Pushback | BOTH | 26 Versioning & Evolution | ENG |
| 12 Failure Mode Extraction | BOTH | 27 Continuous Monitoring | ENG |
| 13 Latency & Throughput | ENG | 28 Alerting & Invariants | ENG |
| 14 Resource Constraints | BOTH | 29 Drift Detection | BOTH |
| 15 Availability & Degradation | ENG | 30 Model Assignment | BOTH |

**Tag reference (Groups 31-40, Prompt 10 — MECE Gaps):**

| Group | Tag | Group | Tag |
|-------|-----|-------|-----|
| 31 Security & Audit | PM | 36 Operational Readiness | ENG |
| 32 Data Lifecycle | PM | 37 Chaos Engineering | ENG |
| 33 Cross-Step Coordination | BOTH | 38 Deprecation & Migration | BOTH |
| 34 Gradual Rollout | PM | 39 Documentation | ENG |
| 35 Incident Response | ENG | 40 Data Quality | ENG |

---

## Phase 1: Interview

**CRITICAL: Use AskUserQuestion for EVERY question group.** Do not generate answers. Do not assume. The interview surfaces implicit knowledge that no document contains.

Load [references/question-banks.md](references/question-banks.md) for the full question bank.

### Interview Flow

**For ALL steps (Prompt 1 — Specification Engineer):**

Work through Groups 1-6 sequentially. Ask 2-3 questions per AskUserQuestion call to keep the flow conversational without overwhelming. After each group, summarize what you heard and confirm before moving on.

1. **Group 1 — Desired Output**: What exists after this step? What's the one job? What's NOT in scope?
2. **Group 2 — Hard Constraints**: What must NEVER happen? Worst-case failure? Data sensitivity?
3. **Group 3 — Hidden Context**: Non-obvious environment facts? Surprising behaviors? Undocumented dependencies?
4. **Group 4 — Edge Cases**: Dangerous scenarios? Valid-but-unusual inputs? Recovery behaviors?
5. **Group 5 — Tradeoffs**: Where can quality yield to speed? What's sacred? Latency vs. correctness?
6. **Group 6 — Definition of Done**: How do you know it worked? Name three conditions.

**For judgment steps, ADD (Prompt 2 — Intent & Delegation):**

7. **Group 7 — Core Value**: What does this optimize for? What does "failed" look like?
8. **Group 8 — Decision Authority**: What's autonomous? What escalates? Where's the delegation boundary?
9. **Group 9 — Quality Thresholds**: Routine vs. high-stakes line?
10. **Group 10 — Special Handling**: True exceptions to normal rules?
11. **Group 11 — Pushback**: Construct a "build for AI agents" challenge specific to this step.

**For high-consequence steps, ADD (Prompt 3 — Constraint Architecture):**

12. **Group 12 — Failure Mode Extraction**: "What is the WORST thing that can go wrong?" Push for 3-5 specific scenarios. Then derive constraints from those scenarios only. Cut any constraint not traceable to a real failure.

### Interview Discipline

**The Grilling Principle**: When the user adds a constraint, HITL gate, or approval step, challenge it:
> "You said we're building for AI agents. [Restate constraint]. Why does [action] require [limitation]? Is that a real safety/compliance constraint, or defensive thinking?"

Keep the constraint only if removing it would cause real harm or a compliance violation. If the worst case is "the AI might do it differently than I would," remove it.

**The Klarna Test**: Before finalizing any classification or routing rule, ask: "Am I optimizing for the label/rule, or for the action it triggers?"

**No skipping**: Do not skip Groups 3 (Hidden Context) and 5 (Tradeoffs). These produce the most valuable spec content and are the groups most often rushed.

### Rejected Patterns (Decision 4, March 10 2026)

The following patterns were evaluated during framework research and explicitly rejected. Do NOT re-introduce them during interviews or spec writing. Build later only when evidence demands it.

- **Three-tier knowledge architecture** (Codified Context paper). Overkill for current scale. Simple CLAUDE.md + spec files are sufficient.
- **11-dimension delegation assessment** (Intelligent AI Delegation paper). Too granular. The 3-tier Decision Authority Map (autonomous / notify / escalate) covers AllCare's needs.
- **Attestation chains**. No current compliance requirement demands cryptographic proof of agent actions. HIPAA audit logging is sufficient.
- **Formal drift detector** (autonomous component). Rejected as a standalone agent. Drift is monitored as an observability practice (Prompt 9), not as a formal autonomous component that auto-corrects.
- **Formal deployment gate**. GSD's verify-work + completeness audit is the gate. No separate deploy ceremony needed.
- **Intra-plan compaction**. Premature optimization. Plans are short enough that context compression isn't needed yet.
- **Three-metric satisfaction signal**. Replaced by probabilistic satisfaction scoring (Prompt 6). Single blended score with per-step thresholds.

---

## Phase 1b: Production Bridge Interview

**CRITICAL: Only run after Phase 1a (behavioral interview) is complete.** These prompts bridge the spec from "behaviorally correct" to "production-ready."

Load [references/production-bridge-questions.md](references/production-bridge-questions.md) for the full production bridge question bank.

### Applicability Check

Not every step needs all 5 production bridge prompts. Before starting, determine which apply:

| Prompt | Apply When | Skip When |
|--------|------------|-----------|
| 5 - NFRs | Step handles live traffic | Pure data transformation, no latency sensitivity |
| 6 - Scenarios | Step has acceptance criteria to validate | Step has < 3 acceptance criteria |
| 7 - DTU | Step talks to external dependencies | Step is purely internal |
| 8 - Data Contracts | Step passes data to another step | Step is terminal (no downstream consumer) |
| 9 - Observability | Step runs continuously in production | One-time migration or batch job |

### Interview Flow

**Prompt 5 — Non-Functional Requirements (Groups 13-16):**

13. **Group 13 — Latency & Throughput**: P99 targets, concurrent request limits, batch vs real-time.
14. **Group 14 — Resource Constraints**: Token budgets, cost ceilings, memory/CPU limits.
15. **Group 15 — Availability & Degradation**: Uptime targets, circuit breakers, graceful degradation.
16. **Group 16 — Load Behavior**: 10x load handling, shed/queue/reject policy, cold start.

**Prompt 6 — Scenarios & Satisfaction (Groups 17-19):**

17. **Group 17 — Scenario Design**: Real user stories, scenario diversity, independence.
18. **Group 18 — Satisfaction Definition**: Probabilistic scoring, per-step thresholds, gaming detection.
19. **Group 19 — Holdout & Regression**: Holdout strategy, bounded feedback templates, regression detection.

**Prompt 7 — Digital Twin Universe (Groups 20-23):**

20. **Group 20 — Dependency Inventory**: External systems, read/write patterns, existing sandboxes.
21. **Group 21 — Failure Mode Replication**: Production incidents, which failures to replicate.
22. **Group 22 — Behavioral Fidelity**: Response fidelity level, state management needs.
23. **Group 23 — Volume & Rate Testing**: Call volume, burst patterns, latency distributions.

**Prompt 8 — Inter-Step Data Contracts (Groups 24-26):**

24. **Group 24 — Schema Definition**: Exact fields, types, required/optional, naming conventions.
25. **Group 25 — Contract Enforcement**: Missing field handling, type validation, defense-in-depth.
26. **Group 26 — Versioning & Evolution**: Version strategy, backward compatibility, migration paths.

**Prompt 9 — Observability & Model Selection (Groups 27-30):**

27. **Group 27 — Continuous Monitoring**: Which criteria to monitor, dashboards, sampling rates.
28. **Group 28 — Alerting & Invariants**: Alert definitions, severity levels, runbooks, false positive tolerance.
29. **Group 29 — Drift Detection**: Input/output drift signals, thresholds, feedback loop to spec.
30. **Group 30 — Model Assignment**: Per-step model selection, consensus for critical decisions, fallback chain.

### Production Bridge Discipline

**The Measurement Principle**: When the user provides an NFR (latency target, availability %, throughput number), always ask: "Has this been measured in production, or is it a guess?" Keep only NFRs backed by measurement or explicit SLA requirements. Cut speculative ones.

**The 3am Test**: For every alert proposed in Prompt 9, ask: "If this alert fired at 3am, would someone actually get out of bed?" If not, downgrade it to a weekly report.

After completing applicable production bridge prompts, ask the post-production-bridge review questions from the question bank.

---

## Phase 1c: Comprehensive Coverage Interview

**Run after Phase 1b (production bridge) is complete.** These prompts close the remaining MECE gaps in the spec.

Load [references/mece-gap-questions.md](references/mece-gap-questions.md) for the full MECE gap question bank.

### Applicability Check

Check the applicability table in the MECE gap question bank. Most steps need at least Groups 31-32 (security and data lifecycle). The rest depend on step characteristics.

### Interview Flow

**Prompt 10 — Comprehensive Coverage (Groups 31-40):**

31. **Group 31 — Security & Audit** `[PM]`: Access control, audit logging, PHI/PII handling
32. **Group 32 — Data Lifecycle** `[PM]`: Retention, deletion, archival, right-to-deletion
33. **Group 33 — Cross-Step Coordination** `[BOTH]`: Side effects, race conditions, compensation
34. **Group 34 — Gradual Rollout** `[PM]`: Rollout stages, gating metrics, rollback triggers
35. **Group 35 — Incident Response** `[ENG]`: Runbooks, diagnostic steps, post-incident spec updates
36. **Group 36 — Operational Readiness** `[ENG]`: On-call, training, handoff procedures
37. **Group 37 — Chaos Engineering** `[ENG]`: Fault injection, blast radius, success criteria
38. **Group 38 — Deprecation & Migration** `[BOTH]`: Lifespan, consumer migration, backward compatibility
39. **Group 39 — Documentation** `[ENG]`: Operational docs, freshness policy, onboarding
40. **Group 40 — Data Quality** `[ENG]`: Quality dimensions, thresholds, responsibility boundaries

**Also includes:** Extensions to Group 14 (cost allocation Q14.4-14.5) and Group 16 (capacity planning Q16.5-16.6).

### Comprehensive Coverage Discipline

**The Existence Test**: For security (Group 31) and data lifecycle (Group 32), don't ask "should we do this?" Ask "show me the current state." If access controls or retention policies don't exist yet, that's the answer. The spec must define them.

---

## Phase 2: Draft

After completing the interview, generate the spec.

### Template Selection

- Structural step (Prompt 1 only) → 7-section format from [references/spec-templates.md](references/spec-templates.md)
- Judgment step (Prompts 1+2+3) → 14-section format from [references/spec-templates.md](references/spec-templates.md)

### Writing Rules

1. Every behavioral statement uses NLSpec format: WHAT / WHEN / WHY
2. Every Must Not Do has a one-line failure mode explanation
3. Every [OPEN] item is explicitly labeled with an owner
4. Acceptance Criteria are numbered, each independently verifiable by an observer with no context
5. Definition of Done has exactly three conditions
6. Constraints are measurable invariants, not policy statements
7. No vague language: "high quality," "fast," "gracefully" are banned. Use numbers, thresholds, specific behaviors.
8. The "why" behind key decisions is always documented. Smart-but-wrong execution comes from knowing the rule but not the reason.

### Output Location

Save the spec to the user's preferred output directory. If working in a project with an existing spec structure, follow that convention. Otherwise, ask the user where to save it.

---

## Phase 3: Review

Present the draft to the user. Use AskUserQuestion with the post-draft review questions from the question bank:

1. "Is anything here that would surprise you to see in production?"
2. "Is anything here that would cause you to call a customer to explain?"
3. "Are any of the [OPEN] items actually already decided?"
4. "Did I miss any channel, input type, or stakeholder that exists in your real system?"

Apply corrections immediately. Document each correction with a brief note of what changed and why (this builds the project's correction log).

---

## Phase 4: Completeness Audit

Load [references/completeness-audit.md](references/completeness-audit.md) and run all four phases:

1. **Structural Completeness** — Every required section exists and is non-empty
2. **Content Quality** — Acceptance criteria are specific, constraints are measurable, [OPEN] items are labeled
3. **Gap Detection** — Input completeness, output completeness, concurrency, failure/recovery, scope boundaries, new-hire test
4. **Cross-Step Consistency** (if other specs exist) — Output/input matching, no contradictions, consistent naming

For every gap found, use AskUserQuestion to get the answer from the user. Do not fill gaps with assumptions.

### The New-Hire Test (Final Gate)

Read the entire spec and ask: "Could a capable new hire with no context implement this with at most one clarifying question?" If the answer is no, identify what they would ask. That answer belongs in the spec. Add it and re-check.

---

## Phase 5: Finalize

1. Apply all corrections and gap fills from Phases 3-4
2. Generate the audit report (format in [references/completeness-audit.md](references/completeness-audit.md))
3. Present the final spec + audit report to the user
4. Ask: "Is this spec ready for production, or are there remaining items to resolve?"

If remaining items exist, loop back to the relevant phase. If ready, save the final version.

For **PM-first** or **Eng-first** mode: Remind the user which `[OPEN]` items need the other role's input before the spec is execution-ready.

---

## Multi-Step Projects

When speccing multiple steps in sequence:

- Maintain a **decisions log** of decisions locked in earlier specs. Do not re-derive.
- Maintain a **corrections log** of corrections applied to earlier drafts. Patterns inform later specs.
- Check **cross-step consistency** after each new spec (Phase 4, check 4).
- Each step has one job. If a step description requires "and," it's probably two steps.
- Steps are written in order. Each fully specced before starting the next.
- Prompt levels are progressive: start with Prompt 1 for structural steps, add Prompt 2 when judgment appears, add Prompt 3 when consequences are high.
