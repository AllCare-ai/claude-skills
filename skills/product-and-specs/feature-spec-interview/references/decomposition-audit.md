# Decomposition Audit — Step Breakdown Evaluation

Use this reference when the user provides a batch of specs or a step breakdown to evaluate. This audit runs BEFORE individual spec interviews. Its purpose: grill the decision to split work into these specific steps.

## When to Run

- User says "run on all specs in this folder" or "interview all steps"
- User provides a pipeline, workflow, or multi-step system to spec
- User asks to evaluate whether the step breakdown is correct
- Any batch of 5+ specs where the decomposition was a human planning decision that hasn't been stress-tested

## Audit Process

### Step 1: Read All Specs

Read every spec in the batch. For each, extract:
1. Step number and name
2. The ONE JOB (purpose statement)
3. Input (what it receives) and Output (what it produces)
4. Whether it involves AI judgment or is structural/mechanical
5. Dependencies on other steps (what must complete before this step can start)
6. Data it reads from other steps vs. data it could derive independently

### Step 2: Map True Dependencies

Build a dependency graph based on actual data flow, not assumed ordering.

**Hard dependency:** Step B literally cannot function without Step A's output. The data doesn't exist until A produces it.

**Soft dependency:** Step B uses Step A's output as context but could function without it (possibly with reduced quality). These are parallelism candidates.

**No dependency:** Steps read the same upstream data and produce independent outputs. These should run in parallel.

### Step 3: Apply the 7 Decomposition Tests

For each step in the batch, run these tests:

#### Test 1: The "AND" Test (Split Candidate)
> Does this step's description require "and" to explain its job?

If yes, it might be two steps. But only split if the two halves have different failure modes, different owners, or different execution timing.

#### Test 2: The Merge Test (Merge Candidate)
> Do two adjacent steps read the same input, run at the same time, and produce outputs that are always consumed together?

If yes, they should probably be one step. Two separate LLM calls on the same text that both produce classification labels are a merge candidate.

**Merge signals:**
- Same input data
- Same execution timing (both run immediately after the same trigger)
- Outputs always consumed together by the next step
- No independent failure modes (if one fails, the other is useless)
- Combined into a single LLM call without loss of quality

**Keep separate signals:**
- Different failure modes with different recovery strategies
- Different owners (PM vs Eng, or different teams)
- One can be skipped/disabled without affecting the other
- Significantly different latency profiles
- Healthcare/compliance requires independent verification (second-opinion pattern)

#### Test 3: The Parallelism Test
> Does this step actually need the previous step's output, or does it just read the same upstream data?

Map which steps can run simultaneously after a common predecessor. If three steps all read "structured text" and produce independent outputs, they're parallel, not sequential.

#### Test 4: The "Is This a Step?" Test
> Is this a pipeline processing step, or is it something else?

Things that are NOT pipeline steps:
- **UI views** (these are features of the frontend, not processing steps)
- **NFR specs** (performance requirements belong as a section within the step they constrain)
- **Data model features** (comments, tags, metadata fields are features of the record, not processing steps)
- **Alternative entry points** (manual creation, event triggers are parallel paths, not sequential steps)

#### Test 5: The Trust Tax Test
> Does this step exist because we don't trust the previous step?

A "quality audit" step that re-checks the previous step's output is a trust tax. It may be justified (healthcare, financial, compliance) or it may be defensive engineering. Ask:
- "What specific systematic errors has the upstream step produced (or is expected to produce) that this step catches?"
- "If the upstream step were perfect, would this step still exist?"

If the answer is "yes, because compliance/regulation requires independent verification," keep it. If the answer is "no, we're just being cautious," challenge it.

#### Test 6: The Entry Point Test
> Does this step create the same output type as another step, just from a different trigger?

If yes, these are alternative entry points, not sequential steps. They should share a common output spec and feed into the same downstream path.

Group them:
- 7a: Automated Task Creation (from pipeline)
- 7b: Manual Task Creation (from coordinator)
- 7c: Event-Triggered Task Creation (from system events)

#### Test 7: The Event-Driven Test
> Does this step happen in sequence, or does it respond to events?

Steps that fire based on time (reminders), external signals (completion confirmations), or system events (task state changes) are event-driven, not sequential. They should be modeled as reactive behaviors, not pipeline steps.

### Step 4: Identify the Architecture Pattern

Based on the dependency graph and test results, determine the execution model:

| Pattern | When | Example |
|---------|------|---------|
| **Linear pipeline** | Each step strictly depends on the previous | ETL: extract → transform → load |
| **Phased parallel** | Groups of steps can run simultaneously within phases | Analyze phase: 3 classifiers in parallel, then join |
| **Event-driven** | Steps respond to events, not sequence | Task lifecycle: follow-up, completion, reminders |
| **Hybrid** | Mix of the above | Most real systems |

### Step 5: Present Findings

Organize findings into three categories:

**RED FLAGS (likely over-engineered):**
Steps that fail multiple tests. These should be merged, folded, or restructured.

**YELLOW FLAGS (questionable separation):**
Steps that fail 1-2 tests but have plausible justification. Present the trade-off and let the user decide.

**GREEN (solid as-is):**
Steps that pass all tests. These earn their existence as separate specs.

### Step 6: Propose Reorganization

If red/yellow flags exist, propose a reorganized structure:
1. New step list with merges applied
2. Dependency graph showing parallel opportunities
3. Phase grouping (which steps form a phase)
4. New specs needed (e.g., a "merger" step for parallel joins)
5. Mapping table: old step → new step

Get user approval before proceeding to individual spec interviews.

## Parallel Execution Contract Template

When steps are identified as parallel, document the contract:

```markdown
## Phase N Parallel Execution Contract

All Phase N agents receive the same input and produce independent outputs.
No Phase N agent reads another Phase N agent's output.

**Shared Input (from Phase N-1):**
- [field]: [description]

**Agent Na Output:** [fields]
**Agent Nb Output:** [fields]
**Agent Nc Output:** [fields]

**Phase N+1 Trigger:** When all outputs exist for the same record ID, the merger fires.

**Exception paths:** [any outputs that trigger immediate action without waiting for the join]
```

## Questions to Ask During Decomposition Audit

### For the batch as a whole:
1. "Walk me through the end-to-end flow. Where does a request enter, and where does it exit?"
2. "Which of these steps were split because they're genuinely independent, vs. split because it felt like a natural planning boundary?"
3. "Are there any steps that could start working before the previous step finishes?"
4. "Which steps produce outputs that are ALWAYS consumed together by the next step?"

### For each red/yellow flag:
5. "These two steps read the same input and produce similar outputs. What breaks if we merge them?"
6. "This step re-checks the previous step's work. What specific errors has it caught (or would it catch) that the upstream step can't prevent?"
7. "This is a UI view, not a processing step. Should it be part of the UI spec instead?"
8. "This is an alternative entry point. Should it share a spec with the other entry points that produce the same output?"

### For parallel opportunities:
9. "If these three steps ran simultaneously on the same input, what would break? What context would be lost?"
10. "Is there a join point where parallel outputs need to be merged? What coherence checks happen at the join?"
