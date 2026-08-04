# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-007 — Add bankable monthly free-swap credits`

## Starting state

- Stone Set allowed a maximum of two confirmed swaps per week.
- Every confirmed swap cost `5 RR`.
- Swaps could be used between any two unlocked days inside the active Monday-Sunday week.
- The owner required two free swaps every month, no expiry, and indefinite accumulation.

## Completed work

- added two free-swap credits per calendar month;
- made credits non-expiring and uncapped;
- allowed users to accumulate unused credits indefinitely;
- preserved the maximum of two confirmed swaps per week;
- defined one free credit as waiving one swap's `5 RR` cost;
- allowed the user to preserve credits and pay `5 RR` instead;
- prohibited silent automatic credit consumption;
- defined current-month grant behavior for new accounts;
- defined idempotent monthly grants keyed by account and `YYYY-MM`;
- defined reward-timezone handling and blocked timezone-based duplicate grants;
- kept monthly grants active during inactivity and protected pauses;
- defined exact correction behavior for free-credit and RR-paid swaps;
- added wallet, grant, consumption, and swap-payment record requirements;
- updated rank behavior so free swaps produce zero RR loss but do not protect later missed sessions;
- versioned the accepted behavior as `rank-v5` and `schedule-v2`;
- synchronized the canonical scheduling and rank specifications, project brief, active context, codebase map, roadmap, audit history, and handoff.

## Accepted free-swap behavior

| Rule | Accepted value |
|---|---|
| Monthly grant | 2 credits |
| Expiry | None |
| Maximum stored balance | None |
| Credit cost per free swap | 1 credit |
| RR cost when using a credit | 0 RR |
| RR cost when preserving credits | Up to -5 RR |
| Maximum confirmed swaps per week | 2 |
| Credits increase weekly limit | No |
| Credit conversion or transfer | Prohibited |
| Protected pause stops grants | No |

## Confirmation behavior

When at least one credit exists, the user chooses one payment method before confirming a swap:

1. `Use 1 free swap` — consumes one credit and deducts no RR; or
2. `Pay 5 RR` — keeps the credit balance unchanged.

A canceled preview consumes neither a weekly swap, a credit, nor RR.

## Example

The user has six stored free-swap credits and exchanges Wednesday Delts and Forearms with Sunday Rest.

After choosing `Use 1 free swap`:

- Wednesday becomes Rest;
- Sunday becomes Delts and Forearms;
- free-swap balance changes from 6 to 5;
- RR changes by 0;
- one of the two weekly swap allowances is consumed.

If the Sunday workout is later missed, the normal `-15 RR` specialization-session penalty still applies.

## Rank-calibration impact

The accepted decent-consistency profile expects `0.26` swaps per week, approximately 11 swaps over ten months.

Two monthly credits provide approximately 20 credits over the same period, so most modeled swaps become free after normal accumulation.

The previous calibration included about `1.30 RR` of expected paid-swap cost per week. Removing most of that cost changes the expected Adonis timeline by roughly `0.4` week, leaving the target at approximately 42-43 weeks.

This is an expected-value adjustment, not a new Monte Carlo run.

## Preserved behavior

- 20 ranks from Bronze I to Adonis;
- Adonis at `5,500 RR`;
- Weeks 0-4: 1.00x;
- Weeks 5-9: 1.50x;
- Weeks 10-14: 2.00x;
- Week 15+: 2.50x;
- any unprotected non-perfect week resets the multiplier;
- protected pauses freeze the streak;
- completed swapped weeks may remain perfect;
- missed main session: -20 RR;
- missed specialization session: -15 RR;
- valid PR: +5 raw RR, maximum two rewarded PRs per session;
- perfect week: +25 RR and +25 lifetime XP;
- penalties are never multiplied;
- lifetime XP does not decay from inactivity.

## Verification evidence

- one monthly grant creates exactly two credits;
- the same calendar month cannot grant twice;
- unused credits carry into later months;
- no maximum balance exists;
- a free-credit swap applies exactly 0 RR loss;
- a paid swap preserves credits and applies the stored RR deduction;
- both payment types consume one weekly swap allowance;
- a third weekly swap remains blocked regardless of credit balance;
- a free swap followed by a missed workout still creates the relevant missed-session penalty;
- swapping back requires a second weekly allowance and a second payment choice;
- correction restores only the original payment instrument;
- timezone changes cannot duplicate a monthly grant;
- rank thresholds, rewards, penalties, and multiplier tiers remain unchanged.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from viewing the weekly schedule and free-swap balance through selecting a swap payment method, starting and logging workouts, showing provisional RR, validating PRs, resolving missed and protected sessions, finalizing weekly consistency, and generating the next-session prescription.

## Known risks

- Unlimited accumulation may make paid swaps rare for long-term users, although the weekly two-swap cap still prevents unlimited schedule churn.
- Monthly grant timing and reward-timezone changes require precise implementation tests.
- Credit-wallet correctness will require transactional persistence once architecture is selected.
- Duplicate-grant and correction flows require immutable audit history.
- The ten-month rank impact is an expected-value estimate rather than a rerun simulation.
- No application implementation is authorized.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no silent change to `rank-v5`, `schedule-v2`, the `5,500 RR` Adonis threshold, or the 5/10/15 multiplier ladder;
- no more than two confirmed swaps per week;
- no expiry or cap on free-swap credits;
- no free-swap conversion or transfer;
- no automatic credit consumption without user payment selection;
- no cross-week or retroactive swaps;
- no daily workout streaks or daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest or protected pauses;
- no nutrition or sleep expansion;
- no speculative ADRs, external accounts, secrets, or false production claims.
