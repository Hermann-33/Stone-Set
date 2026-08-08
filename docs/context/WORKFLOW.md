# Stone Set Workflow

Updated: 2026-08-04

## Purpose

This file defines planning, decisions, implementation packets, verification, audits, documentation, Git handoffs, and new-conversation context loading.

## Authority order

When instructions conflict, use this order:

1. accepted ADRs;
2. `ACTIVE_CONTEXT.md`;
3. `ARCHITECTURE.md`;
4. verified infrastructure or data status documents, when introduced;
5. `PROJECT_BRIEF.md`;
6. `CODEBASE_MAP.md`;
7. `ROADMAP.md`;
8. the current approved task packet under `docs/tasks/`;
9. chat history or memory.

Do not silently reconcile conflicts. Report them before changing files.

## New-conversation bootstrap

Use `docs/context/NEW_CHAT_BOOTSTRAP.md`. It must direct the agent to inspect the repository, mandatory context, product specifications, ADRs, current Git state, and the relevant task packet rather than trust chat memory.

## Planning and decision workflow

1. Define the problem, user, workflow, outcome, constraints, and failure modes.
2. Separate requirements from optional ideas.
3. Compare viable options against security, maintenance, cost, reversibility, and operational burden.
4. Record durable choices as ADRs.
5. Update product, architecture, roadmap, active context, handoff, and audit facts.
6. Create an approved bounded execution packet only when no material ambiguity blocks implementation.

## Task-packet lifecycle

1. Draft the packet under `docs/tasks/`.
2. Verify its prerequisites against current repository state.
3. Mark it `APPROVED` only after relevant decisions are accepted.
4. The implementation agent re-reads current repository state before acting.
5. A stale or conflicting packet is blocked until updated.
6. Approval authorizes only the packet's exact scope.

## Implementation lifecycle

### 1. Context load

Read `AGENTS.md`, mandatory context, relevant product specifications, accepted ADRs, the approved task packet, current Git state, and directly affected code.

### 2. Conflict check

Compare the packet against accepted product, architecture, security, and scope boundaries.

### 3. Pre-change summary

State current state, task ID, exact scope, non-goals, protected boundaries, and verification plan.

### 4. Implementation

Make the smallest coherent change satisfying the acceptance criteria. Avoid unrelated cleanup.

### 5. Verification

Run focused tests, then all applicable formatting, analysis, build, integration, security, database, and runtime checks.

GitHub Actions uses the accepted path-sensitive rules in ADR-0007. Markdown-only changes run
repository/document checks without Android, browser, Web-build, golden or Supabase runtime jobs.
Dashboard, database, shared-contract and mobile changes activate their affected lanes; unknown
paths fail closed to all runtime lanes. The API 24 profile runs only for mobile runtime,
mobile-consumed UI/navigation/rendering, rank assets or other performance-sensitive mobile paths.
Each implementation candidate receives one final-head run; manual golden-candidate generation is a
separate review aid and does not replace comparison on the final head.

### 6. Audit and documentation

Compare the result with the task packet and accepted decisions. Update only canonical documents whose facts changed and append a material audit entry.

### 7. Git and handoff

Inspect the final diff, commit with the task ID, push the intended branch, open the required PR, and report evidence, risks, verdict, and exact next action.

## Codex packet standard

Every packet contains:

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

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID:
Branch:
Commit:
Pull request:
Files changed:
Behavior implemented:
Explicitly not implemented:
Tests and checks run:
Results:
CI result:
Documentation updated:
Risks or blockers:
Exact next action:
```

## Verdicts

- `COMPLETE`: every applicable implementation, verification, documentation, CI, and Git gate passed.
- `PARTIAL`: valid work remains behind a required gate.
- `FAIL`: accepted boundaries were violated or verification failed.

## Documentation ownership

| Fact | Canonical location |
|---|---|
| Product purpose and scope | `PROJECT_BRIEF.md` |
| Accepted system design | `ARCHITECTURE.md` |
| Durable decision and rationale | ADR |
| Present project state | `ACTIVE_CONTEXT.md` |
| File and module responsibility | `CODEBASE_MAP.md` |
| Phase plan | `ROADMAP.md` |
| Implementation execution scope | `docs/tasks/` |
| Latest result and next action | `HANDOFF.md` |
| Historical material findings | audit-log volumes listed in `CODEBASE_MAP.md` |
| New-conversation entry | `NEW_CHAT_BOOTSTRAP.md` |
| Agent rules | `AGENTS.md` and this file |

Preserve ADR and audit history. Never include secrets or personal data.
