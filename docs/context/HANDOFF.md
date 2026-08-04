# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-003 — Add per-missed-session RR penalties`

## Starting state

- Stone Set had an accepted workout routine and rank system.
- The rank system rewarded completed scheduled sessions, logging, PRs, perfect weeks, and long consistency.
- Missing one or two scheduled workouts reduced future rewards but did not directly subtract RR.
- Direct RR loss occurred only after a failed week with fewer than three completed sessions.
- The owner rejected that behavior and required a direct consequence for every missed scheduled workout.

## Completed work

- added a direct `-20 RR` penalty for each unprotected missed main session;
- added a direct `-15 RR` penalty for an unprotected missed specialization session;
- kept lifetime XP immune from missed-session penalties;
- prevented the consistency multiplier from increasing penalties;
- delayed penalties until the week closes so same-week rescheduling remains possible;
- defined partial, missed, invalid, and protected-interruption states;
- kept rest days, deloads, approved reschedules, illness, injury, travel, and gym closure non-punitive;
- retained failed-week rank-local decay after direct penalties when only zero to two sessions are completed;
- added immutable missed-session penalty records and exact reversal behavior;
- updated product scope, roadmap, active context, audit history, and handoff.

## Accepted missed-session behavior

| Event | RR effect |
|---|---:|
| Missed main session | -20 RR |
| Missed specialization session | -15 RR |
| Programmed rest day | 0 |
| Approved same-week reschedule completed | 0 penalty |
| Protected interruption or protected pause | 0 penalty |
| Prescribed deload completed | Normal eligible reward |

A 4-of-5 compliant week now directly loses the relevant session penalty, receives no perfect-week bonus, earns only half consistency credit, and breaks the perfect-week streak.

A failed week receives direct penalties for every missed session and then the existing rank-local failed-week decay.

## Verification evidence

- 5/5 week: no penalties;
- 4/5 week: exactly one direct penalty;
- 3/5 week: exactly two direct penalties and no failed-week decay;
- 0-2/5 week: direct penalties plus rank-local failed-week decay;
- programmed rest days cannot create penalties;
- same-week rescheduling avoids penalties when completed;
- consistency multipliers affect rewards only;
- lifetime XP remains unchanged by missed training;
- correction restores the exact stored penalty rather than recalculating it.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from opening a scheduled workout through entering sets, completing or missing the session, resolving same-week reschedules and protection states, finalizing weekly penalties, validating PRs, displaying the RR transaction breakdown, and generating the next-session prescription.

## Known risks

- Direct penalties plus failed-week decay make low-adherence weeks intentionally strict and require later simulation.
- Protected-state backdating can be abused without immutable correction history.
- Partial-session thresholds and pain-related interruption behavior need explicit UI flows.
- Historical award and penalty configuration must be versioned before implementation.
- The product workflow is still incomplete; no implementation should begin.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no daily workout streaks;
- no daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest or approved protection;
- no silent rank-balance changes;
- no nutrition or sleep feature expansion;
- no speculative ADRs;
- no external accounts or services;
- no secrets or personal sensitive data;
- no false production or implementation claims.