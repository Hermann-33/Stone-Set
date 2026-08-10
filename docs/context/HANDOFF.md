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
TASK-IMP-006  — COMPLETE AND MERGED (PR #22)
TASK-IMP-007  — APPROVED AND EXECUTABLE
```

Latest evidence:

```text
TASK-IMP-006
PR #22
merge commit: c47ad215c962d062298a980ec481099cd8d12c91
implementation CI: 31367237926 PASS
completion: docs/tasks/TASK-IMP-006-COMPLETION.md
```

## Current implementation mode

Stone Set is a two-user application. Optimize for functionality and speed.

Keep existing Auth/RLS/data-ownership boundaries because they already work. Do not add production-grade threat modeling, anti-abuse, broad audit, cron infrastructure, large golden matrices or exhaustive permission testing unless a concrete defect requires it.

## TASK-IMP-007 handoff

```text
task: TASK-IMP-007
branch: codex/task-imp-007-progression-protection-corrections
packet: docs/tasks/TASK-IMP-007.md
mode: FAST TWO-USER MVP
```

Implement only:

- one deterministic next-load recommendation from the latest comparable submitted workout;
- fixed increments of +2.5 kg / +5 lb when every prescribed set reaches the top of the rep range at/above target RIR;
- exercise-level progression protection;
- pain flag + note without diagnosis/advice;
- manual next-load override without changing a published routine;
- preferred substitute used at the next workout start;
- one immutable correction table;
- exact RR/XP correction ledger entries and one-time reversals;
- a compact Progression/Corrections section inside mobile Progress;
- focused database/data/mobile tests.

Deliberately deferred:

- automatic routine mutation;
- full-week/item schedule protection;
- multi-session coaching/periodization;
- fatigue/readiness/deload logic;
- substitution equivalence scoring;
- medical advice;
- dashboard progression/correction UI;
- correction approval workflow;
- charts/background jobs;
- Android guidance/media playback (005B);
- release/deployment work (008).

## Working rule

Planning/docs/code map, deterministic backend/shared implementation, CI fixes, final PR review and merge should be handled outside Codex where possible. Codex is only a fallback for a concrete residual local Dart/Flutter defect that genuinely benefits from a compiler/runtime loop.
