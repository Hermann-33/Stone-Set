# TASK-IMP-017 — Guidance publication propagation audit and E2E hardening

**Status:** In progress on PR #58

## Problem

Owner guidance edits can be saved in the dashboard without becoming visible in Android. Production audit on 2026-08-17 proved this is not a mobile cache/read failure: production contained 25 immutable guidance revisions with maximum version 1, while two mutable guidance drafts remained unpublished. Smith Squat contained text changes relative to published v1. Both remaining drafts had YouTube references in `preview_required` state.

The dashboard previously labeled an authoritative draft save as `Saved`, left the top-level Publish action enabled without reflecting the YouTube/media publication gate, and surfaced publication failure only in the lower media editor. That UX made draft persistence look like app activation.

## Accepted boundary

This task does not change ADR-0011 or ADR-0008 behavior:

- Save persists the mutable owner draft only.
- Publish explicitly creates/finalizes an immutable guidance/media bundle.
- YouTube preview evidence must be genuine and remains valid for one hour.
- A workout already started remains pinned to its immutable guidance revision.
- The next newly started workout resolves the latest finalized published revision.
- Mobile must load the exact revision pinned by the workout snapshot; it must not perform a client-side latest lookup.

## Scope

- Make draft-save versus app-publication state explicit above the fold in the dashboard guidance editor.
- Disable Publish until the loaded media draft is in a truthful publishable state; specifically surface `preview_required` before the owner enters the confirmation flow.
- Explain activation semantics and active-session pinning in the Publish confirmation.
- Surface a top-level failure result if publication returns without an immutable result.
- Add dashboard widget regression coverage for the publication boundary.
- Add database integration coverage that drives the real atomic publication RPC twice and proves old/new workout snapshots resolve v1/v2 correctly.
- Add mobile regression coverage proving the guidance loader requests exactly the server-pinned revision and rejects mismatched bundles.

## Exclusions

- No auto-publication on Save.
- No fabricated YouTube preview validation.
- No mutation of already-started workouts.
- No routine, rank, RR, consistency, penalty, scheduling, weekly-swap, or monthly free-swap changes.
- No signer, Android application-ID, Firebase, or release-channel changes.

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

## Verification gate

- Foundation CI formatting/analyzer gates.
- Dashboard widget tests including publication-boundary copy and preview-required Publish blocking.
- Mobile loader tests for exact pinned revision and mismatch rejection.
- Local Supabase CI reset, pgTAP suite, database lint, including `guidance_publication_activation_e2e.test.sql`.
- PR diff/security review.
- Production content publication remains owner-controlled and is not manufactured by this task.

## Completion rule

Engineering can be `COMPLETE` only after PR checks pass and the implementation is merged. The owner-content activation remains a separate residual from TASK-IMP-014 until genuine YouTube preview validation and Publish create the first production v2.