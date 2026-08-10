# Stone Set Active Context

Updated: 2026-08-10

## Current position

Stone Set is a two-user hypertrophy training application:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

Implementation mode: **FAST TWO-USER MVP**. Prioritize working functionality and short cycles. Preserve existing Auth/RLS/data-ownership boundaries; do not add enterprise hardening or broad verification unless a concrete release defect requires it.

## Completed and verified

```text
TASK-IMP-001  Foundation                           COMPLETE
TASK-IMP-002A Identity/sessions                    COMPLETE
TASK-IMP-002B Shared UI + Android shell/Home       COMPLETE
TASK-IMP-002C Dashboard shell/Overview             COMPLETE
TASK-IMP-003A Exercise library/guidance            COMPLETE
TASK-IMP-003B Private media/YouTube                COMPLETE
TASK-IMP-003C Routine authoring/review/publication COMPLETE
TASK-IMP-004  Weekly plans/free+paid swaps         COMPLETE
TASK-IMP-005A Workout logger/SQLite/sync            COMPLETE
TASK-IMP-005B Workout guidance/media playback       COMPLETE — CI VERIFIED
TASK-IMP-006  RR/XP/rank/wallet/Progress            COMPLETE
TASK-IMP-007  Progression/protection/corrections    COMPLETE
```

Latest implementation evidence:

```text
TASK-IMP-005B
PR: #24
implementation head: 21f780a71ef275be05c9ac1f007e78d41750ef81
Foundation CI: 31386145611 PASS
completion: docs/tasks/TASK-IMP-005B-COMPLETION.md
```

005B adds exact pinned guidance inside the active logger, private revision images through short-lived signed URLs, Android YouTube playback through `webview_flutter 4.14.1`, and state-preservation tests. It intentionally adds no database/media schema.

## Current executable task

```text
TASK-IMP-008 — Minimal deployment/release
Status: NEXT — PACKET REQUIRED
Base: latest main after PR #24 merge
Mode: FAST TWO-USER MVP
```

No other product feature phase remains required before release.

## Phase 8 simplification

Implement only what is needed for the two known users to run Stone Set:

- hosted Supabase project configured from the existing migration/seed/operator model;
- production Vercel dashboard deployment from the existing Flutter Web bundle;
- Android signed/installable release path;
- exact runtime environment/config values;
- basic end-to-end smoke test;
- concise deploy/rollback/backup notes.

Avoid unless a real blocker requires it:

- separate staging environment;
- enterprise observability/log-drain architecture;
- ASVS/MASVS certification work;
- broad security/performance matrices;
- complex CI/CD pipelines;
- formal RPO/RTO drills;
- multi-region/HA architecture;
- public-user anti-abuse systems.

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

## Verification policy

Use targeted release checks plus the existing Foundation CI. Codex remains fallback only for a concrete local-only build/signing/runtime defect that cannot reasonably be completed through connected GitHub/Supabase/Vercel tooling.

## Exact next action

Merge PR #24. Then create the fast TASK-IMP-008 packet/branch from latest `main` and complete the minimum hosted/release path.
