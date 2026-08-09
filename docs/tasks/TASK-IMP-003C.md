# TASK-IMP-003C — Implement routine authoring, review and publication

Status: `APPROVED — EXECUTABLE`

Mode: `FAST PRIVATE TWO-USER MVP`

`TASK-IMP-003A` and `TASK-IMP-003B` are complete and merged. This packet is executable immediately.

## Objective

Implement the smallest complete routine workflow needed by the two known Stone Set users:

```text
owner creates/edits 7-day routine
  -> server validates
  -> owner submits
  -> second user reviews
  -> reviewer approves or rejects
  -> approved routine is published as an immutable version
```

The goal is working functionality, not production hardening. Keep the existing Auth/RLS/private-data boundaries that already work, but do not add enterprise-grade security, audit, recovery, anti-abuse, or exhaustive verification.

## Required branch

```text
codex/task-imp-003c-routine-review-publication
```

Do not work directly on `main`. Do not create another planning task or ADR unless implementation is impossible without one.

## Prerequisites

Verified current baseline:

- `TASK-IMP-003A` complete and merged through PR #14;
- `TASK-IMP-003B` complete and merged through PR #16 at merge commit `1b1c18d95214117e59a6c208139c2b019e313cb2`;
- exercise definitions, published guidance revisions and media contracts are available;
- dashboard shell, auth guards, Riverpod, typed go_router and Supabase repositories already exist;
- the application is private and intended for two known users.

At implementation start, only verify that current `main` contains PR #16 and the worktree is clean. Do not perform a broad architecture or security review.

## Scope

### 1. Routine drafts

Create the minimum server schema needed for editable routines:

```text
routine_drafts
- id
- user_id
- name
- description
- status
- revision
- created_at
- updated_at

routine_draft_days
- id
- routine_draft_id
- day_index (1..7)
- day_type (workout/rest)
- title
- purpose
- position

routine_draft_prescriptions
- id
- routine_draft_id
- routine_draft_day_id
- position
- exercise_definition_id
- guidance_revision_id
- priority
- working_sets
- rep_min
- rep_max
- rir_target
- rest_seconds
- load_unit
- notes
```

Rules:

- exactly seven day slots;
- each day is workout or rest;
- rest days have no prescriptions;
- prescriptions preserve deterministic order;
- only owned active exercises and readable published guidance may be selected;
- draft saves use the root revision to prevent obvious stale overwrites.

Do not add speculative fields that are only useful to later phases.

### 2. Routine validation

Implement one server validator named/versioned `routine-validator-v1`.

Minimum validation:

```text
7 total days
4-6 workout days
1-3 rest days
3-10 prescriptions per workout
8-20 working sets per workout
1-6 sets per prescription
rep min 5-30
rep max >= rep min and <=30
RIR 0-5
rest 30-300 seconds
at least one priority prescription per workout
```

Return simple structured errors containing:

```text
code
message
entity/day/prescription identifier when applicable
field when applicable
```

Live client-side summaries may estimate sets/duration, but server validation is authoritative.

Do not build an elaborate validation evidence/audit subsystem beyond what submission/publication needs.

### 3. Submission

Create an immutable submission record containing at least:

```text
submission id
author id
routine draft id
routine draft revision
snapshot JSON
content hash
validation result/status
submitted_at
status
```

Submission must rerun validation and freeze the submitted snapshot.

A later edit to the draft must not change the submitted snapshot.

Use a straightforward server-generated SHA-256 hash over deterministic JSON. Matching SQL/Dart cryptographic golden vectors are not required for this private MVP unless already trivial to reuse.

### 4. Review

Create the minimum review workflow for the second user.

Use the existing server-managed `routine_reviewer` capability where practical.

Required behavior:

- reviewer must be authenticated;
- reviewer must not be the author;
- reviewer sees submitted snapshot;
- reviewer can approve or reject;
- rejection requires a reason/note;
- decision is stored and cannot be casually overwritten;
- reviewer cannot edit the author's routine through the review screen.

Do not implement an emergency override system.

Do not add complex reviewer delegation, organizations, teams, moderation or audit tooling.

### 5. Publication

After approval, allow publication to create immutable routine version records:

```text
routine_versions
routine_version_days
routine_version_prescriptions
```

A version must pin:

- owner;
- monotonically increasing version number;
- approved submission/review;
- content hash;
- ordered days/prescriptions;
- exercise definition IDs;
- published guidance revision IDs;
- effective date;
- published timestamp.

Keep published versions immutable through normal client operations.

Use the existing accepted rule that publication chooses a future Monday when straightforward. Phase 4 owns actual weekly materialization; 003C does not create training weeks.

### 6. Minimal RPC/repository contract

Implement only the operations the UI actually needs:

```text
list my routines
get routine draft
create routine draft
save routine draft
archive routine draft
validate routine draft
submit routine
list review queue
get submission for review
approve submission
reject submission
publish approved submission
list routine versions
get routine version
duplicate published version as new draft
```

Reuse existing repository/service patterns from 003A/003B.

Do not create duplicate APIs for theoretical future clients.

## Existing security boundary

Do not remove existing Auth/RLS/private-data protections.

Minimum new authorization only:

- owner can manage own drafts;
- other user cannot edit those drafts;
- authorized reviewer can read submitted evidence needed for review;
- author cannot approve own submission;
- normal clients cannot mutate published versions directly.

That is enough for this two-user private app.

Do not perform a new security threat model.
Do not add exhaustive object/RLS/function permission matrices beyond the few tests needed to prove the above behavior.
Do not add anti-abuse/rate-limit/moderation systems.

## Dashboard implementation

Use existing shell/design system and implement these routes:

```text
/routines
/routines/new
/routines/:routineId
/routines/:routineId/versions/:versionId
/reviews
/reviews/:submissionId
```

### Routine library

Implement:

- list routines;
- basic search/filter if easy using existing primitives;
- create routine;
- open/edit routine;
- show draft/submitted/approved/published state;
- show version history.

Do not overbuild advanced filtering or analytics.

### Routine editor

Implement one practical responsive editor:

- routine name/description;
- seven-day outline;
- choose workout/rest per day;
- add/remove/reorder prescriptions;
- choose exercise;
- choose published guidance revision;
- sets;
- rep range;
- RIR;
- rest;
- priority;
- load unit;
- optional notes;
- simple live set/duration summaries;
- Validate action;
- Submit action.

Use existing responsive primitives. A good desktop layout and usable compact layout are sufficient.

Do not spend time on elaborate drag/drop. Move up/down controls are acceptable.

### Review screen

Implement:

- review queue;
- submitted routine snapshot;
- basic comparison to previous published version when easy;
- validation summary;
- Approve;
- Reject with reason/note;
- clear state if already decided;
- self-review unavailable.

A sophisticated field-by-field diff engine is not required. A readable changed/current snapshot is sufficient.

### Publication/history

Implement:

- publish approved submission;
- choose effective date;
- list immutable versions;
- open a published version;
- duplicate published version into a new draft.

## Browser/offline behavior

Do not implement a new complex IndexedDB routine recovery system for 003C.

Use server drafts as the source of truth. A simple debounced autosave or explicit Save button is acceptable.

If existing 003A browser-cache utilities can be reused with very little code, reuse them. Otherwise skip local routine draft recovery.

Submission, review and publication require connectivity.

## Android

Only add/maintain pure-Dart read models/contracts if needed so later phases can consume published routine versions.

Do not implement Android routine editing or routine screens in 003C.

## Explicit exclusions

Do not implement:

- weekly plan materialization;
- swaps/credits;
- workouts;
- SQLite workout persistence;
- rank/RR/XP/wallet;
- Android media playback;
- production deployment;
- enterprise security hardening;
- emergency reviewer override;
- extensive audit/event infrastructure;
- full offline dashboard authoring;
- advanced routine analytics.

## Minimal testing

During implementation run targeted tests only.

### Database

Minimum tests:

1. owner can create/save/validate/submit own routine;
2. invalid routine fails validation;
3. second user cannot edit owner's draft;
4. author cannot approve own submission;
5. reviewer can approve/reject submitted routine;
6. approved submission can publish;
7. published version is not normally editable.

### Domain/data

Test only:

- routine model decoding;
- repository happy path;
- stale revision mapping;
- review/publication result decoding.

### Dashboard

Test only key flows:

- create/edit seven-day routine;
- validation errors display;
- submit;
- review approve/reject;
- publish/history;
- basic route guard/regression.

Do not build a large golden matrix.
Do not run API 24 profiling.
Do not add broad security/abuse tests.

## Final verification

Before PR:

```text
dart run build_runner build --delete-conflicting-outputs
dart run build_runner build
dart format --output=none --set-exit-if-changed .
dart analyze
```

Then run targeted 003C tests and:

```text
flutter build web --release
```

Run one final local Supabase reset/pgTAP/lint only if Docker is available. Otherwise rely on path-sensitive CI.

Android release regression is only required if shared changes affect Android compilation. API 24 must remain skipped for this dashboard/database task.

Use one final path-sensitive CI run after code/tests are finalized.

## Documentation

Codex does not need to update broad project documentation for this task. The prep/handoff documents are maintained separately.

Only update `docs/tasks/TASK-IMP-003C.md` at completion if a status/result line is required by repository checks. Do not rewrite README, architecture, roadmap, threat model or broad context during implementation.

## Completion standard

`TASK-IMP-003C` is complete when the following two-user flow works:

```text
User A creates a valid 7-day routine
User A submits it
User B sees it in Reviews
User B approves or rejects it
approved submission can be published
published version appears in routine history
published version can be duplicated into a new draft
```

Required technical gates:

- migration applies;
- targeted database tests pass;
- targeted Dart/Flutter tests pass;
- dashboard Web release builds;
- path-sensitive CI passes;
- PR merges.

## Git

Commit messages contain `TASK-IMP-003C`.

Open one PR against `main` and merge when the required path-sensitive checks are green.

## Final report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task: TASK-IMP-003C
Branch:
PR:
Merge commit:

Routine drafts:
Validation:
Submission:
Review:
Publication:
Version history:
Dashboard:
Android read contract:

Database tests:
Domain/data tests:
Dashboard tests:
Web build:
CI:

Known limitations:
Exact next action: TASK-IMP-004
```
