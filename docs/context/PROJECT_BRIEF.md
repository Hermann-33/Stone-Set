# Stone Set Project Brief

Updated: 2026-08-04
Status: `IMPLEMENTATION-READY PLANNING BASELINE`

## Product purpose

Stone Set is a private muscle-growth training system for two initial users with independently managed routines and one normalized rank economy.

It makes structured hypertrophy routines executable, understandable, trackable, adaptable, and motivating while preventing routine frequency, trivial prescriptions, random extra volume, or client manipulation from producing unfair rank progress.

## Users

- Two administratively provisioned initial users.
- No public registration in MVP.
- Data model supports later users without redesign.
- Each user owns their private routine, exercise library, guidance media, schedule, workout logs, rank, wallet, and history.
- One user may review another user's reward-bearing routine submission but may not edit it.

## Accepted user outcomes

1. A user manages routines and exercise guidance through the Flutter Web dashboard.
2. Each workout day has a brief purpose, targeted muscles, estimated duration, and equipment summary.
3. Each exercise can provide explanation, primary and secondary muscles, setup and execution steps, technique cues, common mistakes, safety notes, ordered images, and one optional YouTube demonstration.
4. Exercise images are uploaded and managed by the user inside Stone Set.
5. Server validation and an independent reviewer approve or reject the exact reward-bearing routine submission.
6. A published approved routine becomes active only for a future unlocked week.
7. The Android app presents the week, workout guidance, exercise instructions, timers, and set logging while surviving temporary network loss.
8. Supabase authoritatively validates completion, rewards, swaps, penalties, consistency, corrections, and history.
9. Supported 4-, 5-, and 6-day routines have equal maximum weekly RR opportunity.
10. Rest items receive lower automatic rewards without fake check-ins.
11. Users can inspect exercise guidance, routine, workout, rank, wallet, correction, and configuration history.

## Exercise guidance and media

`docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md` defines the accepted guidance baseline.

Core behavior:

- exercise content is user-owned;
- published guidance revisions are immutable;
- materialized weeks pin the guidance revision they use;
- content-only guidance changes may be self-published after validation;
- prescription or PR-comparability changes remain reviewed routine changes;
- 0–6 private images per exercise revision;
- JPEG, PNG, and static WebP only;
- maximum processed image size of 5 MB;
- required alt text and stripped EXIF/GPS metadata;
- one optional normalized YouTube video reference per exercise revision;
- official embedded YouTube playback with no autoplay, download, background play, or reward;
- offline workout guidance text and prefetched images, but online-only video.

Images are product-hosted in private Supabase Storage. They are not embedded in Vercel deployment output. Videos remain hosted by YouTube.

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
- Guidance viewing has no reward effect.

## Accepted architecture

- Flutter Android mobile application.
- Separate Flutter Web dashboard.
- Shared Dart packages.
- Supabase Auth, Postgres, Storage, RLS, and server-authoritative transitions.
- SQLite local active-workout drafts and active-session guidance cache.
- Online session start; offline continuation; online authoritative finalization.
- Official YouTube IFrame playback in an Android WebView.
- Vercel static dashboard hosting.
- Local, staging, and production Supabase environments.
- Pro managed daily database backups plus encrypted independent database and Storage exports.

## MVP scope

- provisioned account sign-in;
- private profiles and reward timezone;
- user-owned exercise library and versioned guidance;
- private exercise image upload;
- YouTube demonstration preview and playback;
- reviewed versioned routines;
- weekly plan materialization and normalized allocations;
- schedule swaps and free-swap wallet;
- Android workout execution, guidance, timers, set logging, and local recovery;
- rank, XP, PR, consistency, penalties, corrections, and weekly finalization;
- basic progression recommendations;
- transparent history;
- Flutter Web deployment and private Android release.

## Explicit non-goals

- public signup or social login;
- iOS initial release;
- coaches, organizations, or public profiles;
- shared public exercise gallery;
- social feeds, chat, or leaderboards;
- direct video uploads or non-YouTube video providers;
- YouTube search inside Stone Set;
- rewards for viewing media;
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

The first task is successful only when the repository has reproducible Flutter and local Supabase scaffolding, exact toolchain pins, passing tests and builds, CI, no secrets, and accurate documentation—without implementing the planned product or media features.
