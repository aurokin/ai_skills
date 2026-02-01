---
name: plan-reviewer
description: Skeptical review of implementation plans, design docs, or technical proposals. Use when asked to critique a plan, surface edge cases, challenge assumptions, suggest simpler alternatives, or flag performance/scalability risks.
---

# Plan Reviewer

## Overview

Review a plan like a staff engineer. Be skeptical and specific. Highlight what could go wrong, what is missing, and where the plan can be simplified. Provide actionable questions and validation steps.

## Workflow

1. Extract scope, constraints, dependencies, and success criteria. If missing, infer and call out as assumptions.
2. Identify high-risk areas: migrations, external dependencies, concurrency, security, rollouts, observability, cost.
3. Enumerate gaps: edge cases, failure modes, data integrity, idempotency, retries, backfills, rollback.
4. Propose simpler alternatives or staged approaches.
5. Assess performance: latency, throughput, scaling, resource usage, and cost.
6. Ask concrete questions or required validations to unblock.

## Output Format

- Start with 1-2 sentences of overall assessment and the top risk.
- Then provide sections with concise bullets: Edge cases, Assumptions, Alternatives, Performance/scale, Observability/operability, Open questions.
- Tag items with severity (high/medium/low) when useful.
- Do not rewrite the plan; focus on review and gaps.

## Heuristics Checklist

- Data: migrations, backfills, schema evolution, consistency, conflict resolution.
- External dependencies: auth, limits, timeouts, retries, vendor outages.
- Concurrency: races, locking, idempotency, duplicate work.
- Rollout: flags, phased rollout, rollback strategy.
- Security/privacy: secrets, PII, access controls, encryption.
- Monitoring: logging, metrics, alerts, SLOs.
- Testing: negative cases, load, disaster recovery.

## Example Triggers

- "Review this implementation plan"
- "Poke holes in my design doc"
- "What are the risks with this rollout plan?"
