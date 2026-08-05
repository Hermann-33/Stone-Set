# Stone Set Database and Server Operation Plan

Updated: 2026-08-05
Status: `ACCEPTED IMPLEMENTATION-GRADE DATA PLAN — CREATE THROUGH PHASE MIGRATIONS`
Task: `TASK-PD-013`

## 1. Purpose

This document closes the gap between accepted product behavior and implementation-ready database design.

It defines:

- relational domains and ownership;
- immutable/versioned records;
- authoritative server operations;
- RLS and privilege boundaries;
- concurrency and idempotency;
- scheduled jobs and catch-up behavior;
- offline synchronization contracts;
- media metadata and Storage relationships;
- observability, retention, export and account lifecycle;
- migration and test requirements.

It is a logical schema plan, not a migration. Exact table and column names may be refined during implementation, but no phase may weaken the guarantees recorded here without an accepted change.

## 2. Database principles

1. Postgres is authoritative for shared product state.
2. Supabase Auth is authoritative for identity credentials and sessions.
3. Supabase Storage is authoritative for private exercise-image bytes.
4. Published, materialized and finalized history is immutable.
5. Scores and balances are derived through append-only transactions, not client-set totals.
6. Every authority-changing workflow is atomic and idempotent.
7. Every exposed user-owned relation has RLS and negative policy tests.
8. Client routes and hidden URLs are never authorization controls.
9. Historical rows retain the exact configuration and content versions used.
10. Local mobile/dashboard drafts are recoverable but non-authoritative.
11. Schema changes originate in committed migrations.
12. Data deletion, export, correction and restoration are explicit workflows.

## 3. Schema boundaries

### `auth`

Managed by Supabase Auth. Application migrations do not modify Auth internals except through supported triggers/functions and foreign keys to `auth.users(id)`.

### `public`

Contains RLS-protected client-facing tables, security-invoker views and explicitly exposed RPC functions.

Only records that a normal authenticated client may safely query or invoke belong here.

### `private`

Contains internal helper tables, configuration bodies, job-control records, operation locks and audit details that clients must not query directly.

The schema is not exposed through the Data API. Privileges are revoked from `anon` and `authenticated` unless a tightly reviewed function requires access.

### `storage`

Managed by Supabase Storage. Application code treats this schema as read-only metadata for policy checks and backup reconciliation. Upload, move, copy and deletion use the Storage API.

### `cron`

Managed by `pg_cron`. Jobs are created through committed migrations and call idempotent functions.

## 4. Common column standards

Unless a domain requires otherwise:

```text
id                   uuid primary key default gen_random_uuid()
user_id              uuid not null references auth.users(id)
created_at           timestamptz not null default now()
updated_at           timestamptz not null default now()
revision             bigint not null default 1
```

Rules:

- all server timestamps use `timestamptz` in UTC;
- reward calendar identity uses `date` plus stored IANA timezone and resolved UTC boundary timestamps;
- monetary-like RR/XP/credit values use integers;
- load measurements store decimal value plus explicit unit, with canonical conversion rules;
- user-facing order uses integer position and a unique parent/position constraint;
- lifecycle states use check constraints or Postgres enums only when evolution cost is acceptable;
- JSONB stores versioned evidence/snapshots, not core relational identity or frequently filtered ownership fields;
- every mutable draft uses optimistic concurrency through `revision` and/or expected `updated_at`;
- every immutable row has no client update/delete policy.

## 5. Identity and account domain

### `profiles`

Purpose: protected application identity linked one-to-one to `auth.users`.

Key fields:

```text
id = auth user id
normalized_username unique immutable
public_display_name
active
must_change_password
reward_timezone
created_at
updated_at
```

Rules:

- profile creation is operator/server controlled;
- usernames are immutable except audited operator migration;
- users may update only permitted display/preferences fields through safe RPC or column privileges;
- active status and password-change requirement are not user-editable;
- no password or password hash exists here.

### `user_preferences`

Fields include:

```text
user_id primary key
load_unit
appearance_mode
reduced_motion
haptics_enabled
rest_timer_sound_enabled
workout_reminders_enabled
reminder_local_time?
locale
revision
```

Preferences do not grant authorization.

### `account_capabilities`

Purpose: explicit server-managed capabilities such as routine reviewer eligibility or operator-facing flags.

Do not use user-editable JWT raw metadata for authorization. Where a capability must be available in JWT claims, it is derived from protected server-managed data through an accepted Auth hook/versioned process.

### `account_status_events`

Append-only events for provisioning, activation, deactivation, password-reset requirement, username migration and operator session revocation. Password values are never recorded.

## 6. Client compatibility and feature control

### `client_compatibility_config`

One active versioned record per environment:

```text
config_version
minimum_mobile_build
minimum_dashboard_build
minimum_schema_contract
recommended_mobile_build
maintenance_mode
read_only_mode
message_code
message_text
features jsonb
active_from
```

Clients fetch this after authentication bootstrap and before mutations.

Rules:

- incompatible clients may read a safe subset but cannot mutate;
- maintenance/read-only state is explicit and accessible;
- feature flags cannot bypass server authorization or alter historical reward rules;
- configuration changes are audited and environment-specific.

## 7. Exercise and guidance domain

### `exercise_definitions`

Stable user-owned exercise identities.

Key fields:

```text
id
user_id
canonical_name
normalized_name
variant_key
equipment_key
primary_muscle_id
archived_at?
cloned_from_exercise_id?
revision
```

Rules:

- names need not be globally unique, but normalized duplicates for one owner require explicit confirmation;
- ordinary users cannot edit another owner's exercise;
- clone creates a new owned ID and records provenance;
- historical references survive archive.

### `muscles`

Server-seeded taxonomy with stable IDs/keys. Readable by authenticated users; not client-editable.

### `exercise_secondary_muscles`

Join table between exercise and muscle with unique pair constraint.

### `guidance_drafts`

Mutable structured guidance work owned by the author.

Fields:

```text
id
exercise_id
user_id
description
setup
execution
cues
common_mistakes
safety_notes
youtube_reference_draft jsonb?
revision
save_state metadata
```

The database stores structured plain text, not executable HTML.

### `guidance_revisions`

Immutable published content revisions.

Fields:

```text
id
exercise_id
user_id
version_number
content_hash
structured_content jsonb or normalized fields
published_at
supersedes_revision_id?
```

Unique `(exercise_id, version_number)` and content-hash evidence prevent silent mutation.

### `guidance_revision_muscles`

Pinned primary/secondary muscle evidence for the published revision where needed.

### `guidance_media_assets`

Authoritative metadata linking published or draft guidance to immutable Storage objects.

Fields:

```text
id
user_id
exercise_id
guidance_draft_id?
guidance_revision_id?
bucket_id
object_path unique
owner_id_snapshot
mime_type
byte_size
width
height
sha256
alt_text
position
is_cover
state
created_at
published_at?
quarantined_at?
deleted_at?
```

Rules:

- exactly one cover image when images exist;
- maximum six active images per revision enforced server-side;
- published paths cannot be overwritten;
- object metadata and bytes must reconcile during backup/restore;
- deletion uses Storage API, then audited metadata transition;
- draft orphan cleanup respects a retention window and active-editor leases.

### `guidance_youtube_references`

Stores normalized video ID, canonical URL, optional start time, title/thumbnail snapshot, validation status and validation time. No video bytes.

## 8. Routine drafting, review and publication

### `routine_drafts`

Mutable owner-only root:

```text
id
user_id
name
description
status
revision
based_on_routine_version_id?
last_validated_at?
validator_version?
```

### `routine_draft_days`

Seven ordered day records with workout/rest type, title, purpose, muscles, duration and equipment summary.

Unique `(routine_draft_id, day_index)` with `day_index` 1–7.

### `routine_draft_prescriptions`

Ordered exercise prescriptions for workout days:

```text
exercise_definition_id
guidance_revision_id
position
priority
working_sets
rep_min
rep_max
rir_target
rest_seconds
load_unit
progression_rule_version
pr_comparability_key
notes
```

Draft edits use expected revision checks.

### `routine_validation_runs`

Immutable validation evidence:

```text
id
routine_draft_id
draft_revision
validator_version
content_hash
result_state
errors jsonb
warnings jsonb
metrics jsonb
created_at
```

Errors include stable codes and exact field/entity paths.

### `routine_submissions`

Immutable submitted snapshot:

```text
id
author_user_id
routine_draft_id
draft_revision
content_hash
snapshot jsonb
validator_run_id
status
submitted_at
```

A later draft edit does not change an existing submission.

### `routine_reviews`

One reviewer decision per submission attempt:

```text
id
submission_id
reviewer_user_id
decision
note
reviewed_at
```

Constraints/functions reject author self-review and reviewer mutation of submitted content.

### `routine_versions`

Immutable published routine root with version number, content hash, author, reviewer evidence, effective week start and supersession link.

### `routine_version_days` and `routine_version_prescriptions`

Normalized immutable version content. Materialization references these IDs and may also store a compact immutable snapshot for resilience.

## 9. Weekly scheduling domain

### `training_weeks`

One record per user and reward week.

```text
id
user_id
week_start_date
week_end_date
reward_timezone
start_at
end_at
routine_version_id
rank_config_version
schedule_config_version
base_schedule_hash
current_schedule_revision
confirmed_swap_count
state
finalized_at?
```

Unique `(user_id, week_start_date)`.

### `weekly_plan_items`

Exactly seven rows per week:

```text
id
training_week_id
original_date
current_date
item_type
routine_version_day_id
prescription_snapshot jsonb
allocated_rr
allocated_base_xp
allocated_missed_penalty_rr
lock_state
resolution_state
started_session_id?
protected_event_id?
finalized_at?
```

Unique `(training_week_id, current_date)` and `(training_week_id, original_date)`. Allocations follow item identity when swapped.

### `schedule_snapshots`

Immutable base, post-swap and final schedule snapshots with revision, hash, reason and creator operation ID.

### `swap_records`

Immutable confirmed or voided swaps including:

- both dates and item IDs before/after;
- swap number;
- payment method;
- exact RR or credit amount;
- balances before/after;
- schedule revision before/after;
- idempotency key;
- correction/void link.

Preview is computed but not persisted as authority unless a short-lived signed preview token is needed. Confirmation revalidates all data transactionally.

### `monthly_credit_grants`

Unique `(user_id, grant_month)` and exact effective timezone/boundary evidence.

### `free_swap_ledger`

Append-only grant, consume, restore and correction entries. The displayed wallet balance is either derived or maintained by an internal transactionally updated snapshot validated against the ledger.

## 10. Workout execution domain

### `workout_sessions`

Authoritative session root:

```text
id
user_id
weekly_plan_item_id unique where active/completed
client_start_idempotency_key unique
state
started_at
server_started_at
completed_at?
submitted_at?
validation_state
prescription_snapshot_hash
prescription_snapshot jsonb
configuration_snapshot jsonb
last_client_sequence
created_at
```

A second start request with the same item/idempotency key returns the existing session.

### `workout_session_exercises`

Immutable ordered exercise snapshot, including exercise/guidance IDs, comparability key and prescription.

### `workout_set_entries`

Server copy of synchronized working-set state:

```text
id
session_id
session_exercise_id
set_index
client_entry_id unique
payload_version
load_value
load_unit
repetitions
rir
completion_state
completed_at_client?
received_at
last_sequence
voided_at?
```

Unique `(session_exercise_id, set_index)`. Server validation does not trust client timestamps or completion flags without session/context checks.

### `workout_sync_batches`

Records accepted outbox batches and idempotency keys, payload versions, sequence range, result and correlation ID.

### `workout_submission_attempts`

Append-only submit attempts with idempotency key, received snapshot hash, result and validation errors. Duplicate submissions return the original accepted result.

### `workout_results`

Immutable authoritative session resolution:

- completed/partial/missed/invalid/protected status;
- completion factor;
- comparable performance evidence;
- provisional transaction references;
- validation/configuration versions;
- reason codes.

## 11. Comparable performance and progression

### `exercise_performance_records`

Immutable accepted set/session performance evidence keyed by exercise, equipment/variant and comparability key.

### `personal_record_events`

Stores baseline or PR classification, source session/set, prior best evidence, reward eligibility, weekly cap position and transaction references.

### `progression_recommendations`

Versioned non-authoritative recommendations:

```text
exercise_id
based_on_evidence_through
rule_version
recommendation
reason_codes
created_at
accepted_at?
overridden_at?
```

Recommendations never silently mutate routine versions.

## 12. Rank, XP and evaluation domain

### `rank_accounts`

One current snapshot per user:

```text
user_id primary key
rank_rr
lifetime_xp
current_rank_id
consecutive_perfect_weeks
active_multiplier
snapshot_version
updated_at
```

Clients cannot update it. Every mutation is reconciled to append-only ledgers.

### `rr_transactions`

Append-only entries for daily award, PR, perfect week, milestone, multiplier top-up, missed penalty, decay, paid swap, correction and void/reversal.

Fields include:

```text
id
user_id
transaction_type
amount signed integer
source_type
source_id
rank_config_version
idempotency_key unique
reverses_transaction_id?
voided_by_transaction_id?
balance_before
balance_after
created_at
```

### `xp_transactions`

Equivalent append-only lifetime-XP ledger.

### `weekly_evaluations`

Immutable stored evaluation inputs and outputs:

- final schedule snapshot;
- item resolutions;
- workout completion ratio;
- perfect/failed/protected classification;
- old/new streak and multiplier;
- PR cap evidence;
- bonuses, penalties and decay;
- ledger transaction IDs;
- config versions;
- finalization operation ID.

### `milestone_awards`

Unique `(user_id, milestone_key)` prevents duplicate lifetime milestones.

### `rank_snapshots`

Optional immutable event snapshots after meaningful transitions, allowing exact historical UI without recalculating using current thresholds.

## 13. Protection, pain, substitution and correction domain

### `protection_events`

Auditable item/full-week protection with scope, effective dates, reason category, operator/authorized actor, evidence note and approval state.

The product does not diagnose medical conditions.

### `pain_flags`

User-reported non-diagnostic flags linked to an exercise/session, controlling progression recommendations but not editing historical records.

### `substitution_records`

Stores approved/used movement substitution, comparability consequences and session/routine context.

### `correction_cases`

Root for exact-value corrections:

```text
id
user_id
requested_by
reason
status
affected_source_type
source_id
opened_at
resolved_at?
```

### `correction_entries`

Immutable reversal/replacement evidence. Corrections create new ledger and state transitions; they never edit finalized transaction values in place.

## 14. Activity and audit domain

### `activity_events`

Human-readable product activity for user-facing history:

- actor;
- action code;
- object type/ID;
- safe summary;
- before/after version IDs where useful;
- correlation ID;
- timestamp.

### `private.operation_audit`

More detailed server operation evidence for debugging/security:

- operation ID;
- authenticated actor/session;
- function name/version;
- idempotency key;
- result code;
- safe structured metadata;
- duration;
- correlation ID.

No password, token, raw private note or media URL is stored.

## 15. Authoritative RPC/function catalogue

All function signatures are versioned and return structured result envelopes.

### Identity/operator

- `operator_create_account` — trusted tooling only;
- `operator_set_temporary_password_requirement` — trusted tooling only;
- `operator_deactivate_account`;
- `operator_revoke_sessions`;
- `get_authenticated_bootstrap` — profile, preferences, compatibility and safe summary.

Admin Auth calls requiring a service role occur only in trusted operator tooling or an explicitly approved Edge Function, never in Flutter clients.

### Guidance and media

- create/update guidance draft with expected revision;
- validate guidance draft;
- publish guidance revision;
- create signed upload intent/path metadata;
- finalize uploaded media metadata after server validation;
- reorder/update draft media metadata;
- archive/delete eligible draft media through trusted Storage workflow.

### Routines

- save routine draft with expected revision;
- validate routine draft;
- submit immutable routine snapshot;
- review routine submission;
- publish approved routine version;
- duplicate version into a new draft.

### Scheduling and wallet

- materialize week;
- get/compute swap preview;
- confirm swap atomically;
- materialize monthly grant;
- resolve day lock;
- apply/void authorized protection.

### Workouts

- start or return workout session;
- synchronize versioned mutation batch;
- submit session;
- get session synchronization/result state;
- void invalid duplicate data through correction workflow.

### Rank/finalization

- finalize eligible training week;
- expire unresolved grace session;
- apply exact correction;
- return authoritative rank/wallet/progress snapshot;
- return transaction explanations.

### Export

- create user export manifest;
- retrieve paginated owned data export views;
- optionally generate a short-lived private export object in a later approved task.

## 16. Function security

- Default to `security invoker`.
- Use `security definer` only when the operation must cross RLS/privilege boundaries.
- Every `security definer` function sets `search_path = ''` and fully qualifies objects.
- Revoke function execution from `public`, `anon` and `authenticated` by default.
- Grant each exposed RPC explicitly to the minimum role.
- Validate `auth.uid()`, active profile, capability, ownership and expected revision inside the function.
- Never trust a client-supplied `user_id` when it should be derived from `auth.uid()`.
- Functions return safe reason codes; internal SQL details stay in redacted logs.
- Every authority-changing function is covered by allow, deny, duplicate, stale-revision and concurrency tests.

## 17. RLS policy model

### General user-owned policy

Authenticated users may read their own ordinary rows where the product permits it:

```sql
user_id = (select auth.uid())
```

Add indexes on owner and foreign-key columns used by policies and common filters.

### Drafts

- owner can select/insert/update eligible draft rows;
- expected revision is still enforced by RPC/repository workflow;
- no cross-user read;
- submitted snapshots are immutable.

### Published/versioned content

- owner reads own versions;
- authorized reviewer reads the exact submitted snapshot needed for review;
- reviewer cannot update author draft/content;
- historical rows have no ordinary update/delete policy.

### Schedule/workout/rank

- user reads own rows;
- direct client update is denied for authoritative state;
- writes occur through explicit functions;
- ledgers and final evaluations are read-only to clients.

### Views

Use `security_invoker = true` for exposed views on supported Postgres versions. Otherwise place views in an unexposed schema or revoke client access.

### Storage

Policies constrain:

- private bucket ID;
- owner ID;
- path prefix containing authenticated owner ID;
- accepted draft/revision state where required;
- allowed operations.

Object ownership uses `owner_id`, not deprecated `owner`.

## 18. Concurrency and idempotency

Every externally retryable authority-changing operation accepts an idempotency key and records it under a unique constraint.

Use:

- unique constraints for account/week, grant/month, session/item, set/client-entry, submit/idempotency, transaction/idempotency and milestone/user;
- row-level `FOR UPDATE` locks for wallet, rank snapshot, week and publication transitions;
- advisory transaction locks only where a natural row does not yet exist;
- expected revisions for draft saves;
- immutable content hashes for submissions/publication;
- deterministic allocation algorithms and stored results;
- serializable or explicit lock ordering for operations where write skew is possible.

A duplicate request returns the stored result. It does not execute rewards, grants, publication or payment twice.

## 19. Scheduled jobs and catch-up paths

Use Supabase Cron/`pg_cron` for bounded jobs created through migrations.

Planned jobs:

1. materialize due training weeks;
2. materialize monthly free-swap grants;
3. finalize eligible rest items after local day close;
4. resolve expired workout synchronization grace;
5. finalize eligible weeks;
6. clean expired draft media and temporary export objects;
7. record/alert failed jobs.

Rules:

- every job calls an idempotent function;
- jobs operate in small batches with bounded runtime;
- each run records cursor, counts, failures and correlation ID;
- application bootstrap and relevant reads include an on-demand catch-up call, so a missed cron run cannot permanently block a user;
- no more concurrent jobs than the hosted database can safely handle;
- long work is split into batches rather than one unbounded transaction.

## 20. Synchronization state machine

Mobile session synchronization states:

```text
local_active
sync_queued
syncing
synced_active
pending_submission
submission_syncing
provisional_result
finalized_result
retry_required
conflict
quarantined
invalidated
```

Principles:

- the local draft is immediately durable;
- server sequence acknowledgement is monotonic;
- stale/duplicate batches are harmless;
- server snapshot can repair client drift;
- conflict never silently discards local entries;
- authoritative result appears only after server validation;
- client presents correlation/error codes for support.

Dashboard draft synchronization uses analogous save states but does not promise full offline publication.

## 21. Data retention and lifecycle

### Persistent history

Retain while the account/product exists:

- published guidance/routine versions;
- materialized weeks;
- completed workouts;
- ledgers;
- reviews;
- protections/corrections;
- activity/audit evidence required to explain authority.

### Draft cleanup

- abandoned unpublished drafts may be archived after a configurable inactivity period;
- local browser/mobile caches expire after confirmed server persistence and a safe recovery window;
- draft media not referenced by an active draft/revision is quarantined before deletion;
- cleanup is auditable and never deletes published objects.

### Logs

- production client logs are short-lived and redacted;
- platform log retention follows the selected plan;
- product audit records are distinct from verbose operational logs.

## 22. Export, deactivation and deletion

### User export

Release hardening provides user-owned export in CSV/JSON with:

- profile/preferences;
- routines and versions;
- exercises/guidance metadata;
- schedules/workouts/sets;
- rank/XP/wallet transactions;
- protections/corrections;
- media manifest and authorized download references where appropriate.

Export generation is authenticated, rate limited, private and expires.

### Deactivation

MVP account closure is operator-managed:

1. verify request out of band;
2. disable profile immediately;
3. revoke sessions;
4. resolve/quarantine pending workout data;
5. offer/export owned data;
6. block future grants/materialization;
7. record audit event.

### Hard deletion

No ordinary self-service hard-delete button in MVP.

A hard-delete runbook must:

- identify immutable cross-user review evidence;
- pseudonymize actor identity where history must remain explainable;
- delete Storage objects through the Storage API before Auth deletion where required;
- remove or reassign objects owned by the Auth user;
- confirm backups/retention implications;
- delete Auth identity only after dependent data policy completes.

Because Stone Set is a private two-user system, whole-project destruction remains a separate operator recovery/closure action.

## 23. Index and query plan requirements

Each migration must include indexes justified by known access patterns, including:

- every ownership/RLS `user_id`;
- foreign keys used for joins;
- `(user_id, week_start_date)`;
- plan item current date and week;
- draft status/update time;
- publication/effective dates;
- workout session item/user/state;
- set session/exercise/index;
- transaction user/time/type;
- activity user/time;
- idempotency keys;
- media bucket/path/state;
- review queue status/submission time.

Use `EXPLAIN (ANALYZE, BUFFERS)` during performance verification for critical queries. Avoid speculative duplicate indexes.

## 24. Migration strategy by implementation phase

### `TASK-IMP-002A`

- profiles;
- preferences;
- account capabilities/status events;
- client compatibility bootstrap;
- identity triggers/functions;
- Auth/profile RLS and tests.

### `TASK-IMP-003A`

- muscle taxonomy;
- exercise definitions;
- guidance drafts/revisions;
- structured content and versioning.

### `TASK-IMP-003B`

- media metadata;
- Storage bucket configuration/policies;
- YouTube references;
- draft-media cleanup foundations.

### `TASK-IMP-003C`

- routine drafts/days/prescriptions;
- validation runs;
- submissions/reviews;
- published versions.

### `TASK-IMP-004`

- training weeks;
- plan items;
- schedule snapshots;
- swaps;
- credit grants/ledger;
- materialization jobs/functions.

### `TASK-IMP-005A/B`

- workout sessions/exercise snapshots/sets;
- sync batches/submission attempts/results;
- performance records;
- guidance-session snapshots and cache contracts.

### `TASK-IMP-006`

- rank account snapshot;
- RR/XP ledgers;
- PR events;
- weekly evaluation/finalization;
- milestones;
- rank snapshots and cron finalization.

### `TASK-IMP-007`

- progression recommendations;
- pain flags/substitutions;
- protections;
- correction cases/entries.

### `TASK-IMP-008`

- export manifests;
- lifecycle tooling;
- observability/runbook refinements;
- production advisors/index tuning;
- restore reconciliation evidence.

## 25. Database test matrix

Every phase adds pgTAP and integration coverage for:

### Structure

- table, column, type, default, primary/foreign key and unique constraints;
- check constraints and immutable triggers/policies;
- required indexes.

### Authorization

- anonymous denied;
- owner allowed only for intended operations;
- other user denied;
- reviewer can read only submitted evidence needed for review;
- reviewer cannot edit author content;
- direct authoritative writes denied;
- Storage allow/deny paths.

### Functions

- success;
- invalid ownership;
- inactive profile;
- stale revision;
- invalid state transition;
- duplicate idempotency key;
- self-review denial;
- insufficient wallet/RR;
- locked schedule;
- concurrent requests;
- exact reversal/correction.

### Determinism

- 4-, 5- and 6-day allocations;
- date tie-breaks;
- timezone boundaries and DST;
- monthly uniqueness;
- rank threshold transitions;
- weekly finalization and cap rules.

### Recovery

- migration reset from empty database;
- seed reproducibility;
- logical export/restore;
- Storage manifest reconciliation;
- failed job catch-up;
- partial sync retry.

Tests run in CI on every relevant pull request.

## 26. Production deployment rules

- Local migrations and tests must pass before staging.
- Staging applies the exact committed migration set and synthetic/non-production data.
- Production schema changes are deployed from reviewed `main` history through one coordinated pipeline/operator.
- Never edit the remote production schema through Table Editor or ad-hoc SQL without immediately treating it as an incident and reconciling migration history.
- Migration deploy uses preflight status, dry-run where supported, backup confirmation and rollback/forward-fix plan.
- Destructive migrations require explicit phased backfill and compatibility period.
- Clients and database support rolling compatibility across at least the currently released and immediately previous compatible build during migrations.

## 27. Backup and restore

- Supabase managed daily database backups are enabled on the production plan.
- Database backups do not include Storage object bytes.
- Independent encrypted weekly logical database exports and Storage object exports are retained as already accepted.
- Storage export includes path, bucket, size, MIME, owner, metadata row and SHA-256 manifest.
- Restore testing uses a separate environment/project.
- A restore passes only when schema, Auth linkage, data counts, ledgers and every required Storage object reconcile.
- RPO target remains 24 hours and RTO target 4 hours for expected scale.
- PITR is evaluated if data volume, activity or RPO needs exceed daily-backup recovery.

## 28. Primary official references

- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase database functions: https://supabase.com/docs/guides/database/functions
- Supabase migrations: https://supabase.com/docs/guides/deployment/database-migrations
- Supabase testing: https://supabase.com/docs/guides/local-development/testing/overview
- Supabase Storage access control: https://supabase.com/docs/guides/storage/security/access-control
- Supabase Storage ownership: https://supabase.com/docs/guides/storage/security/ownership
- Supabase Storage schema: https://supabase.com/docs/guides/storage/schema/design
- Supabase Cron: https://supabase.com/docs/guides/cron
- Supabase sessions: https://supabase.com/docs/guides/auth/sessions
- Supabase database/backups: https://supabase.com/docs/guides/database/overview
- Supabase production checklist: https://supabase.com/docs/guides/deployment/going-into-prod
