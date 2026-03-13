# MECE Gap Question Banks (Prompt 10 — Comprehensive Coverage)

These question groups close the remaining MECE gaps identified in the audit of Groups 1-30. They cover security, data lifecycle, cross-step coordination, rollout, incident response, operational readiness, resilience testing, deprecation, documentation, and data quality.

**When to use:** After completing Prompts 1-3 (behavioral) and Prompts 5-9 (production bridge), check the applicability table below. Most steps need at least Groups 31-32 (security and data lifecycle). The rest depend on step characteristics.

| Group | Apply When | Skip When |
|-------|------------|-----------|
| 31 - Security & Audit | Step handles sensitive data or privileged actions | Pure internal computation with no data access |
| 32 - Data Lifecycle | Step creates or stores data | Step is stateless pass-through |
| 33 - Cross-Step Coordination | Step has side effects observable by other steps | Step is pure function (input in, output out, no mutations) |
| 34 - Gradual Rollout | Step is being introduced or significantly changed | Step is stable and unchanged |
| 35 - Incident Response | Step runs in production with alerting (Group 28) | Step has no production alerting |
| 36 - Operational Readiness | Step requires on-call support | Step is fully autonomous with no human intervention |
| 37 - Chaos Engineering | Step has failed in ways not caught by tests | Step has never had a production incident |
| 38 - Deprecation & Migration | Step will eventually be replaced | Step is permanent infrastructure |
| 39 - Documentation | Step is complex enough to require onboarding | Step is trivial and self-explanatory |
| 40 - Data Quality | Step processes data where quality affects outcomes | Step handles data where quality is guaranteed upstream |

**Also includes:** Extensions to Group 14 (cost allocation) and Group 16 (capacity planning).

---

## Group 14 Extensions --- Cost Allocation & Budget Tracking `[BOTH]`

These questions extend the existing Group 14 (Resource Constraints & Budgets) with cost allocation and tracking.

**Q14.4:** "How are costs for this step attributed? Per-request, per-tenant, per-team, or pooled?"
- **Follow-up probe:** "If per-tenant, how do you handle tenants with wildly different usage patterns?"
- **Follow-up probe:** "Is cost attribution automated or manual? How often is it reconciled?"
- **Good answer:** "Per-tenant attribution via request tags. Each API call carries a tenant_id header. Costs are aggregated daily in our billing pipeline. High-usage tenants (top 5%) get individual cost reports. Reconciliation runs weekly against cloud provider invoices."
- **Bad answer:** "We split costs evenly across teams. It's easier."

**Q14.5:** "What's the budget alert threshold for this step, and who gets notified when it's exceeded?"
- **Follow-up probe:** "Is the alert based on daily run rate, weekly cumulative, or monthly projection?"
- **Follow-up probe:** "What action is taken when the budget is exceeded? Throttle? Alert? Auto-scale?"
- **Good answer:** "Alert at 80% of monthly budget (projected from 7-day rolling average). Engineering lead and finance get notified. At 100%, we throttle non-critical requests. At 120%, we page the on-call engineer."
- **Bad answer:** "We check the bill at the end of the month."

---

## Group 16 Extensions --- Capacity Planning & Growth Projections `[BOTH]`

These questions extend the existing Group 16 (Load Behavior) with capacity planning.

**Q16.5:** "What's the projected growth rate for this step's traffic over the next 6 and 12 months? What's the basis for that projection?"
- **Follow-up probe:** "Is the growth organic (more users) or step-function (new feature, new tenant, new market)?"
- **Follow-up probe:** "At what traffic level does the current architecture hit a hard ceiling that requires re-architecture, not just scaling?"
- **Good answer:** "6-month: 3x current traffic (based on signed contracts for 2 new clinic networks). 12-month: 8x (if we launch in 3 new states). Hard ceiling at 15x due to database connection pool limits. Re-architecture needed before Q3."
- **Bad answer:** "It'll probably grow. We'll scale when we need to."

**Q16.6:** "What's the capacity planning cadence? How far ahead do you provision, and who owns the forecast?"
- **Follow-up probe:** "Is provisioning automated (autoscale) or manual (request infrastructure N weeks ahead)?"
- **Follow-up probe:** "What's the lead time to provision additional capacity?"
- **Good answer:** "Monthly capacity review. Eng lead owns the forecast, validated against product's growth projections. Autoscale handles 2x bursts. Beyond that, we need 2 weeks to provision new database replicas. We maintain 30% headroom above projected peak."
- **Bad answer:** "We autoscale. Cloud handles it."

---

## Prompt 10 --- Comprehensive Coverage <a id="prompt-10"></a>

### Group 31 --- Security, Access Control & Audit `[PM]`

**Filter Question:** "Does this step access, create, modify, or delete sensitive data, or perform privileged actions? If not, skip this group."

**Q31.1:** "Who has access to the data and actions at this step? List every role, system, or service account with the access level (read, write, execute, admin)."
- **Follow-up probe:** "Are there any service-to-service calls that bypass user-level access controls? How are those authenticated?"
- **Follow-up probe:** "How are permissions granted and revoked? Is it self-service, manager-approved, or automated based on role assignment?"
- **Good answer:** "Three roles: (1) Clinician: read + write patient records at this step. (2) Admin: read + audit log access, no write. (3) AI Agent service account: read + write via scoped OAuth token with patient_record:write scope. Permissions are RBAC-managed through our identity provider. Revocation is automatic on role change, with 15-minute propagation delay."
- **Bad answer:** "The team has access. We'll lock it down before launch."

**Q31.2:** "What audit trail is required for this step? For every action, what must be logged: who, what, when, which record, and what changed?"
- **Follow-up probe:** "Are audit logs tamper-proof? Can an admin modify or delete audit entries?"
- **Follow-up probe:** "What's the retention period for audit logs, and does it meet HIPAA's 6-year minimum?"
- **Follow-up probe:** "If a regulator asked 'show me every access to patient X's record in the last year,' could you produce that report?"
- **Good answer:** "Every access to PHI logs: user_id, action (read/write/delete), patient_record_id, timestamp, fields accessed, IP address. Logs are append-only in an immutable store. Retained for 7 years. We can produce per-patient access reports within 4 hours via our audit query tool."
- **Bad answer:** "We log errors. I think there's some access logging too."

**Q31.3:** "What PHI/PII does this step handle, and what are the specific protection requirements?"
- **Follow-up probe:** "Is PHI encrypted at rest and in transit? What encryption standard?"
- **Follow-up probe:** "Does this step transmit PHI to any third-party system? If so, is there a BAA in place?"
- **Follow-up probe:** "What happens if PHI appears somewhere it shouldn't (logs, error messages, debug output)? What's the remediation procedure?"
- **Good answer:** "This step handles patient name, DOB, medication list, and insurance ID. All PHI encrypted at rest (AES-256) and in transit (TLS 1.3). PHI is transmitted to the EHR API (BAA signed Feb 2026). PHI must never appear in application logs. If detected, our PII scanner triggers a critical alert, and the log-redaction tool removes it within 20 minutes."
- **Bad answer:** "It's healthcare data, so we're careful with it."

### Group 32 --- Data Lifecycle & Compliance `[PM]`

**Filter Question:** "Does this step create, store, or persist any data beyond the request lifecycle? If all data is ephemeral (processed and discarded), skip this group."

**Q32.1:** "For each data type this step produces or stores, what's the retention period? Is it based on regulation, business need, or both?"
- **Follow-up probe:** "Which regulation mandates the retention period? Can you cite the specific requirement?"
- **Follow-up probe:** "What happens when the retention period expires? Auto-delete, archive, or manual review?"
- **Follow-up probe:** "Is there a difference between the retention period for the raw data vs. derived/aggregated data?"
- **Good answer:** "Patient records: 7 years (HIPAA mandates 6, we add 1 for legal buffer). Audit logs: 7 years (same). Request metadata (non-PHI): 90 days for debugging, then auto-deleted. Aggregated metrics: retained indefinitely (no PHI). Deletion is automated via a nightly job that checks expiry timestamps."
- **Bad answer:** "We keep everything. Storage is cheap."

**Q32.2:** "If a patient requests deletion of their data ('right to be forgotten'), what happens at this step? What can be deleted, and what must be retained for legal reasons?"
- **Follow-up probe:** "How long does it take to process a deletion request end-to-end?"
- **Follow-up probe:** "Does deletion propagate to downstream steps, caches, backups, and analytics systems?"
- **Follow-up probe:** "How do you verify that deletion is complete across all storage locations?"
- **Good answer:** "Patient deletion request triggers a workflow: (1) Active records anonymized within 72 hours. (2) Audit logs retained (required by HIPAA) but patient name replaced with a hash. (3) Backups are not modified (too costly), but restored backups go through the anonymization check. (4) Downstream steps receive a 'patient_deleted' event and purge their caches. Verification: automated scan confirms zero references to the patient ID across all active stores."
- **Bad answer:** "We delete their account. That should be enough."

**Q32.3:** "What's the archival strategy? How does data move from hot to warm to cold storage, and what triggers the transition?"
- **Follow-up probe:** "What's the retrieval time from each storage tier?"
- **Follow-up probe:** "Is archived data still queryable, or does it need to be restored first?"
- **Follow-up probe:** "What's the cost difference between keeping data hot vs. archiving it?"
- **Good answer:** "Hot (active DB): records accessed in the last 90 days. Warm (read replica): records 90 days to 1 year old, queryable with 2s latency. Cold (S3 Glacier): records older than 1 year, retrieval takes 4-12 hours. Transition is automated based on last_accessed_at timestamp. Cost: hot is 10x cold per GB. Archival saves approximately $3K/month at current data volumes."
- **Bad answer:** "Everything stays in the database. We'll figure out archival later."

### Group 33 --- Cross-Step Coordination & Side Effects `[BOTH]`

**Filter Question:** "Does this step create any side effects (DB writes, cache mutations, external API calls, event emissions) that other steps could observe or depend on? If this step is a pure function with no mutations, skip this group."

**Q33.1:** "What side effects does this step create? For each: what is mutated, who observes it, and what breaks if the mutation is delayed, duplicated, or lost?"
- **Follow-up probe:** "If this step writes to a database and a parallel step reads from it, is there a consistency guarantee (strong, eventual, read-your-writes)?"
- **Follow-up probe:** "Are side effects idempotent? If this step runs twice on the same input, does it produce the same state?"
- **Good answer:** "Three side effects: (1) Writes task record to tasks table (observed by the routing step, breaks routing if delayed >5s). (2) Emits 'task_created' event to message bus (consumed by notification step, duplicate events are handled via idempotency key). (3) Updates patient.last_interaction_at timestamp (observed by analytics, eventual consistency is acceptable). All writes are idempotent via upsert on request_id."
- **Bad answer:** "It saves some data. Other steps read it."

**Q33.2:** "If two instances of this step (or this step and a parallel step) try to modify the same resource simultaneously, what happens?"
- **Follow-up probe:** "What concurrency control is in place? Optimistic locking, pessimistic locking, or none?"
- **Follow-up probe:** "What's the conflict resolution strategy? Last-write-wins, merge, or reject?"
- **Follow-up probe:** "Has this race condition actually occurred in production?"
- **Good answer:** "Optimistic locking via version column on the tasks table. If two writes conflict, the second gets a 409 Conflict and retries with the latest version. We've seen this in production during peak hours (about 0.1% of requests). The retry succeeds on second attempt 99% of the time."
- **Bad answer:** "It won't happen. Our system processes requests sequentially."

**Q33.3:** "If a downstream step fails after this step has already completed and committed its side effects, does this step need to compensate (undo its work)?"
- **Follow-up probe:** "Is there a saga or compensation pattern in place? Who coordinates it?"
- **Follow-up probe:** "What's the time window for compensation? Can you undo a write from 5 minutes ago? 5 hours ago?"
- **Follow-up probe:** "What's the blast radius of a failed compensation (undo that itself fails)?"
- **Good answer:** "Yes, this step publishes a compensating event if downstream routing fails. Compensation sets the task status to 'cancelled' and emits 'task_cancelled' to the bus. Compensation is possible within 24 hours (after that, the task may have been acted on and compensation requires human review). If compensation fails, it goes to a dead-letter queue and pages the on-call engineer."
- **Bad answer:** "Downstream steps handle their own failures. We don't undo anything."

### Group 34 --- Gradual Rollout & Feature Flags `[PM]`

**Filter Question:** "Is this step being introduced for the first time, or is the behavior changing significantly from the current version? If this is a stable, unchanged step, skip this group."

**Q34.1:** "What's the rollout plan? Walk me through the stages: what percentage of traffic at each stage, how long before advancing, and what metrics must be green to advance."
- **Follow-up probe:** "Has this rollout strategy been used before on a similar step, or is it theoretical?"
- **Follow-up probe:** "What's the minimum sample size at each stage before the metrics are statistically meaningful?"
- **Follow-up probe:** "Who approves advancement to the next stage? Automated or human decision?"
- **Good answer:** "Stage 1: 1% of traffic for 48 hours (internal users only). Stage 2: 10% for 1 week (one clinic). Stage 3: 50% for 2 weeks (all clinics, random assignment). Stage 4: 100%. Advancement requires: error rate <0.5%, P99 latency <1s, satisfaction score >85%. Minimum 500 requests per stage. Stage 1-2 advancement is automated. Stage 3-4 requires PM + Eng lead sign-off."
- **Bad answer:** "We'll launch to everyone and watch the metrics."

**Q34.2:** "What triggers an automatic rollback, and what triggers a manual review?"
- **Follow-up probe:** "How fast does the rollback execute? Seconds? Minutes? Does it require a deploy?"
- **Follow-up probe:** "After a rollback, how do you diagnose what went wrong before trying again?"
- **Good answer:** "Automatic rollback: error rate >5% for >3 minutes, or any PII leak alert. Rollback executes in <30 seconds via feature flag toggle (no deploy needed). Manual review: satisfaction score drops >10 points, or classification distribution diverges >15% from baseline. After rollback, we freeze the flag, pull the last 1000 requests for analysis, and require a postmortem before re-attempting."
- **Bad answer:** "We'll roll back if something goes wrong. Someone will notice."

**Q34.3:** "What do users outside the rollout see? Same old behavior, a different experience, or an error?"
- **Follow-up probe:** "How do you ensure the control group's experience doesn't degrade during the rollout?"
- **Follow-up probe:** "If a user is in the rollout group and then gets rolled back, do they notice the switch? Is there a jarring experience?"
- **Good answer:** "Users outside the rollout see the existing step (v1) with zero changes. Feature flag routes at the API gateway level, so the decision happens before any processing. On rollback, users revert to v1 seamlessly. No jarring experience because both versions use the same data contracts. We monitor v1 performance during rollout to ensure it's not degraded by shared resource contention."
- **Bad answer:** "They won't notice. Probably."

### Group 35 --- Incident Response & Runbooks `[ENG]`

**Filter Question:** "Does this step have production alerting (from Group 28)? If no alerts exist, incident response is undefined. Skip this group and complete Group 28 first."

**Q35.1:** "For each critical alert on this step, what are the first three diagnostic steps an on-call engineer should take? Be specific enough that an engineer who has never seen this step could follow them."
- **Follow-up probe:** "What tools are needed for each diagnostic step? Are they all accessible to the on-call engineer?"
- **Follow-up probe:** "What's the expected time to complete each diagnostic step?"
- **Follow-up probe:** "If the runbook was followed at 3am by an engineer who has never seen this step, would they resolve the incident?"
- **Good answer:** "For 'Error rate >10%' alert: (1) Check dependency health dashboard (Grafana, link in runbook) to see if a dependency is down (2 min). (2) If dependency is healthy, check recent deployments in the deploy log for this step (1 min). (3) If no recent deploy, pull the last 50 error logs from Datadog with the query in the runbook and look for a new error pattern (5 min). All tools are accessible via SSO. Total diagnostic time: <10 min."
- **Bad answer:** "Check the logs and figure out what's wrong."

**Q35.2:** "What's the rollback procedure specific to this step? Not a generic deploy rollback. What does rolling back THIS step's behavior look like?"
- **Follow-up probe:** "Does rollback require a redeploy, a feature flag toggle, or a database migration reversal?"
- **Follow-up probe:** "What's the blast radius of the rollback? Does rolling back this step affect other steps?"
- **Good answer:** "Rollback is a feature flag toggle (no redeploy). The flag routes traffic to the previous version of the classification logic. Rollback takes <30 seconds. No impact on other steps because each step has an independent feature flag. If the issue is data corruption (not logic), rollback also requires running the data-fix script documented in the runbook."
- **Bad answer:** "We'll redeploy the previous version."

**Q35.3:** "After an incident is resolved, how does the spec get updated to prevent recurrence? What's the feedback loop from incident to spec change?"
- **Follow-up probe:** "Who owns the postmortem for this step? Is it the spec author, the on-call engineer, or someone else?"
- **Follow-up probe:** "What's the SLA for updating the spec after an incident?"
- **Good answer:** "Postmortem within 5 business days, owned by the on-call engineer who resolved it. Output: (1) Root cause analysis. (2) Spec change proposal (new constraint, updated threshold, or new failure mode in Group 12). (3) Spec updated within 2 weeks of postmortem approval. The spec changelog links to the incident ID."
- **Bad answer:** "We do a retro sometimes."

### Group 36 --- Operational Readiness (On-Call, Training) `[ENG]`

**Filter Question:** "Does this step require human intervention to operate (on-call support, manual review queues, periodic maintenance)? If fully autonomous with no human touchpoints, skip this group."

**Q36.1:** "Who is on-call for this step, what's the rotation schedule, and what's the escalation path if they don't respond?"
- **Follow-up probe:** "Is the on-call specific to this step, or shared across multiple steps/services?"
- **Follow-up probe:** "What's the maximum response time SLA for the primary on-call?"
- **Good answer:** "Shared on-call across the AI pipeline team, rotating weekly. Primary has 15-minute response SLA. If no response in 15 min, auto-escalate to secondary. If no response in 30 min, escalate to engineering manager. Rotation: 4 engineers, each on-call 1 week per month. No one is on-call more than 7 consecutive days."
- **Bad answer:** "Someone on the team handles it."

**Q36.2:** "What training does an engineer need before being on-call for this step? How do you verify they're ready?"
- **Follow-up probe:** "Is there a shadow shift before going on-call solo?"
- **Follow-up probe:** "What happens when a new engineer joins the team? How long before they're on-call-ready for this step?"
- **Good answer:** "Prerequisites: (1) Complete the 'AI Pipeline On-Call Training' doc (2 hours). (2) Shadow one full on-call shift with a senior engineer. (3) Successfully resolve one simulated incident in our staging environment. New engineers are on-call-ready after ~3 weeks. Training doc is reviewed quarterly."
- **Bad answer:** "They'll figure it out. We all learned on the job."

**Q36.3:** "What's the handoff procedure between on-call shifts? What information transfers?"
- **Follow-up probe:** "Where is the handoff documented? Is it a Slack message, a wiki page, a structured form?"
- **Follow-up probe:** "What happens if the outgoing on-call engineer forgot to mention an ongoing issue?"
- **Good answer:** "Structured handoff in our on-call tool at shift change. Includes: open incidents, ongoing investigations, recent deploys, known flaky alerts, and anything unusual observed during the shift. If something is missed, the incoming engineer checks the alert history for the last 24 hours as standard practice."
- **Bad answer:** "We tell the next person what's going on."

### Group 37 --- Chaos Engineering & Resilience Testing `[ENG]`

**Filter Question:** "Has this step ever failed in a way that wasn't caught by unit or integration tests? If the step has never had a production incident, chaos engineering may be premature. Skip this group."

**Q37.1:** "Which failure modes should be intentionally triggered to verify this step handles them correctly? List the specific faults: dependency down, dependency slow, malformed response, resource exhaustion."
- **Follow-up probe:** "For each failure mode, what's the expected behavior? Not 'handle gracefully.' What specific output, status code, or fallback?"
- **Follow-up probe:** "Which of these have actually been tested, and which are theoretical?"
- **Good answer:** "Three fault injections: (1) EHR API returns 503 for 60 seconds. Expected: circuit breaker opens, serve cached response, alert fires. Tested monthly. (2) Classification model returns in 5s instead of 200ms. Expected: timeout at 3s, fallback to rule-based classifier. Tested quarterly. (3) Message bus is unavailable. Expected: queue locally, retry with backoff, alert if queue depth >100. Never tested. That's the one I'm worried about."
- **Bad answer:** "We'll break things and see what happens."

**Q37.2:** "What blast radius controls limit the chaos experiment so it doesn't take down production?"
- **Follow-up probe:** "Is the experiment scoped to a percentage of traffic, a specific tenant, or a staging environment?"
- **Follow-up probe:** "What's the kill switch? How fast can you stop the experiment if something goes wrong?"
- **Good answer:** "Experiments run on 5% of production traffic, isolated via feature flag. Kill switch is a single API call that disables the fault injection in <10 seconds. All experiments have a maximum duration of 30 minutes, after which they auto-terminate. We never run chaos experiments on more than one step simultaneously."
- **Bad answer:** "We'll be careful."

**Q37.3:** "What proves the step is resilient? Define the success criteria for each chaos experiment."
- **Follow-up probe:** "What metrics must stay within bounds during the experiment?"
- **Follow-up probe:** "What's the difference between 'degraded but acceptable' and 'failed' during a chaos experiment?"
- **Good answer:** "Success: (1) Error rate for the 95% non-experiment traffic stays below 0.5%. (2) Experiment traffic degrades gracefully (returns fallback response, not 500). (3) Recovery time after fault injection stops is <60 seconds. (4) No data corruption or inconsistency. Failed: any of those conditions violated."
- **Bad answer:** "If nothing breaks, it passed."

### Group 38 --- Deprecation & Migration Strategy `[BOTH]`

**Filter Question:** "Is there a foreseeable scenario where this step will be replaced, significantly redesigned, or deprecated? If this step is permanent infrastructure with no planned changes, skip this group."

**Q38.1:** "What's the expected lifespan of this step before it needs replacement or major rework? What would trigger that replacement?"
- **Follow-up probe:** "Is the trigger technology-driven (better model, new architecture), business-driven (pivot, new regulation), or scale-driven (outgrown the current design)?"
- **Follow-up probe:** "When this step is replaced, how many other steps depend on it and would need to adapt?"
- **Good answer:** "Expected lifespan: 12-18 months. Trigger: we're currently using a rule-based classifier as a bridge. Once we have enough production data (target: 50K labeled examples), we'll replace it with a fine-tuned model. 3 downstream steps consume this step's output. Migration plan will need to run both classifiers in parallel during transition."
- **Bad answer:** "It'll last forever. We built it right."

**Q38.2:** "When this step is deprecated, how do consumers migrate? What's the backward compatibility period and support policy?"
- **Follow-up probe:** "Is migration automated (adapter layer, shim) or manual (each consumer rewrites their integration)?"
- **Follow-up probe:** "How long do you support the old version after the new version launches?"
- **Good answer:** "6-month backward compatibility period. During that period, the old step runs alongside the new one. Consumers opt in to the new version via a version header. After 6 months, the old step returns deprecation warnings for 1 month, then is shut down. We provide a migration guide and an adapter library for the 2 most common integration patterns."
- **Bad answer:** "We'll tell everyone to switch. They'll have a week."

**Q38.3:** "How is deprecation communicated to dependent teams and downstream steps?"
- **Follow-up probe:** "How much advance notice do dependent teams get?"
- **Follow-up probe:** "Is there an automated deprecation check that warns consumers they're using a deprecated step?"
- **Good answer:** "Deprecation announced 3 months before the backward compatibility period starts (9 months total before shutdown). Communication: (1) Deprecation notice in the step's API response headers. (2) Linear ticket created for each consuming team. (3) Weekly status email during the migration period. (4) Automated CI check that flags imports of deprecated step interfaces."
- **Bad answer:** "We'll send a Slack message."

### Group 39 --- Documentation & Knowledge Base `[ENG]`

**Filter Question:** "If a new engineer joined the team tomorrow and had to debug this step, what would they read first? Does that document exist and is it current?"

**Q39.1:** "What documentation must exist alongside this spec for an engineer to operate and debug this step? List each document, its purpose, and its current state (exists/missing/stale)."
- **Follow-up probe:** "Is there an architecture diagram showing how this step fits into the larger pipeline?"
- **Follow-up probe:** "Is there a decision rationale doc explaining WHY the step works this way (not just WHAT it does)?"
- **Follow-up probe:** "Is there an FAQ of the top 5 questions new engineers ask about this step?"
- **Good answer:** "Four docs needed: (1) Architecture diagram of the pipeline with this step highlighted (exists, current). (2) Runbook for on-call (exists, updated last month). (3) Decision rationale doc explaining why we chose rule-based classification over ML (exists, current). (4) FAQ for new engineers (missing, need to create). The FAQ should cover: 'Why is there a 3-second timeout?', 'Why do we use Haiku instead of Sonnet?', 'What's the dead-letter queue for?'"
- **Bad answer:** "The code is self-documenting."

**Q39.2:** "Where does documentation live, and who owns keeping it current?"
- **Follow-up probe:** "Is documentation co-located with the code (repo), or in a separate system (wiki)?"
- **Follow-up probe:** "What happens when the doc owner leaves the team?"
- **Good answer:** "Runbooks live in the repo (docs/ directory) so they're versioned with the code. Architecture diagrams in Confluence, linked from the repo README. Decision rationale in the spec itself (Section 13: Context and Reference). Owner: the engineer who last modified the step. On team departure, ownership transfers during the offboarding checklist."
- **Bad answer:** "It's somewhere in Confluence. Not sure who owns it."

**Q39.3:** "What's the freshness policy? How often is documentation reviewed, and what triggers an update?"
- **Follow-up probe:** "Is there an automated check that flags stale documentation?"
- **Follow-up probe:** "What's the maximum acceptable staleness before documentation becomes a liability?"
- **Good answer:** "Reviewed quarterly as part of the spec review cycle. Mandatory update triggers: (1) Any spec change. (2) Any incident postmortem that references this step. (3) Any new team member onboarding (they flag gaps). Staleness limit: 6 months. After that, the doc is flagged as 'unverified' and cannot be referenced in incident response until reviewed."
- **Bad answer:** "We update it when we remember."

### Group 40 --- Data Quality & Validation `[ENG]`

**Filter Question:** "Does the quality (completeness, accuracy, freshness) of data at this step directly impact the correctness of the step's output or downstream clinical decisions? If data quality is guaranteed by upstream validation and cannot degrade at this step, skip this group."

**Q40.1:** "Which data quality dimensions matter most for this step: completeness, accuracy, freshness, consistency, or uniqueness? Why those and not others?"
- **Follow-up probe:** "Can you give a specific example of how poor quality in that dimension would produce a wrong output at this step?"
- **Follow-up probe:** "Has data quality actually been measured at this step, or is the expectation theoretical?"
- **Good answer:** "Completeness and accuracy are critical. Completeness: if the medication list is incomplete, the classification step may miss a drug interaction request. Accuracy: if the patient's insurance ID is wrong, routing sends the request to the wrong workflow. We measure completeness weekly (currently 97.2% of records have all required fields). Accuracy is validated against the EHR source system monthly (99.1% match rate)."
- **Bad answer:** "All dimensions are equally important."

**Q40.2:** "What are the specific data quality thresholds for this step, and what happens when quality falls below them?"
- **Follow-up probe:** "Is the threshold per-field, per-record, or aggregate across all records?"
- **Follow-up probe:** "When quality drops below threshold, does the step reject the record, flag it for review, or degrade gracefully?"
- **Follow-up probe:** "Who gets notified, and what's the remediation SLA?"
- **Good answer:** "Per-record: if any required field is missing, the record is flagged (not rejected) and routed to a human review queue. Aggregate: if completeness drops below 95% over a 1-hour window, an alert fires and the data team investigates the upstream source. Remediation SLA: 4 hours for aggregate quality alerts (because it likely indicates a systematic upstream issue). Per-record flags are reviewed within 24 hours."
- **Bad answer:** "We reject bad data. Quality should be 100%."

**Q40.3:** "Who is responsible for data quality at this step vs. upstream? Where is the boundary?"
- **Follow-up probe:** "If this step receives bad data from upstream, does it reject it, fix it, or pass it through?"
- **Follow-up probe:** "Is there a data quality SLA between this step and its upstream provider?"
- **Follow-up probe:** "How are data quality issues escalated to the upstream team?"
- **Good answer:** "This step validates on receipt (defense-in-depth) but does not attempt to fix data. If validation fails, the record is quarantined and the upstream team is notified via automated ticket. SLA: upstream must respond to data quality tickets within 48 hours. We track quality metrics per upstream source and review them monthly. If a source consistently fails, we escalate to the PM for a conversation with the data provider."
- **Bad answer:** "Upstream should send clean data. Not our problem."
