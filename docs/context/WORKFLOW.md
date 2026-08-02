# Stone Set Workflow

Updated: 2026-08-03

## Purpose

This file defines how planning, decisions, Codex implementation, verification, audits, documentation, and Git handoffs are performed.

## Authority order

When instructions conflict, use this order:

1. accepted ADRs;
2. `ACTIVE_CONTEXT.md`;
3. `ARCHITECTURE.md`;
4. verified infrastructure or data status documents, when introduced;
5. `PROJECT_BRIEF.md`;
6. `CODEBASE_MAP.md`;
7. `ROADMAP.md`;
8. the current bounded task instruction;
9. chat history or memory.

Do not silently reconcile conflicts. Report the conflicting statements and stop before changing files.

## Planning workflow

1. Capture the idea without selecting implementation details.
2. Define the problem, user, trigger, workflow, outcome, and failure modes.
3. Separate requirements from optional ideas.
4. Record constraints, privacy expectations, cost limits, and maintenance limits.
5. Stress-test the scope and remove features that do not support the primary outcome.
6. Compare architecture options only after requirements exist.
7. Record durable accepted decisions as ADRs.
8. Update the project brief, architecture, roadmap, and active context.

## Implementation task lifecycle

### 1. Context load

Read `AGENTS.md`, every mandatory context document, relevant ADRs, current Git state, and the code directly affected by the task.

### 2. Conflict check

Compare the request against accepted product, architecture, security, and scope boundaries.

### 3. Pre-change summary

State the current project state, task ID, exact scope, non-goals, protected boundaries, and verification plan.

### 4. Implementation

Make the smallest coherent change that satisfies the acceptance criteria. Do not perform opportunistic rewrites or unrelated cleanup.

### 5. Verification

Run focused tests first, then all applicable lint, type checks, build, integration tests, security scans, and runtime verification.

### 6. Audit

Compare the result against the task packet, accepted ADRs, current architecture, security boundaries, and completion definition.

### 7. Documentation sync

Update only documents whose canonical facts changed. Add a material audit entry when findings, risks, architecture, security, data state, or phase completion changed.

### 8. Git sync

Inspect the final diff, stage only relevant files, commit with the task ID, push the intended branch, and report the resulting commit.

### 9. Handoff

Record completed work, evidence, remaining risks, exact next action, and protected boundaries.

## Decision workflow

A durable decision requires:

1. explicit context and problem;
2. viable alternatives;
3. selection criteria;
4. exact decision;
5. consequences and trade-offs;
6. privacy, security, data, and operational impact;
7. scope boundaries;
8. rollback or supersession path;
9. acceptance status and activation evidence.

Proposals remain non-authoritative until accepted.

## Codex prompt standard

Every Codex prompt must be a bounded execution packet containing:

```text
Task ID and title
Objective
Mandatory repository reads
Verified starting state
Exact scope
Non-goals
Protected boundaries
Required implementation behavior
Acceptance criteria
Required tests and checks
Required documentation updates
Git requirements
Completion-report schema
```

Codex must inspect the repository rather than trust a stale file list in the prompt.

## Required Codex completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID:
Branch:
Commit:
Files changed:
Behavior implemented:
Tests and checks run:
Results:
Documentation updated:
Risks or blockers:
Exact next action:
```

Claims must be backed by commands, test results, diffs, runtime evidence, or verified external state.

## Audit verdicts

### COMPLETE

All applicable implementation, verification, documentation, and Git gates passed.

### PARTIAL

The work is valid, but one or more required gates remain incomplete or unverified.

### FAIL

The task violates accepted boundaries, weakens security without authorization, fails required checks, changes protected systems, or cannot be safely reconciled.

## Documentation ownership

| Fact | Canonical document |
|---|---|
| Product purpose and scope | `PROJECT_BRIEF.md` |
| Accepted current system design | `ARCHITECTURE.md` |
| Durable decision and rationale | ADR |
| Present project state | `ACTIVE_CONTEXT.md` |
| File and module responsibility | `CODEBASE_MAP.md` |
| Phase plan and completion criteria | `ROADMAP.md` |
| Latest task result and next action | `HANDOFF.md` |
| Historical material findings | `AUDIT_LOG.md` |
| Agent rules | `AGENTS.md` and this file |

## Documentation quality rules

- Record facts, not chat transcripts.
- Keep current-state documents concise.
- Preserve audit and ADR history.
- Never include secrets or sensitive personal data.
- Do not create empty specialist documents before the relevant system exists.
- Do not duplicate the same authoritative fact across multiple files.
