# Stone Set Active Context

Updated: 2026-08-13

## Current position

Stone Set is a private hypertrophy training application with:

- Android Flutter client;
- Flutter Web dashboard hosted on Vercel;
- Supabase Auth/Postgres/Storage backend;
- private Android updates through Firebase App Distribution.

Implementation mode remains **FAST PRIVATE RELEASE**. Preserve Auth/RLS/private-data boundaries, immutable history, and server authority without adding unnecessary enterprise process.

## Active bounded task

```text
TASK-IMP-014 — Guidance/media publication freshness
ADR: ADR-0011
branch: agent/task-imp-014-guidance-publication-freshness
PR: #48
status: PARTIAL — implementation candidate green; merge/deployment pending
```

Exact implementation candidate:

```text
c82b33f7fda5edc515d16133a3ddf28fb91ea6d5
```

Foundation CI `31628667732` (#382), attempt 2, passed every applicable lane: repository/docs, generated sources, formatting, strict analysis, dashboard goldens, dashboard unit/widget tests, Chrome tests, Web release build/credential review, Local Supabase reset, Auth/Storage lifecycle checks, pgTAP and database lint. The first Local Supabase attempt hit external Docker/Supabase rate limiting/upstream HTTP 502 during reset; retrying only that failed job passed on the identical code head.

## TASK-IMP-014 root cause

Production read-only verification showed:

```text
published guidance revisions       25
highest guidance version           1
editable guidance drafts            2
drafts with unpublished text        1
draft YouTube references            2
YouTube status              preview_required (2)
```

The dashboard publication path was correctly being rejected by the server because current YouTube draft references lacked valid successful-preview evidence, but the dashboard collapsed that specific condition into a generic media error. Therefore the owner could edit text/media and attempt Publish without receiving the actual remediation, while no immutable guidance v2 was created.

A second independent activation defect existed in workout start: `start_workout_v1` created workout-session exercise snapshots from the guidance revision pinned in the immutable routine prescription. Even after a successful future v2 publication, a new workout would therefore continue to receive v1 indefinitely.

## Implemented repair

### Dashboard

- loaded `preview_required` YouTube drafts fail before publication reservation with explicit remediation;
- server-side `previewRequired`, including expired one-hour preview evidence, maps to the same message;
- the existing real YouTube IFrame playable callback remains the only path that records validation;
- no preview evidence or publication is fabricated.

### Server

Migration `20260812180500_latest_published_guidance_for_new_workouts.sql` adds a private insert-time resolver on `workout_session_exercises`.

For a **new** workout-session exercise snapshot, the server selects the latest owner-matching published guidance revision for that exercise that has a finalized media manifest. The routine-prescription revision remains fallback only when no eligible bundle exists.

This preserves:

- immutable routine versions/prescriptions/materialized week evidence;
- immutable published guidance revisions;
- an already-started workout's exact guidance snapshot;
- Android's deterministic exact-revision guidance/media lookup;
- online authoritative workout start.

A later publication affects the next newly started workout containing that exercise, not an already-started session.

## Exact next engineering action

1. finish TASK-IMP-014 context/audit documentation on the branch;
2. obtain Foundation CI success on that final documentation head;
3. mark PR #48 ready and merge only that exact green head;
4. verify Foundation CI on the exact resulting `main` SHA;
5. apply the exact committed migration through production Supabase migration history and verify the trigger/function without modifying existing sessions/drafts;
6. verify the production Vercel dashboard is deployed from the merged main revision.

After engineering/deployment, the owner must still perform the genuine YouTube preview for affected drafts and click Publish. Engineering must not mark a preview validated or publish owner content automatically.

## Recent completed mobile slice

TASK-IMP-013A merged through PR #47 at main commit:

```text
ec8fb9324ecadc90654e011f242e523e8f517ca0
```

Exact-main Foundation CI #372 (`31623712890`) passed. TASK-IMP-013A added the owner-scoped offline-first cached mobile shell, central synchronization, Home pull-to-refresh and mounted rank refresh without changing the online workout-start boundary.

Its independent real-device airplane-mode acceptance remains an external physical gate; do not conflate that residual with TASK-IMP-014.

## Preserved authority boundaries

- Supabase remains authoritative for authentication, routines, guidance publication, workout start/finalization, schedule/swaps and reward/rank state.
- Storage remains private; Postgres owns media metadata/publication manifests.
- Android consumes server-pinned workout-session guidance revision IDs and never chooses authoritative `latest` content itself.
- Routine versions/materialized weeks remain immutable historical prescription evidence.
- Started workout snapshots remain immutable with respect to later guidance publication.
- `rank-v6`, `schedule-v3`, signing/application ID and Firebase architecture are unchanged.
- Offline-created workout sessions remain outside scope and require a separate TASK-IMP-013B decision.

## Production topology

```text
dashboard            https://stone-set.vercel.app
Supabase project      pjltldrernuvrjsnmcqg
Firebase project      stone-set
Android Firebase app  1:263990431224:android:fe2bf52c3f622047225a0d
tester group          stone-set-testers
```

Direct owner routine publication remains authoritative:

```text
Create/Edit → Save → Validate → Publish
```

Do not reintroduce the retired independent review/approval lifecycle without a new explicit product decision.
