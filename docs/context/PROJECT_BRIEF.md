# Stone Set Project Brief

Updated: 2026-08-04
Status: `IMPLEMENTATION-READY PLANNING BASELINE`

## Product purpose

Stone Set is a private muscle-growth training system for two initial users with independently managed routines and one normalized rank economy.

It makes structured hypertrophy routines executable, trackable, adaptable, and motivating while preventing routine frequency, trivial prescriptions, random extra volume, or client manipulation from producing unfair rank progress.

## Users

- Two administratively provisioned initial users.
- No public registration in MVP.
- Data model supports later users without redesign.
- Each user owns their private routine, schedule, workout logs, rank, wallet, and history.
- One user may review another user's submitted routine but may not edit it.

## Accepted user outcomes

1. A user drafts and submits a routine through the Flutter Web dashboard.
2. Server validation and an independent reviewer approve or reject the exact immutable submission.
3. A published approved routine becomes active only for a future unlocked week.
4. The Android app presents the week, starts workouts online, logs sets, survives temporary network loss, and synchronizes idempotently.
5. Supabase authoritatively validates completion, rewards, swaps, penalties, consistency, corrections, and history.
6. Supported 4-, 5-, and 6-day routines have equal maximum weekly RR opportunity.
7. Rest items receive lower automatic rewards without fake check-ins.
8. Users can inspect routine, workout, rank, wallet, correction, and configuration history.

## Routine eligibility

`docs/product/ROUTINE_ELIGIBILITY.md` defines `routine-validator-v1`.

Core constraints:

- 7 day slots;
- 4–6 workouts and 1–3 rest days;
- 32–100 weekly working sets;
- each workout contains 3–10 exercises and 8–20 working sets;
- each workout estimates to 20–60 minutes;
- valid reps, RIR, rest, ordering, equipment, priority, and progression prescriptions;
- independent review and stored content hash;
- self-approval prohibited;
- published versions immutable.

These controls block mechanically trivial reward-bearing routines. Human review remains necessary because arithmetic alone cannot prove physiological quality.

## Accepted rank and scheduling

- `rank-v6` and `schedule-v3` are canonical.
- 20 ranks from Bronze I to Adonis at `5,500 RR`.
- Normalized daily-item RR pools: 110, 167, 220, and 277.
- Perfect-week bonus: 25 RR and 25 lifetime XP.
- Workout/rest allocation: 4:1.
- Weekly base-XP item pool: 110.
- Weekly missed-workout penalty pool: 95 RR.
- Maximum two rewarded PRs per week.
- Failed week below 60% workout completion.
- Multiplier unlocks at 5, 10, and 15 consecutive perfect weeks.
- Maximum two weekly swaps.
- Two non-expiring, uncapped free-swap credits granted monthly.
- Extra unscheduled training earns no RR or XP.

## Accepted architecture

- Flutter Android mobile application.
- Separate Flutter Web dashboard.
- Shared Dart packages.
- Supabase Auth, Postgres, RLS, and server-authoritative transitions.
- SQLite local active-workout drafts.
- Online session start; offline continuation; online authoritative finalization.
- Vercel static dashboard hosting.
- Local, staging, and production Supabase environments.
- Pro managed daily backups plus encrypted independent logical exports.

## MVP scope

- provisioned account sign-in;
- private profiles and reward timezone;
- reviewed versioned routines;
- weekly plan materialization and normalized allocations;
- schedule swaps and free-swap wallet;
- Android workout execution, timers, set logging, and local draft recovery;
- rank, XP, PR, consistency, penalties, corrections, and weekly finalization;
- basic progression recommendations;
- transparent history;
- Flutter Web deployment and private Android release.

## Explicit non-goals

- public signup or social login;
- iOS initial release;
- coaches, organizations, or public profiles;
- social feeds, chat, or leaderboards;
- nutrition or sleep tracking;
- payments or subscriptions;
- wearables;
- automatic medical decisions;
- microservices;
- client-authoritative rewards;
- production analytics beyond essential operational error evidence;
- historical recalculation with current formulas.

## Current maturity

```text
Phase 0: complete
Phase 1: ready, not started
Runtime: none
External infrastructure: none
```

## Implementation success boundary

The first task is successful only when the repository has reproducible Flutter and local Supabase scaffolding, exact toolchain pins, passing tests and builds, CI, no secrets, and accurate documentation—without falsely implementing product features.
