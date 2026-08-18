# TASK-IMP-017 — Guidance publication propagation audit and E2E hardening

**Status:** Ready for owner verification on PR #58; not merged

## Problem

Owner guidance edits can be saved in the dashboard without becoming visible in Android. Production audit on 2026-08-17 proved this is not a mobile cache/read failure: production contained 25 immutable guidance revisions with maximum version 1, while two mutable guidance drafts remained unpublished. Smith Squat contained text changes relative to published v1. Both remaining drafts had YouTube references in `preview_required` state.

The dashboard previously labeled an authoritative draft save as `Saved`, left the top-level Publish action enabled without fully reflecting the authoritative YouTube/media publication gate, and surfaced publication failure only in the lower media editor. That UX made draft persistence look like app activation.

## Accepted boundary

This task does not change ADR-0011 or ADR-0008 behavior:

- Save persists the mutable owner draft only.
- Publish explicitly creates/finalizes an immutable guidance/media bundle.
- YouTube preview evidence must be genuine and remains valid for one hour.
- A workout already started remains pinned to its immutable guidance revision.
- The next newly started workout resolves the latest finalized published revision.
- Mobile must load the exact revision pinned by the workout snapshot; it must not perform a client-side latest lookup.

## Scope

- Make draft-save versus app-publication state explicit and prominent in the dashboard guidance editor.
- Disable Publish until the loaded media draft is truthfully publishable.
- Mirror the authoritative YouTube gate before reservation: block `preview_required`, unavailable preview state, missing validation evidence, and validation older than one hour.
- Explain activation semantics and active-session pinning in the Publish confirmation.
- Surface a top-level failure result if publication returns without an immutable result.
- Preserve 200% text accessibility by keeping publication status first in the scrollable editor instead of adding an unbounded fixed-height header.
- Add dashboard widget/controller regression coverage for the publication boundary.
- Add database integration coverage that drives the real atomic publication RPC twice and proves old/new workout snapshots resolve v1/v2 correctly through `public.start_workout_v1(uuid)`.
- Add mobile regression coverage proving the guidance loader requests exactly the server-pinned revision and rejects mismatched bundles.

## Exclusions

- No auto-publication on Save.
- No fabricated YouTube preview validation.
- No mutation of already-started workouts.
- No routine, rank, RR, consistency, penalty, scheduling, weekly-swap, or monthly free-swap changes.
- No signer, Android application-ID, Firebase, or release-channel changes.
- No production owner content publication as part of engineering verification.

## Production evidence

Read-only production inspection of Supabase project `pjltldrernuvrjsnmcqg` on 2026-08-17 found:

```text
guidance_revisions       25
max guidance version     1
guidance_media_manifests 25
guidance_drafts          2
published YouTube refs   0
```

Draft evidence:

- Smith Squat: draft revision 3; text differs from published v1; YouTube `preview_required`.
- Hanging Knee Raise: draft revision 1; YouTube `preview_required`.

Therefore Android cannot display a v2 until the owner completes genuine preview validation where required and Publish succeeds.

## Implemented verification coverage

Dashboard:

- saved draft is labeled as draft, not live app state;
- preview-required YouTube blocks Publish before confirmation;
- unavailable and validation-older-than-one-hour evidence are rejected by controller preflight;
- expired validation blocks Publish before confirmation;
- confirmation explains next-workout activation and active-session pinning;
- the editor remains responsive/accessibility-safe at 200% text.

Database:

- first real atomic guidance/media publication creates v1;
- first real authenticated workout start pins v1;
- second real atomic publication creates v2;
- the already-started workout remains v1;
- the next real authenticated workout start resolves v2;
- fixture behavior is day-independent and preserves the non-self-review invariant.

Mobile:

- loader requests exact pinned guidance/media IDs;
- a newer revision is consumed only when the workout snapshot pins it;
- mismatched guidance/media remains a hard failure.

## Automated verification evidence

Clean implementation head:

```text
0bb4bbe3bb2076659984886ce7002b9e6eb9af91
```

Foundation gate:

```text
Foundation CI #461 / 32026665136 — PASS
```

The run passed:

- repository/docs hygiene and changed-path classification;
- generated Riverpod/typed-route verification;
- canonical formatting and strict static analysis;
- mobile tests;
- dashboard unit/widget tests, including the 200% text regression;
- dashboard Chrome tests;
- Android release APK build and rank-asset verification;
- dashboard release Web build and privileged-credential scan;
- clean-tree verification;
- Local Supabase start/reset, Auth/private Storage lifecycle, full pgTAP including `guidance_publication_activation_e2e.test.sql`, and database lint.

## Owner pre-merge acceptance

PR/feature Vercel previews are intentionally suppressed under ADR-0014/TASK-IMP-016, so `stone-set.vercel.app` cannot be used to prove PR #58 before merge. Use an explicit local/branch dashboard build against an approved test environment.

Verify:

1. edit text/media and Save: state is `Draft saved`, not live;
2. preview-required/unavailable/expired YouTube evidence blocks Publish;
3. genuine playable validation permits Publish only inside the one-hour window;
4. successful Publish creates a later immutable version;
5. an already-started workout stays on its prior revision;
6. the next newly started workout receives the later text/media revision;
7. rank/RR/schedule/swap/history behavior is unchanged.

## Completion rule

The current task verdict remains `PARTIAL` because PR #58 is unmerged and owner pre-merge acceptance is outstanding. The automated engineering gate is complete. Engineering can be `COMPLETE` only after owner acceptance succeeds, the implementation is merged, and repository completion documentation is synchronized. TASK-IMP-014 production owner-content activation remains a separate residual until genuine YouTube preview validation and explicit Publish create the first production v2.
