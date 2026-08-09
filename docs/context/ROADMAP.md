# Stone Set Roadmap

Updated: 2026-08-10

Stone Set is a private two-user MVP. The roadmap optimizes for functional completion and short implementation cycles rather than production-grade hardening.

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
```

### Latest completion evidence

```text
TASK-IMP-003C
PR #18 — MERGED
merge commit: d1997c8e9ef306301806001f6540a1d9ba3314dc
CI: 31314739913 PASS
```

## Current task — Phase 4

```text
TASK-IMP-004 — Real weekly plans, swaps and free-swap credits
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-004-weekly-plans-swaps
Packet: docs/tasks/TASK-IMP-004.md
```

Required result:

```text
published routine
  -> lazy current week creation
  -> 7 real dated plan items
  -> Home/Week use real schedule
  -> monthly 2-credit grant
  -> user swaps two unlocked dates using 1 free credit
```

Phase 4 intentionally defers paid RR swaps and reward finalization to 006, workout-driven locks to 005A, and cron/background generation because those are unnecessary for the private two-user build right now.

## Remaining phases

### Phase 5A — TASK-IMP-005A

Android workout execution, set logging, rest timer, SQLite autosave, offline continuation, outbox sync, submission and recovery.

### Phase 5B — TASK-IMP-005B

Pinned workout guidance, private images, cached media and YouTube playback while preserving logger state.

### Phase 6 — TASK-IMP-006

Authoritative RR/XP/rank/wallet, paid RR swaps, workout history and real Progress screen.

### Phase 7 — TASK-IMP-007

Progression recommendations, substitutions, protection and basic correction/reversal behavior.

### Phase 8 — TASK-IMP-008

Only deployment/release work actually required for the two users to run Stone Set: hosted backend/dashboard where needed, Android installable release, secrets/config and a basic backup procedure.

## Execution policy

- prepare/simplify task packets outside Codex where possible;
- Codex spends usage on implementation code;
- implementation PRs remain bounded for rollback;
- targeted tests during coding;
- external final verification and docs/result updates;
- one path-sensitive CI run after push;
- no API 24/golden/security matrices unless directly useful;
- preserve existing Auth/RLS/private-data boundaries;
- no enterprise hardening for hypothetical public users.

## Exact next action

Execute `TASK-IMP-004` directly from `docs/tasks/TASK-IMP-004.md` and push the implementation branch for external verification.
