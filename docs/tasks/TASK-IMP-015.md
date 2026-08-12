# TASK-IMP-015 — Week day detail, deliberate swaps, and reliable workout start

Updated: 2026-08-13
Status: `IN PROGRESS`
Branch: `agent/task-imp-015-week-interaction-workout-start`
Decision: `ADR-0012`

## Objective

Fix the mobile Week workflow so any weekday can be opened for complete exercise/prescription/guidance inspection, swap selection requires deliberate long presses, and a stale synchronized local workout cannot prevent today's authoritative workout start.

## Mandatory repository reads

`AGENTS.md`, current context/architecture/code map/roadmap/workflow/handoff, `WEEKLY_SCHEDULING.md`, ADR-0003, ADR-0007, ADR-0010, ADR-0011 and ADR-0012.

## Verified starting state

Production week `4f864f3a-0b27-4f68-b9b8-ffeeb8dc9ce6` has two confirmed swaps for the same Thursday/Friday item pair in opposite order. The second legal confirmation reversed the first, so Thursday 2026-08-13 is again Rest. Production also has older active server workout-session rows; these are not to be deleted or rewritten by this task. Mobile `WorkoutController.loadOrStart` independently blocks a different local active draft before the requested server start.

## Exact scope

- normal Week tap opens read-only detail for that materialized day;
- workout days show all prescriptions and guidance access; rest days show no exercises;
- long press, not normal tap, selects each swap day;
- swap confirmation is single-flight and clears selection after server acceptance;
- authenticated owner-scoped week-item detail RPC;
- safe different-local-workout switching: synchronize pending edits first, preserve them on failure, clear only synchronized stale local state, then perform normal authoritative online start;
- focused mobile and database regressions;
- canonical context/audit updates and private Android release verification after merge.

## Non-goals / protected behavior

No historical swap reversal/refund, no server-session deletion, no rank-v6 or schedule-v3 changes, no swap-limit/payment rule changes, no routine publication change, no started-workout guidance mutation, no offline new-workout creation, no signing/application-ID/Firebase architecture change.

## Acceptance criteria

1. Tapping Monday through Sunday opens that day's details without selecting it for swap.
2. A workout detail lists every exercise with sets/reps/RIR/rest/notes and opens its guidance.
3. A rest detail explicitly has no prescribed exercises.
4. Two unlocked days become swap-selected only through long press.
5. Re-entrant confirmation cannot produce a duplicate second mutation from one confirmation action.
6. A different synchronized stale local workout no longer blocks today's start.
7. A different pending local workout synchronizes before switching; failed synchronization preserves the draft and blocks switching.
8. Server remains authoritative for today's-item eligibility and workout start.
9. Exact-head Foundation CI passes, production migration is verified, exact-main CI passes, and a fresh private Android distribution is verified.

## Required tests/checks

Path-sensitive Foundation CI including formatting, strict analysis, affected mobile/widget tests, Android release/API24 lanes as classified, Local Supabase reset/pgTAP/lint, plus exact-main and private distribution verification.

## Required documentation updates

ADR/task indexes, `ACTIVE_CONTEXT.md`, `HANDOFF.md`, `CODEBASE_MAP.md`, architecture if ownership facts change, active append-only audit log.

## Git requirements

Draft PR from the named branch, merge only an exact green head, then verify exact resulting main.

## Completion report

Return verdict, root causes, task/ADR, branch/PR/final main, behavior changes, tests/CI, production migration, Android distribution evidence, remaining user action and residual risks.
