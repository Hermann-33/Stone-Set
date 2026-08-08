# Stone Set Project Brief

Updated: 2026-08-08
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

1. Both the Android app and Flutter Web dashboard provide dedicated login pages.
2. The same provisioned username/password account works on both clients.
3. A user manages routines and exercise guidance through the Flutter Web dashboard.
4. Each workout day has a brief purpose, targeted muscles, estimated duration, and equipment summary.
5. Each exercise can provide explanation, primary and secondary muscles, setup and execution steps, technique cues, common mistakes, safety notes, ordered images, and one optional YouTube demonstration.
6. Exercise images are uploaded and managed by the user inside Stone Set.
7. Server validation and an independent reviewer approve or reject the exact reward-bearing routine submission.
8. A published approved routine becomes active only for a future unlocked week.
9. The Android app presents the week, workout guidance, exercise instructions, timers, and set logging while surviving temporary network loss.
10. Supabase authoritatively validates identity, ownership, completion, rewards, swaps, penalties, consistency, corrections, and history.
11. Supported 4-, 5-, and 6-day routines have equal maximum weekly RR opportunity.
12. Rest items receive lower automatic rewards without fake check-ins.
13. Users can inspect exercise guidance, routine, workout, rank, wallet, correction, and configuration history.

## Authentication and sessions

`docs/product/AUTHENTICATION_AND_SESSION_UX.md` defines the accepted login and session baseline.

Core behavior:

- dedicated mobile and dashboard login surfaces;
- username and password fields;
- shared provisioned accounts across both clients;
- Supabase Auth owns credentials and sessions;
- no public signup, social login, or anonymous mode;
- first login requires changing the operator-generated temporary password;
- valid sessions persist and protected routes require authentication;
- generic login errors do not reveal whether an account exists;
- dashboard logout clears private browser state;
- mobile logout preserves or explicitly resolves unsynchronized workout drafts;
- password recovery is operator-managed in MVP.

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

- mobile login page;
- web dashboard login page;
- provisioned account sign-in and first-login password change;
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

- public signup, public invitations, or social login;
- self-service email password recovery in MVP;
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
Phase 1: complete and merged
Phase 2A: complete and merged through pull request #7
Phase 2B: complete and merged through pull request #10
Phase 2C: complete and merged through pull request #12
Phase 3A: complete and merged through pull request #14
Runtime: identity/session, fixture-only mobile presentation, adaptive dashboard and exercise/guidance authoring implemented
External infrastructure: none
```

## Implementation success boundary

The foundation, identity/session, fixture-only mobile/dashboard presentation and owner-scoped
exercise/guidance vertical are complete and merged. `TASK-IMP-003B` is the next approved packet. It
must implement only private exercise media and YouTube with Storage/database/client/security
evidence, without adding routines, scoring or deployment. `TASK-IMP-003C` remains blocked until
003B completes and merges.
