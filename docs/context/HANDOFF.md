# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-002 — Define the workout rank and RR system`

## Starting state

- Stone Set had an accepted limited-equipment hypertrophy routine.
- The owner supplied a complete rank system from another project as inspiration.
- The source system separated permanent lifetime XP from current rank score, used reward tiers, daily rank-local decay, and long daily streak rewards.
- No Stone Set rank behavior existed.

## Completed work

- retained the source model's strongest portable ideas: lifetime achievement versus current rank, stored awards, demotion, rank-local decay, and consistency scaling;
- rejected daily workout streaks and daily decay because the gym program contains prescribed rest days;
- defined 20 ranks from Bronze I through Titan;
- defined session base rewards, complete-logging rewards, and capped valid PR rewards;
- defined a rolling six-week consistency multiplier from 1.00x to 1.50x;
- defined perfect-week bonuses and once-per-account streak milestones;
- defined weekly rank decay only after materially failed unprotected weeks;
- defined deload, illness, injury, travel, gym-closure, and protected-pause behavior;
- defined anti-farming rules for extra workouts, extra sets, duplicate sessions, changed exercise variants, and invalid PRs;
- defined award records, reversal behavior, weekly evaluation order, and required state;
- documented the accepted system in `docs/product/RANK_SYSTEM.md`;
- synchronized the project brief, active context, roadmap, codebase map, audit log, and handoff.

## Accepted rank baseline

- Lifetime track: `lifetimeXP`
- Current rank track: `rankRR`
- Rank ladder: 20 ranks, Bronze I to Titan
- Main-session base: 20 RR
- Specialization-session base: 15 RR
- Complete logging: +3 raw RR
- Valid PR: +5 raw RR, maximum two rewarded PRs per session
- Consistency multiplier: rolling six-week adherence, maximum 1.50x
- Perfect-week bonus: 25 RR
- Rank decay: weekly only after fewer than three completed scheduled sessions in an unprotected week
- Rest days: no reward and no penalty
- Unscheduled extra work: no RR

## Verification evidence

- reward formulas were calculated against the accepted five-session workout schedule;
- a maximum-consistency week without PRs produces approximately 192 RR;
- rank thresholds were paced so Titan represents years rather than months of sustained adherence;
- one imperfect week does not erase the entire multiplier because consistency is rolling rather than a single brittle streak;
- PR rewards are capped so novice PR frequency cannot dominate consistency;
- decay is rank-local and weekly rather than daily;
- all rank-changing events require stored award or evaluation records;
- no UI, architecture, data-store, technology, or implementation claim was introduced.

## Branch and repository

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`

## Exact next action

Define the complete app workflow from opening a scheduled workout through entering sets, validating PRs, completing the session, displaying the stored RR award breakdown, and producing the next-session prescription.

## Known risks

- Rank thresholds and reward values remain balance parameters, not physiological facts.
- Self-reported RIR and technique can be inaccurate.
- PR comparison requires strict exercise-variant identity.
- Protected pauses can become an exploit if backdating and correction history are weak.
- Historical award behavior must be versioned before future balance changes.
- The product workflow is still incomplete; no implementation should begin.

## Do-not-touch boundaries

- no app scaffolding;
- no technology selection;
- no daily workout streaks;
- no daily RR decay;
- no RR for unscheduled extra workouts or extra sets;
- no silent rank-balance changes;
- no nutrition or sleep feature expansion;
- no speculative ADRs;
- no external accounts or services;
- no secrets or personal sensitive data;
- no false production or implementation claims.