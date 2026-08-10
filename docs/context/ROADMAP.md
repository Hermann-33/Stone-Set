# Stone Set Roadmap

Updated: 2026-08-10

Stone Set is a two-user MVP. The roadmap optimizes for functional completion and short implementation cycles rather than production-grade hardening.

## Completed

```text
Phase 0   Product/architecture planning                     COMPLETE
Phase 1   TASK-IMP-001 Foundation                           COMPLETE
Phase 2A  TASK-IMP-002A Identity/sessions                   COMPLETE
Phase 2B  TASK-IMP-002B Shared UI + Android shell/Home      COMPLETE
Phase 2C  TASK-IMP-002C Dashboard shell/Overview            COMPLETE
Phase 3A  TASK-IMP-003A Exercise library/guidance           COMPLETE
Phase 3B  TASK-IMP-003B Private media/YouTube               COMPLETE
Phase 3C  TASK-IMP-003C Routine/review/publication          COMPLETE
Phase 4   TASK-IMP-004 Weekly plans/free swaps              COMPLETE
Phase 5A  TASK-IMP-005A Workout logger/SQLite/sync          COMPLETE
Phase 6   TASK-IMP-006 RR/XP/rank/wallet/Progress           COMPLETE
Phase 7   TASK-IMP-007 progression/protection/corrections   COMPLETE
```

Latest completion evidence:

```text
TASK-IMP-007
PR #23
implementation head: 5342b260353169533fac265e95fddd158cc21f51
Foundation CI: 31383285750 PASS
completion: docs/tasks/TASK-IMP-007-COMPLETION.md
```

## Current required task — TASK-IMP-005B

```text
TASK-IMP-005B — Workout guidance and media playback
Status: IMPLEMENTING
Branch: codex/task-imp-005b-workout-guidance-media
PR: #24
Packet: docs/tasks/TASK-IMP-005B.md
Mode: FAST TWO-USER MVP
```

Required result:

```text
active workout pinned exercise/guidance revision IDs
  -> immutable guidance revision
  -> immutable published media manifest
  -> structured text guidance in same-route modal
  -> private images via short-lived signed URLs
  -> validated YouTube playback on Android
  -> logger state remains intact
```

005B intentionally adds no new database/media schema and skips offline video, background prefetch, custom disk caching, new top-level routes and dashboard work.

## Remaining phase

### Phase 8 — TASK-IMP-008

Only deployment/release work actually required for the two users to run Stone Set: hosted backend/dashboard where needed, Android installable release, secrets/config and basic backup.

TASK-IMP-008 starts only after TASK-IMP-005B is complete and merged.

## Execution policy

- prepare/simplify task packets outside Codex;
- do safe implementation outside Codex where possible;
- Codex is fallback rather than default;
- targeted tests during implementation;
- final confidence from path-sensitive Foundation CI;
- no new enterprise security/golden/performance matrices unless directly useful;
- preserve existing Auth/RLS/data-ownership boundaries.

## Exact next action

Finish `TASK-IMP-005B` on PR #24, retarget it to `main` after PR #23 merges, pass Foundation CI, merge it, then prepare `TASK-IMP-008`.
