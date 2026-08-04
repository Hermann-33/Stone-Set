# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-004 — Define weekly session swaps and swap penalties`

## Starting state

- Stone Set had an accepted five-session hypertrophy routine and rank system.
- Same-week rescheduling was acknowledged, but no exact swap limit, penalty, locking, or schedule-integrity behavior existed.
- Approved rescheduling previously avoided missed-session penalties without any direct RR cost.
- The owner required any day to be swappable with any other day, limited to two swaps per week, with an RR consequence.

## Completed work

- created `docs/product/WEEKLY_SCHEDULING.md`;
- defined a swap as exchanging the complete scheduled contents of two days;
- allowed workout-to-rest and workout-to-workout exchanges inside the active Monday–Sunday week;
- limited each week to two confirmed swaps;
- set a flat `-5 RR` penalty per confirmed swap;
- kept lifetime XP immune from swap penalties;
- prevented consistency multipliers from amplifying swap penalties;
- allowed a fully completed swapped week to remain perfect;
- prohibited retroactive, cross-week, completed-day, and duplicate-session swaps;
- defined day locking, recovery warnings, confirmation previews, no-free-undo behavior, record shapes, corrections, and weekly finalization order;
- updated the rank system so swap penalties and missed-session penalties interact coherently;
- synchronized project brief, active context, roadmap, codebase map, audit history, and handoff.

## Accepted swap behavior

| Rule | Accepted value |
|---|---|
| Maximum swaps per week | 2 |
| RR cost per confirmed swap | -5 RR |
| Maximum weekly swap cost | -10 RR |
| Lifetime XP effect | 0 |
| Consistency multiplier effect | None |
| Workout ↔ rest | Allowed |
| Workout ↔ workout | Allowed |
| Cross-week swap | Prohibited |
| Retroactive swap after day lock | Prohibited |
| Free undo | Prohibited |
| Perfect week after all sessions completed | Still possible |

## Example

Wednesday Delts and Forearms may be exchanged with Sunday Rest before Wednesday locks.

After confirmation:

- Wednesday becomes Rest;
- Sunday becomes Delts and Forearms;
- `5 RR` is deducted immediately;
- completing Sunday avoids the `15 RR` missed-session penalty;
- missing Sunday creates an additional `15 RR` loss.

## Verification evidence

- workout-to-rest swap preserves five workout identities and two rest-day identities;
- workout-to-workout swap changes dates without duplicating rewards;
- each confirmed exchange counts as one swap operation;
- a second swap can restore the original order but costs another 5 RR;
- a third confirmed swap is blocked;
- canceled previews consume no swap and deduct no RR;
- past, started, completed, finalized, and cross-week days cannot be exchanged;
- a five-of-five swapped week still earns perfect-week classification and consistency credit;
- moved-session missed penalties follow session type to the new date;
- swap deductions and missed-session penalties are stored as separate auditable transactions;
- repository product and current-state documents were synchronized.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from viewing the weekly schedule through previewing and confirming a swap, starting the assigned workout, recording sets, validating PRs, completing or missing sessions, finalizing RR transactions, and producing the next-session prescription.

## Known risks

- Any-day swaps can create poor recovery sequences; warnings are defined but not yet designed visually.
- Flat `-5 RR` is a product-balance parameter and requires simulation against real usage.
- Day locking and timezone behavior need precise implementation tests.
- Protected-state backdating remains an abuse risk.
- Historical rank and schedule configuration migration remains undefined.
- The product workflow is incomplete; no implementation should begin.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no more than two confirmed swaps per week;
- no free confirmed-swap reversal;
- no cross-week or retroactive swaps;
- no daily workout streaks or daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest by itself;
- no silent rank or scheduling balance changes;
- no nutrition or sleep feature expansion;
- no speculative ADRs;
- no external accounts, secrets, or false production claims.