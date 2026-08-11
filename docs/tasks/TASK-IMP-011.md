# TASK-IMP-011 — Exercise media authoring completion and population

Updated: 2026-08-11
Status: `APPROVED — NOT EXECUTED`
Branch: `codex/task-imp-011-exercise-media-completion`

## Objective

Replace the stale exercise-detail media placeholder with truthful published/draft media state and
actions that reuse the complete TASK-IMP-003B stack. Enable the real production dataset to create an
editable guidance/media draft from an immutable revision, then inventory and populate only
explicitly approved media.

## Mandatory repository reads

Read AGENTS and all canonical context in repository order, then:

- `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`;
- ADR-0002, ADR-0005, ADR-0006, ADR-0007 and ADR-0008;
- `docs/tasks/TASK-IMP-003A.md`, `TASK-IMP-003B.md`, `TASK-IMP-005B.md`, and `TASK-PD-023.md`;
- this packet and the current exercise/media domain, data, dashboard, migration and test sources.

## Verified starting state

```text
accepted main                 377eeee582d0974a6ff1d306d327790deab19e6e
TASK-IMP-010                  COMPLETE; production migration verified
TASK-IMP-003B                 COMPLETE; existing media architecture authoritative
production active exercises  25
used in latest routine        25
latest guidance revisions     25
current editable drafts       0
published images/covers       0
published YouTube references  0
current media state           all published text-only
stale detail placeholder      present
routine-usage placeholder     present and explicitly out of scope
```

## Exact scope

### Database contract

- create exactly one additive CLI-created migration implementing ADR-0008;
- add `public.create_guidance_media_draft_from_revision_v1` and a hardened private implementation;
- require active authenticated ownership, exact exercise/source binding, non-archived state,
  expected exercise revision and idempotency;
- atomically create the guidance draft, media draft state, copied immutable media metadata and
  optional copied YouTube reference;
- reuse published object references without overwriting/copying bytes and preserve source deletion
  protection;
- return bounded operation/replayed/correlation/source/draft/media revision evidence;
- return a safe deterministic existing-draft conflict rather than replacing a draft;
- revoke unintended `PUBLIC`, `anon`, `authenticated`, and `service_role` EXECUTE before granting
  only the public wrapper to `authenticated`;
- preserve Data API grants, RLS, Storage policies, hashes and existing publication RPCs.

### Domain and data

- add one immutable command/result and repository method for the new operation;
- bind the exact RPC with strict envelope and safe conflict-detail decoding;
- do not duplicate manifest, upload, signed-URL or YouTube logic;
- preserve read-only mobile repository boundaries and all existing 003A/003B contracts.

### Dashboard

- remove only the stale Media placeholder in
  `dashboard_exercise_library_view.dart`;
- show latest published media loading/error/empty/populated states using
  `dashboardGuidanceRevisionMediaProvider` and `DashboardPrivateMediaImage`;
- show cover thumbnail, image count and YouTube-attached state without exposing private object paths
  or durable signed URLs;
- show current draft media state when a draft exists;
- route **Manage media** to the existing guidance/media editor for that draft;
- route **View published media** to the existing immutable revision view;
- when no draft exists, **Add media** invokes the new atomic operation for the latest revision,
  refreshes the authoritative exercise, then routes directly to the existing editor;
- preserve read-only/archived/session-revoked/error/conflict behavior and never claim success before
  server confirmation;
- preserve compact/medium/expanded layouts, keyboard/focus/semantics, reduced motion and 200% text;
- leave the Routine usage placeholder byte-for-byte unchanged unless compilation makes that
  impossible, in which case stop and report.

### Production inventory and population

- after merge/deployment, rerun a credential-safe exact inventory with exercise name/definition ID,
  latest revision, draft ID, image count, cover asset ID, YouTube reference and media state;
- target one clear setup/execution cover image and one explicitly approved YouTube demonstration per
  currently used exercise, with extra images only when materially useful;
- accept only user-provided, Stone Set-owned/generated, or explicitly licensed images;
- never scrape/rehost arbitrary web images, store video bytes, or invent a YouTube selection;
- use immutable revision → new draft → attach media → validate → publish; never rewrite old
  revisions, routine prescriptions, materialized weeks or workout snapshots;
- if approved assets/selections are unavailable, stop population and return the exact 25-exercise
  content checklist. This is a valid external content boundary, not permission to fabricate media.

## Non-goals and protected behavior

- no second media architecture, new bucket, public URL, YouTube search, video download or rehosting;
- no routine-usage UX or active review queue;
- no prescription, set, rep, RIR, rest, identity, variant, PR-comparability, routine or schedule
  change;
- no files under `apps/mobile/lib/features/week/`, no swap/payment-choice work, and no schedule-v3
  change;
- no RR, XP, rank, wallet, progression, workout history or cached snapshot rewrite;
- no secret, service-role credential, database password, token or private signed URL in source,
  logs, browser persistence, CI artifacts or reports.

## Acceptance criteria

1. Exercise detail never claims media is future work.
2. Published empty and populated manifests render truthfully.
3. Existing drafts open the existing media editor.
4. A published revision with no draft creates exactly one owner-scoped draft atomically and opens
   the editor; replay is idempotent and concurrent creation cannot replace work.
5. Published guidance/media and Storage objects remain immutable.
6. Anonymous, cross-user, archived, disabled, password-change-required and revoked sessions are
   denied; client roles receive no direct table write or private-function execution.
7. Routine usage and every protected product behavior remain unchanged.
8. Production inventory is exact and population uses only approved media.

## Required verification

### Database/security

- clean local Supabase reset and full migration replay;
- focused pgTAP for schema, grants, RLS/EXECUTE, owner success, missing source, cross-user,
  anonymous/disabled/revoked denial, archived denial, existing-draft conflict, idempotent replay and
  concurrent uniqueness;
- text/media/YouTube provenance copy, published-object deletion protection and no-source-media cases;
- database lint/advisors and migration status inspection.

### Dart/dashboard

- domain/data tests for strict command/result/envelope/conflict mapping;
- widget tests for loading/error/text-only/images/cover/YouTube/draft/read-only/conflict states;
- routing tests for manage, view, and create-draft-then-editor flows;
- keyboard, focus, semantics, 200% text, reduced-motion and responsive regressions;
- existing 003A/003B media/editor/revision tests and relevant Chrome privacy/lifecycle tests;
- formatting, generated freshness, fatal-info analysis, dashboard Web release build and bundle
  secret/private-URL scan.

### Final gates

- one final-head path-appropriate CI run; database/shared/dashboard paths must activate their owning
  jobs while API 24 remains skipped unless mobile runtime actually changes;
- complete diff, migration, generated source, audit append-only, secret/personal-data and clean-tree
  review;
- deploy only the committed migration to exact production project `pjltldrernuvrjsnmcqg` after
  merge and green CI, through reviewed migration history, without seed data;
- credential-safe production RPC smoke and final inventory.

## Required documentation updates

Update only this packet, AGENTS, ACTIVE_CONTEXT, CODEBASE_MAP, ROADMAP, HANDOFF, task index, ADR index,
and append-only active audit for material completion facts. Do not churn product baselines.

## Git requirements

```text
branch: codex/task-imp-011-exercise-media-completion
no work on main; no history rewriting
commits contain TASK-IMP-011
push and open a draft PR
inspect the complete diff
require exact final-head path-appropriate CI
merge only the verified exact head
sync main and prove ancestry
```

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-011
Branch:
Commit:
Pull request:
Files changed:
Database changes:
Domain/data changes:
Dashboard changes:
Production migration:
Production media inventory:
Media populated:
Behavior intentionally unchanged:
Tests/checks:
CI result:
Security/accessibility review:
Secrets/personal-data review:
Remaining content inputs:
Exact next action:
```

`COMPLETE` requires the code, migration, production authoring path, exact inventory, approved media
population, docs, Git and CI gates. Use `PARTIAL` only when all autonomous engineering is complete
and approved image/YouTube content is genuinely unavailable.
