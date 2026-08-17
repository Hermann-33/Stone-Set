# Stone Set Latest Handoff

Updated: 2026-08-17

## Current engineering result

```text
TASK-IMP-017 — Guidance publication propagation audit and E2E hardening
PR #58 — DRAFT / UNMERGED
branch codex/task-imp-017-guidance-propagation-e2e
status PARTIAL — automated final gate and owner pre-merge acceptance remain
```

The reported guidance-update problem has been traced across the dashboard, publication RPCs, workout snapshot creation and mobile loader.

Read-only production inspection on 2026-08-17 found:

```text
guidance_revisions       25
max guidance version     1
guidance_media_manifests 25
guidance_drafts          2
published YouTube refs   0
```

Smith Squat has unpublished text changes relative to published v1. Both remaining production drafts require genuine YouTube preview validation. There is no published v2 for Android to consume.

## PR #58 behavior

Dashboard:

- `Saved` is now `Draft saved`;
- an above-fold status explains that a saved draft is not live in Android;
- Publish is disabled while authoritative media is loading, saving, conflicted, offline or failed;
- any YouTube reference must be genuinely validated and no older than the server's one-hour publication window;
- preview-required, unavailable and expired validation are blocked before publication reservation;
- successful publication semantics and active-session pinning are explicit in the confirmation flow;
- a failed publication cannot masquerade as app activation.

Server/mobile regression protection:

- `supabase/tests/database/guidance_publication_activation_e2e.test.sql` publishes v1 through the real atomic RPC path, starts a real workout through `public.start_workout_v1(uuid)`, publishes v2, proves the original session remains v1, then starts the next real workout and proves it resolves v2;
- mobile loader tests prove the client requests the exact guidance/media revision pinned by the workout snapshot and only consumes a newer revision when the server snapshot pins it.

A focused Flutter dashboard regression run for the final YouTube publication preflight passed after adding unavailable/expired-validation cases. Final Foundation CI must still pass on the clean documentation-synchronized PR head.

## Owner verification boundary

Do not merge PR #58 before the requested owner test.

Vercel PR/feature preview deployments are intentionally disabled under ADR-0014/TASK-IMP-016. `stone-set.vercel.app` is production main and does not contain PR #58 before merge. Pre-merge dashboard testing therefore requires an explicit local/branch build against an approved test environment.

Owner acceptance should verify:

1. edit guidance text/media and Save; dashboard says `Draft saved`, and no immutable app version is implied;
2. preview-required, unavailable or expired YouTube evidence prevents Publish;
3. genuine playable validation enables Publish only within the one-hour window;
4. successful Publish creates a later immutable guidance version;
5. a workout already started before publication remains on its old pinned revision;
6. the next newly started workout receives the newly published text/media;
7. rank, RR, schedule, swaps and workout history are unchanged.

Exact next action: finish the final clean Foundation CI run for PR #58, then perform the owner pre-merge verification above. Merge only after owner acceptance.

## Latest deployed runtime baseline

TASK-IMP-015 remains the latest fully merged/deployed runtime result:

```text
TASK-IMP-015 — Week day detail, deliberate swaps, reliable workout start
ADR-0012
PR #56 — MERGED
main d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
Foundation CI #414 / 31782008565 — PASS
production Supabase 20260814080728_training_week_item_detail
private Android #73 / 31782531713 — PASS
release 0.1.0 (1000073), Firebase 3evhve7djjghg
```

TASK-IMP-017 is not yet production-live.

## Independent residuals

- TASK-IMP-017: final Foundation CI plus owner pre-merge E2E acceptance.
- TASK-IMP-014: production owner guidance drafts still require genuine preview validation and explicit Publish; never fabricate preview evidence or auto-publish content.
- TASK-IMP-013A: real-device airplane-mode acceptance remains separate.
- TASK-IMP-012: signing-key backup/phone confirmation remains separate.
- Do not rewrite historical swaps, discard pending workout data, mutate started-workout guidance snapshots, fabricate media evidence or alter rank/RR/scheduling foundations.
