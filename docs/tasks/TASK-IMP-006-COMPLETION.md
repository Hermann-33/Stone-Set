# TASK-IMP-006 — Completion Evidence

Status: `COMPLETE — CI VERIFIED`

Date: 2026-08-10

PR: #22

## Delivered

- Lazy authoritative RR/XP scoring refresh from weekly allocations and workout results.
- Append-only RR and XP ledgers with a cached rank account snapshot.
- Rank derivation from the existing rank-v6 thresholds.
- Proportional submitted-workout rewards, rest rewards, and idempotent missed-workout penalties.
- Free-swap-first behavior with automatic 5 RR paid-swap fallback.
- Authoritative Home rank/RR/XP state.
- Progress screen with current rank, RR, lifetime XP, next-rank progress, ladder, transactions, and workout history.
- Focused database, data, mobile, and API-24 integration coverage.

## Verification

Foundation CI run `31367237926` passed on implementation head `e33180cda16945f46e4dd00a4a52e2ba04b05426` after fixing the concrete API-24 fixture and Progress scrolling defects exposed by CI.

The final documentation-only completion commit is required to pass the same path-sensitive Foundation CI before merge.

## Scope held

Not implemented here:

- TASK-IMP-005B workout guidance/media playback;
- streaks, multipliers, milestones, PR caps, or rank decay;
- weekly finalization/cron/provisional reward machinery;
- charts or correction/reversal UI;
- TASK-IMP-007 or TASK-IMP-008.
