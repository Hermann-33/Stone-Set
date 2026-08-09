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
```

### Latest completion evidence

```text
TASK-IMP-003C
PR: #18
merge commit: d1997c8e9ef306301806001f6540a1d9ba3314dc
final head: febc4bfa4a82083f5b3b1f720b69c6df98484c3c
final CI: 31314739913 PASS
```

003C provides owner-scoped seven-day routine drafts, server validation, immutable submission snapshots, second-user review, self-review denial, approval/rejection, immutable published routine versions, version history and duplicate-as-draft.

## Current executable task

```text
TASK-IMP-004 — Real weekly plans, swaps and free-swap credits
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-004-weekly-plans-swaps
Packet: docs/tasks/TASK-IMP-004.md
Mode: FAST PRIVATE TWO-USER MVP
```

No additional planning task is required.

## Phase 4 simplification

Phase 4 intentionally implements only what is needed before workouts and rank authority exist:

- lazy Monday-Sunday week materialization from the effective published routine version;
- exactly seven stored plan items;
- stored 1.00x RR/base-XP allocations and missed-penalty allocations;
- lazy monthly two-credit grant;
- maximum two weekly swaps;
- free-credit swap payment only;
- real Android Home/Week schedule binding.

Deferred:

- paid `5 RR` swaps until TASK-IMP-006 creates authoritative rank RR;
- cron/background materialization;
- weekly reward finalization;
- workout-completion locks beyond simple date/state locking;
- protection/corrections;
- advanced recovery warnings.

## Accepted technology baseline

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
State/DI      Riverpod
Routing       typed go_router
Backend       Supabase Auth/Postgres/Storage
Web drafts    IndexedDB where already useful
Mobile local  SQLite in 005A
```

Use one root Dart lockfile and the existing repository architecture.

## Existing functional boundary

Implemented:

- provisioned username/password login and session lifecycle;
- owner-separated private data;
- shared Flutter design system;
- Android Home/Week/Progress/Profile shell;
- adaptive Web dashboard shell;
- exercise/guidance authoring and immutable publication;
- private exercise images and YouTube references;
- seven-day routine authoring, validation, independent review and immutable publication.

Not yet implemented:

- real weekly plans/swaps/credits;
- workout logger/SQLite/offline sync;
- Android workout guidance/media playback;
- authoritative RR/XP/rank/wallet/Progress;
- progression/protection/corrections;
- release/deployment needed for actual use.

## Remaining sequence

```text
004   real weekly plans/swaps/free credits
005A  workout logger + SQLite/offline sync
005B  workout guidance/media
006   RR/XP/rank/wallet/Progress + paid RR swaps
007   progression/protection/corrections
008   minimal deployment/release for the two users
```

## Verification policy

During coding: targeted affected tests only.

External verification after Codex pushes Phase 4 will handle:

- diff review;
- required generated-source/format/analysis checks;
- focused feature tests;
- path-sensitive CI;
- docs/result update;
- PR merge.

Do not run API 24 unless mobile runtime/performance actually changes in a way requiring it. Do not create broad golden/security matrices.

## Exact next action

Implement `TASK-IMP-004` directly from `docs/tasks/TASK-IMP-004.md` on
`codex/task-imp-004-weekly-plans-swaps` and push the coding branch for external verification.
