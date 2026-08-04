# TASK-IMP-001 — Create Flutter and Supabase project foundation

Status: `APPROVED — NOT EXECUTED`
Approved by: `TASK-PL-002`; reaffirmed by `TASK-PD-009`
Target phase: `Phase 1 — Repository and quality foundation`

## Objective

Create the minimum executable Stone Set repository foundation for the Android mobile app, Flutter Web dashboard, shared Dart packages, local Supabase development, quality checks, and CI.

The task must create reliable scaffolding only. It must not implement authentication, routines, exercise guidance, images, YouTube playback, workouts, rank logic, database product schema, Storage policies, or deployment.

## Mandatory repository reads

Read before changing files, in this order:

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/PROJECT_BRIEF.md`
4. `docs/context/ARCHITECTURE.md`
5. `docs/context/CODEBASE_MAP.md`
6. `docs/context/ROADMAP.md`
7. `docs/context/WORKFLOW.md`
8. `docs/context/HANDOFF.md`
9. `docs/context/IMPLEMENTATION_PLAN.md`
10. `docs/product/ROUTINE_ELIGIBILITY.md`
11. `docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md`
12. `docs/product/RANK_SYSTEM.md`
13. `docs/product/WEEKLY_SCHEDULING.md`
14. `docs/product/APPLICATION_WORKFLOW.md`
15. every accepted ADR under `docs/decisions/`
16. this task packet

Inspect current Git state and recent commits. Repository facts override this packet when newer accepted decisions exist.

## Verified starting state

At reaffirmation time:

- repository: `Hermann-33/Stone-Set`;
- branch: `main`;
- documentation only;
- Phase 0 complete;
- Phase 1 ready but not started;
- active rank configuration: `rank-v6`;
- active scheduling configuration: `schedule-v3`;
- Flutter mobile, Flutter Web, Supabase Auth/Postgres/Storage, SQLite draft, Android-first, Vercel, YouTube embed, and operations ADRs accepted;
- dashboard-managed workout and exercise guidance accepted;
- no Flutter project, Supabase project, schema, Storage bucket, account, credential, deployment, CI, or test suite exists.

Re-verify this state before implementation.

## Required branch and Git behavior

1. Create branch:

```text
codex/task-imp-001-foundation
```

2. Do not implement directly on `main`.
3. Do not rewrite history or force-push.
4. Commit only task-related files.
5. Commit messages must contain `TASK-IMP-001`.
6. Push the branch.
7. Open a draft pull request when the branch is pushed and connector support permits.
8. Report final branch and commit SHA.

## Exact scope

### 1. Toolchain pinning

- Use Flutter `3.44.7` and its bundled Dart SDK for this foundation unless official compatibility evidence requires a documented change before scaffolding.
- Record the expected Flutter and Dart versions in a committed machine-readable tool-version file.
- Add a repository check that fails when CI uses a different Flutter version.
- Pin all package and CLI dependencies to exact resolved versions.
- Commit the root Dart lockfile and any package-manager lockfile used for tooling.
- Never install unbounded `latest` versions in CI.

### 2. Native Dart Pub workspace

Create one Pub workspace using native Dart workspace support.

Required workspace members:

```text
apps/mobile
apps/dashboard
packages/domain
packages/data
packages/ui
```

Requirements:

- one root `pubspec.yaml` with workspace membership;
- every member uses `resolution: workspace`;
- one root `pubspec.lock`;
- no nested stray lockfiles;
- packages use `publish_to: none`;
- package names are unique and Stone Set-specific.

Do not introduce Melos unless native Pub workspaces cannot satisfy a documented acceptance criterion.

### 3. Flutter mobile shell

Create `apps/mobile` as a Flutter application with:

- Android platform only;
- minimum Android API 24;
- no iOS, desktop, or web platform directories;
- package/application identifier documented and stable;
- a minimal accessible placeholder screen identifying the mobile foundation;
- no authentication, Supabase call, routine, guidance, image, YouTube, workout, rank, timer, or local-database feature;
- smoke widget test;
- release APK build capability.

The Android signing configuration must remain debug/default only. Do not create production signing keys or commit signing secrets.

### 4. Flutter Web dashboard shell

Create `apps/dashboard` as a Flutter application with:

- web platform only;
- a minimal desktop-appropriate placeholder screen identifying the dashboard foundation;
- keyboard focus and semantic labels on the placeholder interaction, if any;
- path URL strategy support or routing-ready server fallback configuration;
- smoke widget test;
- release web build capability;
- no authentication, Supabase call, exercise library, image upload, YouTube preview, routine editor, data table, or production feature.

Add `apps/dashboard/vercel.json` containing only static SPA configuration required to rewrite application routes to `index.html`. Do not create or link a Vercel project.

### 5. Shared packages

Create:

```text
packages/domain
packages/data
packages/ui
```

Responsibilities:

- `domain`: pure Dart placeholder library and tests; no Flutter or Supabase dependency;
- `data`: pure Dart repository-contract placeholder and tests; no direct product implementation;
- `ui`: Flutter package containing design-token placeholders and one tested neutral shared widget only if necessary.

Do not create speculative product models, schemas, media models, reward formulas, or repositories. Shared packages must demonstrate dependency direction without fabricating future code.

Allowed dependency direction:

```text
mobile -> domain, data, ui
dashboard -> domain, data, ui
data -> domain
ui -> Flutter only
domain -> Dart SDK only
```

Circular dependencies are prohibited.

### 6. Configuration templates

Create non-secret configuration documentation and templates:

```text
config/dart_defines.example.json
config/README.md
```

The example may define only placeholders such as:

```text
APP_ENV
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Rules:

- actual local, staging, and production define files are ignored by Git;
- no real URL, key, token, password, account ID, project ref, media URL, or personal data;
- clients must never receive service-role, database, Storage backup, or deployment credentials;
- placeholder shells must build without a real Supabase project.

### 7. Local Supabase foundation

Initialize local Supabase configuration only.

Required committed files include:

```text
supabase/config.toml
supabase/seed.sql
supabase/tests/database/
```

Requirements:

- use the Supabase CLI through an exact pinned project tooling dependency;
- local stack only;
- no `supabase link`;
- no remote project reference;
- no product tables;
- no Storage bucket or policy;
- no user accounts;
- no private values in `config.toml` or seed data;
- an empty or synthetic-only seed;
- one pgTAP smoke test proving the local database test runner works;
- local stack must recreate successfully from a clean state.

The local stack is development-only and must not be exposed externally.

### 8. Cross-platform developer commands

Provide documented commands that work from the repository root on Windows and CI Linux for:

- dependency restore;
- formatting check;
- static analysis;
- unit/widget tests;
- Android release build;
- dashboard release build;
- local Supabase start;
- local database reset;
- database tests;
- database lint;
- complete verification.

Prefer Dart or package-manager scripts over shell-only orchestration. Do not require Make as the sole entry point.

### 9. GitHub Actions CI

Create CI that runs on pull requests and pushes to `main`.

Required independent jobs:

#### Documentation and repository checks

- verify required context, product, task, and ADR paths exist;
- verify no committed known secret-file patterns;
- verify Pub workspace structure and dependency direction;
- verify generated/build directories are not committed.

#### Flutter and Dart

- install exact Flutter `3.44.7`;
- restore the root workspace;
- verify tool versions;
- run formatting check;
- run static analysis;
- run all package and widget tests;
- build Android release APK without production signing;
- build Flutter Web release output.

#### Supabase

- install the exact pinned Supabase CLI;
- start the local stack;
- run `supabase db reset --local` or the current verified equivalent;
- run `supabase test db --local` or the current verified equivalent;
- run `supabase db lint --local` or the current verified equivalent;
- stop the local stack even after test failure.

Discover current CLI flags with `--help`; do not guess deprecated commands.

CI must not:

- create remote infrastructure;
- create Storage buckets;
- deploy to Vercel;
- link Supabase;
- use production secrets;
- upload media;
- seed real users.

### 10. Ignore and repository hygiene

Update `.gitignore` for at least:

- `.dart_tool/`;
- Flutter build output;
- local IDE files where appropriate;
- actual Dart-define configuration files;
- `.env*` except explicit examples;
- Supabase CLI temporary and branch state;
- Vercel linkage state;
- Android signing files and local properties;
- test coverage output;
- local media fixtures outside explicit synthetic test assets.

Do not ignore committed lockfiles, migrations, `supabase/config.toml`, synthetic seed data, or approved examples.

### 11. Documentation synchronization

Update only facts changed by implementation:

- `README.md`: exact local setup and verification commands;
- `docs/context/ARCHITECTURE.md`: implemented foundation versus planned features;
- `docs/context/CODEBASE_MAP.md`: actual paths and responsibilities;
- `docs/context/ROADMAP.md`: Phase 1 completion state;
- `docs/context/ACTIVE_CONTEXT.md`: present implemented state and next task;
- `docs/context/HANDOFF.md`: result, evidence, risks, exact next action;
- `docs/context/AUDIT_LOG_CONTINUED.md`: material task audit entry.

Do not mark authentication, persistence schema, Storage, exercise guidance, media, YouTube playback, routine management, workout execution, rank behavior, or deployment as implemented.

## Non-goals

- remote Supabase project creation;
- Supabase Storage bucket, object, or policy creation;
- Vercel project creation or deployment;
- production Android signing;
- iOS scaffolding;
- authentication UI or logic;
- database product schema;
- profiles or RLS product policies;
- exercise definitions or guidance models;
- image processing, upload, cache, or backup;
- YouTube URL parsing, preview, package, WebView, or playback;
- routine models or editor;
- weekly plans or allocation formulas;
- workout logging or SQLite draft implementation;
- swaps, wallet, RR, XP, PR, consistency, or finalization;
- navigation architecture beyond the minimum shell;
- state-management library selection unless the placeholder shell cannot compile without it;
- analytics, telemetry, crash reporting, payments, social features, nutrition, sleep, wearables, or medical logic.

## Protected behavior and boundaries

- Preserve `rank-v6` and `schedule-v3` exactly.
- Preserve Adonis at `5,500 RR` and the 5/10/15 multiplier ladder.
- Preserve the two-swap weekly limit and bankable monthly free credits.
- Preserve ADR-0006's private-media and YouTube-policy boundaries without implementing them here.
- No password table.
- No service-role or secret key in clients.
- No client-authoritative score or wallet state.
- No production data, media, or personal information in seed or fixture files.
- No direct work on `main`.
- No claims that planned product or media features exist.

## Acceptance criteria

The task passes only when all conditions hold:

1. Root Pub workspace resolves with one lockfile.
2. `apps/mobile` contains Android only and builds a release APK.
3. `apps/dashboard` contains web only and builds a release web bundle.
4. Shared packages compile and their dependency direction is valid.
5. Placeholder apps have passing smoke widget tests.
6. Pure Dart packages have passing unit tests.
7. Formatting check passes.
8. Static analysis passes with no unresolved warnings accepted silently.
9. Tool-version verification passes.
10. Local Supabase starts from committed configuration.
11. Local database reset succeeds from a clean state.
12. pgTAP smoke test passes.
13. Database lint completes successfully or documents a verified no-schema result.
14. No remote Supabase, Storage, or Vercel project is created.
15. No secrets, media, or personal data are committed.
16. CI contains all required jobs and passes on the branch.
17. Documentation accurately distinguishes implemented foundation from planned product and media features.
18. Complete diff contains no unrelated changes.
19. Branch is pushed with a `TASK-IMP-001` commit.
20. Draft PR is opened when supported.

## Required tests and checks

At minimum, report exact commands and exit results for:

```text
flutter --version

dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze

all Dart unit tests
all Flutter widget tests
flutter build apk --release
flutter build web --release

Supabase CLI version
Supabase CLI help for used commands
supabase start
supabase db reset --local
supabase test db --local
supabase db lint --local

Git status
git diff --check
git diff against main
```

Adjust command syntax only when current official tool help proves a different supported form.

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-001
Branch:
Commit:
Pull request:
Files changed:
Repository structure created:
Behavior implemented:
Explicitly not implemented:
Tests and checks run:
Results:
CI result:
Secrets and media review:
Documentation updated:
Risks or blockers:
Exact next action:
```

A `COMPLETE` verdict requires every acceptance criterion, successful CI, pushed branch, accurate documentation, and no false product or media claims.
