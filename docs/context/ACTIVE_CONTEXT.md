# Stone Set Active Context

Updated: 2026-08-10

## Current position

Stone Set is a two-user hypertrophy training application:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

Implementation mode: **FAST TWO-USER MVP**. Prioritize working functionality and short cycles. Preserve existing Auth/RLS/data-ownership boundaries, but do not add enterprise security, anti-abuse, exhaustive verification or broad CI unless a concrete defect requires it.

## Completed and merged

```text
TASK-IMP-001  Foundation                           COMPLETE
TASK-IMP-002A Identity/sessions                    COMPLETE
TASK-IMP-002B Shared UI + Android shell/Home       COMPLETE
TASK-IMP-002C Dashboard shell/Overview             COMPLETE
TASK-IMP-003A Exercise library/guidance            COMPLETE
TASK-IMP-003B Private media/YouTube                COMPLETE
TASK-IMP-003C Routine authoring/review/publication COMPLETE
TASK-IMP-004  Weekly plans/free swaps              COMPLETE
TASK-IMP-005A Workout logger/SQLite/sync            COMPLETE
TASK-IMP-006  RR/XP/rank/wallet/Progress            COMPLETE
```

Latest completion evidence:

```text
TASK-IMP-006
PR: #22
merge commit: c47ad215c962d062298a980ec481099cd8d12c91
implementation CI: 31367237926 PASS
completion: docs/tasks/TASK-IMP-006-COMPLETION.md
```

006 provides authoritative RR/XP ledgers, rank account state, proportional workout rewards, rest/missed-workout scoring, free-first/5-RR paid swaps, real Home rank state, and real Progress totals/ladder/transactions/workout history.

## Deliberately deferred

`TASK-IMP-005B` workout guidance/media playback remains optional/deferred and is not required before progression or release.

## Current executable task

```text
TASK-IMP-007 — Progression, substitutions, protection and corrections
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-007-progression-protection-corrections
Packet: docs/tasks/TASK-IMP-007.md
Mode: FAST TWO-USER MVP
```

No additional planning task is required.

## Phase 7 simplification

Implement only:

- one exercise-level settings row for protection, pain flag, preferred substitute, note and manual next-load override;
- one deterministic next-load recommendation rule from the latest comparable submitted workout;
- fixed numeric increments only: +2.5 kg / +5 lb;
- preferred substitute applied at the next workout start without mutating the published routine;
- one immutable correction table;
- exact RR/XP correction ledger entries plus one-time reversal;
- a compact Progression/Corrections UI inside the existing mobile Progress branch;
- focused database/data/mobile tests.

Deferred:

- automatic routine mutation;
- full-week/item schedule protection;
- deload/fatigue/readiness models;
- multi-session smoothing;
- substitution equivalence scoring;
- medical diagnosis/advice;
- dashboard progression UI;
- correction approval workflow;
- charts/background jobs.

## Technology baseline

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
State/DI      Riverpod
Routing       typed go_router
Backend       Supabase Auth/Postgres/Storage
Mobile local  SQLite/sqflite
```

## Existing functional boundary

Implemented:

- provisioned login/session lifecycle and owner-separated private data;
- exercise/guidance/private media authoring;
- routine validation/review/publication;
- real weekly schedule, locks and free/paid swaps;
- Android workout start/logger/SQLite/offline continuation/sync/submit;
- authoritative RR/XP/rank/Progress.

Not yet implemented:

- progression recommendations/settings/substitution/corrections (007);
- minimal deployment/release (008);
- Android workout guidance/media playback (optional deferred 005B).

## Remaining sequence

```text
007   progression/substitution/protection/corrections
008   minimal deployment/release
005B  optional deferred workout guidance/media playback
```

## Verification policy

Use targeted tests while implementing. Final confidence comes from existing path-sensitive Foundation CI on the final branch head. Do not add new CI infrastructure or broad security/performance matrices.

## Exact next action

Implement `TASK-IMP-007` on `codex/task-imp-007-progression-protection-corrections` using `docs/tasks/TASK-IMP-007.md`, with direct GitHub implementation and CI-driven fixes before any Codex fallback.
