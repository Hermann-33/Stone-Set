# TASK-IMP-011 — Exercise media authoring completion and population

Updated: 2026-08-11
Status: `PARTIAL — ENGINEERING/DEPLOYMENT COMPLETE; APPROVED CONTENT INPUTS PENDING`
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

## Implementation and production evidence

PR #38 merged exact final head `d23605261d4b3288ac20c16a476f84e250082d06` as merge commit
`2abf3493f0d0169f090ecf082fcf273d12fe1af5`. Foundation CI `31465486245` passed documentation,
strict Flutter/Dart, generated freshness, dashboard Chrome/Web/bundle checks and Local Supabase
reset/migration/pgTAP/lint. Private Release `31465486209` passed. API 24 and manual golden-candidate
jobs were correctly skipped by path policy.

Production project `pjltldrernuvrjsnmcqg` records
`20260811064653_create_guidance_media_draft_from_revision_v1`. Catalog verification proves hardened
empty search paths, no `PUBLIC`, `anon` or `service_role` execution and only the public wrapper
granted to `authenticated`. A real eligible owner/session smoke materialized a draft and bounded
success envelope inside a transaction that was rolled back. Post-smoke counts remain zero drafts,
published images and YouTube references.

### Exact production content checklist

Every row has `draft = none`, `images = 0`, `cover = none`, `YouTube = none`, and state
`published_text_only`. Completion requires one approved setup/execution cover file and one explicitly
selected YouTube URL per row; no selection may be invented or scraped.

| Exercise | Definition ID | Latest guidance revision ID |
|---|---|---|
| Cable Chest Fly | `cd054a15-3125-44e0-96a8-89592df9a162` | `6667e290-fc8e-453a-9744-03088332e900` |
| Cable Crunch | `f00e4e8c-a80e-42e8-b3d4-141da06a2026` | `cc121b88-8e26-40d9-89fd-7575c191475b` |
| Cable Curl | `47b174a6-3b72-4005-8bf8-17791eb039f5` | `56c0cfb2-6a84-411f-9f3e-248bc29554f8` |
| Cable Lateral Raise | `815a4ea2-e25e-41a3-beb3-c870b8992108` | `a27ab7b7-7530-4c41-8755-c45a8893ab61` |
| Cable Rear-Delt Fly | `320efa8d-1c7b-4d08-b2b9-e745bff70ffc` | `487d6a58-8461-49d6-a4e1-420b8535ec81` |
| Cable Triceps Pressdown | `a301f0f2-346a-44c2-b9c6-d632cd48b0bb` | `6af6cac1-0538-433c-89f7-08e8125e2f4f` |
| Hanging Knee Raise | `198534fc-921a-45ef-8c7b-dd35068dfe54` | `25abb70e-3338-4b49-bcb9-b92db5e8fc5e` |
| Incline Dumbbell Curl | `40c0e702-61d1-4637-820e-1e37b071fffd` | `e284e64e-6c65-4919-8878-8e739e9b623d` |
| Lat Pulldown | `d27ed081-28dd-4f98-95db-a744fa3a73fb` | `969c45a2-0f15-4014-a14a-4a230ee6b2ca` |
| Leg Curl | `8db794e1-d219-49d4-afa6-2103f0e4bd0b` | `a78a3b9a-2829-4a77-b4b1-00a96488a788` |
| Leg Extension | `55d1098b-9e7b-45a3-abae-04435dd020b9` | `a1072e0c-eaf5-40a7-96b5-7762bb77454e` |
| Neutral-Grip Lat Pulldown | `5461ef1f-06cd-4fdf-8e77-a49d47f8e0e5` | `c2368e54-9b5a-40f2-8dfc-b1ceb5d83a1b` |
| Overhead Cable Triceps Extension | `409fb89d-33d1-407d-8974-334699f7d7c5` | `818ab366-60f5-43d0-8233-4c1b392e6d1c` |
| Reverse Curl | `d7b7fe37-6210-450d-81d0-a79e97051756` | `18b0f83a-5eba-49cc-b712-8abfe2cf2bb8` |
| Reverse Wrist Curl | `b1a8c2d4-7e84-4a80-b253-e2aab633c014` | `85ebbfce-738a-494f-a9fd-cb16228aa912` |
| Seated Row | `ffabb01a-29bb-4044-a991-5842a06a200f` | `49308528-3b0e-4cc9-8acf-b2687efbde7a` |
| Seated Wrist Curl | `e06c28dc-0ffa-42a1-a112-70e50ff25e27` | `c1d0ee88-a45a-4491-aaf0-ae9954dcb96a` |
| Single-Arm Cable Lateral Raise | `9df029e0-c84f-4219-8b71-acbc38e8f772` | `8fa2d0e2-f576-4580-bb8c-d564110a6411` |
| Smith Bulgarian Split Squat | `14d5ef6c-7302-484b-bd66-382d607c81a6` | `bf189766-c67d-4714-9d65-3e7d7537f534` |
| Smith Flat Bench Press | `de46ea14-d1b8-4f6d-b183-20073681647e` | `8b68eeb9-1b31-4728-81d9-e9b739a32dd3` |
| Smith Hip Thrust | `8e257b4a-4b7b-4dc5-9054-ff801603cdd1` | `f95ff6be-4f5a-4ad9-9d14-9c949d774764` |
| Smith Incline Bench Press | `1590688f-522c-4bf4-9298-0fdea9572c4e` | `b0c0a4c1-683d-4b5a-a0d3-75b31e91c398` |
| Smith Romanian Deadlift | `e2f9ef56-8624-4af5-984d-2a7bcd5b806e` | `6f062b46-fdee-4954-a619-769da659a705` |
| Smith Squat | `a9ae0f1c-09b1-4604-b139-501602626937` | `d1f1e90b-8c99-4ba9-b155-20b675a29209` |
| Smith Standing Calf Raise | `36e8f85c-fe90-431f-acf7-27c30bb4696c` | `f900d4d0-f0ab-4421-bec3-0c5e7b0ed92d` |

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
