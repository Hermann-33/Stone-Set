# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-008 — Audit and finalize multi-user routine normalization`

## Starting state

- Flutter mobile, Flutter Web, and Supabase planning architecture had been accepted.
- The end-to-end workflow was proposed but not active.
- `rank-v5` and `schedule-v2` remained canonical.
- The multi-user daily-RR model was documented as a proposal.
- The product owner explicitly accepted the proposed `rank-v6` model.
- No application, schema, account, infrastructure, or deployment existed.

## Decision

The multi-user normalization is accepted and activated.

- Active rank configuration: `rank-v6`.
- Active scheduling configuration: `schedule-v3`.
- `rank-v6` supersedes `rank-v5`.
- `schedule-v3` supersedes `schedule-v2`.
- The application workflow is promoted to accepted status.
- No production migration is required because implementation and persisted history do not exist.

## Accepted routine model

- Two provisioned initial users.
- Public registration excluded from MVP.
- Account count not hardcoded to two.
- Users manage only their own routine drafts.
- Published routine versions are immutable.
- Routine changes apply only to future unlocked weeks.
- Supported MVP routines contain 4-6 workout days and at least 1 programmed rest day.
- Every materialized week contains 7 dated plan items.
- The original five-session hypertrophy routine remains the initial owner routine.

## Accepted `rank-v6` economics

### Weekly ordinary RR

| Multiplier | Daily-item pool | Perfect-week bonus | Maximum no-PR weekly RR |
|---:|---:|---:|---:|
| 1.00x | 110 | 25 | 135 |
| 1.50x | 167 | 25 | 192 |
| 2.00x | 220 | 25 | 245 |
| 2.50x | 277 | 25 | 302 |

### Allocation

```text
workout item weight = 4
rest item weight = 1
weekly ordinary base-XP item pool = 110
```

Allocation uses largest remainder with earlier calendar date as the deterministic tie-break.

### Workout resolution

- fully completed and fully logged: 100%;
- fully completed with incomplete logging: 85%;
- 70-89% completed: 50%;
- below 70% or invalid: 0% plus stored missed penalty unless protected.

### Rest resolution

- automatic finalization at local day close;
- lower stored RR and base-XP allocation;
- no manual check-in;
- no missed penalty;
- no PR;
- no extra reward for unscheduled training.

### Penalties and PRs

```text
weekly direct missed-workout penalty pool = 95 RR
maximum rewarded PRs per week = 2
valid PR = 5 raw RR and 5 lifetime XP
failed week = unprotected workout completion ratio < 0.60
```

PR RR remains consistency-multiplied; PR lifetime XP is unmultiplied.

## Preserved rank behavior

- 20 ranks from Bronze I to Adonis;
- Adonis at `5,500 RR`;
- multiplier tiers at Weeks 5, 10, and 15;
- exact milestone-week top-ups;
- full reset after an unprotected non-perfect week;
- protected full-week freeze;
- perfect-week and once-per-account streak milestones;
- rank-local failed-week decay;
- no daily rank decay;
- no reward for random extra workouts or sets;
- stored-value reversals and configuration versioning.

## Accepted `schedule-v3` behavior

- seven materialized plan items per week;
- immutable routine-version and allocation references;
- maximum two confirmed swaps per week;
- any two distinct unlocked dates may exchange complete items;
- two non-expiring, uncapped monthly free-swap credits;
- explicit credit-versus-`5 RR` payment choice;
- free credits do not increase the weekly limit;
- swaps move item identity, prescription, RR, XP, and penalty allocations;
- no free undo;
- no retroactive, started-item, resolved-item, or cross-week swaps;
- exact-instrument restoration through auditable correction.

## Fairness verification

A deterministic-seed preliminary simulation used 50,000 synthetic users per supported workout frequency.

| Workout days | Mean weeks | Median | 25th percentile | 75th percentile | 90th percentile |
|---:|---:|---:|---:|---:|---:|
| 4 | 42.87 | 43 | 40 | 46 | 49 |
| 5 | 42.00 | 42 | 39 | 45 | 48 |
| 6 | 41.41 | 42 | 39 | 45 | 47 |

The maximum synthetic mean spread is approximately `1.46 weeks` and is accepted.

The perfect-week maximum is exactly equal. The residual spread results from discrete workout counts in imperfect weeks.

Synthetic results are balance evidence, not observed user data.

## Files changed

Canonical product specifications:

- `docs/product/RANK_SYSTEM.md`;
- `docs/product/WEEKLY_SCHEDULING.md`;
- `docs/product/APPLICATION_WORKFLOW.md`.

Supporting analysis:

- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`.

Planning and context:

- `README.md`;
- `docs/context/ACTIVE_CONTEXT.md`;
- `docs/context/PROJECT_BRIEF.md`;
- `docs/context/ARCHITECTURE.md`;
- `docs/context/CODEBASE_MAP.md`;
- `docs/context/ROADMAP.md`;
- `docs/context/IMPLEMENTATION_PLAN.md`;
- `docs/context/HANDOFF.md`.

## Verification performed

- confirmed weekly RR pools preserve the accepted no-PR weekly totals;
- verified four-, five-, and six-day 1.00x allocations sum to 110;
- verified base-XP allocations sum to 110;
- verified penalty allocations sum to 95 for all supported frequencies;
- preserved the 20-rank ladder and Adonis at `5,500 RR`;
- preserved the 5/10/15 multiplier ladder;
- preserved the two-swap limit and monthly bankable free credits;
- normalized PR opportunity to two per week;
- replaced fixed session-count failed-week logic with a ratio below 60%;
- promoted the workflow only after rank and schedule activation;
- introduced no code, schema, credentials, external project, deployment, or runtime claim.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`
- Task commits: documentation commits prefixed with `TASK-PD-008`

## Known risks

- Equal rank opportunity does not guarantee equal physical effort.
- User-controlled routine publication can be gamed without concrete minimum prescription rules.
- Rest-item rewards may require careful UX so they are understood as prescribed-week adherence rather than a reward for inactivity.
- The 1.46-week simulation spread is accepted but should be checked against real data later.
- Offline synchronization and duplicate submission remain unresolved implementation risks.
- RLS mistakes can expose cross-user data.
- Dashboard hosting, mobile release scope, backups, and operator access remain undecided.

## Exact next action

Create and execute:

`TASK-PL-002 — Close implementation constraints and authorize the foundation task`

It must:

1. define concrete reward-eligible routine validation and anti-triviality rules;
2. define local in-progress-workout storage and recovery;
3. define offline submission and server-finalization behavior;
4. select Android-only or Android-and-iOS initial release scope;
5. select dashboard hosting;
6. define Supabase backup, restore, and operator access;
7. produce the bounded `TASK-IMP-001` packet;
8. synchronize context and handoff;
9. authorize scaffolding only if every gate passes.

## Do-not-touch boundaries

- no Flutter scaffolding yet;
- no Supabase project or schema yet;
- no credentials or accounts yet;
- no application-table password storage;
- no service-role or secret key in public clients;
- no client-authored RR, XP, penalty, wallet, milestone, or finalization totals;
- no silent change to `rank-v6` or `schedule-v3`;
- no silent change to Adonis at `5,500 RR` or the 5/10/15 multiplier ladder;
- no increase to the two-swap weekly limit through free credits;
- no expiry or cap on free-swap credits;
- no reward for unscheduled extra workouts or sets;
- no nutrition, sleep, social, payment, wearable, analytics, or medical-diagnosis expansion.

## Verdict

`PARTIAL`

The multi-user rank, scheduling, and workflow baseline is accepted and canonical. The task cannot be marked complete until the material audit entry is synchronized in `docs/context/AUDIT_LOG.md`. Implementation also remains blocked by the explicitly listed Phase 0 constraints.