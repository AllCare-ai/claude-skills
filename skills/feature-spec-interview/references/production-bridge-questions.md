# Production Bridge Question Banks (Prompts 5-9)

These question groups bridge specs from "behaviorally correct" to "production-ready." They're applied AFTER the behavioral interview (Prompts 1-3) but BEFORE the spec is considered complete.

Not every step needs all 5 prompts. Determine which apply based on the step type:

| Prompt | When to Use | Skip When |
|--------|-------------|-----------|
| 5 - Non-Functional Requirements | Every step that handles live traffic | Pure data transformation with no latency sensitivity |
| 6 - Scenarios & Satisfaction | Every step with acceptance criteria | Step has < 3 acceptance criteria |
| 7 - Digital Twin Universe | Step talks to external dependencies | Step is purely internal with no external calls |
| 8 - Inter-Step Data Contracts | Step passes data to another step | Step is terminal (no downstream consumer) |
| 9 - Observability & Model Selection | Step runs in production continuously | One-time migration or batch job |

---

## Prompt 5 --- Non-Functional Requirements <a id="prompt-5"></a>

**Purpose:** Extract performance, scalability, availability, and resource constraints. StrongDM's Shift Work technique warns: functional specs are easy. Non-functional requirements exist primarily OUTSIDE the functional specification and are the hard part. Without NFRs, an agent will build something that works for 1 request but falls over under load.

**When to use:** Every step that handles live traffic or processes requests in real time.

### Group 13 --- Latency & Throughput Targets `[ENG]`

**Filter Question:** "Has this latency limit actually been hit or measured in production, or is it a guess? If it's a guess, what's the basis?"

**Q13.1:** "What is the target P99 latency for a single request through this step? Not average. P99."
- **Follow-up probe:** "How was that number determined? Load test, production measurement, or SLA requirement?"
- **Follow-up probe:** "What happens to the user experience if latency exceeds that target by 2x? By 10x?"
- **Good answer:** "P99 must stay under 800ms. We measured this from production traces over the last quarter. Above 2s, the downstream step times out and the request is lost."
- **Bad answer:** "It should be fast. Under a second hopefully."

**Q13.2:** "What is the maximum number of concurrent requests this step needs to handle? Sustained, not peak."
- **Follow-up probe:** "What's the peak multiplier over sustained? 2x? 5x? When does peak happen?"
- **Follow-up probe:** "What happens when concurrency exceeds the max? Queue? Reject? Shed?"
- **Good answer:** "Sustained: 200 concurrent. Peak during morning clinic hours: 600 concurrent (3x). Above 600, we shed with a 429 and the client retries after 5s."
- **Bad answer:** "A lot. Probably hundreds."

**Q13.3:** "Is this step real-time (must respond within the request lifecycle) or batch (can process asynchronously)?"
- **Follow-up probe:** "If batch, what's the maximum acceptable delay from input to output?"
- **Follow-up probe:** "If real-time, is there a portion that could be deferred to async without impacting the user?"
- **Good answer:** "Real-time for the initial classification (must respond in <500ms). The enrichment substep can be async, processed within 30s."
- **Bad answer:** "Real-time I think. Everything needs to be instant."

### Group 14 --- Resource Constraints & Budgets `[BOTH]`

**Filter Question:** "Do you have a cost ceiling per request for this step? If not, what's the total monthly budget for this pipeline?"

**Q14.1:** "What's the token budget for any LLM call in this step? Input tokens, output tokens, and which model?"
- **Follow-up probe:** "What happens if the input exceeds the token budget? Truncate? Summarize? Reject?"
- **Follow-up probe:** "Is the model choice locked or can the agent select based on complexity?"
- **Good answer:** "Max 4K input tokens, 1K output tokens, using Claude Haiku for classification. If input exceeds 4K, truncate from the middle (keep first 2K and last 2K). Model is locked for this step."
- **Bad answer:** "Use whatever model works best. Tokens don't matter."

**Q14.2:** "What's the cost ceiling per request through this step?"
- **Follow-up probe:** "Is that a hard ceiling (reject if exceeded) or a budget target (alert if trending over)?"
- **Follow-up probe:** "How does this step's cost relate to the total pipeline cost per request?"
- **Good answer:** "Hard ceiling of $0.02 per request for this step. Total pipeline budget is $0.15 per request. This step is 13% of the budget."
- **Bad answer:** "Keep it cheap. We don't have a specific number."

**Q14.3:** "What are the memory and CPU constraints for this step?"
- **Follow-up probe:** "Is this running in a container with fixed limits, or on shared infrastructure?"
- **Follow-up probe:** "What happens when memory is exhausted? OOM kill? Swap? Graceful rejection?"
- **Good answer:** "Container with 512MB memory limit, 0.5 vCPU. OOM triggers container restart. Must not hold more than 50 requests in memory simultaneously."
- **Bad answer:** "Whatever the default is. We haven't thought about it."

### Group 15 --- Availability & Degradation `[ENG]`

**Filter Question:** "Has this step actually gone down in production? What happened? How long was it down?"

**Q15.1:** "What's the availability target for this step? 99.9%? 99.99%? And what's the measurement window (monthly, quarterly)?"
- **Follow-up probe:** "Is that target contractual (SLA) or aspirational (SLO)?"
- **Follow-up probe:** "What's the error budget? How many minutes of downtime per month?"
- **Good answer:** "99.9% monthly SLO. That's ~43 minutes of downtime per month. Not contractual, but if we breach it twice consecutively, we do a postmortem."
- **Bad answer:** "It should always be up. 100% uptime."

**Q15.2:** "When a dependency this step relies on is degraded but not down, what does this step do?"
- **Follow-up probe:** "Does it serve stale data? Return a partial response? Queue and retry?"
- **Follow-up probe:** "How does the user know something is degraded vs. fully working?"
- **Good answer:** "If the EHR is slow (>2s), we serve the last cached patient record (max 1hr stale) and flag the response as 'possibly stale.' If the EHR is fully down, we queue the request and notify the user: 'We'll process this when the system recovers.'"
- **Bad answer:** "It should handle errors gracefully."

**Q15.3:** "What are the circuit breaker specs? Threshold to open, cooldown to half-open, conditions to close."
- **Follow-up probe:** "Is it per-dependency or per-endpoint?"
- **Follow-up probe:** "What does the step do while the circuit is open? Fail fast? Serve cached? Redirect?"
- **Good answer:** "Per-endpoint. Open after 5 consecutive failures or 50% error rate in 30s window. Half-open after 60s, send one probe request. Close after 3 consecutive successes. While open, return cached response if available, otherwise return structured error with retry-after header."
- **Bad answer:** "We'll add a circuit breaker. Standard stuff."

### Group 16 --- Load Behavior `[ENG]`

**Filter Question:** "Has this system ever been hit with unexpected load? What happened? What broke first?"

**Q16.1:** "What happens to this step under 10x normal load? Not 'what should happen.' What actually happens today?"
- **Follow-up probe:** "Which component is the first bottleneck? Database connections? Memory? External API rate limits?"
- **Follow-up probe:** "Is there a load test that proves the answer, or is this theoretical?"
- **Good answer:** "At 10x, the database connection pool exhausts first (max 20 connections). Requests queue for up to 30s then timeout. We've load-tested this. The fix is to shed load at the API gateway before it reaches the connection pool."
- **Bad answer:** "It should scale. We're using cloud infrastructure."

**Q16.2:** "When this step hits resource exhaustion, what's the policy: shed load, queue, or reject?"
- **Follow-up probe:** "If shedding, what's the priority order? Which requests get shed first?"
- **Follow-up probe:** "If queuing, what's the max queue depth and max wait time?"
- **Good answer:** "Shed load. Priority order: (1) keep urgent/safety requests, (2) keep requests from active clinical sessions, (3) shed routine requests first. Shed with 429 + retry-after header. Never queue. Queuing hides the problem."
- **Bad answer:** "Queue everything. We can't drop requests."

**Q16.3:** "What's the max retry/iteration count before this step declares failure? What happens when it hits it?"
- **Follow-up probe:** "Is there a doom-loop detector? If the step retries the same failing operation 50 times, does anything stop it?"
- **Follow-up probe:** "What's the cost of a doom loop? Wasted tokens? Blocked queue? Cascading timeout upstream?"
- **Good answer:** "Max 3 retries per external call, max 5 total retries per request across all substeps. If we hit 5, the request goes to dead-letter queue with a structured error. No retry on the DLQ entry. An alert fires if DLQ depth exceeds 10 in any 5-minute window."
- **Bad answer:** "We retry until it works. Eventually it'll succeed."

**Q16.4:** "What's the cold start behavior? How long from deploy to handling first request at full performance?"
- **Follow-up probe:** "Does it need a warm-up phase (cache priming, connection pool fill, model loading)?"
- **Follow-up probe:** "What happens if traffic arrives during cold start? Errors? Slow responses?"
- **Good answer:** "Cold start takes ~15s (model loading + connection pool init). During cold start, requests get 503 with retry-after: 20. After 15s, we're at full capacity. No warm-up cache needed because we pull on demand."
- **Bad answer:** "It starts up pretty quick. Shouldn't be an issue."

---

## Prompt 6 --- Scenarios & Satisfaction Metrics <a id="prompt-6"></a>

**Purpose:** Replace structured test cases with end-to-end user story scenarios and probabilistic satisfaction scoring. StrongDM evolved from "tests" to "scenarios" because agents exploit narrowly-written tests by "taking shortcuts like returning true." Satisfaction is probabilistic: "Of all observed trajectories through all scenarios, what fraction likely satisfy the user?" Not pass/fail.

**When to use:** Every step with acceptance criteria that need validation.

### Group 17 --- Scenario Design `[PM]`

**Filter Question:** "Would a real user actually encounter this scenario in production, or is it a test case you invented to check a code path?"

**Q17.1:** "Walk me through a real user story that exercises this step end-to-end. Start from the user's action and end at the user's outcome."
- **Follow-up probe:** "What's the second most common path through this step? The one that's not the happy path but isn't an error either."
- **Follow-up probe:** "What's an adversarial scenario, something a confused or frustrated user might do that's technically valid?"
- **Good answer:** "A patient sends a text: 'I need to refill my blood pressure meds and also my appointment next Tuesday might need to move.' That's two requests in one message. The step must split them, classify each independently, and route to the right downstream step. The second path: a provider's office sends a message on behalf of a patient. The adversarial case: a patient sends 'cancel everything' with no specifics."
- **Bad answer:** "User sends a message. System processes it. Output is correct."

**Q17.2:** "Give me three scenarios that are independent of each other, meaning the outcome of one doesn't affect the outcome of another."
- **Follow-up probe:** "If I ran these three in any order, would the results be identical? If not, they're not independent."
- **Follow-up probe:** "Do any of these scenarios share state that could leak between runs?"
- **Good answer:** "Scenario A: new patient inquiry about insurance coverage. Scenario B: existing patient requesting appointment reschedule. Scenario C: provider sending lab results for patient review. None share patient records, none modify shared state."
- **Bad answer:** "Test login, then test the dashboard after login, then test logout. They build on each other."

**Q17.3:** "What makes a scenario representative vs. contrived? How do you know your scenario set covers real production traffic?"
- **Follow-up probe:** "What percentage of real production requests would be covered by your top 5 scenarios?"
- **Follow-up probe:** "Where do scenarios come from? Support tickets? Production logs? User interviews?"
- **Good answer:** "We pull the top 20 message types from production logs (covers 85% of traffic). Each becomes a scenario with real, anonymized content. We add 5 adversarial scenarios from support escalations. Coverage target: 90% of production traffic patterns."
- **Bad answer:** "We brainstorm scenarios in a meeting. We try to think of everything."

### Group 18 --- Satisfaction Definition `[PM]`

**Filter Question:** "If the agent passes all your test cases but users are still unhappy, what did the tests miss?"

**Q18.1:** "For this step, what does 'satisfied' mean? Not 'correct output.' What would make a user say 'that worked well'?"
- **Follow-up probe:** "Is satisfaction binary (worked/didn't) or is there a spectrum (worked perfectly, worked okay, barely acceptable, failed)?"
- **Follow-up probe:** "What's the difference between 'correct but unsatisfying' and 'satisfying'?"
- **Good answer:** "Satisfaction has three levels. Perfect: classified correctly AND routed within 2s. Acceptable: classified correctly but took 5-10s. Failed: misclassified OR took >10s. An LLM judge scores each trajectory 1-5 based on: correct classification (40%), response time (30%), appropriate tone in any user-facing output (30%)."
- **Bad answer:** "If it gives the right answer, the user is satisfied."

**Q18.2:** "What's the aggregate satisfaction threshold? Below what percentage do you stop shipping?"
- **Follow-up probe:** "Is that threshold per-scenario or across all scenarios?"
- **Follow-up probe:** "What's the minimum sample size before the threshold is meaningful?"
- **Good answer:** "Aggregate: 85% of trajectories must score 4+ out of 5. Per-scenario: no single scenario below 70%. Minimum 100 runs per scenario before the threshold is valid. Below 85% aggregate, we block the deploy."
- **Bad answer:** "Above 80% is probably fine. We'll know it when we see it."

**Q18.3:** "How would you detect if the agent is gaming the satisfaction metric? Taking shortcuts that score well but don't actually serve the user."
- **Follow-up probe:** "What's a specific shortcut an agent might take on this step?"
- **Follow-up probe:** "What canary signal would reveal the gaming before users notice?"
- **Good answer:** "An agent could classify everything as 'general inquiry' (the safest bucket) to avoid misclassification penalties. Canary: if >40% of requests route to 'general inquiry,' something is wrong. Production baseline is 15%. Also: track distribution of classifications. If it diverges >20% from production baseline, flag it."
- **Bad answer:** "We trust the metrics. If it scores well, it's working."

### Group 19 --- Holdout & Regression `[ENG]`

**Filter Question:** "If the builder has seen every scenario, what stops them from overfitting to the exact test set?"

**Q19.1:** "Which scenarios should the builder never see? What's your holdout strategy?"
- **Follow-up probe:** "What percentage of scenarios are holdout?"
- **Follow-up probe:** "How often do you rotate scenarios between the training set and holdout set?"
- **Good answer:** "20% holdout, rotated quarterly. Holdout scenarios are drawn from the most recent production traffic (last 2 weeks) so they reflect current patterns, not historical ones. The builder never sees holdout scenarios or their results."
- **Bad answer:** "We use all scenarios for testing. More data is better."

**Q19.2:** "When a scenario fails, what information goes back to the builder? What's the bounded feedback template?"
- **Follow-up probe:** "What information is deliberately withheld to prevent overfitting?"
- **Follow-up probe:** "Is the feedback the same for holdout failures and training failures?"
- **Good answer:** "Feedback template: scenario ID, which satisfaction criteria failed (not the score), the step where failure occurred, and the category of failure (wrong classification, timeout, wrong routing). We do NOT reveal: the exact expected output, the scoring rubric weights, or the judge's reasoning. Holdout failures get NO feedback, only a pass/fail signal."
- **Bad answer:** "We show them everything so they can fix it."

**Q19.3:** "How do you detect regression when you add or modify scenarios?"
- **Follow-up probe:** "What's your baseline? How do you know the previous version's scores?"
- **Follow-up probe:** "What's the regression threshold that blocks a deploy?"
- **Good answer:** "Every scenario run is versioned. When we modify a scenario, we run the current agent against both old and new versions. If the score on unchanged scenarios drops by more than 5 points, it's a regression. Regression blocks deploy. We store historical scores in a time-series DB."
- **Bad answer:** "We just rerun everything and see if it passes."

---

## Prompt 7 --- Digital Twin Universe (DTU) <a id="prompt-7"></a>

**Purpose:** Spec the behavioral replicas of external dependencies needed for testing. StrongDM built behavioral replicas of Okta, Jira, Slack, Google Workspace and runs thousands of scenarios per hour. A DTU doesn't need to be a perfect replica. It needs to replicate the BEHAVIORS that matter for testing, including failure modes, rate limits, and latency patterns. Without DTU, holdout scenarios can't run at scale.

**When to use:** Any step that talks to an external dependency (API, database, third-party service).

### Group 20 --- Dependency Inventory `[BOTH]`

**Filter Question:** "Has this dependency actually caused a production incident? If not, are we building insurance for a risk that hasn't materialized?"

**Q20.1:** "List every external system this step talks to. For each: what's the purpose, is it read-only or read-write, and does a sandbox already exist?"
- **Follow-up probe:** "Which of these are critical path (step fails without them) vs. enrichment (step works without them, just less data)?"
- **Follow-up probe:** "For existing sandboxes, how closely do they mirror production data and behavior?"
- **Good answer:** "Three dependencies: (1) EHR API, read-only, critical path, no sandbox (production only). (2) Scheduling API, read-write, critical path, sandbox exists but data is 6 months stale. (3) SMS gateway, write-only, enrichment (can queue if down), sandbox exists and mirrors production."
- **Bad answer:** "We talk to a few systems. I'd have to check which ones."

**Q20.2:** "For each dependency, what are the known rate limits, quotas, or throttling behaviors?"
- **Follow-up probe:** "What happens when you hit the rate limit? 429? Silent drop? Queuing on their side?"
- **Follow-up probe:** "Have you actually hit these limits in production?"
- **Good answer:** "EHR API: 100 req/min per API key, returns 429 with retry-after header. We've hit this during morning clinic hours (8-9am). Scheduling API: no documented limit but we've seen 503s above ~200 req/min. SMS gateway: 50 messages/sec, queues on their side with eventual delivery."
- **Bad answer:** "I think there are some limits but I don't know the specifics."

### Group 21 --- Failure Mode Replication `[ENG]`

**Filter Question:** "Has this failure mode actually happened in production, or is it theoretical? If theoretical, what's the evidence it could happen?"

**Q21.1:** "For each dependency, what failure modes has production actually seen? Give me specific incidents, not categories."
- **Follow-up probe:** "What was the blast radius? How many users were affected? How long did it last?"
- **Follow-up probe:** "How did you detect it? Monitoring? User complaint? Accident?"
- **Good answer:** "EHR API: (1) Full outage for 45 min on Jan 15, affected all patient lookups, detected by error rate alert. (2) Slow degradation (responses went from 200ms to 8s) on Feb 3, lasted 2 hours, detected by a user complaint. (3) Started returning HTML error pages instead of JSON on Mar 1, broke our parser, detected by exception monitoring."
- **Bad answer:** "It goes down sometimes. The usual stuff."

**Q21.2:** "Which of those failure modes must the DTU replicate? Which can we skip?"
- **Follow-up probe:** "For the ones we replicate: does the twin need to reproduce the exact error response, or just the behavior pattern (slow, down, malformed)?"
- **Follow-up probe:** "Can we inject failures on demand, or must the twin fail probabilistically?"
- **Good answer:** "Must replicate: (1) Full outage (twin returns 503 for configurable duration). (2) Slow degradation (twin adds configurable latency). (3) Malformed response (twin returns HTML instead of JSON). Skip: auth token expiry (happens once a year, not worth building). Failures should be injectable on demand AND probabilistic (e.g., 5% of requests get 500ms added latency)."
- **Bad answer:** "Replicate everything. Better safe than sorry."

### Group 22 --- Behavioral Fidelity `[ENG]`

**Filter Question:** "If the twin's response is 95% similar to the real service but differs on 5% of edge cases, would your scenarios catch the difference?"

**Q22.1:** "For each dependency, what level of response fidelity is needed? Exact JSON shape? Approximate? Just status codes?"
- **Follow-up probe:** "Which specific fields in the response does this step actually read? Only those need fidelity."
- **Follow-up probe:** "Does the step parse the response body or just check the status code?"
- **Good answer:** "EHR API: exact JSON shape for the 6 fields we read (patient_id, name, dob, allergies, medications, insurance_id). Other fields can be stubbed. Scheduling API: exact JSON for available_slots array. SMS gateway: just status code (200 = sent, 429 = rate limited)."
- **Bad answer:** "Make it identical to production. We might need any field."

**Q22.2:** "Does the twin need to maintain state between calls? Does it need to remember what happened in previous requests?"
- **Follow-up probe:** "If stateful: what's the minimum state it must track? How long must state persist?"
- **Follow-up probe:** "Can the twin be reset between scenario runs, or must state carry across?"
- **Good answer:** "Scheduling API twin must be stateful: when a slot is booked, subsequent availability queries must reflect that. State resets between scenario runs. EHR twin is stateless (read-only). SMS twin is stateless (fire-and-forget)."
- **Bad answer:** "Everything should be stateless. Stateful is too complicated."

### Group 23 --- Volume & Rate Testing `[ENG]`

**Filter Question:** "Do you need to test at production volume, or is 10% representative enough?"

**Q23.1:** "What's the expected call volume per dependency? Average, peak, and burst."
- **Follow-up probe:** "What triggers bursts? Time of day? System events? Marketing campaigns?"
- **Follow-up probe:** "How long do bursts last?"
- **Good answer:** "EHR API: 50 req/min average, 200 req/min peak (8-9am weekdays), bursts of 500 req/min during bulk patient import (lasts ~10 min, happens monthly). Scheduling: 30 req/min average, 150 req/min peak when appointment reminders trigger rescheduling."
- **Bad answer:** "Probably not that many calls. A few per second maybe."

**Q23.2:** "What latency distribution should the twin replicate? P50, P95, P99 of the real service."
- **Follow-up probe:** "Should the twin add jitter to simulate real-world variance?"
- **Follow-up probe:** "What happens to your step's behavior if the twin is consistently faster than the real service?"
- **Good answer:** "EHR: P50=80ms, P95=200ms, P99=500ms. Twin should add random jitter within that distribution. If the twin is too fast, our timeout handling and circuit breaker logic won't be exercised, which defeats the purpose."
- **Bad answer:** "Make it fast. Speed doesn't matter for testing."

---

## Prompt 8 --- Inter-Step Data Contracts <a id="prompt-8"></a>

**Purpose:** Define the exact data contract between pipeline steps so that factory agents building different steps in different context windows produce compatible interfaces. StrongDM calls these "Semantic Ports": interfaces need formal semantic definitions, not just "Step 3 outputs a patient record." Without explicit contracts, integration breaks silently.

**When to use:** Any step that passes data to another step (which is almost every step except terminal ones).

### Group 24 --- Schema Definition `[BOTH]`

**Filter Question:** "Can you write the exact JSON shape that this step passes to the next step, right now, with field names and types? If not, that ambiguity will cause integration failures when agents build these steps independently."

**Q24.1:** "What are the exact fields this step outputs? For each: name, data type, required or optional, and a one-sentence description of what it contains."
- **Follow-up probe:** "Are there any fields that are always present but sometimes empty/null? That's different from optional."
- **Follow-up probe:** "Are there fields whose presence depends on a condition (e.g., 'only present if classification is urgent')?"
- **Good answer:** "Output: { request_id: string (UUID, required), classification: string (enum: urgent|routine|inquiry, required), confidence: float (0-1, required), patient_id: string (UUID, required if patient identified, null if not), extracted_entities: array of Entity objects (required, may be empty), raw_text: string (required, original message text) }"
- **Bad answer:** "It passes the patient record and the classification to the next step."

**Q24.2:** "For any nested objects or arrays in the output, what's the exact shape? Go one level deeper."
- **Follow-up probe:** "What's the maximum array length? Is it bounded?"
- **Follow-up probe:** "Can nested objects have their own optional fields?"
- **Good answer:** "Entity object: { type: string (enum: medication|appointment|provider|facility, required), value: string (required, the extracted text), normalized_value: string (optional, canonical form if resolved), confidence: float (0-1, required) }. Max 20 entities per request. If more than 20, keep the 20 with highest confidence."
- **Bad answer:** "It's a list of entities. Each has a type and value."

**Q24.3:** "What naming conventions must all fields follow across the entire pipeline?"
- **Follow-up probe:** "camelCase or snake_case? Are there existing conventions from other parts of the system?"
- **Follow-up probe:** "How are dates formatted? Times? Timestamps? Timezone handling?"
- **Good answer:** "snake_case everywhere. Dates: ISO 8601 (YYYY-MM-DD). Timestamps: ISO 8601 with timezone (2026-03-13T08:30:00Z). All times in UTC. IDs: UUID v4 format. Enums: lowercase with underscores. This matches our existing API conventions."
- **Bad answer:** "Whatever feels natural. We'll standardize later."

### Group 25 --- Contract Enforcement `[ENG]`

**Filter Question:** "Step N sends a string where Step N+1 expects an integer. What catches that, and what happens? If the answer is 'nothing,' your pipeline has a silent failure waiting to happen."

**Q25.1:** "What happens when a required field is missing from the output? Does the next step fail? Use a default? Skip processing?"
- **Follow-up probe:** "Is that behavior documented in the consuming step's spec, or is it implicit?"
- **Follow-up probe:** "Does the producing step validate its own output before passing it downstream?"
- **Good answer:** "Producer validates output against the schema before emitting. If validation fails, the request goes to a dead-letter queue with the validation error. Consumer also validates on receipt as a defense-in-depth check. Missing required field = reject, log structured error, do not process. No defaults for required fields."
- **Bad answer:** "The next step should handle whatever it gets. We'll add error handling later."

**Q25.2:** "What happens when a field has an unexpected type or value? String instead of integer, unknown enum value, negative number where positive is expected."
- **Follow-up probe:** "Is type coercion ever acceptable (e.g., '42' -> 42), or is it always a contract violation?"
- **Follow-up probe:** "For enums: what happens when a new enum value is added by the producer but the consumer doesn't know about it yet?"
- **Good answer:** "No coercion. Type mismatch is always a contract violation. For enums: consumer must handle unknown values by routing to a 'needs_review' fallback, not by crashing. This is explicitly documented in the consumer's spec. When we add enum values, we update consumer specs first, deploy consumers, then update producers."
- **Bad answer:** "We'll just try to parse it. If it fails, we'll catch the exception."

**Q25.3:** "Where does schema validation run? Producer side, consumer side, or both? What's the validation mechanism?"
- **Follow-up probe:** "What's the performance cost of validation? Is it acceptable at production volume?"
- **Follow-up probe:** "Is the schema definition shared (single source of truth) or duplicated across steps?"
- **Good answer:** "Both sides. Single JSON Schema file per contract, stored in a shared schemas/ directory. Producer validates before emit, consumer validates on receipt. Validation adds <1ms overhead (negligible at our volume). Schema files are the single source of truth. Both steps import from the same file."
- **Bad answer:** "We'll validate somewhere. Probably in a middleware."

### Group 26 --- Versioning & Evolution `[ENG]`

**Filter Question:** "If Step N adds a new field tomorrow, what breaks? If the answer is 'I don't know,' your pipeline is fragile."

**Q26.1:** "How do contracts change over time? What's the versioning strategy?"
- **Follow-up probe:** "Semantic versioning (major.minor.patch)? Or something simpler?"
- **Follow-up probe:** "What triggers a major version bump vs. a minor one?"
- **Good answer:** "Semantic versioning. Adding optional fields = minor bump. Removing fields, changing types, or adding required fields = major bump. Major bumps require a migration plan and both producer and consumer updates before deploy. Contract version is included in every message header."
- **Bad answer:** "We don't version contracts. We just update them."

**Q26.2:** "How do you add a field without breaking consumers?"
- **Follow-up probe:** "Do consumers ignore unknown fields, or do they reject them?"
- **Follow-up probe:** "How long do you support the old shape after adding a new field?"
- **Good answer:** "New fields are always optional for at least one release cycle. Consumers must ignore unknown fields (open-world assumption). After two release cycles with the new field, it can be promoted to required. Consumer is updated first to accept the new field, then producer starts sending it."
- **Bad answer:** "We add it and tell everyone to update. It's their problem."

**Q26.3:** "When a contract changes, what's the migration path? How do both sides coordinate?"
- **Follow-up probe:** "Can both old and new contract versions coexist during migration?"
- **Follow-up probe:** "Who is responsible for ensuring backward compatibility during the transition?"
- **Good answer:** "Two-phase deploy. Phase 1: deploy consumers that accept both old and new contract. Phase 2: deploy producers that emit new contract. Rollback: producers revert to old contract. The contract owner (producer step's spec author) is responsible for the migration plan. Both versions coexist for max 1 release cycle."
- **Bad answer:** "We do a big-bang deploy. Everything updates at once."

---

## Prompt 9 --- Production Observability & Model Selection <a id="prompt-9"></a>

**Purpose:** Spec the monitoring, alerting, drift detection, and per-step model assignment for production. StrongDM's Weather Report shows dedicated model assignments per step. Production behavior is continuously compared against spec invariants. Drift creates feedback into the next spec iteration. Without observability, you're flying blind. Without model selection, you're overspending or underperforming.

**Important distinction (Decision 4, March 10 2026):** Drift detection here is an **observability practice** (monitoring metrics, flagging divergence, feeding back to spec owner). It is NOT a formal autonomous drift detector component that auto-corrects behavior. The formal drift detector pattern was explicitly rejected. Humans review drift signals and decide whether to update specs.

**When to use:** Every step that runs continuously in production.

### Group 27 --- Continuous Monitoring `[ENG]`

**Filter Question:** "If this metric degraded by 20% over a week, would anyone notice without an alert? If not, you need monitoring."

**Q27.1:** "Which acceptance criteria from this spec should be continuously monitored in production, not just at deploy time?"
- **Follow-up probe:** "For each: what's the metric name, measurement method, and collection frequency?"
- **Follow-up probe:** "Which metrics are leading indicators (predict problems) vs. lagging indicators (confirm problems)?"
- **Good answer:** "Monitor: (1) Classification accuracy, measured by sampling 5% of requests and comparing to human labels, weekly batch. Leading indicator. (2) P99 latency, measured from application traces, every request. Lagging indicator. (3) Error rate per classification type, from structured logs, aggregated per minute. Leading indicator (spikes predict downstream failures)."
- **Bad answer:** "Monitor everything. More data is better."

**Q27.2:** "What dashboard does an operator need to assess this step's health in under 30 seconds?"
- **Follow-up probe:** "What are the 3-5 panels on that dashboard? What does each show?"
- **Follow-up probe:** "What's the default time range? What drill-down is needed?"
- **Good answer:** "Five panels: (1) Request rate with 24hr overlay. (2) P50/P95/P99 latency. (3) Error rate by type (timeout, validation, dependency). (4) Classification distribution (pie chart, compared to baseline). (5) Cost per request trend. Default: last 6 hours. Drill-down: click any panel to filter by patient type or message channel."
- **Bad answer:** "A dashboard that shows if things are working."

**Q27.3:** "What's the sampling rate for detailed monitoring? 100%? 10%? 1%?"
- **Follow-up probe:** "What's the cost of monitoring at that rate?"
- **Follow-up probe:** "For sampled metrics, what's the minimum sample size for statistical significance?"
- **Good answer:** "Latency and errors: 100% (low overhead, structured logs). Classification accuracy: 5% sample with human review weekly. Cost tracking: 100% (derived from token counts already in logs). At 5% sample rate, we need ~400 samples per classification type per week for 95% confidence."
- **Bad answer:** "100% of everything. We need full visibility."

### Group 28 --- Alerting & Invariant Violation `[ENG]`

**Filter Question:** "If this alert fired at 3am, would someone actually get out of bed? If not, it's not a real alert. Downgrade it to a weekly report."

**Q28.1:** "What alerts fire when a spec invariant is violated? Be specific: which invariant, what threshold, what severity."
- **Follow-up probe:** "For each alert: who gets paged? What's the escalation path if they don't acknowledge in N minutes?"
- **Follow-up probe:** "What's the difference between a warning (investigate tomorrow) and a critical (wake someone up)?"
- **Good answer:** "Critical (page on-call): (1) PII detected in logs (any occurrence). (2) Error rate >10% for >5 min. (3) P99 latency >5s for >5 min. Warning (Slack channel, investigate next business day): (4) Classification distribution diverges >15% from baseline. (5) Cost per request trending >20% above budget over 24hr. Escalation: unacknowledged critical in 15min goes to engineering manager."
- **Bad answer:** "Alert on everything. Someone will triage."

**Q28.2:** "For each critical alert, what's the runbook? First three steps an on-call engineer takes."
- **Follow-up probe:** "Is the runbook automated (self-healing) or manual?"
- **Follow-up probe:** "What's the mean time to resolve for each alert type historically?"
- **Good answer:** "PII in logs: (1) Identify affected log entries via structured query. (2) Redact entries using log-redaction tool. (3) Check if PII propagated to downstream consumers. MTTR: ~20 min. Error rate spike: (1) Check dependency health dashboard. (2) If dependency down, confirm circuit breaker is open. (3) If circuit breaker failed, manually open it. MTTR: ~10 min."
- **Bad answer:** "Look at the logs and figure out what's wrong."

**Q28.3:** "What's the false positive tolerance? How many false alerts per week before the team starts ignoring them?"
- **Follow-up probe:** "How do you tune thresholds to reduce false positives without missing real incidents?"
- **Good answer:** "Max 2 false positives per week per alert type. Above that, we must tune thresholds or the alert gets muted and goes to weekly review. We tune by analyzing the last 30 days of alert history, adjusting thresholds to the 99th percentile of normal behavior."
- **Bad answer:** "False positives are fine. Better safe than sorry."

### Group 29 --- Drift Detection & Feedback Loop `[BOTH]`

**Filter Question:** "If the input distribution shifted gradually over 3 months, would your current monitoring catch it before users complained?"

**Q29.1:** "How do you detect when production behavior drifts from what the spec defined? What specific signals indicate drift?"
- **Follow-up probe:** "Input drift (the requests are changing) vs. output drift (the step's behavior is changing). Which matters more?"
- **Follow-up probe:** "What statistical test or metric quantifies drift?"
- **Good answer:** "Input drift: monitor classification distribution weekly. If any category shifts >10% from the 30-day rolling average, flag for review. Output drift: sample 50 requests per week for human evaluation. If satisfaction score drops >5 points from baseline, trigger spec review. We use Jensen-Shannon divergence for distribution comparison."
- **Bad answer:** "We'll notice if things go wrong. Users will tell us."

**Q29.2:** "What's the drift threshold that triggers action? And what action?"
- **Follow-up probe:** "Is the action automatic (retrain, update) or manual (review, decide)?"
- **Follow-up probe:** "What's the SLA from drift detection to resolution?"
- **Good answer:** "Threshold: JS divergence >0.1 on input distribution OR satisfaction drop >5 points. Action: (1) Auto-create a review ticket assigned to spec owner. (2) Spec owner has 1 week to investigate and propose spec update. (3) If drift is confirmed, enter spec revision cycle. No automatic changes. Always human-reviewed."
- **Bad answer:** "We'll look at it when we get around to it."

**Q29.3:** "How does feedback from production flow back into the spec? What's the loop?"
- **Follow-up probe:** "Who owns the feedback loop? Who decides when a spec needs updating?"
- **Follow-up probe:** "How do you prevent the spec from accumulating patches until it's incoherent?"
- **Good answer:** "Monthly spec review meeting. Inputs: (1) Drift alerts from the past month. (2) Satisfaction trend data. (3) New failure modes discovered. (4) Support escalation themes. Output: updated spec with changelog. The spec owner (PM for behavioral, Eng for technical) approves all changes. Every 6 months, full spec rewrite to clear accumulated patches."
- **Bad answer:** "We update the spec whenever someone remembers to."

### Group 30 --- Model Assignment & Consensus `[BOTH]`

**Filter Question:** "Are you choosing this model because it's the best for this task, or because it's the model you're most familiar with?"

**Q30.1:** "Which model should handle this step? What's the selection criteria: speed, cost, accuracy, or a specific capability?"
- **Follow-up probe:** "Have you benchmarked multiple models on this step's specific task?"
- **Follow-up probe:** "What's the cost difference between your preferred model and the cheapest model that meets the accuracy threshold?"
- **Good answer:** "Classification step: Claude Haiku. Benchmarked against Sonnet and GPT-4o-mini on 500 production samples. Haiku: 94% accuracy, 120ms P50, $0.003/req. Sonnet: 97% accuracy, 350ms P50, $0.012/req. The 3% accuracy gain doesn't justify the 4x cost increase. Haiku meets our 90% threshold."
- **Bad answer:** "Use the best model available. Accuracy is what matters."

**Q30.2:** "Do any decisions in this step need multi-model consensus? Where one model isn't trusted enough alone?"
- **Follow-up probe:** "How is consensus defined? Majority vote? Unanimous? Weighted by confidence?"
- **Follow-up probe:** "What happens when models disagree?"
- **Good answer:** "Urgency classification for potential safety issues: requires 2-of-3 agreement (Haiku + Sonnet + GPT-4o-mini). If 2 agree it's urgent, route to urgent queue. If no consensus, escalate to human. Cost: 3x per safety-flagged request (~5% of traffic). Worth it for patient safety."
- **Bad answer:** "One model is fine. We trust it."

**Q30.3:** "What's the model fallback chain? If the primary model is down or rate-limited, what's next?"
- **Follow-up probe:** "Does the fallback model meet the same acceptance criteria as the primary?"
- **Follow-up probe:** "How do you detect that you're running on fallback? Is it alertable?"
- **Good answer:** "Primary: Claude Haiku via Anthropic API. Fallback 1: Claude Haiku via AWS Bedrock. Fallback 2: GPT-4o-mini via Azure. Fallback 3: rule-based classifier (no LLM). Each fallback is benchmarked against the same 500-sample set. Fallback 2 meets 90% threshold. Fallback 3 meets 75% (below threshold, triggers alert). Running on any fallback triggers a warning alert."
- **Bad answer:** "If it's down, we wait for it to come back."

---

## Post-Production-Bridge Review Questions

After completing Prompts 5-9, ask the user:

1. "Are any of the NFRs aspirational rather than measured? Which ones need load testing before they're real?"
2. "Do your scenarios cover the top 80% of production traffic? What's missing?"
3. "For each dependency in the DTU, has the failure mode actually been seen in production?"
4. "Can you write the exact JSON contract between every pair of connected steps right now?"
5. "If every alert on your list fired simultaneously at 3am, which one would you look at first? That's your priority order."
