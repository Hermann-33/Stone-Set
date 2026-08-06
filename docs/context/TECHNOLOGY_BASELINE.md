# Stone Set Technology and Dependency Baseline

Updated: 2026-08-06
Status: `ACCEPTED IMPLEMENTATION BASELINE — VERSIONS PINNED PER TASK`
Tasks: `TASK-PD-013`, `TASK-PD-015`

## 1. Purpose

This document records the technology choices that implementation packets must use unless a later accepted ADR changes them.

The baseline selects product-level technologies and integration patterns. Exact dependency versions are pinned and verified when the owning implementation task begins. No package is added merely because it appears in this plan.

## 2. Client platforms

| Surface | Technology | Release target |
|---|---|---|
| Android application | Flutter and Dart | Android API 24+, private signed release initially |
| Management dashboard | Flutter Web and Dart | Static single-page application on Vercel |
| Shared client code | Native Dart Pub workspace | One root dependency resolution and lockfile |

Flutter Web is used as an application interface, not as a content or SEO website. The dashboard is private, authenticated, editor-heavy and interaction-heavy, which fits Flutter Web's intended application model.

## 3. Application architecture

Stone Set follows Flutter's recommended layered architecture:

```text
View
  -> presentation controller / view model
  -> repository interface
  -> repository implementation
  -> local and remote services
```

An optional use-case layer is introduced only when a workflow coordinates multiple repositories, transactions or policy decisions. Simple reads and writes do not receive ceremonial use-case wrappers.

### Layer rules

- Views render immutable state and send user intent.
- Presentation controllers own screen orchestration, validation display and transient UI state.
- Repositories are the application source of truth and are the only client layer that coordinates local and remote persistence.
- Services contain raw Supabase, SQLite, browser-storage, media and platform integrations.
- Domain models do not import Flutter or Supabase.
- Widgets do not call Supabase, SQLite or Storage directly.
- No client layer gains authority over RR, XP, rank, wallet, schedule finalization or review publication.

## 4. State management and dependency injection

Use **Riverpod** as the single state-management and dependency-injection system.

Accepted usage:

- generated providers for feature state where code generation is already part of the task toolchain;
- `Notifier` / `AsyncNotifier` for mutable and asynchronous presentation state;
- plain providers for repositories, services, configuration and clocks;
- provider overrides for deterministic tests and fixtures;
- scoped containers for app bootstrap and tests;
- explicit invalidation or refresh rather than hidden global mutation.

Do not mix Riverpod with BLoC, Provider, GetX or another application-wide state framework.

Riverpod does not replace repositories or domain rules. Providers wire and expose those layers.

## 5. Routing and navigation

Use **go_router** with typed routes.

### Android

- `StatefulShellRoute` or its current supported equivalent owns the four persistent branches: Home, Week, Progress and Profile.
- Each branch preserves its own navigation stack, scroll state and selected filters.
- Workout, guidance, result, rank detail and correction routes open contextually outside the permanent tab set where appropriate.
- Authentication, mandatory password change, session loss and app-version incompatibility use explicit route guards.

### Dashboard

- Every primary resource and selected entity has a stable URL.
- Browser back, forward, refresh and direct-link opening work predictably.
- Compact, medium and expanded layouts render the same route state rather than using unrelated route trees.
- Unsaved or conflicted editor state can block route exit with an explicit resolution flow.
- Unknown and unauthorized routes have separate user-visible outcomes.

The Vercel static deployment rewrites application routes to `index.html`; static files are served normally before the catch-all rewrite.

## 6. Models, serialization and validation

- Domain and presentation models are immutable.
- JSON/database DTOs are separate from domain models when raw persistence shape differs from product meaning.
- Generated immutable/value and JSON code may be used after dependency review; exact packages are selected and pinned by the implementing packet.
- Server-returned structured errors use stable machine codes plus user-safe messages and field paths.
- Dates and timestamps are never represented as ambiguous locale strings in persistence contracts.
- IDs are UUIDs unless an accepted migration requires another type.

## 7. Backend and data access

Use:

- Supabase Auth for identity, password authentication, sessions and revocation;
- Supabase Postgres for authoritative relational data, immutable versions and ledgers;
- Supabase Storage for private exercise-image bytes;
- Postgres functions/RPC for atomic authoritative workflows;
- Supabase Cron/`pg_cron` for bounded recurring database jobs;
- Edge Functions only when a workflow genuinely requires a trusted HTTP/runtime boundary that Postgres cannot safely provide.

### Explicit MVP decisions

- No custom REST server.
- No GraphQL requirement.
- No Supabase Realtime subscription in MVP.
- No client-side service-role operation.
- No direct remote database editing after migrations begin.
- No hidden authorization based on UI routes or obscured object URLs.

Normal client reads may use RLS-protected tables, security-invoker views and narrowly scoped RPCs. Mutations that affect authority, multiple records, ledgers or immutable history use database functions.

## 8. Android local persistence and synchronization

Use **SQLite through `sqflite`** for:

- active workout drafts;
- immutable session/prescription snapshots required for offline continuation;
- guidance-text snapshots;
- private cache metadata;
- outbox mutations;
- pending submission records;
- synchronization metadata.

### Rules

- Database files remain in Android internal app storage.
- Rows are scoped by authenticated user ID and session ID.
- Schema migrations are versioned and tested.
- Passwords, refresh tokens, service keys and database credentials are never stored in the feature database.
- Logout clears ordinary private cache and either resolves, quarantines or explicitly discards unsynchronized drafts.
- A different account cannot query or submit a quarantined draft.
- SQLite data is non-authoritative and can be rebuilt except for unsynchronized active-session work.

### Outbox contract

Every queued mutation contains at least:

```text
outboxId
userId
sessionId
mutationType
idempotencyKey
payloadVersion
sequenceNumber
payload
createdAt
attemptCount
lastAttemptAt?
lastErrorCode?
state
```

The server returns the existing result for duplicate idempotency keys.

Synchronization occurs on:

- explicit retry;
- application foreground;
- connectivity regain;
- final workout submission;
- best-effort constrained Android background work.

Use Android WorkManager, through a maintained Flutter integration selected during `TASK-IMP-005A`, only for short deferrable network-constrained retry. It must not poll continuously or become the authority for completion.

## 9. Dashboard draft persistence

Dashboard editors use a private browser-local draft cache for recovery from refresh, temporary offline state and browser/process failure.

Requirements:

- IndexedDB-backed storage or an equivalent durable browser adapter selected during the owning task;
- user-, object- and draft-version scoping;
- no authoritative publication state;
- visible `Saving`, `Saved`, `Offline`, `Syncing`, `Conflict` and `Failed` states;
- optimistic-concurrency revision or ETag checks against the server;
- explicit conflict comparison and recovery;
- private cache clearing on logout;
- automatic expiry/cleanup for obsolete local drafts after confirmed server persistence.

The dashboard is not a fully offline product. Offline behavior protects editing work; review, publication, media upload and authority-changing actions require connectivity.

## 10. Android notifications and timers

Notifications are optional and permission-aware.

Accepted uses:

- active-workout rest timer notification when the user leaves the foreground;
- opt-in scheduled workout reminder;
- pending synchronization reminder only when it is actionable and not repetitive.

Rules:

- request Android 13+ notification permission in context, not at first launch;
- the logger remains usable when permission is denied;
- no exact-alarm permission in MVP;
- reminders use ordinary/inexact scheduling and document possible delay;
- rest timing is persisted from timestamps and does not rely on a continuously running Dart timer;
- no promotional notification system.

## 11. Flutter Web build and Vercel

The production baseline is the normal supported Flutter Web build.

```text
flutter build web --release
```

A WebAssembly build is a release-hardening experiment, not the initial requirement. Flutter Web Wasm requires COOP/COEP response headers for multithreaded rendering; those headers and cross-origin behavior must be tested with Supabase, YouTube previews, images, downloads and browser compatibility before adoption.

### Vercel requirements

- static build output only;
- SPA rewrite to `index.html` after filesystem handling;
- preview deployments connected only to staging;
- Vercel Authentication or equivalent deployment protection for previews;
- HTTPS and HSTS;
- content-security policy tested against Flutter, Supabase and permitted YouTube origins;
- `X-Content-Type-Options`, Referrer Policy and Permissions Policy;
- long immutable caching for hashed assets;
- no-cache or short revalidation for `index.html`, bootstrap and public runtime configuration;
- no secret or private user data in the static artifact.

## 12. Media and YouTube

- Private exercise images use Supabase Storage.
- Upload preprocessing is performed in the dashboard before Storage upload.
- JPEG, PNG and static WebP only.
- Six images maximum per guidance revision and 5 MB maximum per processed image.
- EXIF/GPS removed, orientation normalized, dimensions bounded, content hash recorded and alt text required.
- Immutable published paths; ordinary upload uses no silent overwrite.
- The Storage schema is never modified directly; object deletion and movement use the Storage API.
- Android YouTube playback uses the official IFrame Player API through an OS WebView.
- Dashboard preview uses an official supported embed.
- Video is never downloaded, cached, background played or connected to rewards.

## 13. Internationalization, units and time

- English is the MVP language, but all user-facing strings are externalized from feature logic.
- Number, date, duration and unit formatting are centralized.
- User display units are preferences; authoritative stored measurements use explicit units and lossless conversion rules.
- Server timestamps use UTC `timestamptz`.
- Reward dates and week boundaries store local `date` values plus the IANA reward timezone and resolved boundary timestamps.
- Timezone changes are future-effective and audited; they never rewrite historical weeks or duplicate monthly grants.

## 14. Observability and privacy

- Every authoritative request has a correlation/request ID.
- Database functions record stable operation and idempotency identifiers where relevant.
- Client logs are structured and redacted.
- Passwords, tokens, complete guidance text, workout notes, private media URLs and raw user payloads are not logged.
- Supabase Logs Explorer, Cron run details, database advisors and Storage logs are the initial operational tools.
- External analytics and crash reporting are excluded until a separate privacy, retention and cost decision.
- The app exposes a user-safe diagnostics view containing versions, synchronization state and correlation IDs—not secrets.

## 15. Security verification baselines

- Dashboard and API verification uses OWASP ASVS 5.0 as the reference catalogue, targeting the controls applicable to an authenticated private application.
- Android verification uses OWASP MASVS categories for storage, authentication, network, platform interaction and code quality.
- Dashboard accessibility targets WCAG 2.2 AA-equivalent behavior.
- Android accessibility uses platform semantics with equivalent contrast, focus, text scaling, touch target, non-color and reduced-motion requirements.

Certificate pinning is not an MVP requirement because the primary endpoints include managed Supabase and YouTube services and pin lifecycle risk would exceed the current benefit. TLS validation and Android network-security configuration remain mandatory.

## 16. Dependency policy

Every dependency must have:

- an active maintained release compatible with the pinned Flutter/Dart toolchain;
- a compatible licence;
- a documented purpose that cannot be met reasonably by the SDK;
- no known unresolved critical advisory at selection time;
- a test strategy and replacement boundary;
- an exact resolved version in the root lockfile.

Avoid packages for trivial animations, formatting, state duplication or visual effects. Prefer first-party Flutter/Dart primitives and official vendor clients.

### TASK-IMP-002A coordinated dependency baseline

`TASK-PD-015` replaces an unsatisfiable Analyzer-13 Riverpod/build family with the smallest proven
Analyzer-12-compatible stable family for Flutter 3.44.7 and Dart 3.12.2:

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
riverpod_lint plugin   3.1.8
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1
```

The coordinated application workspace resolution is Analyzer 12.1.0, test 1.31.0, test_api 0.7.11,
build 4.0.7 and source_gen 4.2.4. The previous attempt combined newer generator/build_runner
packages and the analyzer-plugin package in the application workspace; that graph required Analyzer
13, which cannot coexist with test 1.31.0. Flutter 3.44.7 prevents the narrower test upgrade because
its `flutter_test` pins test_api 0.7.11. Dependency overrides and additional workspace lockfiles are
prohibited.

The selected stable Riverpod application packages transitively require the non-retracted vendor utility
`riverpod_analyzer_utils 1.0.0-dev.10`; no project manifest pins it directly. Riverpod lint remains
an analysis-server plugin, not a `custom_lint` configuration. Under Dart 3.12's current plugin
system, its `3.1.8` constraint is resolved from `analysis_options.yaml` separately from the
application workspace lock graph. Final identity CI run `31093560109` proved exact restore,
zero-output generation and strict analysis with that configuration. Later implementation packets
must preserve and reverify both graphs rather than treating the plugin version as a root lockfile
dependency.

## 17. Current selected stack summary

```text
Android UI                 Flutter
Dashboard UI               Flutter Web
Language                   Dart
State/DI                    Riverpod
Routing                     go_router typed routes/stateful shells
Architecture                views/view models, repositories, services
Backend                     Supabase
Authentication              Supabase Auth
Database                    Supabase Postgres
Object storage              Supabase Storage
Authoritative operations    Postgres functions/RPC
Scheduled operations        Supabase Cron / pg_cron
Mobile local data           SQLite / sqflite
Mobile background retry     Android WorkManager integration
Dashboard draft recovery    IndexedDB-backed adapter
Dashboard hosting           Vercel static deployment
CI/CD                       GitHub Actions + Supabase CLI
Security verification       OWASP ASVS 5.0 + MASVS
Accessibility               WCAG 2.2 AA-equivalent / Android semantics
```

## 18. Primary research references

- Flutter app architecture: https://docs.flutter.dev/app-architecture/guide
- Flutter offline-first support: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Flutter SQL persistence architecture: https://docs.flutter.dev/app-architecture/design-patterns/sql
- go_router: https://pub.dev/packages/go_router
- Riverpod: https://riverpod.dev/
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase database functions: https://supabase.com/docs/guides/database/functions
- Supabase local development and migrations: https://supabase.com/docs/guides/local-development/overview
- Supabase database testing: https://supabase.com/docs/guides/local-development/testing/overview
- Supabase Storage access control: https://supabase.com/docs/guides/storage/security/access-control
- Supabase Cron: https://supabase.com/docs/guides/cron
- Flutter Web deployment: https://docs.flutter.dev/deployment/web
- Vercel rewrites: https://vercel.com/docs/routing/rewrites
- Android persistent work: https://developer.android.com/develop/background-work/background-tasks/persistent
- WCAG 2.2: https://www.w3.org/TR/WCAG22/
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- OWASP MASVS: https://mas.owasp.org/MASVS/
