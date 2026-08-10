# Stone Set Active Context

Updated: 2026-08-10

## Current position

Stone Set is a private two-user hypertrophy training application:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

Implementation mode: **FAST PRIVATE TWO-USER MVP**. Prioritize working functionality and short cycles. Preserve existing Auth/RLS/private-data boundaries, but do not add enterprise security, anti-abuse, exhaustive verification or broad CI unless a concrete defect requires it.

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
```

Latest completion evidence:

```text
TASK-IMP-005A
PR: #21
merge commit: 406b489cdef9881d595d29312e4fb4a8127abe1c
final CI: 31349815218 PASS
```

005A provides online start for today's workout, immutable session snapshots, load/reps/RIR logging, SQLite autosave, offline continuation after start, revision sync, completed/partial submission and real Home/Week workout navigation.

## Deliberately deferred

`TASK-IMP-005B` workout guidance/media playback is not required for scoring and is deferred. Existing guidance/media authoring remains intact; Android workout playback can be added later if it is still useful.

## Current executable task

```text
TASK-IMP-006 — Authoritative RR, XP, rank, wallet and Progress
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-006-rank-progress-wallet
Packet: docs/tasks/TASK-IMP-006.md
Mode: FAST PRIVATE TWO-USER MVP
```

No additional planning task is required.

## Phase 6 simplification

Implement only:

- lazy server scoring refresh from existing weekly allocations and workout results;
- append-only RR/XP ledgers;
- one rank account snapshot;
- rank from the existing 20 rank-v6 thresholds;
- proportional workout rewards;
- simple missed-workout penalties and rest rewards;
- automatic 5-RR paid-swap fallback when free credits are unavailable;
- real Home rank/RR/XP;
- useful Progress totals/rank ladder/transactions/workout history.

Deferred:

- streaks/multipliers;
- milestones/PR caps;
- rank decay;
- weekly finalization tables/cron;
- provisional rewards;
- charts;
- correction/reversal systems;
- progression/protection work (007).

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
- Android Home/Week shell and real weekly schedule;
- Web dashboard authoring shell;
- exercise/guidance/private media authoring;
- routine validation/review/publication;
- lazy weekly materialization and free swaps;
- Android workout start/logger/SQLite/offline continuation/sync/submit.

Not yet implemented:

- authoritative RR/XP/rank/wallet/Progress;
- Android workout guidance/media playback (deferred 005B);
- progression/protection/corrections (007);
- minimal deployment/release (008).

## Remaining sequence

```text
006   RR/XP/rank/wallet/Progress + paid RR swaps
007   progression/protection/corrections
008   minimal deployment/release
005B  optional deferred workout guidance/media playback
```

## Verification policy

Use targeted tests while implementing. Final confidence comes from the existing path-sensitive Foundation CI on the final branch head. Do not add new CI infrastructure or broad security/performance matrices.

## Exact next action

Implement `TASK-IMP-006` on `codex/task-imp-006-rank-progress-wallet` using `docs/tasks/TASK-IMP-006.md`.
