# TASK-IMP-002A — Implement identity, login, sessions, profiles and ownership

Status: `APPROVED — NOT EXECUTED`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001 — Create Flutter and Supabase project foundation` complete and merged;
2. `docs/context/TECHNOLOGY_BASELINE.md` still accepted;
3. `docs/context/DATABASE_AND_SERVER_PLAN.md` still accepted;
4. `docs/product/AUTHENTICATION_AND_SESSION_UX.md` still accepted;
5. a task-start verification that current Supabase Auth/Flutter APIs are compatible with the pinned toolchain.

## Verified starting state

Verified on 2026-08-06 before approval:

```text
TASK-IMP-001             COMPLETE AND MERGED
Pull request #5          MERGED
Merge commit             3d0830767fd5320f33a4b7a209d937d2b59f7a6e
Phase 1                  COMPLETE
Foundation CI            PASS
Flutter                  3.44.7
Dart                     3.12.2
Node.js                  24.11.1
Supabase CLI             2.111.0
Workspace lockfile       one root pubspec.lock
Client foundations       Android-only mobile and Web-only dashboard shells
Supabase foundation      local-only configuration, empty seed and pgTAP smoke test
Identity/product runtime NOT IMPLEMENTED
```

The repository contains no implemented identity, login, profile, session, RLS, operator-account or
product behavior. Approval authorizes only this bounded packet on its required branch.

## Objective

Implement the complete private-account foundation shared by the Android app and Flutter Web dashboard:

- provisioned username/password identities;
- protected profiles and preferences;
- first-login password change;
- session restoration and route guards;
- active/disabled profile enforcement;
- operator-managed reset/deactivation/session revocation;
- ownership/RLS foundations;
- client compatibility bootstrap;
- safe logout, expiry and mobile draft-quarantine interfaces;
- automated allow/deny, client and lifecycle verification.

This packet creates identity and ownership infrastructure only. It does not implement routines, guidance, Storage media, weekly schedules, workouts, RR/XP/wallet, rank finalization or the feature-complete Home/dashboard shell.

## Mandatory repository reads

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/ARCHITECTURE.md`
4. `docs/context/TECHNOLOGY_BASELINE.md`
5. `docs/context/DATABASE_AND_SERVER_PLAN.md`
6. `docs/context/SYSTEM_IMPLEMENTATION_READINESS_AUDIT.md`
7. `docs/context/CODEBASE_MAP.md`
8. `docs/context/ROADMAP.md`
9. `docs/context/IMPLEMENTATION_PLAN.md`
10. `docs/context/UI_IMPLEMENTATION_PLAN.md`
11. `docs/context/WORKFLOW.md`
12. `docs/context/HANDOFF.md`
13. `docs/product/AUTHENTICATION_AND_SESSION_UX.md`
14. `docs/product/APPLICATION_WORKFLOW.md`
15. accepted ADRs;
16. all foundation code, tests and CI.

## Required branch

Required branch:

```text
codex/task-imp-002a-identity-sessions
```

Do not work directly on `main`. Reverify the merged foundation and current official API
compatibility at implementation start.

## Exact scope

## 1. Dependencies and architecture

Add only pinned, reviewed dependencies required for:

- Supabase Flutter client;
- Riverpod state/DI and selected code-generation/lint support;
- go_router typed routing;
- secure platform session storage as provided by the supported Supabase Flutter implementation;
- immutable/serialization support only if selected and justified.

The approved direct pins are:

```text
flutter_riverpod       3.4.2
riverpod_annotation    4.0.6
riverpod_generator     4.0.8
riverpod_lint          3.1.8
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.16.0
```

Use exact constraints and commit the single root lockfile resolution. Reverify these pins against
current official package metadata and APIs at implementation start if official evidence has
changed. Riverpod lint uses its current analysis-server plugin configuration; do not introduce
obsolete `custom_lint` configuration unless current official compatibility evidence requires it.
Run exact dependency restore, inspect the resolved graph and prove the root lockfile remains the
only workspace lockfile.

Implement feature-first identity modules using:

```text
views
presentation controllers/view models
repository contracts
repository implementations
Supabase Auth/profile services
```

Widgets do not call Supabase directly.

## 2. Database migration

Create committed migrations for:

### `public.profiles`

- primary key referencing `auth.users(id)`;
- immutable normalized username;
- display name;
- active flag;
- `must_change_password`;
- IANA reward timezone;
- timestamps/revision;
- required constraints and indexes.

### `public.user_preferences`

- one row per user;
- units;
- appearance;
- reduced motion;
- haptics/sound/reminder preferences;
- locale;
- timestamps/revision.

### protected capabilities/status

Create the minimum server-managed capability/status structures needed for independent review eligibility and account lifecycle. Do not create product-role inflation or organization/coach models.

### client compatibility

Create the versioned compatibility/read-only/maintenance configuration defined in `DATABASE_AND_SERVER_PLAN.md` with synthetic local defaults that do not block development.

### identity operation audit

Create append-only safe events for provisioning linkage, activation/deactivation, password-change requirement and operator session-revocation intent. Never record passwords or tokens.

## 3. Profile linkage

Implement the supported server-side linkage from a provisioned Auth user to exactly one profile.

Requirements:

- public signup is disabled in local, staging and production Auth configuration;
- anonymous signup is disabled and no client-accessible account-creation path exists;
- account provisioning exists only in trusted operator tooling;
- automated verification proves public and anonymous signup are disabled;
- no public signup trigger creates arbitrary active accounts;
- missing profile is a safe authentication failure;
- duplicate username/profile is impossible;
- username normalization is deterministic and tested;
- profile active/password-change flags are not user-editable;
- reward timezone validates an accepted IANA identifier;
- user-editable fields use a safe function or column privilege boundary.

## 4. RLS and privileges

Treat these as separate gates:

```text
Data API object access
RLS row authorization
function EXECUTE privilege
```

For every new table, view, sequence and function:

- explicitly manage object privileges and grant only the minimum access to intended roles;
- revoke unintended `PUBLIC`, `anon` and `authenticated` privileges;
- do not assume a SQL-created object is automatically exposed or usable through the Data API;
- enable RLS on every exposed identity table;
- use `security_invoker` for exposed views;
- prefer security-invoker functions; any necessary security-definer function must be in an
  appropriate non-exposed schema, use an empty fixed `search_path`, validate the caller and receive
  only a narrow explicit `EXECUTE` grant;
- use `TO authenticated` with ownership predicates, never `auth.role()` authorization;
- use indexed `(select auth.uid())` ownership checks where appropriate;
- define both `USING` and `WITH CHECK` for updates;
- keep username, active status, capabilities and password-change flags immutable to clients;
- enforce active-profile status for protected operations;
- use only server-managed authorization data and never editable `user_metadata`.

Test at minimum:

- anonymous denied;
- owner reads permitted own profile/preferences;
- owner updates only permitted fields;
- other authenticated user denied;
- direct update of active, username, capability and `must_change_password` denied;
- compatibility config exposes only safe active data;
- privileged functions are not executable by unintended roles.
- object-level denial is tested separately from row-level denial;
- anonymous and cross-user access are denied even when the object is exposed to `authenticated`.

An UPDATE path must also have the required SELECT policy. No authorization decision may depend on
editable Auth user metadata or a stale user-controlled claim.

## 5. Bootstrap RPC

Implement a narrow authenticated bootstrap operation returning:

- safe profile;
- preferences;
- active/password-change state;
- current compatibility/maintenance state;
- server time/version metadata;
- correlation ID.

It must not return another user's data, privileged configuration, service credentials or future product records.

The client uses bootstrap after local session restoration and before rendering private product content.

## 6. Operator tooling

Create a trusted local operator CLI/script boundary, documented and excluded from client builds, for:

- creating a confirmed Supabase Auth user with an internal alias and temporary password;
- creating/linking protected profile/preferences;
- setting `must_change_password`;
- resetting to a temporary password after out-of-band verification;
- deactivating/reactivating profile;
- revoking sessions with an explicit local/global scope;
- inspecting safe account status;
- recording audit events.

Requirements:

- service-role and management credentials come only from uncommitted secret input to trusted
  operator tooling;
- credentials never enter Flutter assets, Dart defines, browser bundles, logs, CI artifacts or
  committed files;
- tooling distinguishes local, staging and production explicitly;
- dry-run is required where technically feasible;
- every action requires an explicit environment flag and production requires an additional
  confirmation flag;
- temporary passwords are shown only at the controlled initial handoff;
- tokens and passwords are never logged or printed afterward;
- synthetic local provisioning for tests is separate from real operator commands.

Do not expose operator actions in the user dashboard.

## 7. Android authentication UI

Implement:

- session-check/bootstrap screen with no private flash;
- native username/password login;
- show/hide password;
- password-manager autofill where supported;
- Enter/IME submission;
- busy duplicate-submit prevention;
- generic invalid credential/access error;
- rate-limit and network states;
- first-login password-change screen;
- incompatible/maintenance/read-only messaging;
- authenticated route guard;
- active-profile revalidation where required;
- logout entry and session-loss state.

The main feature shell may remain a clearly labelled protected placeholder until `TASK-IMP-002B`.

## 8. Dashboard authentication UI

Implement:

- responsive `/login`;
- username/password fields and accessible show/hide control;
- keyboard-only submission and complete focus order;
- generic errors/status announcements;
- session restoration before protected content;
- intended-route preservation after successful authentication;
- first-password-change route;
- protected route guard;
- authenticated user redirected away from `/login`;
- logout clearing private caches and preventing private back-navigation exposure;
- compatibility/maintenance/read-only messaging.

The feature dashboard may remain a protected placeholder until `TASK-IMP-002C`.

## 9. Username alias mapping

Implement one shared pure-Dart mapping:

```text
trim
lowercase
validate allowed username grammar
append configured internal auth domain
```

Rules:

- use either a controlled domain suitable for internal aliases or a documented supported no-op or
  custom email-delivery hook strategy;
- do not use a fake or intentionally bouncing domain for staging/production without an accepted
  delivery strategy;
- a non-routable synthetic value is allowed only for local automated tests;
- the production strategy must be established before staging or production provisioning;
- domain configuration is public and non-secret;
- no lookup endpoint;
- no account existence leak;
- normal login does not depend on successful email delivery;
- account creation remains operator-controlled;
- mapping tests include whitespace, case, invalid characters and maximum length;
- user-visible UI never presents the alias as contact email.

## 10. Session lifecycle

Use the supported Supabase Flutter session lifecycle and explicitly handle:

- initial session recovery and no local session;
- local session requiring refresh;
- token refresh success;
- token refresh failure;
- expired session;
- signed in and signed out;
- user/password update events;
- operator revocation/disabled profile;
- app foreground revalidation;
- browser refresh/direct URL.

Auth-state subscriptions must handle errors and must not assume every event represents a usable
authenticated session. Do not assume a locally restored session is fully valid before
bootstrap/refresh completes.

Mobile and dashboard sessions are independent. Logging out one does not imply global revocation unless the operator chooses that scope.

Deleting, disabling or revoking a session does not necessarily invalidate an already-issued JWT
immediately. The implementation must document the configured JWT expiry tolerance, foreground and
bootstrap revalidation, disabled-profile enforcement, stale-access-token handling, deterministic
client state after operator revocation, and supported session evidence for sensitive operations
when stronger revocation guarantees are required. Tests must model the residual JWT lifetime and
must not claim instantaneous invalidation unless the implementation actually validates current
session evidence.

## 11. First-password-change transaction

Flow:

1. authenticated bootstrap reports requirement;
2. all product routes redirect to password change;
3. validate new password/confirmation locally;
4. update password through Supabase Auth;
5. invoke a narrow server operation that verifies the authenticated identity and supported recent
   authentication evidence before clearing the server-controlled flag;
6. re-bootstrap;
7. enter protected placeholder.

The implementation agent must choose and document a supported server-verifiable proof mechanism
before code is accepted. A client report that `updateUser` returned success is not sufficient proof,
and Postgres must not be represented as directly inspecting a user's password. The proof boundary:

- must establish that the password update succeeded through Supabase Auth;
- must prevent a client from clearing the flag without valid recent authentication evidence;
- must validate the authenticated identity on the server;
- must not use editable `user_metadata`;
- must document its precise guarantees, limitations and failure modes.

Failure cannot leave the UI claiming completion when the server flag remains set. Password values
never enter application logs or tables. Tests must prove direct table updates and direct calls that
lack the required evidence cannot clear the flag.

## 12. Logout and draft-resolution contract

Dashboard:

- sign out;
- clear Riverpod containers/private repository caches/browser draft cache;
- stop media/network work;
- route to `/login`;
- no private content via back navigation.

Android:

- define and test an interface for `hasUnsynchronizedPrivateWork`;
- before workout features exist it returns false through a deterministic placeholder implementation;
- later `TASK-IMP-005A` replaces it with SQLite/outbox evidence;
- logout supports sync/remain/discard UI contract without fabricating an actual draft in this packet;
- involuntary expiry invokes a user-scoped quarantine interface for later SQLite implementation.

Do not implement feature SQLite tables in this task.

## 13. Cache partitioning

All client repository caches and future local stores are partitioned by Auth user ID.

- profile/preferences cache can be discarded and refetched;
- no cross-account singleton data;
- provider containers are invalidated on account transition;
- dashboard local private cache clears on logout;
- Android feature cache cleanup hooks exist for later use;
- public static assets may remain shared.

## 14. Error model and diagnostics

Create stable safe client error categories:

```text
invalid_credentials
rate_limited
network_unavailable
profile_unavailable
profile_disabled
password_change_required
session_expired
client_incompatible
maintenance
server_unavailable
unknown
```

User messages remain generic where account enumeration is possible.

Diagnostics may expose correlation ID, app build and safe state code. Never expose tokens, internal aliases, SQL details or secret configuration.

## 15. Non-goals

Do not implement:

- public signup/invitation;
- social, anonymous, magic-link or SSO auth;
- public forgot-password/email recovery;
- routine/exercise/guidance product schema;
- Storage bucket/media;
- mobile Home/rank UI beyond protected placeholder;
- dashboard productivity shell beyond protected placeholder;
- weekly plans/workouts/SQLite/outbox;
- RR/XP/rank/wallet;
- remote production/staging provisioning unless a separately approved environment task explicitly authorizes it;
- analytics/crash SDK;
- user-facing account deletion.

## Acceptance criteria

1. Both clients authenticate the same provisioned account using username/password UI.
2. No private screen flashes before session/bootstrap verification.
3. First login cannot access product routes until password change completes.
4. Missing/disabled/mismatched profile signs out safely with a generic message.
5. Protected URLs/routes restore correctly after login and reject signed-out access.
6. Browser refresh and Android restart restore valid sessions correctly.
7. Session expiry/revocation produces deterministic safe state.
8. Dashboard logout clears private state and protects back navigation.
9. Android logout contract is ready for later unsynchronized-draft implementation.
10. RLS allows own intended reads/updates and denies anonymous/cross-user/privileged-field access.
11. Operator tooling is separate, environment-safe and never enters client builds.
12. Compatibility/maintenance bootstrap works and can block mutations safely.
13. Passwords, tokens and service credentials are absent from tables, logs, fixtures and Git.
14. All migrations, pgTAP tests, client tests, builds and CI pass.
15. Documentation accurately distinguishes implemented identity from unimplemented product features.
16. Public and anonymous signup are disabled and verified; client code cannot create accounts.
17. First-password-change completion uses the documented server-verifiable proof boundary.
18. Object privileges, RLS row authorization and function execution grants pass independent tests.
19. Revocation tests accurately preserve the configured residual JWT-expiry limitation.

## Required tests

### Pure/unit

- username normalization/alias derivation;
- bootstrap state reducer;
- route guard matrix;
- error mapping;
- password validation;
- compatibility state;
- cache partition/invalidation;
- logout decision contract.

### Widget/browser

- login mobile/web;
- keyboard/IME/Enter submission;
- focus/semantics/error announcements;
- password change;
- session checking/loading;
- intended-route return;
- disabled/profile-error states;
- maintenance/incompatible states;
- logout/back-navigation behavior;
- 200% text scale and narrow/expanded dashboard widths.

### Database/pgTAP

- schema/constraints/indexes;
- profile one-to-one and username uniqueness;
- RLS allow/deny matrix;
- privileged-field denial;
- bootstrap isolation;
- function grants/security;
- stale preference revision;
- inactive-profile behavior;
- compatibility config visibility.
- explicit table/view/sequence/function privileges and unintended-role denial;
- anonymous, owner and two-user cross-access at both object and row levels;
- active/disabled-profile enforcement;
- direct `must_change_password` update and unsupported completion-call denial;
- public/anonymous signup-disabled configuration evidence.

### Integration

- local operator provision -> login both clients -> password change;
- session restart/refresh;
- local and global signout behavior where supported;
- deactivation/revocation;
- two-user cross-access denial.

## Required verification

Run and record every applicable gate:

- exact dependency restore, resolved-graph review and root lockfile verification;
- formatting and strict analysis, including Riverpod's analysis-server plugin;
- all pure Dart unit and Flutter widget/browser tests;
- Android release build;
- dashboard Flutter Web release build;
- local Supabase clean reset from committed migrations;
- migration ordering and clean-replay verification;
- pgTAP schema, RLS allow/deny and function-privilege tests;
- anonymous, owner, cross-user and disabled-profile tests;
- first-password-change success, failure and direct-clear-denial tests;
- session restoration, refresh, expiry, stale-JWT and revocation tests;
- operator-tool dry-run and environment/confirmation tests;
- public and anonymous signup-disabled verification;
- no-secret scan and client-bundle review;
- complete Git diff and clean-tree verification;
- all required CI jobs passing with tracked files unchanged after generated/build checks.

## Documentation on completion

Update implemented-state README/context, codebase map, roadmap, handoff, audit and operator runbook. Do not mark feature UI, product schema or remote infrastructure complete.

## Git requirements

```text
branch: codex/task-imp-002a-identity-sessions
```

- do not work directly on `main`;
- do not rewrite history;
- include `TASK-IMP-002A` in implementation commit messages;
- inspect the complete diff and remove unrelated changes;
- push the branch;
- open a draft pull request;
- report the branch, commit and pull request in the completion report.

## Completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-002A
Branch:
Commit:
Pull request:
Migrations/functions/policies:
Operator tooling:
Android authentication:
Dashboard authentication:
Session/bootstrap behavior:
Tests/checks:
CI:
Security/RLS result:
Accessibility result:
Explicitly not implemented:
Documentation updated:
Risks/blockers:
Exact next action:
```
