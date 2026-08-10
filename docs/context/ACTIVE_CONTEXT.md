# Stone Set Active Context

Updated: 2026-08-10

## Current position

Stone Set is a two-user hypertrophy training application:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

Implementation mode: **FAST TWO-USER MVP**. Prioritize working functionality and short cycles. Preserve existing Auth/RLS/data-ownership boundaries, but do not add enterprise hardening or broad verification unless a concrete defect requires it.

## Completed and merged/verified

```text
TASK-IMP-001  Foundation                           COMPLETE
TASK-IMP-002A Identity/sessions                    COMPLETE
TASK-IMP-002B Shared UI + Android shell/Home       COMPLETE
TASK-IMP-002C Dashboard shell/Overview             COMPLETE
TASK-IMP-003A Exercise library/guidance            COMPLETE
TASK-IMP-003B Private media/YouTube                COMPLETE
TASK-IMP-003C Routine authoring/review/publication COMPLETE
TASK-IMP-004  Weekly plans/free swaps              COMPLETE
TASK-IMP-005A Workout logger/SQLite/sync            COMPLETE
TASK-IMP-006  RR/XP/rank/wallet/Progress            COMPLETE
TASK-IMP-007  Progression/protection/corrections    COMPLETE — CI VERIFIED
```

Latest implementation evidence:

```text
TASK-IMP-007
PR: #23
implementation head: 5342b260353169533fac265e95fddd158cc21f51
Foundation CI: 31383285750 PASS
completion: docs/tasks/TASK-IMP-007-COMPLETION.md
```

007 provides deterministic latest-comparable-workout progression, +2.5 kg/+5 lb increases, manual override, exercise protection, pain flag, preferred substitution at workout start, and exact RR/XP corrections with one-time reversal.

## Current executable task

```text
TASK-IMP-005B — Workout guidance and media playback
Status: IMPLEMENTING
Branch: codex/task-imp-005b-workout-guidance-media
PR: #24
Packet: docs/tasks/TASK-IMP-005B.md
Mode: FAST TWO-USER MVP
```

005B is required before release.

## 005B simplification

Implement only:

- Guidance action inside the existing workout logger;
- same-route modal/bottom sheet;
- exact pinned immutable guidance revision;
- exact published media manifest for that revision;
- private images through short-lived signed URLs;
- validated YouTube playback through Android WebView;
- focused loader/widget/state-preservation tests.

No new database schema, media mutation, offline video, background prefetch, custom disk-cache schema, top-level route or dashboard feature.

## Technology baseline

```text
Flutter          3.44.7
Dart             3.12.2
Node.js          24.11.1
Supabase CLI     2.111.0
State/DI         Riverpod
Routing          typed go_router
Backend          Supabase Auth/Postgres/Storage
Mobile local     SQLite/sqflite
Android WebView  webview_flutter 4.14.1
```

## Existing functional boundary

Implemented:

- provisioned login/session lifecycle and owner-separated private data;
- exercise/guidance/private media authoring;
- routine validation/review/publication;
- real weekly schedule and free/paid swaps;
- Android workout logger/SQLite/offline continuation/sync/submit;
- authoritative RR/XP/rank/Progress;
- progression/substitution/protection/corrections.

Still required:

- Android workout guidance/media playback (005B);
- minimal deployment/release (008).

## Remaining sequence

```text
005B  workout guidance/media playback
008   minimal deployment/release
```

## Verification policy

Use targeted tests while implementing. Final confidence comes from existing path-sensitive Foundation CI on the final branch head. Codex remains fallback only for a concrete local-only defect.

## Exact next action

Finish PR #23 merge, retarget PR #24 to `main`, validate and merge TASK-IMP-005B, then begin TASK-IMP-008.
