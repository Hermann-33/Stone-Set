# Stone Set Latest Handoff

Updated: 2026-08-10

## Current state

```text
TASK-IMP-003A — COMPLETE AND MERGED (PR #14)
TASK-IMP-003B — COMPLETE AND MERGED (PR #16)
TASK-IMP-003C — COMPLETE AND MERGED (PR #18)
TASK-IMP-004  — COMPLETE AND MERGED (PR #20)
TASK-IMP-005A — COMPLETE AND MERGED (PR #21)
TASK-IMP-005B — DEFERRED / NOT A BLOCKER
TASK-IMP-006  — APPROVED AND EXECUTABLE
```

Latest evidence:

```text
TASK-IMP-005A
PR #21
merge commit: 406b489cdef9881d595d29312e4fb4a8127abe1c
final CI: 31349815218 PASS
```

## Current implementation mode

Stone Set is a private application for two known users. Optimize for functionality and speed.

Keep existing Auth/RLS/private-data boundaries because they already work. Do not add production-grade threat modeling, anti-abuse, broad audit, cron infrastructure, large golden matrices or exhaustive permission testing unless a concrete defect requires it.

## TASK-IMP-006 handoff

```text
task: TASK-IMP-006
branch: codex/task-imp-006-rank-progress-wallet
packet: docs/tasks/TASK-IMP-006.md
mode: FAST PRIVATE TWO-USER MVP
```

Implement only:

- lazy scoring refresh using existing weekly allocations and submitted workout results;
- append-only RR/XP ledgers;
- rank account snapshot;
- existing rank-v6 thresholds;
- proportional workout RR/XP;
- simple rest rewards and missed-workout penalties;
- paid swap fallback of 5 RR after free credits are exhausted;
- authoritative Home rank/RR/XP;
- Progress totals, rank ladder, transactions and workout history.

Deliberately deferred:

- streaks/multipliers;
- milestones/PR caps;
- decay;
- weekly evaluation/finalization tables and cron;
- provisional rewards;
- charts;
- correction/reversal systems;
- Android guidance/media playback (005B);
- 007 and 008.

## Working rule

Planning/docs/code-map/final PR review/CI/merge should be handled outside Codex where possible. Codex is only a fallback for residual coding defects that genuinely benefit from a local compiler/runtime loop.
