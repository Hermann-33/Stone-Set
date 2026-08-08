# TASK-IMP-003C — Implement routine authoring, review and publication

Status: `APPROVED — BLOCKED BY TASK-IMP-003B MERGE AND START-STATE REVERIFICATION`

This packet is prepared by `TASK-PD-019` but is not executable yet. `TASK-IMP-003A` has satisfied
its merge gate. Approval becomes executable only after `TASK-IMP-003B` is complete and merged, its
final-head CI is successful, and the implementation agent verifies that both prerequisite
contracts still match `main`. A merged planning packet does not satisfy that gate by itself.

## Objective

Implement the first complete reward-bearing routine lifecycle:

```text
owner draft
  -> deterministic routine-validator-v1 result
  -> immutable submitted snapshot and content hash
  -> independent authorized review
  -> immutable future-effective published routine version
```

Deliver owner-only routine authoring, an exact submitted-evidence review workflow, immutable
publication/history, responsive dashboard editor/review surfaces and pure-Dart Android read
contracts. Do not implement weekly materialization, workout execution or rewards.

## Verified planning-time state and execution gate

At packet preparation time:

- Phase 0, Phase 1 and Phase 2A–2C are complete and merged;
- `TASK-IMP-003A` is complete and merged through pull request #14 at merge commit
  `eb59a3b4707ff12c154594408f1f7902555f39e0`;
- its final implementation head is `54d537208e3d44d57173328bf0c03470239a5a9d` and final-head CI
  run `31258974949` succeeded;
- exercise/guidance runtime is present on `main`, while the 003B media prerequisite is not yet
  complete and merged;
- no routine draft, validation, submission, review or publication runtime exists;
- no weekly-plan, workout, RR/XP/rank/wallet or deployment runtime exists;
- Flutter 3.44.7, Dart 3.12.2, Node.js 24.11.1 and Supabase CLI 2.111.0 remain the approved pins;
- the repository uses one root Dart workspace lockfile and one root npm lockfile;
- `public.account_capabilities` already defines the server-managed `routine_reviewer` capability;
- public, anonymous and social signup remain disabled; and
- Supabase's current Data API behavior requires explicit object privileges independently of RLS.

Before any implementation edit, re-check `main`, merge ancestry, tool pins, locks, migrations,
generated source and final CI evidence for both prerequisites. Stop if the verified 003A merge is
not an ancestor, 003B is not complete and merged, or either exercise/guidance/media contract differs
materially from this packet.

Required prerequisite evidence:

```text
TASK-IMP-003A — COMPLETE AND MERGED (PR #14, eb59a3b4707ff12c154594408f1f7902555f39e0)
TASK-IMP-003B — COMPLETE AND MERGED
exercise/guidance revisions and media references available through accepted read contracts
TASK-IMP-003A final-head CI — PASS (31258974949)
TASK-IMP-003B final-head CI — PASS
```

## Mandatory repository reads

Read `AGENTS.md`, every mandatory context file it lists, this packet, and at minimum:

- `docs/product/APPLICATION_WORKFLOW.md`;
- `docs/product/COMPLETE_UI_UX_SYSTEM.md`;
- `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`;
- `docs/product/HYPERTROPHY_ROUTINE.md`;
- `docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`;
- `docs/product/ROUTINE_ELIGIBILITY.md`;
- `docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md`;
- `docs/decisions/ADR-0006-exercise-media-storage-and-youtube-embedding.md`;
- the merged `TASK-IMP-003A` and `TASK-IMP-003B` packets and diffs; and
- the current identity, exercise, guidance, media, dashboard routing/provider, browser-cache,
  migration, pgTAP and CI implementations.

Re-check current official Supabase Data API, Postgres/RLS/function and CLI evidence only where
platform behavior is relevant or has changed. Do not add a dependency without current official
compatibility, license and lockfile review.

## Required branch and Git behavior

```text
branch: codex/task-imp-003c-routine-review-publication
no work directly on main
no history rewriting or force-push
all commits contain TASK-IMP-003C
push the branch
open a draft pull request targeting main
inspect the complete main...HEAD diff
report branch, commit, pull request and final-head CI
```

## Architecture and ownership

```text
Flutter dashboard view
  -> Riverpod controller / view model
  -> routine repository contract
  -> Supabase routine repository/service
       -> owner draft and immutable publication RPCs
       -> reviewer-scoped submitted-evidence RPCs
       -> user-partitioned IndexedDB recovery
```

- Views do not call Supabase or browser storage directly.
- Domain models remain immutable and import neither Flutter nor Supabase.
- Dashboard authoring/review contracts remain separate from Android read-only contracts.
- Browser recovery is private, user-scoped and non-authoritative.
- Author identity, reviewer capability, validation, hashes and state transitions are server-owned.
- A reviewer sees only the exact submitted evidence required to decide a submission and cannot
  mutate the author's draft or snapshot.
- No client may set approval, reward eligibility, publication identity or effective authority.

## Exact database scope

Create one new imperative migration after the merged 003B migration using the supported Supabase
CLI migration command. Do not edit older migrations.

### 1. Mutable routine drafts

Create owner-scoped normalized records equivalent to:

```text
routine_drafts
  id, user_id, name, description, status, revision
  based_on_routine_version_id?, created_at, updated_at

routine_draft_days
  id, routine_draft_id, user_id, day_index, day_type
  title, purpose, primary_muscle_keys[], secondary_muscle_keys[]
  equipment_summary[], coach_note?, position/revision evidence

routine_draft_prescriptions
  id, routine_draft_day_id, routine_draft_id, user_id, position
  exercise_definition_id, guidance_revision_id
  priority, working_sets, rep_min, rep_max, rir_target, rest_seconds
  load_unit, superset_group_key?, progression_rule_version
  pr_comparability_key, notes?
```

Constraints must enforce exactly seven distinct day positions `1..7`, one workout or rest item per
day, no prescriptions on rest days, deterministic prescription order and no duplicate canonical
exercise aliases used as cosmetic complexity. Workout prescriptions reference only active owned
exercise definitions and immutable published guidance revisions readable by the routine owner.
Media is referenced through those pinned guidance revisions; routine rows do not duplicate Storage
paths or YouTube authority.

Draft text uses the accepted Unicode/plain-text safety boundary. Names, summaries and notes have
documented bounded lengths, reject NUL/disallowed controls and are never rendered as executable
HTML or Markdown. Optional superset grouping is a stable bounded draft value used only by the
accepted duration estimator; it does not create reward authority.

All draft saves use an expected root revision and idempotency key. Child replacement/reorder occurs
atomically under the locked root. Stale saves return safe current-revision/correlation evidence and
never silently overwrite another tab's work.

### 2. Deterministic `routine-validator-v1`

Create immutable `routine_validation_runs` containing the draft ID/revision, validator version,
content hash, result state, structured errors, warnings, metrics and timestamp. Errors use stable
codes and exact entity/field paths suitable for dashboard focus links. Do not store executable
markup in validation output.

The server validator must enforce at least:

```text
day slots                         exactly 7
workout days                      4 through 6
rest days                         1 through 3
weekly working sets               32 through 100
prescriptions per workout         3 through 10
working sets per workout          8 through 20
priority prescriptions/workout    at least 1
working sets per prescription     1 through 6
rep minimum                       5 through 30
rep maximum                       rep minimum through 30
RIR target                        0 through 5
rest seconds                      30 through 300
estimated workout duration        20 through 60 minutes
validator version                 routine-validator-v1
```

Use the accepted deterministic estimator: 480-second warm-up, 45 seconds per working set,
45-second standalone exercise transition, 60-second superset-group transition, standalone rest
between working sets and prescribed superset rest once per completed round. Store per-day seconds
and weekly/muscle/set evidence in metrics. Bodyweight load omission is allowed only for a verified
bodyweight variant. Validation is product-integrity guidance, not medical advice.

### 3. Canonical content and immutable submissions

Canonicalize the full reward-bearing routine as one documented versioned JSON array, not an
ambiguous concatenated string or unordered object. Its order must include:

```text
"stone-set-routine-content-v1"
normalized routine name and description
seven days ordered by day_index
for each day: type, normalized summaries, ordered muscle/equipment values and coach note/null
for each workout: ordered prescriptions
for each prescription: exercise/guidance IDs, position, priority, sets, reps, RIR, rest,
load unit, superset group/null, progression version, server-derived PR comparability key and note
```

Use UTF-8, Unicode NFC, the accepted whitespace/newline rules and Postgres `jsonb::text` SHA-256
serialization consistent with the 003A canonical-hash boundary. Commit matching SQL/Dart golden
vectors for null/empty values, escaping, Unicode normalization and every ordered array. The server,
not the client, derives the authoritative content hash and comparability evidence.

Create immutable `routine_submissions` that pin author, draft ID/revision, canonical snapshot,
content hash, validation-run ID, status and submission timestamp. Submission reruns hard validation
under locks. Later draft edits do not mutate the snapshot. A retry with the same idempotency key
returns the stored correlation/result; a changed request using that key is rejected.

### 4. Independent review

Create immutable `routine_reviews` that pin submission, author, reviewer, decision, structured
rejection reasons, reviewer note, submitted hash, validator evidence and review timestamp.

- reviewer authorization comes only from active server-managed `routine_reviewer` capability;
- the authenticated reviewer must differ from the author;
- reviewers can approve or reject but cannot edit author drafts or submitted snapshots;
- approval names the exact submission/hash/validator result;
- rejection requires at least one stable structured reason and a useful bounded note;
- decision reruns or verifies current hard-validator evidence without trusting client claims;
- a decision is immutable and idempotent; and
- a rejected or superseded attempt leaves the last published routine unchanged.

Implement the accepted emergency override only as a separate trusted-operator operation using the
existing service-role boundary. It requires explicit environment and confirmation flags, dry-run
where technically feasible, a mandatory bounded reason and an immutable audit event. It must never
enter Flutter code, appear in the reviewer UI or weaken ordinary self-review denial. Tests must
prove missing reason, wrong environment/confirmation and public-client execution are denied.

### 5. Immutable publication and history

Create immutable `routine_versions`, `routine_version_days`,
`routine_version_prescriptions` and `routine_eligibility_snapshots`. Pin at least:

```text
owner and monotonically increasing version number
approved submission/review and exact content hash
routine-validator-v1 result and metrics
ordered days/prescriptions
exercise definition and published guidance revision IDs
progression/comparability evidence
future effective Monday
supersedes routine version/null
published timestamp and correlation evidence
```

Publication locks the approved submission/review and current owner version sequence, reruns the
hard validator, proves the approved hash still matches and rejects self-review or stale evidence.
It accepts only a future Monday. Because Phase 4 owns weeks and locks, 003C stores scheduled
future-effect evidence but does not materialize or activate a training week. Phase 4 must later
revalidate that the selected version is effective and the week is unlocked.

Published versions, child rows, hashes, validator snapshots, reviewer identity and timestamps have
no ordinary update/delete path. Restore or reuse duplicates an immutable version into a new owned
draft. History is paginated, exact-counted and never recalculated under a newer validator.

### 6. Narrow RPC contract

Implement versioned, bounded operations equivalent to:

- list/get owner routines and exact-counted version history;
- create/save/archive routine draft with expected revision and idempotency;
- validate a precise draft revision;
- submit an immutable validated snapshot;
- list/get reviewer-visible submissions with bounded search/filter/sort/pagination;
- approve or reject the exact submission;
- publish an approved submission for a future Monday; and
- duplicate an immutable routine version as a new owner draft.

Every retryable mutation returns a durable safe envelope with operation, object IDs, revision/state,
`replayed` and `correlationId`. State-transition errors use stable safe codes. No error, log or
operation-result record contains complete routine text, reviewer private notes, tokens or secrets.

### 7. Data API, grants, RLS and function execution

Treat these as independent controls:

```text
Data API object privilege
RLS row authorization
function EXECUTE privilege and function-body checks
```

For every table, view, sequence and function:

- revoke unintended `PUBLIC`, `anon` and `authenticated` privileges;
- explicitly grant only the required operations to intended roles;
- enable RLS on every exposed private relation;
- use `TO authenticated` plus indexed ownership/reviewer predicates;
- use both `USING` and `WITH CHECK` for any permitted direct update;
- never use `auth.role()` or editable user metadata for authorization;
- expose views only with `security_invoker = true`;
- keep security-definer helpers in an unexposed schema with empty search path, qualified objects,
  actor/capability/ownership validation and narrow wrapper execution grants;
- deny anonymous access and direct mutation of submissions, reviews, validator runs and versions;
- allow owners to read only their own drafts/submissions/versions;
- allow capable reviewers to read only exact submitted evidence needed for review;
- deny reviewer access to unrelated drafts and deny all reviewer edits to author content; and
- test object-level denial separately from row-level denial and function denial.

No SQL-created object is assumed automatically exposed or usable through the Data API.

## Shared domain/data scope

- Immutable pure-Dart routine draft/read/version, prescription, validation, review and result types.
- Separate read-only published-routine contract suitable for Android from dashboard authoring and
  reviewer contracts.
- Supabase services/repositories that bind bounded RPCs and strictly decode schema/version/state,
  replay/correlation and ownership evidence.
- Safe error mapping for validation paths, stale revisions, duplicate retries, forbidden review,
  self-review, changed hashes and invalid state transitions.
- No Flutter, Supabase or browser imports in domain.
- No client implementation of authoritative hash, eligibility, review or publication decisions.

## Dashboard scope

Typed guarded routes must cover at least:

```text
/routines
/routines/new
/routines/:routineId
/routines/:routineId/versions/:versionId
/reviews
/reviews/:submissionId
```

Integrate the existing shell, search, command palette, attention queue and activity abstractions
without inventing later persisted activity authority.

### Routine library/editor

- bounded owner-only search/filter/sort/pagination and draft/submitted/approved/published states;
- expanded three-pane and compact single-pane layouts;
- seven-day outline with exactly one workout/rest item per day;
- exercise/guidance picker limited to permitted published guidance;
- prescription create/edit/remove/duplicate/reorder with keyboard alternative;
- live set, duration, equipment and muscle summaries clearly marked preview/non-authoritative;
- server validation summary linking/focusing exact fields;
- mobile preview using the accepted Android presentation contracts;
- autosave, offline, retry, stale/conflict compare and recovery without silent overwrite;
- named checkpoint/duplicate-as-new-draft behavior where it does not imply publication authority;
- compare against current published version and immutable history; and
- persistent state bar limited to valid lifecycle actions.

Use a user/routine/revision/schema-partitioned IndexedDB record through the existing browser-cache
boundary. Compare-and-swap local revisions, expiry, corruption/quota/unsupported handling,
logout/user-change clearing and remote conflict preservation are mandatory. Submission, review and
publication require connectivity and fresh server revalidation.

### Review queue/screen

- bounded permission-filtered queue containing submitted items only;
- owner, submission time, validator state, requested effective date and status;
- exact immutable snapshot and hash being reviewed;
- side-by-side/inline diff from the prior published version;
- highlighted prescription and pinned guidance changes;
- volume/duration/muscle summaries and mobile preview;
- approve/reject with exact hash confirmation;
- self-approval unavailable with explanation;
- structured rejection reasons and required useful note;
- permission, already-decided, changed/stale and connectivity states; and
- no control that edits another user's content.

All layouts cover loading, empty, refreshing, offline, saving, conflict, rejected, approved,
scheduled, published, superseded, permission-denied and not-found states. Preserve URL/back/forward,
focus, scroll and safe resize behavior.

## Android scope

Add compile-time pure-Dart read-only contracts/models for immutable routine versions, days,
prescriptions, eligibility snapshots and pinned guidance references needed by later Week/workout
tasks. Run Android compile/regression tests. Do not bind real Week/Home/workout data, add routine
authoring/review UI, persist routine data locally or claim an active schedule in this task.

## Explicit non-goals

- Phase 4 weekly materialization, seven dated plan items, locks, allocations, swaps or grants;
- workout start/logger/SQLite/outbox/synchronization or active-session snapshots;
- RR, XP, PR, rank, wallet, penalty, milestone, consistency or finalization behavior;
- progression recommendations, pain/substitution, protection or correction behavior;
- remote Supabase/Vercel resources, production deployment or account provisioning;
- public/shared routine marketplace, public profiles, coach/organization editing or comments;
- cross-user draft editing, reviewer rewriting or self-approval;
- medical diagnosis, AI-generated routines or automatic claims of physiological optimality;
- new exercise/media upload or YouTube playback behavior owned by 003A/003B; and
- historical mutation or recalculation using a later validator.

## Acceptance criteria

1. Owner drafts represent exactly seven ordered days and accepted bounded prescriptions.
2. `routine-validator-v1` deterministically enforces all hard structural/duration rules.
3. Submission pins an immutable server-canonical snapshot, hash and validation run.
4. Only a different active capable reviewer may decide the exact submitted evidence.
5. Approved publication reruns validation/hash checks and creates immutable future-Monday history.
6. Object privileges, RLS and function execution independently deny anonymous/cross-user/edit paths.
7. Durable idempotency, expected revisions and locks prevent duplicate/lost transitions.
8. Dashboard authoring/review works adaptively, accessibly and survives recoverable interruption.
9. Android receives pure-Dart read-only contracts only; no schedule/workout authority is added.
10. Emergency override exists only through confirmed trusted tooling with reason and immutable audit.
11. No Phase 4+, remote infrastructure, secret or personal data enters the diff.

## Required verification

### Dependencies and generated source

- exact locked Dart/npm restore, one root lockfile each and no overrides/nested locks;
- two-pass Riverpod/typed-route generation with zero freshness-pass output;
- formatting and strict fatal-info analysis including Riverpod lint;
- dependency/license/advisory review if and only if the approved graph changes.

### Database/security

- local Supabase clean reset, migration list/replay, pgTAP, database lint and advisors;
- schema/default/FK/check/unique/index/immutable-trigger tests;
- exact seven-day and prescription constraints;
- `routine-validator-v1` fixtures for valid 4/5/6-day routines and every required invalid boundary;
- duration-estimator and SQL/Dart canonical-hash golden parity;
- anonymous/owner/other-user/capable-reviewer/self-review/inactive-profile matrices;
- object privilege, RLS row and function execution denial tested independently;
- reviewer exact-submission visibility and unrelated-draft/edit denial;
- stale save, concurrent save/submit/review/publish, changed-hash and duplicate-idempotency tests;
- rejection preserves current publication; future-Monday and immutable-history tests;
- operator override allow/deny/environment/confirmation/reason/audit tests;
- no complete routine/reviewer note in operation results or logs.

### Shared/data/cache

- domain validation/model and repository/service/error-mapping tests;
- server-bounded pagination/filter/sort and strict response-decoding tests;
- read-only Android contract compilation;
- IndexedDB schema upgrade, transaction completion, compare-and-swap, multi-tab conflict,
  expiry, corruption/quota/unsupported and logout/user-isolation tests.

### Dashboard/browser/accessibility

- create/edit/reorder/duplicate/validate/submit/review/reject/approve/publish/history flows;
- exact diff, field-link, mobile-preview and conflict recovery tests;
- compact/medium/expanded widths, 100/150/200% text, dark/light/system and reduced motion;
- keyboard reorder, focus/error summary, semantics/status announcement and table-header tests;
- direct link, refresh, back/forward and route-exit conflict protection;
- Chrome integration and reviewed deterministic Linux goldens for editor/review/conflict states;
- bounded long-routine, autosave and list performance tests.

### Regression/build/CI/review

- all affected shared, dashboard, identity, exercise/guidance/media and Android compile tests;
- dashboard release Web build and privileged-credential bundle scan;
- Android release build because mobile-consumed shared contracts change;
- API 24 profile only if the final diff changes mobile runtime/rendering/performance paths;
- complete migration/generated/main diff, `git diff --check`, secret/personal-data review and
  clean tree;
- one path-sensitive final-head GitHub Actions run with every required affected lane successful and
  no unexpected skip/cancel/pending check.

## Required documentation updates

Update only documents whose owned implemented facts change: README, current-state/architecture/
codebase/roadmap/implementation/UI/handoff/task/security documents and the active append-only audit
volume. Preserve historical audits and accepted ADRs. Do not approve or execute `TASK-IMP-004`
during this implementation task.

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-003C
Branch/commit/PR:
Prerequisite merge verification:
Database/migration:
Routine drafts/validator:
Submission/review/publication:
Canonical hashes/immutable history:
Data API/grants/RLS/functions:
Dashboard editor/review/routes/cache:
Android read-only contracts:
Accessibility/themes/performance:
Tests/builds/CI:
Security/secrets:
Explicitly not implemented:
Documentation:
Risks/blockers:
Exact next action:
```
