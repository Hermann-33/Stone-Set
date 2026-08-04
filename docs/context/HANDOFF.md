# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-WF-002 — Close foundational product logic and add reusable new-chat bootstrap prompt`

## Starting state

- The accepted workout routine was documented in `docs/product/HYPERTROPHY_ROUTINE.md`.
- The accepted rank, RR, consistency, PR, missed-session, decay, and calibration rules were documented in `docs/product/RANK_SYSTEM.md`.
- The accepted weekly scheduling, swap, and bankable monthly free-swap rules were documented in `docs/product/WEEKLY_SCHEDULING.md`.
- Current configurations were `rank-v5` and `schedule-v2`.
- The repository had no reusable constant prompt for loading full context in a new conversation.
- Foundational product logic was effectively complete but not explicitly closed as a milestone.

## Completed work

- reviewed `AGENTS.md`, every mandatory context file, the accepted product baselines, and the ADR index;
- confirmed that the workout, rank, RR, consistency, missed-session, swap, and free-swap documents are internally consistent;
- marked the foundational product-logic workstream as complete without falsely marking Phase 0 complete;
- created `docs/context/NEW_CHAT_BOOTSTRAP.md` with a reusable copy-paste prompt;
- made the bootstrap prompt load repository context instead of duplicating a full project snapshot that would become stale;
- added the new-conversation bootstrap process to `docs/context/WORKFLOW.md`;
- synchronized `README.md`, `PROJECT_BRIEF.md`, `ACTIVE_CONTEXT.md`, `CODEBASE_MAP.md`, `ROADMAP.md`, `WORKFLOW.md`, `HANDOFF.md`, and `AUDIT_LOG.md`;
- preserved all accepted workout, rank, RR, consistency, penalty, scheduling, and free-credit values;
- introduced no application code, architecture, stack, persistence, service, or deployment change.

## Closed foundational baselines

| Area | Canonical source | Status |
|---|---|---|
| Hypertrophy routine | `docs/product/HYPERTROPHY_ROUTINE.md` | Accepted |
| Rank and RR system | `docs/product/RANK_SYSTEM.md` | Accepted as `rank-v5` |
| Weekly scheduling and swaps | `docs/product/WEEKLY_SCHEDULING.md` | Accepted as `schedule-v2` |
| Repository governance | `AGENTS.md` and `docs/context/WORKFLOW.md` | Active |
| New-chat context loading | `docs/context/NEW_CHAT_BOOTSTRAP.md` | Active |

## Current accepted product snapshot

- five resistance-training sessions and two non-lifting days;
- 60-minute hard cap including warm-up;
- 20 ranks from Bronze I to Adonis;
- Adonis threshold: `5,500 RR`;
- expected decent-consistency timeline: approximately ten months;
- multiplier tiers: 1.00x, 1.50x, 2.00x, and 2.50x at the accepted streak thresholds;
- any unprotected non-perfect week resets the consistency multiplier;
- missed main session: `-20 RR`;
- missed specialization session: `-15 RR`;
- maximum two confirmed swaps per week;
- two free-swap credits granted each calendar month;
- free-swap credits never expire and have no balance cap;
- one credit waives one swap's `5 RR` cost;
- users may preserve credits and pay RR instead;
- free credits never increase the weekly swap limit.

Detailed rules remain in the canonical product documents and must not be reconstructed from this summary when those files are available.

## Current project position

- Phase: `Phase 0 — Product discovery and governance`
- Foundational product-logic milestone: `COMPLETE`
- Application implementation: not started
- Technology stack: not selected
- Architecture: not accepted
- Persistence: not designed
- Accepted ADRs: none

## Exact next action

Start the next Stone Set conversation using `docs/context/NEW_CHAT_BOOTSTRAP.md` and define the complete end-to-end application workflow, including:

1. weekly schedule and free-swap wallet presentation;
2. swap preview, payment selection, confirmation, locking, and correction behavior;
3. workout start, timers, set entry, RIR entry, and session completion;
4. PR validation and provisional RR presentation;
5. missed, partial, protected, and invalid session resolution;
6. weekly consistency finalization, top-ups, resets, bonuses, penalties, and decay;
7. next-session progression prescription;
8. MVP boundary and measurable success criteria.

Only after that workflow and platform constraints are defined should architecture options be evaluated.

## Verification evidence

- repository authority order remains unchanged;
- no contradictory rank or scheduling configuration was introduced;
- foundational logic is explicitly marked complete while Phase 0 remains active;
- the reusable prompt names every mandatory repository read;
- the reusable prompt requires a context report and conflict check before action;
- the reusable prompt prohibits stale-memory substitution when repository access exists;
- the reusable prompt contains a placeholder for the next task;
- product documents were not modified during this closure task;
- no code, runtime, database, external service, or deployment artifact exists.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Known risks

- Product details can still drift if future agents ignore the repository-loading prompt.
- The end-to-end workflow remains the largest product-definition gap.
- Monthly credit grants and score transactions will require transactional persistence and concurrency tests once architecture is selected.
- Synthetic rank calibration must eventually be checked against real usage.
- No implementation is authorized yet.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection before workflow and platform constraints are documented;
- no silent change to the accepted workout routine;
- no silent change to `rank-v5`, `schedule-v2`, Adonis at `5,500 RR`, or the 5/10/15 multiplier ladder;
- no more than two confirmed swaps per week;
- no expiry or cap on free-swap credits;
- no automatic credit consumption without user payment selection;
- no daily workout streaks or daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest or protected pauses;
- no nutrition or sleep expansion;
- no speculative ADRs, external accounts, secrets, or false implementation claims.

## Verdict

`COMPLETE`

The foundational Stone Set workout, rank, RR, consistency, scheduling, and free-swap logic is closed and documented. The repository is ready for a new conversation focused on end-to-end workflow discovery, not implementation.
