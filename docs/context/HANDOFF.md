# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-005 — Rename the highest rank and replace rolling consistency with a resettable 15-week multiplier`

## Starting state

- Stone Set had a 20-rank ladder ending at Titan with a 27,300 RR threshold.
- Consistency used a rolling six-week credit model capped at 1.50x.
- One imperfect week reduced rolling credit but did not fully reset the multiplier.
- The owner required the highest rank to be renamed Adonis.
- The owner required 1.50x at five consecutive perfect weeks, 2.00x at ten, 2.50x at fifteen, a permanent 2.50x cap while the streak continues, and a complete reset after a missed week.

## Completed work

- renamed the highest rank from Titan to Adonis without changing its 27,300 RR threshold;
- replaced the rolling six-week model with a consecutive-perfect-week ladder;
- defined 1.00x for weeks 0-4, 1.50x for weeks 5-9, 2.00x for weeks 10-14, and 2.50x for week 15 onward;
- defined exact RR top-ups on the fifth, tenth, and fifteenth perfect weeks so milestone weeks receive the new multiplier only after they are confirmed perfect;
- defined full reset to zero consecutive perfect weeks and 1.00x after any unprotected non-perfect week;
- preserved protected-pause freezing, perfect swapped weeks, deload completion, PR rewards, missed-session penalties, swap penalties, and failed-week decay;
- recalibrated the complete path to Adonis using all current weekly rewards and one-time streak milestones;
- synchronized the rank specification, project brief, active context, roadmap, audit history, README, and handoff.

## Accepted rank and consistency behavior

| Rule | Accepted value |
|---|---:|
| Highest rank | Adonis |
| Adonis threshold | 27,300 RR |
| Weeks 0-4 | 1.00x |
| Weeks 5-9 | 1.50x |
| Weeks 10-14 | 2.00x |
| Week 15+ | 2.50x |
| Maximum multiplier | 2.50x |
| Unprotected non-perfect week | Reset to 0 weeks / 1.00x |
| Protected pause | Freeze streak and multiplier |
| Perfect week after valid swaps | Continues streak |

The fifth, tenth, and fifteenth perfect weeks receive an auditable consistency top-up after weekly finalization. A week that later fails cannot receive the higher tier.

## Adonis calibration

Assumptions for the clean baseline:

- every week is perfect;
- every session is completely logged;
- no PR rewards;
- no swaps;
- no misses or failed-week decay;
- existing one-time streak milestones remain active.

| Multiplier | Weekly RR without PRs |
|---:|---:|
| 1.00x | 135 |
| 1.50x | 192 |
| 2.00x | 245 |
| 2.50x | 302 |

Results:

- Week 15: 3,512 cumulative RR;
- Week 52: 16,786 cumulative RR;
- Week 86: 27,054 cumulative RR;
- Week 87: 27,356 cumulative RR.

The clean no-PR path reaches Adonis in `87 perfect weeks`, approximately `20 months`.

One isolated reset near 2.50x costs approximately 1,606 RR of immediate and rebuilding opportunity, roughly five to six additional perfect weeks.

Practical estimates:

- perfect or near-perfect with ordinary PRs: about 19-22 months;
- occasional isolated reset: around 2 years or slightly longer;
- one missed week around every 12 weeks: around 3 years;
- one missed week around every 8 weeks: around 3.4 years;
- one missed week around every 5 weeks: around 4.3 years.

## Verification evidence

- weekly RR was recalculated for all four multiplier tiers;
- one-time streak milestones were included in the Adonis projection;
- cumulative RR was checked at Weeks 15, 52, 86, and 87;
- Week 86 remains below 27,300 RR;
- Week 87 exceeds 27,300 RR;
- consistency reset does not revoke lifetime XP, historical RR, or already earned one-time milestones;
- protected pauses freeze rather than reset consistency;
- a five-of-five swapped week remains perfect;
- penalties remain unmultiplied;
- no threshold, workout, scheduling, architecture, or implementation change was introduced beyond the requested rank balance.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from viewing the weekly schedule through swapping days, starting and logging workouts, showing provisional RR, validating PRs, resolving missed and protected sessions, finalizing weekly multiplier top-ups or resets, applying penalties, and generating the next-session prescription.

## Known risks

- The 2.50x cap makes Adonis materially faster than the previous three-year perfect-adherence pacing assumption.
- Milestone-week top-ups add implementation and transaction-history complexity.
- A strict full reset creates large progression volatility and may feel punitive after long streaks.
- Protected-state backdating remains an abuse risk.
- Historical rank-configuration migration remains undefined.
- No application implementation is authorized.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no silent Adonis threshold change;
- no change to the 5/10/15 consistency ladder without an explicit balance task;
- no more than two confirmed swaps per week;
- no free swap reversal;
- no cross-week or retroactive swaps;
- no daily workout streaks or daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no penalties for programmed rest or protected pauses;
- no nutrition or sleep expansion;
- no speculative ADRs, external accounts, secrets, or false production claims.