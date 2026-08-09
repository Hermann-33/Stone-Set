# Stone Set Latest Handoff

Updated: 2026-08-10

## Current state

```text
TASK-IMP-003A — COMPLETE AND MERGED (PR #14)
TASK-IMP-003B — COMPLETE AND MERGED (PR #16)
TASK-IMP-003C — COMPLETE AND MERGED (PR #18)
TASK-IMP-004  — APPROVED AND EXECUTABLE
```

Latest evidence:

```text
TASK-IMP-003C
PR #18
merge commit: d1997c8e9ef306301806001f6540a1d9ba3314dc
final CI: 31314739913 PASS
```

Implemented through 003C:

- authentication/session lifecycle and owner-separated private data;
- shared Flutter design system and Android shell;
- adaptive Web dashboard shell;
- exercise/guidance authoring and immutable publication;
- private exercise media and YouTube authoring;
- seven-day routine drafts;
- server validation;
- immutable submission snapshots;
- second-user review with self-review denial;
- approval/rejection;
- immutable effective-dated routine versions;
- version history and duplicate-as-draft.

## Current implementation mode

Stone Set is a private application for two known users. Optimize for functionality and speed.

Keep existing Auth/RLS/private-data boundaries because they already work. Do not add production-grade threat modeling, anti-abuse, broad audit, complex cron infrastructure, large golden matrices or exhaustive permission testing.

## TASK-IMP-004 handoff

```text
task: TASK-IMP-004
branch: codex/task-imp-004-weekly-plans-swaps
packet: docs/tasks/TASK-IMP-004.md
mode: FAST PRIVATE TWO-USER MVP
```

The packet is already prepared. No planning or ADR work is required.

Implement only:

- lazy real current-week materialization;
- exactly seven stored plan items from the effective published routine version;
- stored rank-v6 1.00x RR/base-XP and missed-penalty allocations;
- lazy monthly two-credit grants;
- maximum two swaps/week;
- free-credit swap confirmation;
- Android Home/Week binding to real schedule data.

Deliberately deferred:

- paid RR swaps to 006;
- reward finalization;
- cron/background materialization;
- workout execution/locks to 005A;
- rank/wallet authority to 006;
- protection/corrections to 007.

## Coding handoff rule

Codex should code, perform only targeted sanity checks, commit and push. External verification will handle final diff review, CI, result docs, PR creation/merge and next-task preparation.
