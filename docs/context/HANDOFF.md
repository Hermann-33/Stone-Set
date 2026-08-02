# Stone Set Latest Handoff

Updated: 2026-08-03

## Current task

`TASK-PD-001 — Establish the evidence-based hypertrophy routine baseline`

## Starting state

- The product was identified only as a personal app.
- The user supplied a five-session weekly workout plan built around limited gym equipment.
- Four main sessions were scheduled for 75 minutes, conflicting with the new hard limit of 60 minutes.
- The supplied plan included a Wednesday shoulder press between Monday and Friday upper-body sessions.
- No accepted product-domain workout specification existed in the repository.

## Completed work

- reviewed only the workout-program content from the supplied PDF;
- compared the split, volume, frequency, rest, repetition ranges, exercise order, proximity to failure, and time-efficiency strategy against primary resistance-training trials;
- retained the five-session weekly structure as a time-distribution method;
- reduced time-expensive or redundant volume;
- removed the Wednesday shoulder press;
- reduced Bulgarian split squats from three to two hard sets per leg;
- established a strict 60-minute execution rule;
- documented the accepted routine in `docs/product/HYPERTROPHY_ROUTINE.md`;
- updated the product brief, active context, roadmap, codebase map, README, audit log, and handoff.

## Accepted workout baseline

- Monday: Upper A, 16 working sets
- Tuesday: Lower A, 15 working sets
- Wednesday: Delts and forearms, 13 working sets
- Thursday: no resistance training
- Friday: Upper B, 17 working sets
- Saturday: Lower B, 15 working sets
- Sunday: no resistance training
- Maximum session duration: 60 minutes including warm-up

## Evidence position

The plan is an evidence-informed starting prescription. Research does not establish one universally optimal split or exact weekly set count. The accepted routine therefore begins at moderate recoverable volume and must later adapt from logged performance, recovery, pain, and time compliance.

## Verification evidence

- the supplied routine was inspected exercise by exercise;
- weekly direct-set exposure was recalculated;
- each revised session was time-budgeted against the 60-minute limit;
- exercise selection remains inside the equipment boundary demonstrated by the source plan;
- research citations and PubMed identifiers are recorded in the product-domain document;
- no nutrition, sleep, university schedule, architecture, data, or implementation claims were introduced.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from starting a scheduled workout through entering sets, managing rest, completing the session, and receiving the next-session progression prescription.

## Known risks

- The user's actual training response may require lower or higher volume than the baseline.
- A crowded gym may disrupt accessory pairings and equipment order.
- RIR estimates may be inaccurate until calibrated through repeated training.
- The app must not convert training heuristics into medical or injury diagnosis.
- The product scope is still incomplete; no implementation should begin.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no nutrition or sleep feature expansion;
- no silent changes to the accepted routine;
- no speculative ADRs;
- no external accounts or services;
- no secrets or personal sensitive data;
- no false production or implementation claims.