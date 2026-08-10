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
Phase 4   TASK-IMP-004 Weekly plans/free swaps              COMPLETE
Phase 5A  TASK-IMP-005A Workout logger/SQLite/sync          COMPLETE
```

Latest completion evidence:

```text
TASK-IMP-005A
PR #21 — MERGED
merge commit: 406b489cdef9881d595d29312e4fb4a8127abe1c
CI: 31349815218 PASS
```

## Deferred

### TASK-IMP-005B

Android workout guidance/media playback is deferred and is not a prerequisite for scoring, progression or release. Existing authoring/media data remains available.

## Current task — Phase 6

```text
TASK-IMP-006 — Authoritative RR, XP, rank, wallet and Progress
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-006-rank-progress-wallet
Packet: docs/tasks/TASK-IMP-006.md
```

Required result:

```text
existing weekly allocations + workout results
  -> lazy authoritative scoring refresh
  -> RR / XP ledgers and rank account
  -> Home real rank/RR/XP
  -> Progress totals/ladder/history
  -> free swap first, otherwise automatic 5 RR paid swap
```

Phase 6 intentionally skips streaks, multipliers, milestones, PR caps, decay, cron, weekly-finalization tables, provisional rewards and charts for the private two-user build.

## Remaining phases

### Phase 7 — TASK-IMP-007

Progression recommendations, substitutions, protection and basic correction/reversal behavior. This will also be aggressively simplified.

### Phase 8 — TASK-IMP-008

Only deployment/release work actually required for the two users to run Stone Set: hosted backend/dashboard where needed, Android installable release, secrets/config and basic backup.

### Optional deferred Phase 5B

Workout guidance/media playback may be revisited after the core product is functionally complete.

## Execution policy

- prepare/simplify task packets outside Codex;
- do safe implementation outside Codex where possible;
- Codex is fallback rather than default;
- targeted tests during implementation;
- one final path-sensitive CI run on the implementation head;
- no new security/golden/performance matrices unless directly useful;
- preserve existing Auth/RLS/private-data boundaries;
- no enterprise hardening for hypothetical public users.

## Exact next action

Execute `TASK-IMP-006` from `docs/tasks/TASK-IMP-006.md` on `codex/task-imp-006-rank-progress-wallet`.
