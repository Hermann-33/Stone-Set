# Stone Set Active Context

Updated: 2026-08-09

## Current position

Stone Set is a private two-user hypertrophy training application consisting of:

- Android Flutter client;
- Flutter Web dashboard;
- Supabase Auth/Postgres/Storage backend.

The implementation now prioritizes working functionality and speed over production-grade hardening. Preserve existing Auth/RLS/private-data boundaries, but do not add enterprise security, anti-abuse, exhaustive verification or broad CI unless a concrete task requires it.

## Completed and merged

```text
TASK-IMP-001  Foundation                           COMPLETE
TASK-IMP-002A Identity/sessions                    COMPLETE
TASK-IMP-002B Shared UI + Android shell/Home       COMPLETE
TASK-IMP-002C Dashboard shell/Overview             COMPLETE
TASK-IMP-003A Exercise library/guidance            COMPLETE
TASK-IMP-003B Private media/YouTube                COMPLETE
```

### 003B completion evidence

```text
PR: #16
merge commit: 1b1c18d95214117e59a6c208139c2b019e313cb2
final CI: 31305011340 PASS
```

003B provides private exercise images, processing/re-encoding, upload/finalization, ordering, cover selection, alt text, deterministic media manifests, signed private previews, strict YouTube normalization and official IFrame preview. Android workout media playback remains deferred to 005B.

## Current executable task

```text
TASK-IMP-003C — Routine authoring, review and publication
Status: APPROVED — EXECUTABLE
Branch: codex/task-imp-003c-routine-review-publication
Packet: docs/tasks/TASK-IMP-003C.md
Mode: FAST PRIVATE TWO-USER MVP
```

No additional planning task is required before 003C.

## Accepted technology baseline

```text
Flutter       3.44.7
Dart          3.12.2
Node.js       24.11.1
Supabase CLI  2.111.0
State/DI      Riverpod
Routing       typed go_router
Backend       Supabase Auth/Postgres/Storage
Web drafts    IndexedDB where already useful
Mobile local  SQLite in 005A
```

Use one root Dart lockfile and the existing repository architecture.

## Client architecture

```text
View
  -> Riverpod controller/view model
  -> repository contract
  -> repository implementation
  -> service / Supabase / local store
```

Widgets do not call Supabase/Storage/SQLite directly. Domain models do not import Flutter or Supabase. Do not add a second state-management or routing framework.

## Existing functional boundary

Implemented:

- provisioned username/password login;
- first-password-change;
- session restoration/revalidation/logout;
- owner-separated private data;
- shared themes/components;
- Android Home/Week/Progress/Profile shell with fixture product data;
- dashboard Overview/search/commands/responsive shell;
- exercise definitions and muscle taxonomy;
- structured guidance drafts and immutable published revisions;
- exercise/guidance dashboard authoring and history;
- private exercise images and YouTube references.

Not yet implemented:

- routine lifecycle runtime;
- real weekly plans/swaps/credits;
- workout logger/SQLite/offline sync;
- workout guidance/media playback on Android;
- authoritative RR/XP/rank/wallet/Progress;
- progression/protection/corrections;
- deployment/release hardening.

## Remaining sequence

```text
003C  routine authoring/review/publication
004   real weekly plans/swaps/credits
005A  workout logger + SQLite/offline sync
005B  workout guidance/media
006   RR/XP/rank/wallet/Progress
007   progression/protection/corrections
008   minimal release/deployment needed for actual use
```

Future packets should be simplified for the private two-user use case before implementation when their existing requirements are unnecessarily production-oriented.

## Verification policy

Use path-sensitive, targeted verification.

During development:

- run only tests affected by current edits;
- run database tests for database changes;
- run dashboard tests for dashboard changes;
- run Android tests only when Android/shared runtime changes.

Before merge:

- generation freshness;
- formatting;
- analysis;
- focused feature tests;
- relevant release build;
- one final path-sensitive CI run.

Do not run API 24 for dashboard/database-only tasks. Do not create broad golden matrices. Documentation-only changes should run documentation/repository checks only.

## Security policy for this private build

Keep existing authentication, RLS, private Storage and secret hygiene because removing them would create regressions.

Do not add:

- new threat-model exercises;
- complex anti-abuse/rate-limit systems;
- enterprise audit platforms;
- exhaustive adversarial matrices;
- public-user hardening.

Never commit real passwords, tokens, service-role keys or private keys.

## Exact next action

Implement `TASK-IMP-003C` directly from `docs/tasks/TASK-IMP-003C.md` on
`codex/task-imp-003c-routine-review-publication`.
