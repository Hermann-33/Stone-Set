# Stone Set Roadmap

Updated: 2026-08-04

## Completion rule

A phase is complete only when every applicable track is implemented, verified, documented, committed, and pushed.

Applicable tracks may include:

1. product behavior;
2. user interface and accessibility;
3. application and service behavior;
4. persistence and synchronization;
5. security and privacy;
6. testing, static checks, and build;
7. documentation, decisions, and handoff.

A documentation milestone may be complete without application implementation only when its scope is explicitly limited to planning or decision closure.

## Phase 0 — Product discovery, architecture, and implementation planning

Status: `ACTIVE`

### Goal

Define a precise, secure, testable, and bounded two-user product before creating runtime code or infrastructure.

### Foundational single-routine product-logic milestone

Status: `COMPLETE`

Accepted baselines:

- hypertrophy routine;
- `rank-v5`;
- `schedule-v2`;
- missed-session penalties;
- weekly decay;
- consistency multipliers;
- swaps;
- bankable monthly free-swap credits.

This milestone remains valid for the original fixed five-session model.

### Architecture-selection milestone

Status: `COMPLETE`

Accepted decisions:

- Flutter mobile application;
- separate Flutter Web dashboard;
- shared Dart domain and data packages;
- Supabase Auth and Postgres;
- RLS-protected ownership;
- no application-table password storage;
- server-authoritative reward and wallet transitions.

No runtime activation exists.

### Workflow and implementation-plan milestone

Status: `PARTIAL`

Completed planning outputs:

- proposed end-to-end application workflow;
- two-user account and ownership model;
- proposed routine draft, validation, publication, and history flow;
- planned weekly materialization, workout logging, swap, finalization, progression, protection, and correction flows;
- phased implementation plan from foundation through release hardening;
- planned repository and data-domain boundaries.

Remaining gate:

- workflow cannot be accepted while the variable-routine reward and scheduling model remains proposed.

### Reopened product-balance workstream

Status: `ACTIVE`

The new requirement for different user routines conflicts with the fixed five-session assumptions in `rank-v5` and `schedule-v2`.

Proposed replacement:

- `rank-v6`;
- `schedule-v3`;
- four-to-six workout days;
- lower RR for programmed rest items;
- fixed equal weekly RR pools;
- fixed equal weekly direct missed-workout penalty exposure;
- weekly PR cap;
- normalized failed-week threshold;
- immutable user-owned routine versions.

Canonical proposal:

- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`

### Completed Phase 0 outcomes

- repository governance established;
- product purpose and boundaries documented;
- evidence-informed workout baseline accepted;
- 60-minute session cap accepted;
- 20-rank ladder and Adonis at `5,500 RR` accepted;
- ten-month synthetic pacing target documented;
- rank and consistency formulas accepted for the fixed routine;
- swap and free-credit behavior accepted;
- new-chat bootstrap established;
- Flutter client architecture accepted;
- Supabase Auth and Postgres architecture accepted;
- two provisioned users and disabled public signup planned;
- no plaintext application-table password storage accepted;
- RLS ownership boundary accepted;
- documentation-only implementation sequence established;
- nutrition, sleep, public social, payment, wearable, and medical-diagnosis expansion excluded.

### Remaining Phase 0 outcomes

1. audit and accept or reject `rank-v6` and `schedule-v3`;
2. synchronize canonical rank and scheduling documents if accepted;
3. promote the application workflow to accepted status;
4. decide local in-progress-workout persistence technology;
5. decide offline final-submission behavior;
6. decide mobile release targets;
7. decide dashboard hosting;
8. decide production Supabase backup and operational-access procedures;
9. approve the first bounded implementation task packet.

### Phase 0 completion criteria

Phase 0 is complete only when:

- no material product ambiguity blocks implementation;
- the active rank and scheduling configurations support the intended user model;
- workflow states and failure modes are testable;
- architecture and security decisions are accepted;
- platform, connectivity, persistence, deployment, cost, and maintenance constraints are accepted;
- the first implementation task has exact acceptance criteria and verification commands.

## Phase 1 — Repository and quality foundation

Status: `BLOCKED BY PHASE 0`

Planned task:

`TASK-IMP-001 — Create Flutter and Supabase project foundation`

Expected deliverables:

- Flutter mobile project;
- Flutter Web dashboard project;
- shared Dart packages;
- Supabase local-development configuration;
- migration and database-test structure;
- environment templates without secrets;
- formatting, analysis, tests, builds, and CI;
- synchronized architecture and codebase map.

Phase 1 is not complete. It has not started.

## Phase 2 — Identity and routine ownership

Status: `PLANNED`

Expected deliverables:

- provisioned-account authentication;
- profile and timezone state;
- RLS ownership isolation;
- dashboard routine drafts;
- immutable publication and effective-week behavior;
- routine validation and history.

## Phase 3 — Weekly plan and workout execution

Status: `PLANNED`

Expected deliverables:

- weekly plan materialization;
- deterministic reward and penalty allocations;
- current-week mobile presentation;
- workout start and day locking;
- set logging and timers;
- local in-progress draft recovery;
- full, partial, invalid, and protected resolution.

## Phase 4 — Rank, swaps, wallet, and finalization

Status: `PLANNED`

Expected deliverables:

- swap preview and confirmation;
- free-credit versus RR payment;
- wallet ledger;
- daily and weekly awards;
- PR validation;
- consistency top-ups and resets;
- penalties and decay;
- idempotent weekly finalization;
- transparent rank history.

## Phase 5 — Progression and correction workflow

Status: `PLANNED`

Expected deliverables:

- double-progression recommendations;
- user overrides;
- exercise-variant history;
- pain and substitution flags;
- protected periods;
- exact-value corrections and audit presentation.

## Phase 6 — Release hardening

Status: `PLANNED`

Expected deliverables:

- full end-to-end verification;
- security and RLS audit;
- database advisor review;
- backup and restore demonstration;
- dashboard deployment;
- mobile release packaging;
- production runbook;
- final documentation and handoff.

## Current position

`Phase 0 — Product discovery, architecture, and implementation planning`

Current workstream:

`Audit the proposed multi-user routine and normalized daily-RR model before any scaffolding.`

## Reopening rule

A completed phase, milestone, accepted product baseline, or ADR must be reopened when later evidence invalidates its assumptions, completion evidence, security boundary, or intended user model.
