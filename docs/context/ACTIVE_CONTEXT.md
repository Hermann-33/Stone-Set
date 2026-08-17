# Stone Set Active Context

Updated: 2026-08-17

## Current position

Stone Set is a private hypertrophy training application with an Android Flutter client, Vercel-hosted Flutter Web dashboard, Supabase Auth/Postgres/Storage backend and private Android Firebase distribution.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries, immutable history and server authority.

## TASK-IMP-017 — ready for owner verification on PR #58

TASK-IMP-017 audits the reported guidance-update propagation failure across dashboard draft save, media/YouTube publication, immutable guidance revision activation, workout snapshot creation and mobile pinned-revision loading.

Read-only production inspection on 2026-08-17 proved the Android client was not ignoring a newer published revision: production still contained 25 immutable guidance revisions with maximum version 1 and 25 finalized media manifests. Two owner guidance drafts remained unpublished. Smith Squat contained text changes relative to published v1; both remaining drafts had YouTube references requiring genuine preview validation.

PR #58 now hardens the full boundary:

- dashboard save state is explicitly `Draft saved`, not live/published;
- the publication boundary is surfaced above the fold;
- Publish is disabled unless media state is ready and any YouTube reference has genuine non-expired validation;
- unavailable, preview-required and validation-older-than-one-hour YouTube states are rejected before reservation, matching the authoritative server publication gate;
- Publish confirmation explains that only a successful immutable publication changes app guidance;
- already-started workouts remain pinned to their existing revision;
- the next newly started workout resolves the latest finalized published revision;
- mobile loader regression coverage requires exact server-pinned guidance/media IDs rather than a client-side latest lookup;
- database integration coverage drives the real publication RPCs and real `public.start_workout_v1(uuid)` path across v1 -> first workout -> v2 -> second workout.

TASK-IMP-017 is **not merged and not production-live**. Final Foundation CI on the clean PR head must pass, then the owner performs the requested pre-merge manual verification. Vercel preview builds remain intentionally suppressed under TASK-IMP-016, so pre-merge dashboard verification must use an explicit local/branch build rather than assuming `stone-set.vercel.app` contains PR #58.

Exact next action after clean CI: owner manually verifies draft-save versus Publish behavior, genuine YouTube validation blocking, successful publication, active-workout pinning and next-workout activation on the PR branch/local environment; merge only after that owner acceptance.

## TASK-IMP-015 — complete and deployed

```text
Task          TASK-IMP-015 — Week day detail, deliberate swaps, reliable workout start
ADR           ADR-0012
PR            #56 — MERGED
main          d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
main CI       Foundation CI #414 / 31782008565 — PASS
status        COMPLETE
```

### User-visible behavior

- tap any Monday-Sunday Week item to open read-only day detail;
- workout days show every prescribed exercise, sets/reps/RIR/rest/notes and guidance access;
- rest days explicitly show no prescribed exercises;
- ordinary taps never select swap days;
- long-press two open days to select a swap, review the preview and explicitly confirm;
- swap confirmation is single-flight and clears selection immediately after server acceptance;
- a different synchronized stale local workout no longer blocks today's requested workout start;
- a different pending local workout must synchronize before switching, and failed synchronization preserves the old draft.

### Production backend

Tracked migration:

```text
supabase/migrations/20260813042000_training_week_item_detail.sql
```

Production history:

```text
20260814080728_training_week_item_detail
```

`public.get_training_week_item_detail_v1(uuid)` is a security-invoker, owner-scoped authenticated read RPC. Anonymous execution is denied. It uses a left join so rest items remain inspectable and resolves latest finalized published guidance only for read-only display; materialized routine/week history is not rewritten.

Post-deploy counts remained unchanged:

```text
training_week_items  7
workout_sessions     2
weekly_swaps         2
```

### Android distribution

```text
workflow run       Private Android Distribution #73 / 31782531713 — PASS
commit             d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
application ID     io.github.hermann33.stoneset
version/build      0.1.0 (1000073)
Firebase release   3evhve7djjghg
tester group       stone-set-testers
```

The permanent signer, application ID, version identity and APK integrity were verified before Firebase distribution.

Vercel correctly ignored/canceled the mobile/database-only main event (`dpl_D6RgWmX6ucoy9j8eWrmfCujch1wy`), so no dashboard build quota was consumed.

## TASK-IMP-014 — independent owner content action remains

Guidance/media publication freshness engineering is deployed, but the two affected production owner drafts still require genuine YouTube preview evidence and explicit Publish. Do not fabricate preview validation or owner publication.

For an affected production draft: open it at `stone-set.vercel.app`, play the YouTube preview until validation succeeds, then Publish within the one-hour validation window. A newly started workout receives the newest published bundle; an already-started workout remains pinned. TASK-IMP-017 changes are not present on production until PR #58 is accepted and merged.

## Preserved boundaries

- routine versions/prescriptions/materialized weeks remain immutable historical evidence;
- published guidance/media revisions remain immutable;
- started workout snapshots remain immutable;
- online authoritative workout start remains required;
- local pending workout edits are never silently discarded;
- `rank-v6`, `schedule-v3`, reward authority, Android application ID/signing and Firebase architecture are unchanged;
- the historical double swap was not silently deleted or refunded;
- Save does not auto-publish guidance and genuine YouTube preview evidence is never fabricated.

## Independent residuals

- TASK-IMP-017 owner pre-merge E2E acceptance remains required before merge.
- TASK-IMP-013A real-device airplane-mode acceptance remains separate.
- TASK-IMP-012 signing-key backup/phone confirmation remains separate.
- TASK-IMP-014 production owner preview/publish remains separate.

## Production topology

```text
dashboard            https://stone-set.vercel.app
Supabase project      pjltldrernuvrjsnmcqg
Firebase project      stone-set
Android Firebase app  1:263990431224:android:fe2bf52c3f622047225a0d
tester group          stone-set-testers
```

Direct owner routine publication remains authoritative: `Create/Edit → Save → Validate → Publish`. Do not reintroduce the retired independent review/approval lifecycle without a new explicit decision.
