# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-006 — Recalibrate rank progression for a ten-month average Adonis target`

## Starting state

- Stone Set had 20 ranks ending at Adonis at `27,300 RR`.
- The consistency ladder used 1.50x at five perfect weeks, 2.00x at ten, and 2.50x at fifteen.
- Any unprotected non-perfect week reset the streak and multiplier.
- Under perfect no-PR adherence, Adonis required approximately 87 weeks.
- The owner required an average user with decent consistency to reach Adonis in approximately ten months.

## Completed work

- defined ten months as approximately 43 weeks for product calibration;
- defined a synthetic decent-consistency profile rather than pretending population data exists;
- ran 50,000 deterministic-seed simulations using current workout rewards, multiplier resets, swaps, penalties, PRs, and complete logging;
- compressed the 20-rank ladder while preserving all rank names;
- changed Adonis from `27,300 RR` to `5,500 RR`;
- retained session base rewards, complete-logging rewards, PR rewards, perfect-week rewards, multiplier tiers, missed-session penalties, and swap penalties;
- reduced one-time streak milestone rewards so the compressed ladder cannot be skipped by one oversized milestone;
- reduced failed-week base decay values to remain proportional to the compressed rank spans;
- defined the current balance as `rank-v4`;
- synchronized the canonical rank specification, project brief, active context, roadmap, audit history, README, and handoff.

## Accepted rank ladder

| CL | Rank | Minimum RR |
|---:|---|---:|
| 1 | Bronze I | 0 |
| 2 | Bronze II | 100 |
| 3 | Bronze III | 200 |
| 4 | Silver I | 325 |
| 5 | Silver II | 475 |
| 6 | Silver III | 650 |
| 7 | Gold I | 825 |
| 8 | Gold II | 1,025 |
| 9 | Gold III | 1,250 |
| 10 | Platinum I | 1,500 |
| 11 | Platinum II | 1,775 |
| 12 | Platinum III | 2,075 |
| 13 | Diamond I | 2,400 |
| 14 | Diamond II | 2,750 |
| 15 | Diamond III | 3,125 |
| 16 | Elite | 3,525 |
| 17 | Champion | 3,950 |
| 18 | Apex | 4,400 |
| 19 | Prodigy | 4,900 |
| 20 | Adonis | 5,500 |

## Defined decent-consistency profile

- 72% perfect weeks: 5 of 5 sessions;
- 23% compliant weeks: 4 of 5 sessions;
- 5% weak weeks: 3 of 5 sessions;
- approximately 93% scheduled-session completion;
- 76% of weeks with no swap, 22% with one swap, and 2% with two swaps;
- 0.5 rewarded PRs per week for Weeks 1-20 and 0.3 per week afterward;
- complete logging for all completed working sets;
- no failed 0-2-session weeks in the baseline profile.

## Calibration result

| Result | Weeks to Adonis |
|---|---:|
| Mean | 42.7 |
| Median | 43 |
| 25th percentile | 40 |
| 75th percentile | 46 |
| 90th percentile | 48 |

Reference pacing:

- perfect, no PRs, no swaps: approximately 23 weeks;
- excellent consistency: approximately 30-31 weeks;
- good consistency: approximately 36-37 weeks;
- defined decent consistency: approximately 42-43 weeks;
- inconsistent but still regular training: approximately 52-53 weeks.

## Preserved behavior

- Weeks 0-4: 1.00x;
- Weeks 5-9: 1.50x;
- Weeks 10-14: 2.00x;
- Week 15+: 2.50x;
- any unprotected non-perfect week resets the multiplier;
- protected pauses freeze the streak;
- completed swapped weeks may remain perfect;
- missed main session: -20 RR;
- missed specialization session: -15 RR;
- confirmed swap: -5 RR, maximum two per week;
- valid PR: +5 raw RR, maximum two rewarded PRs per session;
- perfect week: +25 RR and +25 lifetime XP;
- penalties are never multiplied;
- lifetime XP does not decay from inactivity.

## Verification evidence

- 20 rank names remain intact;
- threshold spans increase through the ladder rather than using a flat proportional cut;
- simulation includes resets, swaps, ordinary PR frequency, complete logging, and existing session economics;
- the 42.7-week mean satisfies the requested ten-month target;
- the 43-week median prevents the target from depending on a small number of unusually fast simulations;
- milestone rewards and failed-week decay were recalibrated against the smaller ladder;
- no workout, scheduling, architecture, runtime, persistence, or implementation behavior was introduced.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from viewing the weekly schedule through swapping days, starting and logging workouts, showing provisional RR, validating PRs, resolving missed and protected sessions, finalizing weekly multiplier top-ups or resets, applying penalties, and generating the next-session prescription.

## Known risks

- The ten-month target is based on a synthetic calibration profile, not real Stone Set usage data.
- A perfect user can reach Adonis in approximately 23 weeks, much faster than the average target.
- Strict consistency resets still create significant volatility.
- Protected-state backdating remains an abuse risk.
- Historical rank-configuration migration remains undefined for the future implementation.
- No application implementation is authorized.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no silent change to `rank-v4`, the `5,500 RR` Adonis threshold, or the 5/10/15 multiplier ladder;
- no more than two confirmed swaps per week;
- no free swap reversal;
- no cross-week or retroactive swaps;
- no daily workout streaks or daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest or protected pauses;
- no synthetic calibration presented as observed population evidence;
- no nutrition or sleep expansion;
- no speculative ADRs, external accounts, secrets, or false production claims.