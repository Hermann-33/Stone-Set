# TASK-IMP-002A — Implement identity, login, sessions, profiles and ownership

Status: `PLANNED — NOT YET AUTHORIZED`
Target phase: `Phase 2 — Identity, sessions and authenticated UI foundation`

Depends on:

1. `TASK-IMP-001 — Create Flutter and Supabase project foundation` complete and merged;
2. `docs/context/TECHNOLOGY_BASELINE.md` still accepted;
3. `docs/context/DATABASE_AND_SERVER_PLAN.md` still accepted;
4. `docs/product/AUTHENTICATION_AND_SESSION_UX.md` still accepted;
5. a task-start verification that current Supabase Auth/Flutter APIs are compatible with the pinned toolchain.

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

Suggested branch:

```text
codex/task-imp-002a-identity-sessions
```

Do not work directly on `main`. Promote this packet to `APPROVED` only after verifying the merged foundation and current official API compatibility.

## Exact scope

## 1. Dependencies and architecture

Add only pinned, reviewed dependencies required for:

- Supabase Flutter client;
- Riverpod state/DI and selected code-generation/lint support;
- go_router typed routing;
- secure platform session storage as provided by the supported Supabase Flutter implementation;
- immutable/serialization support only if selected and justified.

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

- no public signup trigger that creates arbitrary active accounts;
- missing profile is a safe authentication failure;
- duplicate username/profile is impossible;
- username normalization is deterministic and tested;
- profile active/password-change flags are not user-editable;
- reward timezone validates an accepted IANA identifier;
- user-editable fields use a safe function or column privilege boundary.

## 4. RLS and privileges

Enable RLS on every exposed table.

Test at minimum:

- anonymous denied;
- owner reads permitted own profile/preferences;
- owner updates only permitted fields;
- other authenticated user denied;
- direct update of active, username, capability and `must_change_password` denied;
- compatibility config exposes only safe active data;
- privileged functions are not executable by unintended roles.

Use indexed `(select auth.uid())` policy expressions where appropriate. Exposed views use `security_invoker`.

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

- service-role/management credentials come from uncommitted environment/secret input;
- dry-run where feasible;
- explicit environment confirmation;
- production actions require an additional confirmation argument;
- output never prints passwords after initial secure handoff and never prints tokens;
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

- domain is public environment configuration;
- no lookup endpoint;
- no account existence leak;
- mapping tests include whitespace, case, invalid characters and maximum length;
- user-visible UI never presents the alias as contact email.

## 10. Session lifecycle

Use the supported Supabase Flutter session lifecycle and explicitly handle:

- no local session;
- local session requiring refresh;
- token refresh success;
- token refresh failure;
- signed in;
- signed out;
- user/password update;
- operator revocation/disabled profile;
- app foreground revalidation;
- browser refresh/direct URL.

Do not assume a locally restored session is fully valid before bootstrap/refresh completes.

Mobile and dashboard sessions are independent. Logging out one does not imply global revocation unless the operator chooses that scope.

## 11. First-password-change transaction

Flow:

1. authenticated bootstrap reports requirement;
2. all product routes redirect to password change;
3. validate new password/confirmation locally;
4. update password through Supabase Auth;
5. clear server-controlled flag only through an atomic safe server operation after Auth update success;
6. re-bootstrap;
7. enter protected placeholder.

Failure cannot leave the UI claiming completion when the server flag remains set. Password values never enter application logs or tables.

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

### Integration

- local operator provision -> login both clients -> password change;
- session restart/refresh;
- local and global signout behavior where supported;
- deactivation/revocation;
- two-user cross-access denial.

## Documentation on completion

Update implemented-state README/context, codebase map, roadmap, handoff, audit and operator runbook. Do not mark feature UI, product schema or remote infrastructure complete.

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
