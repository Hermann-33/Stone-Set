# TASK-IMP-003A — Implement exercise library and structured guidance

Status: `COMPLETE AND MERGED`
Result: pull request #14, final head `54d537208e3d44d57173328bf0c03470239a5a9d`, merge commit
`eb59a3b4707ff12c154594408f1f7902555f39e0`, final CI run `31258974949` passed.
Approved by: `TASK-PD-018`
Target phase: `Phase 3A — Exercise library and structured guidance`

## Objective

Implement the first authoritative Stone Set product-content vertical:

- server-seeded muscle taxonomy;
- owner-scoped exercise definitions and ordered primary/secondary muscle assignments;
- mutable server guidance drafts with optimistic concurrency;
- private IndexedDB recovery for dashboard edits;
- deterministic validation and immutable published guidance revisions;
- adaptive dashboard exercise library, structured guidance editor, conflict recovery and version
  history;
- compile-time Android read-only exercise/guidance contracts.

This packet stops before images, Storage, YouTube, routines, independent review, scheduling,
workouts, scoring or deployment.

## Dependencies and verified starting state

Depends on:

1. `TASK-IMP-001`, `TASK-IMP-002A`, `TASK-IMP-002B` and `TASK-IMP-002C` complete and merged;
2. accepted technology, database, product/UI and ADR baselines still current;
3. final implementation-start tool, dependency, Supabase and browser compatibility verification.

Verified by `TASK-PD-018` on 2026-08-07:

```text
main / origin/main        be0f57eee35066da0590e0cf2a3f55d6193231af
TASK-IMP-001              COMPLETE AND MERGED
TASK-IMP-002A             COMPLETE AND MERGED
TASK-IMP-002B             COMPLETE AND MERGED
TASK-IMP-002C             COMPLETE AND MERGED
Dashboard PR              #12 — MERGED
Dashboard merge           be0f57eee35066da0590e0cf2a3f55d6193231af
Final 002C CI             31165238497 — PASS
Post-merge main CI        31166440467 — PASS
Flutter                   3.44.7
Dart                      3.12.2
Node.js                   24.11.1
Supabase CLI              2.111.0
Workspace lockfile        one root pubspec.lock; no nested locks or overrides
Dashboard                 Web-only authenticated adaptive shell/Overview
Supabase                  local-only identity/session foundation
Product schema            no exercise/guidance/media/routine runtime yet
Remote infrastructure     NONE
```

Preserve the proven coordinated application graph:

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
riverpod_lint plugin   3.1.8
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1
analyzer               12.1.0
test                   1.31.0
test_api               0.7.11
```

The only new third-party direct dependency approved is:

```text
idb_shim               2.9.6+2   apps/dashboard only
```

Current package metadata identifies it as stable, compatible with Dart `^3.12.0`, based on modern
Web APIs and usable with JavaScript/Wasm compilation. Reverify the exact current official evidence
and solve the full workspace graph at implementation start. Pin it exactly, update only the root
lockfile and verify licences/advisories. Do not add `sembast_web`, `shared_preferences`, another
database adapter, dependency overrides, nested lockfiles, obsolete `custom_lint`, a second state
framework or a second router. Riverpod lint remains an analysis-server plugin.

## Mandatory repository reads

Read `AGENTS.md`, README, every mandatory context document, the accepted application workflow,
exercise-guidance/media and complete UI specifications, ADR-0001/0002/0005/0006, this packet,
merged identity/dashboard/shared code, existing migrations/tests/tooling and the CI workflow.
Recheck current `main`, all prerequisites and official Supabase/package evidence rather than trusting
this packet blindly.

## Required branch and Git behavior

```text
branch: codex/task-imp-003a-exercise-guidance
no work directly on main
no history rewriting or force-push
all commits contain TASK-IMP-003A
push the branch
open a draft pull request targeting main
inspect complete main...HEAD diff
report branch, commit, pull request and final-head CI
```

## Architecture and ownership

```text
Flutter view
  -> Riverpod controller / AsyncNotifier
  -> exercise/guidance repository contract
  -> dashboard repository implementation
       -> Supabase table/RPC service
       -> IndexedDB draft-cache service
```

- Views contain no Supabase or browser-storage calls.
- Repositories coordinate local recovery and authoritative remote state.
- Domain models/contracts remain immutable and import neither Flutter nor Supabase.
- Provider overrides supply deterministic test fixtures.
- Exercise/guidance controllers and cache state live below the authenticated user-keyed scope and
  are destroyed on logout, session loss, operator revocation or user-ID change.
- The browser cache integrates with the existing dashboard private-cache clearing contract.
- Android receives compile-time read-only models/contracts only; it gets no editor or product read
  integration before the workout/guidance packets.

## Exact database scope

Use one new imperative migration after `20260806000100_identity_sessions.sql`. Create it through the
supported Supabase CLI migration command; do not invent a filename and do not alter the old migration.

### 1. Muscle taxonomy

Create a stable `public.muscles` taxonomy seeded idempotently by migration, not by user seed data.
Stable lowercase keys cover the accepted MVP groups used by the product routine: chest, back,
anterior/lateral/posterior deltoids, biceps, triceps, forearms, quadriceps, hamstrings, glutes,
calves and abdominals. Each row has a fixed UUID, stable key, display name and display order.

- authenticated read only;
- anonymous and direct client insert/update/delete denied;
- fixed keys/IDs tested;
- no medical-diagnosis meaning;
- changing the canonical taxonomy later requires a bounded migration and compatibility review.

### 2. Exercise definitions

Create owner-scoped stable definitions with at least:

```text
id, user_id
canonical_name, normalized_name
variant_key
archived_at
cloned_from_exercise_id
revision
created_at, updated_at
```

Use server-owned normalization: Unicode NFC, trim, collapse internal whitespace and lowercase for
duplicate comparison. Names are 1–120 Unicode characters. Optional variant keys use stable
lowercase snake-case identifiers up to 64 characters.

Because accepted product guidance uses `equipment[]`, create an ordered
`exercise_definition_equipment` association with one to ten non-empty lowercase snake-case keys,
each at most 64 characters, and a unique exercise/key pair. Phase 3A does not claim a complete
global equipment taxonomy. Duplicate detection compares normalized name/variant plus the equipment
key set in lexical order, while stored display order remains explicit. A duplicate for one owner
requires confirmation through the authoritative operation; it must never silently overwrite an
existing definition.

Create `exercise_definition_muscles` (or an equivalently explicit association) with role
`primary|secondary`, stable position, a unique exercise/muscle pair and an ownership path that can
be indexed and enforced without trusting client-supplied ownership. Each exercise has one or more
primary muscles. The same muscle cannot occur in both roles. Primary and secondary display order is
deterministic. All foreign keys and RLS predicate columns have justified indexes.

The migration seeds this exact immutable MVP taxonomy matrix:

| Order | Fixed UUID | Stable key | Display name |
|---:|---|---|---|
| 1 | `a3000000-0000-4000-8000-000000000001` | `chest` | Chest |
| 2 | `a3000000-0000-4000-8000-000000000002` | `back` | Back |
| 3 | `a3000000-0000-4000-8000-000000000003` | `anterior_deltoids` | Anterior deltoids |
| 4 | `a3000000-0000-4000-8000-000000000004` | `lateral_deltoids` | Lateral deltoids |
| 5 | `a3000000-0000-4000-8000-000000000005` | `posterior_deltoids` | Posterior deltoids |
| 6 | `a3000000-0000-4000-8000-000000000006` | `biceps` | Biceps |
| 7 | `a3000000-0000-4000-8000-000000000007` | `triceps` | Triceps |
| 8 | `a3000000-0000-4000-8000-000000000008` | `forearms` | Forearms |
| 9 | `a3000000-0000-4000-8000-000000000009` | `quadriceps` | Quadriceps |
| 10 | `a3000000-0000-4000-8000-00000000000a` | `hamstrings` | Hamstrings |
| 11 | `a3000000-0000-4000-8000-00000000000b` | `glutes` | Glutes |
| 12 | `a3000000-0000-4000-8000-00000000000c` | `calves` | Calves |
| 13 | `a3000000-0000-4000-8000-00000000000d` | `abdominals` | Abdominals |

Tests assert every literal UUID, key, label and order and reject direct mutation.

Archive is soft and reversible while no later accepted rule prevents restoration. Ordinary hard
delete is unavailable. Archive preserves published history and future foreign-key safety.

Once an exercise has a published guidance revision, canonical name, variant and equipment identity
cannot be silently redefined in this phase. A material identity change creates/clones a new
definition. Muscle-assignment and structured-guidance changes are captured in a new draft/revision,
while older revisions retain their pinned ordered muscle evidence.

### 3. Guidance drafts

Create one current mutable owner draft per exercise with:

```text
id, exercise_id, user_id
base_guidance_revision_id
structured_content_schema_version = 1
structured_content
revision
created_at, updated_at
```

Schema version 1 is structured plain text only:

```text
shortExplanation
setupSteps[]
executionSteps[]
techniqueCues[]
commonMistakes[]
safetyNotes[]
```

Short explanation is 1–2,000 characters. Each ordered list contains at most 50 trimmed, non-empty
items of at most 500 characters. At least one setup or execution step is required for publication.
At least one primary muscle is always present through the exercise-muscle association. Text-only guidance
is publishable; images/video are recommended but not required and are not part of this phase.

Server save accepts the expected draft revision and an idempotency key. It returns a stable result
envelope with the new revision or a structured stale-revision conflict containing safe comparison
evidence. It never applies last-write-wins and never logs complete guidance text.

### 4. Immutable guidance revisions and hashes

Create immutable published revisions and ordered pinned primary/secondary muscle evidence with at least:

```text
id, exercise_id, user_id
version_number
structured_content_schema_version
structured_content
content_hash
revision_hash
supersedes_revision_id
published_at
```

Publication validates and canonicalizes content on the server. Canonical JSON version 1 is a JSON
array, avoiding ambiguous concatenation and object-key-order assumptions. Its exact ordered elements
are:

```text
[
  "stone-set-guidance-content-v1",
  normalizedCanonicalName,
  variantKeyOrNull,
  orderedEquipmentKeys,
  orderedPrimaryMuscleKeys,
  orderedSecondaryMuscleKeys,
  normalizedShortExplanation,
  normalizedSetupSteps,
  normalizedExecutionSteps,
  normalizedTechniqueCues,
  normalizedCommonMistakes,
  normalizedSafetyNotes
]
```

Every string is UTF-8, Unicode NFC and trimmed. Names collapse internal Unicode whitespace to one
space. Guidance strings normalize CRLF/CR to LF, preserve intentional internal spaces/newlines,
reject NUL and disallowed control characters, and never convert empty items to null: absent variant
is JSON null; ordered lists are arrays; blank list items are invalid. Array order is semantically
meaningful and changes the hash. The server hashes `convert_to(canonical_jsonb::text, 'UTF8')` with
the supported Postgres crypto extension and stores lowercase hexadecimal SHA-256 values:

- `content_hash`: canonical user-visible guidance and pinned identity/muscle content;
- `revision_hash`: a second fixed JSON array containing
  `stone-set-guidance-revision-v1`, exercise ID, owner ID, version number, content hash and
  supersession revision ID/null.

The revision row stores the canonical name/variant/equipment snapshot that was hashed, while the
revision-muscle association stores the ordered stable muscle evidence. SQL and Dart share committed
golden input/hex vectors for normalization, escaping, null/empty values and every ordered array.

Document the exact serialization in SQL comments/tests and Dart fixtures. A no-op duplicate publish
returns the existing matching revision or a stable no-change result; it does not create silent
duplicate history. Published rows, version numbers, hashes, timestamps and muscle evidence have no
ordinary update/delete path and are protected by grants, RLS and immutable constraints/triggers.

Create a narrow private operation-result table (for example,
`private.guidance_mutation_operations`) for every retryable create/save/archive/unarchive/clone/
publish mutation. Unique `(user_id, operation_name, idempotency_key)` records store the safe result
envelope for exact replay and correlation evidence. They store no complete guidance text and are
inaccessible to public clients.

### 5. Atomic operations

Implement narrow versioned RPCs/result envelopes for:

- create/update exercise and ordered equipment plus primary/secondary muscles with expected
  revision;
- archive/unarchive exercise with expected revision;
- save guidance draft with expected revision and idempotency;
- validate guidance draft;
- publish guidance revision atomically with expected exercise revision, expected draft revision and
  idempotency;
- clone an owned exercise into a new owned definition and draft with provenance.

Every retryable mutation accepts an idempotency key and persists/replays its safe result. Duplicate
confirmation is a server input bound to the normalized identity; concurrent confirmed creates are
serialized so a race cannot bypass the warning or overwrite another definition.

Publication locks the exercise, equipment/muscle assignments and draft in consistent order, rejects
either stale expected revision, assigns the next version safely, validates active
profile/ownership/state, stores immutable evidence and returns the stored result on retry.
The clone source must belong to the authenticated user in Phase 3A. Cross-user read/clone is denied
because no accepted sharing permission model exists.

### 6. Data API, RLS and function privilege boundary

Review every table, view, sequence and function independently:

```text
Data API object access
RLS row authorization
function EXECUTE privilege
```

- revoke unintended `PUBLIC`, `anon`, `authenticated` and `service_role` privileges before narrow
  grants;
- include `service_role` in every table/view/sequence/function ACL test; grant it nothing unless an
  explicit trusted maintenance path is documented and required;
- enable RLS on every exposed table;
- use `TO authenticated` with indexed `(select auth.uid())` ownership predicates;
- use both `USING` and `WITH CHECK` for mutable owner rows;
- anonymous, anonymous-Auth, inactive-profile and cross-user access denied;
- deny expired sessions, selected/global revocations and `must_change_password` sessions through
  the existing active-session authorization helper;
- grant authenticated clients only intended SELECT access; direct authenticated INSERT, UPDATE and
  DELETE are denied on every new table and every write goes through narrow RPCs;
- direct mutation of server-owned identity, revision, hashes, publication or archive evidence denied;
- no `auth.role()` pattern and no authorization from editable user metadata;
- exposed views use `security_invoker = true` and explicit grants;
- functions default to invoker; any necessary definer helper lives in `private`, uses an empty search
  path and qualified names, validates the authenticated identity/active session/profile, revokes
  default execution and grants only the narrow wrapper/caller role;
- no assumption that a SQL-created object is automatically exposed or usable.

## Dashboard scope

### Routes and integration

Replace the Exercises placeholder with typed, auth-guarded routes equivalent to:

```text
/exercises
/exercises/new
/exercises/:exerciseId
/exercises/:exerciseId/guidance/drafts/:draftId
/exercises/:exerciseId/guidance/revisions/:revisionId
```

Use UUID validation, safe not-found/unauthorized outcomes and the existing shell/auth/password/
compatibility guards. Back/forward, refresh, direct link and safe resize preserve URL-backed
selection/filter/editor state. Enable the command-palette create-exercise action. Global search
uses real permission-filtered exercise/guidance results; categories not yet implemented remain
truthfully unavailable or explicitly labelled fixtures.

### Exercise library

- paginated, bounded and permission-filtered search;
- filters for archive/publication/equipment/muscle;
- sort by name, updated time and publication state;
- compact cards and medium/expanded list-detail presentation;
- create, edit-before-publication, archive/unarchive and owned clone;
- explicit normalized-duplicate warning/confirmation;
- Overview, Guidance and Versions detail sections;
- media and routine usage shown only as unavailable future capability, never fake persisted data.

Widths retain the established dashboard tiers: compact below 720, medium 720–1119 and expanded at
1120 or wider. The same route tree serves every tier. Long lists paginate or virtualize.

### Structured guidance editor

- ordered plain-text sections from schema version 1;
- inline validation plus linked/focusable error summary;
- keyboard move alternatives for ordered items;
- visible `Saving`, `Saved`, `Offline`, `Syncing`, `Conflict`, `Failed to save`, and `Read only`
  states with semantics, not color alone;
- debounced local recovery save and bounded remote sync;
- stale server revision preserves both local and remote variants and opens compare/recover;
- retry, use-local-as-new-draft and accept-server recovery actions;
- online-only publication with explicit validation/no-op/result states;
- immutable version list, compare and duplicate-as-new-draft;
- clear explanation that identity/prescription-affecting changes require later routine review.

No UI may claim that an IndexedDB draft is published or authoritative.

### IndexedDB recovery contract

Use `idb_shim 2.9.6+2` through an interface with an in-memory fake for tests. Database schema version
1 stores only non-secret draft recovery records with stable composite identity
`(userId, exerciseId, draftId, cacheSchemaVersion)`. Expected server revision is mutable record data,
never part of the key. Records include local revision, structured payload, timestamps, sync/expiry
metadata and no token, password, service key or privileged configuration.

- await transaction completion;
- create/upgrade stores only in the supported upgrade callback;
- compare-and-swap local revisions so concurrent tabs surface conflict rather than overwrite;
- tolerate unsupported/quota/corrupt storage with explicit failed local-save state while retaining
  the in-memory editor value;
- never auto-expire unsynchronized work;
- clean confirmed obsolete/synchronized recovery records after a documented 30-day window;
- clear the user's records on logout/session loss/revocation/user change and prove no second-account
  access;
- browser cache is non-authoritative and publication always revalidates remote revision/content.

## Android scope

Add only compile-time pure Dart read-only exercise/guidance models and repository contracts needed
by later pinned workout guidance. Ensure Android builds and tests still pass. Do not add an Android
exercise library, editor, product fetch, cache or route.

## Explicit non-goals

- media metadata, image processing/upload, Storage bucket/RLS or backup manifest;
- YouTube URL parsing, preview or playback;
- routine usage persistence, prescriptions, validation, review or publication;
- cross-user gallery/read/clone/edit;
- workout/mobile guidance rendering or offline workout cache;
- schedule, rewards, rank, wallet, progression or correction behavior;
- public signup/recovery, new operator credential behavior or Auth configuration change;
- remote Supabase, Vercel, production accounts or deployment;
- executable HTML/Markdown rendering, rich-text embeds or medical advice;
- hard deletion of published/history-bearing content;
- analytics, telemetry or logging complete guidance payloads.

## Acceptance criteria

1. Clean migration reset creates the fixed taxonomy and complete exercise/guidance schema.
2. Object grants, RLS and function execution independently enforce anonymous/owner/cross-user and
   inactive-profile boundaries.
3. Expected revisions, idempotency and locks prevent lost updates and duplicate publication.
4. Published revisions and hashes are deterministic and immutable.
5. Dashboard provides real owner-scoped library/create/edit/archive/clone/publish/history behavior.
6. IndexedDB recovery survives refresh/process interruption without becoming authority and clears
   across account transitions.
7. Conflict comparison/recovery never silently discards either version.
8. Compact/medium/expanded, keyboard, semantics, 200-percent text and reduced motion pass.
9. Android adds read-only contracts only and all prerequisite behavior regresses cleanly.
10. No Phase 3B/3C, remote infrastructure, secret or personal data enters the diff.

## Required verification

### Dependency and generated source

- exact `dart pub get --enforce-lockfile` and `npm ci`, then tracked-file cleanliness;
- one root Dart lockfile, no nested locks/overrides and exact `idb_shim 2.9.6+2` resolution;
- dependency licence/advisory and full graph review;
- two-pass Riverpod/typed-route generation with zero outputs on the freshness pass;
- formatting and strict fatal-info analysis including Riverpod lint.

### Database and security

- local Supabase start, clean reset, migration list/replay, pgTAP and database lint;
- schema/type/default/FK/unique/check/immutable/index tests;
- fixed taxonomy IDs/keys/order and mutation denial;
- object grants, RLS and function execution tests as independent layers;
- anonymous/owner/cross-user/inactive-profile and ownership-mutation matrices;
- save/archive/clone/publish allow/deny and structured safe errors;
- stale revision, concurrent save/publish, idempotent retry and duplicate content tests;
- serialized concurrent duplicate-create/confirmation tests and durable replay tests for every
  idempotent mutation;
- content/revision hash golden vectors and immutable update/delete denial;
- archive/history/provenance preservation;
- no executable HTML and no unsafe metadata/logging path;
- database advisors where supported by the pinned CLI/local stack.

### Dart, repository and browser cache

- normalization, duplicate confirmation and validation unit tests;
- domain/repository/service/controller/provider tests;
- canonical serialization/hash fixture parity with SQL;
- local/remote save, offline, retry, conflict, compare and recovery tests;
- IndexedDB schema upgrade, transaction completion, multi-tab compare-and-swap, quota/unsupported/
  corruption handling, expiry and logout/user-isolation tests;
- provider invalidation and authenticated user-scope destruction.

### Dashboard/UI/browser

- create/edit/archive/unarchive/clone/validate/publish/version/compare flows;
- loading/empty/populated/refreshing/stale/offline/saving/failed/conflict/read-only/permission/not-found
  states;
- compact/medium/expanded list-detail/editor and safe resize;
- keyboard/focus/semantics/error-summary/status-announcement/table-header tests;
- 100/150/200-percent text, long content, light/dark/system and reduced motion;
- direct links, refresh, back/forward and route-exit conflict protection;
- browser recreation proves IndexedDB recovery and account transition proves clearing;
- reviewed deterministic Linux goldens for representative list/editor/error/conflict states;
- Chrome tests, idle-frame/performance and bounded long-list/search/autosave tests.

### Regression/build/review

- all existing identity, mobile, dashboard, shared-package and golden tests;
- Android release build and rank-bundle regression; API 24 only if the final diff affects mobile
  runtime/performance (pure read-only contracts do not trigger it under ADR-0007);
- dashboard release Web build and static bundle privileged-credential scan;
- local Auth/signup/operator/pgTAP/lint lifecycle regressions;
- complete migration/generated/main diff, `git diff --check`, no-secret/client-bundle review and clean
  tree;
- all required final-head GitHub Actions successful with no unexpected skip/cancel/pending check.

## Required documentation updates

Update only owned implemented facts in README, canonical current-state/architecture/codebase/roadmap/
implementation/UI/handoff documents, this packet, security documentation and the active append-only
audit volume `docs/context/AUDIT_LOG_CONTINUED_3.md`. Preserve historical audits and ADRs. Do not
approve `TASK-IMP-003B` during implementation.

## Implementation result

The approved database, shared-contract, dashboard, IndexedDB, tests, documentation and
path-sensitive CI scope was completed and merged through pull request #14. Final implementation
head `54d537208e3d44d57173328bf0c03470239a5a9d` merged as
`eb59a3b4707ff12c154594408f1f7902555f39e0`. Final-head GitHub Actions run `31258974949`
passed repository/path classification, generation freshness, formatting, strict analysis,
domain/data/mobile/dashboard tests, reviewed Linux dashboard goldens, Chrome, Android release,
Web release/bundle review and local Supabase reset/Auth/pgTAP/lint. The API 24 profile correctly
skipped because the final diff did not affect mobile runtime performance. No media, routine,
workout, reward or remote infrastructure was implemented.

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-003A
Branch/commit/PR:
Database/migration:
Taxonomy/exercises:
Guidance drafts/publication/hashes:
Data API/grants/RLS/functions:
Dashboard library/editor/routes:
IndexedDB recovery/conflicts:
Android read-only contracts:
Accessibility/themes/performance:
Tests/builds/CI:
Security/secrets:
Explicitly not implemented:
Documentation:
Risks/blockers:
Exact next action:
```
