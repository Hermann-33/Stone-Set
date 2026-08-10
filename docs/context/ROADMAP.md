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
```

Latest completion evidence:

```text
TASK-IMP-006
PR #22 — MERGED
merge commit: c47ad215c962d062298a980ec481099cd8d12c91
implementation CI: 31367237926 PASS
completion: docs/tasks/TASK-IMP-006-COMPLETION.md
```

## Deferred

### TASK-IMP-005B

Android workout guidance/media playback remains optional/deferred. It is not a prerequisite for progression or release. Existing authoring/media data remains available.

## Current task — Phase 7

```text
TASK-IMP-007 — Progression, substitutions, protection and corrections
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-007-progression-protection-corrections
Packet: docs/tasks/TASK-IMP-007.md
Mode: FAST TWO-USER MVP
```

Required result:

```text
submitted workout evidence
  -> deterministic next-load recommendation
  -> optional manual override
  -> preferred substitute at next workout start
  -> exercise-level progression protection / pain flag
  -> exact RR/XP corrections and one-time reversals
  -> controls inside the existing Progress branch
```

Phase 7 intentionally skips automatic routine mutation, full-week protection, coaching/periodization models, deload algorithms, substitution equivalence scoring, medical advice, dashboard UI and complex approval workflows.

## Remaining phases

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
- preserve existing Auth/RLS/data-ownership boundaries;
- no enterprise hardening for hypothetical public users.

## Exact next action

Execute `TASK-IMP-007` from `docs/tasks/TASK-IMP-007.md` on `codex/task-imp-007-progression-protection-corrections`, doing as much direct GitHub implementation and CI-driven fixing as possible before involving Codex.
