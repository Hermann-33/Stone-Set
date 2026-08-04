# Stone Set Active Context

Updated: 2026-08-05

## Current state

Stone Set is a private two-user muscle-growth training system with accepted product, authentication, architecture, media, operational, rank-asset, mobile-UI, and implementation-planning baselines.

The repository contains accepted documentation plus a curated, reproducibly generated `rank-v6` emblem set under `assets/ranks/`. There is no Flutter project, Supabase project, schema, Storage bucket, account, Vercel project, deployment, product runtime, or foundation CI.

## Active phase

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

`TASK-PD-011` defines the Android mobile Home hierarchy, Stone Set design direction, authenticated mobile shell, full-circle rank-progress hero, today's workout action states, motion/accessibility contract, and future implementation packet. It does not change the approved foundation scope or start application implementation.

## Accepted authentication baseline

- Both clients have dedicated login pages.
- The same two provisioned accounts work on mobile and dashboard.
- User-visible credentials are username and password.
- Supabase Auth uses an operator-provisioned internal email alias derived from the normalized username.
- Public signup, social login, anonymous access, and self-service recovery are excluded from MVP.
- First login requires changing the temporary password.
- Valid sessions persist and protected routes require authentication.
- Login failures are generic and do not reveal account existence.
- Dashboard logout clears private browser state.
- Mobile logout must resolve unsynchronized workout data before clearing private state.
- Expired mobile sessions quarantine unsynchronized drafts until the same account reauthenticates.

## Accepted mobile UI baseline

- The authenticated Android shell uses Home, Week, History, and Profile destinations.
- Home is the daily command surface.
- The current rank emblem is centered as the dominant first-viewport element.
- A complete `360°` inactive circular track surrounds the emblem and remains visible at `0%`.
- The authoritative active arc begins at 12 o'clock, advances clockwise, and becomes a seamless full circle at `100%`.
- The previous top-gap ring concept is superseded.
- The hero exposes current RR, percentage, next rank, and Adonis max-rank state in text and semantics.
- Solid active progress represents finalized authoritative RR only.
- Provisional RR uses a distinct secondary treatment and does not change the authoritative emblem.
- Pending local synchronization does not move the authoritative active arc.
- Home contains today's workout/rest card, seven-day summary, lifetime XP, multiplier, free-swap balance, and conditional synchronization/provisional banners.
- Today's scheduled workout exposes `Start workout`, `Continue workout`, `Sync workout`, or `View result` according to state.
- `Start workout` becomes the Home entry point for logging sets, repetitions, load, RIR, rest, and completion when workout execution is implemented.
- A programmed rest day does not expose a rewarded unscheduled workout or manual completion action.
- Motion is event-driven and covers first render, RR increase/decrease, rank-up, rank-down, palette change, and reduced-motion substitution.
- No continuous idle animation is allowed.
- The supplied Fortnite screenshot is inspiration only; its screenshot, artwork, exact styling, sound, particles, and animation choreography are not copied or committed.
- `TASK-IMP-002B` implements the fixture-driven UI after foundation and authentication.
- Real weekly-plan data binds in `TASK-IMP-004`, workout logging and synchronization in `TASK-IMP-005A`, and authoritative rank events in `TASK-IMP-006`.

## Accepted product baseline

- Initial provisioned users: 2; account count not hardcoded.
- User-owned draft routines and immutable published versions.
- Independent review required before a routine becomes reward eligible.
- `routine-validator-v1` defines hard structural limits and review evidence.
- Supported routines: 4–6 workout days, 1–3 rest days, 7 total plan items.
- Dashboard-managed workout-day summaries and user-owned exercise guidance.
- Published guidance revisions are immutable and pinned to materialized weeks.
- Guidance contains explanation, muscles, instructions, ordered images, and one optional YouTube video.
- Viewing guidance never awards RR or XP and is never required for completion.
- Active rank configuration: `rank-v6`.
- Curated rank-emblem asset set: `stone-set-ranks-v1`, 20 transparent 256 × 256 PNGs; not yet integrated into either client.
- Active scheduling configuration: `schedule-v3`.
- Highest rank: Adonis at `5,500 RR`.
- Weekly daily-item RR pools: 110, 167, 220, and 277.
- Workout/rest allocation weight: 4:1.
- Weekly ordinary base-XP item pool: 110.
- Weekly missed-workout penalty pool: 95 RR.
- Maximum rewarded PRs: 2 per week.
- Failed week: unprotected workout-completion ratio below 60%.
- Consistency multipliers: 1.00x, 1.50x, 2.00x, and 2.50x at Weeks 0, 5, 10, and 15.
- Maximum swaps: 2 per week.
- Monthly free-swap grant: 2 non-expiring, uncapped credits.
- Unscheduled extra workouts and sets earn no RR or XP.

## Accepted architecture

### Clients

- Flutter Android mobile application with native login and authenticated routing.
- Separate Flutter Web management dashboard with responsive `/login` and protected routes.
- Shared Dart packages in a native Pub workspace.
- Initial mobile target: Android API 24+ only.
- iOS deferred until a real user need, macOS/Xcode environment, signing, and tests are accepted.

### Exercise guidance and media

- The dashboard is the primary routine and exercise-content management surface.
- Exercise guidance is user-owned and versioned separately from reward-bearing prescriptions.
- Private exercise images are stored in Supabase Storage, not the Vercel static build.
- Images are immutable, owner-scoped, MIME-restricted, size-limited, metadata-stripped, and protected by Storage RLS.
- The app uses the official YouTube IFrame Player API in an OS-provided Android WebView.
- YouTube playback is user-initiated, online-only, and never downloaded, cached, background-played, or rewarded.
- Workout-start snapshots include pinned guidance identifiers, text, image references, and normalized YouTube references.
- Guidance text and successfully prefetched images remain available for the active offline session.

### Backend and authorization

- Supabase Auth manages credentials, sessions, identity, and token refresh.
- Supabase Postgres is authoritative for profiles, product state, and media metadata.
- Supabase Storage is authoritative for exercise image bytes.
- RLS isolates user-owned database rows and Storage objects.
- User-editable profile fields do not grant authorization.
- Server operations authoritatively perform routine publication, schedule materialization, swaps, rewards, penalties, wallet changes, workout start, submission, and finalization.
- Clients never contain service-role or database secrets and never set authoritative scores.

### Local and offline behavior

- Mobile local drafts use SQLite through `sqflite`.
- Starting a workout requires connectivity so the server can validate and lock the item.
- A server-started workout may continue offline with transactional autosave and an idempotent outbox.
- Finishing offline creates `pending_submission`; no RR or XP is committed until server validation succeeds.
- Started sessions receive a 24-hour post-week synchronization grace.
- Logout with unsynchronized data requires sync, cancellation, or explicit discard.
- Cached private guidance media is removed under account logout and cache-cleanup rules.

### Hosting and operations

- Flutter Web dashboard target: Vercel static deployment.
- GitHub Actions will build and test an exact artifact before preview and production promotion.
- Preview deployments connect to staging data and staging media, never production.
- Environments: local, hosted staging, hosted production.
- Production Supabase target: Pro with managed daily database backups and seven-day retention.
- Independent encrypted weekly logical database exports and Storage object exports are retained as 12 weekly and 12 month-end copies.
- Recovery targets: RPO 24 hours; RTO 4 hours for the expected small dataset.
- Restore drills must reconcile database media metadata with the restored Storage object manifest.
- Two distinct Supabase Owner accounts, MFA enforcement, backup factors, and least-privileged collaborators.

## Accepted decisions

- ADR-0001: Flutter mobile and Flutter Web clients.
- ADR-0002: Supabase backend, Auth, Postgres, and RLS.
- ADR-0003: SQLite drafts and online authoritative finalization.
- ADR-0004: Android-first release and Vercel dashboard hosting.
- ADR-0005: Supabase production operations and recovery.
- ADR-0006: private exercise-media Storage and YouTube embedding.
- No new ADR for `TASK-PD-011`; the mobile UI baseline is a reversible product-interface decision inside the accepted Flutter architecture.

## Implemented versus documented

### Documented and accepted

Authentication UX, sessions, product rules, mobile Home and rank-progress UI, workout and exercise guidance, media ownership, workflow, architecture, security, offline behavior, release targets, operations, phased plan, and the first implementation packet.

### Implemented

Repository documentation, Git history, and the curated `stone-set-ranks-v1` PNG asset set with its manifest, provenance, review sheet, generator, and verification workflow. No application consumes the assets and no mobile UI exists yet.

## Planned packet sequence

```text
TASK-IMP-001 — Foundation — APPROVED, next
TASK-IMP-002A — Identity/login/sessions — PLANNED
TASK-IMP-002B — Mobile design system/Home/rank hero — PLANNED, blocked by 001 and 002A
```

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
packet: docs/tasks/TASK-IMP-001.md
```

The task creates scaffolding, local Supabase configuration, tests, builds, and CI only.

## Do-not-touch boundaries

- Do not claim Phase 1 has started until the task branch contains implementation work.
- Do not create remote Supabase, Storage, or Vercel infrastructure in `TASK-IMP-001`.
- Do not add real keys, accounts, project references, signing secrets, media, or personal data.
- Do not implement login, authentication, mobile Home feature UI, product schema, routine management, exercise media, YouTube playback, workouts, SQLite drafts, rank, wallet, or deployment in the foundation task.
- Do not execute `TASK-IMP-002B` before foundation and authentication are complete and its packet is explicitly approved.
- Do not change `rank-v6`, `schedule-v3`, Adonis at `5,500 RR`, the 5/10/15 multiplier ladder, swap limit, or bankable credits.
- Do not store passwords in application tables or expose privileged credentials to clients.
