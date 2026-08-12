# ADR-0011 — Latest published guidance for newly started workouts

Date: 2026-08-13
Status: `ACCEPTED`

## Context

Exercise guidance and media are published as immutable revisions. Routine versions and materialized training weeks intentionally preserve immutable prescription evidence, including the guidance revision selected when the routine was published. The Android workout session then snapshots that prescription into `workout_session_exercises` when a workout starts.

Production investigation on 2026-08-13 found that this makes later content-only guidance/media publication ineffective for an already-published routine: even after a new immutable guidance revision exists, a newly started workout copies the older revision pinned in `routine_version_prescriptions`.

The same investigation found a separate dashboard usability problem: an unvalidated YouTube draft correctly blocks atomic publication, but the dashboard collapses the server's `youtube_preview_required` failure into a generic media failure. This made a blocked publication look like a successful content workflow that simply failed to reach mobile.

## Decision

1. Published routine versions and materialized training-week rows remain immutable prescription/history evidence and are not rewritten when guidance/media is republished.
2. When a **new** `workout_session_exercises` snapshot row is created, the server resolves the latest owner-matching published guidance revision that has a finalized `guidance_media_manifests` row for that exercise.
3. If no newer finalized manifest-backed revision exists, the routine prescription's pinned guidance revision remains the fallback.
4. The resolved revision is written once into the workout-session snapshot. An already-started workout never changes revision because of a later dashboard publication.
5. Android continues loading guidance/media by the revision pinned in the workout-session snapshot. No client-side 'latest' lookup is introduced.
6. Dashboard publication must surface `preview_required` as an explicit actionable blocker. It must not invent YouTube playback evidence or bypass the existing successful-preview requirement.
7. A changed/new YouTube reference remains publishable only after the real preview flow records current playable evidence. Expired preview evidence remains server-authoritative.

## Why this boundary

Resolving at workout-session creation gives new workouts the latest accepted content without mutating routine history, materialized scheduling evidence, or started-workout history. It also keeps one authoritative revision ID in the session, so offline continuation and historical replay remain deterministic.

Selecting only manifest-backed revisions is required because mobile guidance loads text and media as one revision bundle. A text revision without a finalized media manifest is not eligible to replace the routine fallback at workout start.

## Security and ownership

- Resolution is constrained by both `exercise_definition_id` and immutable owner UUID.
- No cross-owner revision can be selected.
- The trigger/function is private and not exposed as a client mutation surface.
- Existing Auth/RLS and `start_workout_v1` authorization remain unchanged.
- No service-role or deployment credential is introduced into either Flutter client.

## Consequences

- Publishing guidance/media does not alter an active workout that has already started.
- The next newly started workout that contains the exercise uses the newest finalized published bundle.
- Routine version comparison continues to show the guidance revision originally selected for that routine version; this is historical prescription evidence, not the runtime content resolution for a future session.
- Dashboard users receive a specific message when YouTube preview validation is the only publication blocker.

## Superseded/related decisions

- ADR-0002 remains authoritative for Supabase/Auth/RLS/server-owned state.
- ADR-0003 remains authoritative for online workout start and immutable/durable started-workout snapshots.
- ADR-0006 remains authoritative for private exercise media and YouTube preview requirements.
- ADR-0008 remains authoritative for guidance/media draft materialization from immutable revisions.
- This ADR narrows the activation point for later content-only guidance/media publication; it does not make routine prescriptions mutable.
