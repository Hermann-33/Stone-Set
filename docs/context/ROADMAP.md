# Stone Set Roadmap

Updated: 2026-08-09

Stone Set is a private two-user MVP. The roadmap now optimizes for functional completion and short implementation cycles rather than production-grade hardening.

## Completed

```text
Phase 0   Product/architecture planning                     COMPLETE
Phase 1   TASK-IMP-001 Foundation                           COMPLETE
Phase 2A  TASK-IMP-002A Identity/sessions                   COMPLETE
Phase 2B  TASK-IMP-002B Shared UI + Android shell/Home      COMPLETE
Phase 2C  TASK-IMP-002C Dashboard shell/Overview            COMPLETE
Phase 3A  TASK-IMP-003A Exercise library/guidance           COMPLETE
Phase 3B  TASK-IMP-003B Private media/YouTube               COMPLETE
```

### Phase 3B evidence

```text
PR #16 — MERGED
merge commit: 1b1c18d95214117e59a6c208139c2b019e313cb2
CI: 31305011340 PASS
```

## Current task — Phase 3C

```text
TASK-IMP-003C — Routine authoring, review and publication
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-003c-routine-review-publication
```

Required user-visible result:

```text
User A creates/edits a 7-day routine
User A validates and submits it
User B reviews it
User B approves or rejects it
approved routine is published as an immutable version
version history is visible
published version can be duplicated into a new draft
```

Weekly plan materialization remains Phase 4.

## Remaining phases

### Phase 4 — TASK-IMP-004

Real weekly plans, exactly seven items, schedule materialization, swaps and basic credit handling. Replace fixture Home/Week scheduling with real data.

### Phase 5A — TASK-IMP-005A

Android workout execution, set logging, rest timer, SQLite autosave, offline continuation, outbox sync, submission and recovery.

### Phase 5B — TASK-IMP-005B

Pinned workout guidance, private images, cached media and YouTube playback while preserving logger state.

### Phase 6 — TASK-IMP-006

Authoritative RR/XP/rank/wallet, workout history and real Progress screen. Simplify formulas/verification to the accepted product rules needed by the two users.

### Phase 7 — TASK-IMP-007

Progression recommendations, substitutions, protection and basic correction/reversal behavior.

### Phase 8 — TASK-IMP-008

Only the deployment/release work actually required for the two users to run Stone Set: hosted backend/dashboard where needed, Android installable release, secrets/config and basic backup procedure. Production-enterprise hardening is not required.

## Execution policy

- no unnecessary planning PR before an already-approved task;
- implementation PRs remain bounded for rollback;
- targeted tests during development;
- one path-sensitive final CI run;
- no API 24 for dashboard/database-only work;
- no broad golden/security matrices unless a concrete defect requires them;
- preserve existing Auth/RLS/private-data boundaries;
- do not add enterprise hardening for hypothetical public users.

## Exact next action

Execute `TASK-IMP-003C` directly from `docs/tasks/TASK-IMP-003C.md`.
