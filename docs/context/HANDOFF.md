# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-PD-010 — Make mobile and dashboard login pages explicit`

## Starting state

- Phase 0 was complete and `TASK-IMP-001` was approved but not executed.
- Supabase Auth and provisioned accounts were accepted in ADR-0002.
- The workflow mentioned sign-in but did not define complete mobile and dashboard login-page behavior.
- No application code, Auth project, account, credential, or external infrastructure existed.

## User requirement

Both the Android app and Flutter Web dashboard must have login pages.

## Accepted decisions

### Login surfaces

- Android has a native login screen.
- Flutter Web has a responsive `/login` page.
- Both use the same provisioned account credentials.
- Both include username, password, show/hide password, submit, loading, accessible error, and keyboard behavior.
- Neither includes signup.

### Credentials and provisioning

- Supabase Auth owns password authentication.
- The user enters username and password.
- The normalized username deterministically maps to an operator-provisioned internal email alias under a configured Stone Set auth domain.
- The alias is not a secret or user contact email.
- Users receive temporary passwords through a secure out-of-band channel.
- First login requires a password change before product access.

### Session behavior

- Valid sessions persist on both clients.
- Mobile and dashboard sessions are independent.
- Private content is not rendered before session and profile checks complete.
- Protected web routes redirect unauthenticated users to `/login`.
- Authenticated users are redirected away from the login route.
- Token refresh, expiry, revocation, and disabled-profile states are explicit.

### Error and abuse behavior

- Login failures are generic and do not reveal account existence.
- Passwords and complete credential payloads are never logged.
- Duplicate submissions are blocked while a request is active.
- Supabase Auth rate limits remain enabled.
- CAPTCHA is deferred to release hardening unless abuse evidence requires it.
- No custom permanent client lockout is used.

### Logout and recovery

- Dashboard logout clears private browser state and prevents private back-navigation display.
- Mobile logout with unsynchronized data requires sync, remain signed in, or confirmed discard.
- Involuntary mobile session expiry quarantines the draft for same-account reauthentication.
- Another account cannot read or submit that draft.
- Password recovery is operator-managed in MVP: identity verification, temporary password, optional session revocation, and forced password change.
- No public `Forgot password` workflow exists in MVP.

## New specification

- `docs/product/AUTHENTICATION_AND_SESSION_UX.md`

No new ADR was required because the accepted Supabase Auth architecture in ADR-0002 remains unchanged.

## Implementation-plan impact

Phase 2 is now explicitly:

```text
TASK-IMP-002 — Identity, login, sessions, profiles, and ownership
```

It will implement both login pages, first-login password change, route guards, session lifecycle, logout, operator recovery support, profiles, and RLS tests.

## Foundation packet decision

`TASK-IMP-001` remains approved and valid. It creates only application shells, local Supabase scaffolding, quality gates, builds, and CI. It must not implement login or authentication behavior.

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

## Verification performed

- both clients now have explicit login-page requirements;
- the same provisioned account works on both clients;
- Supabase Auth remains the only password owner;
- public signup and self-service recovery remain excluded;
- first-login, session restoration, route guards, error, rate-limit, expiry, revocation, logout, and mobile draft-protection states are defined;
- Phase 2 implementation scope is explicit;
- rank, routine, media, scheduling, backup, and foundation boundaries remain unchanged;
- no code, account, credential, schema, project, deployment, or runtime was created.

## Known risks

- The internal alias domain must be configured identically in both clients and provisioning tooling.
- A lost password requires operator availability in MVP.
- Persistent browser sessions require users to log out on shared devices.
- Mobile session loss and draft quarantine need careful integration testing.
- Auth rate limits and CAPTCHA policy must be rechecked during release hardening.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `main`
- Task: documentation and product-planning changes only.

## Exact next action

Execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
```

## Do-not-touch boundaries for the next task

- no remote Supabase, Storage, or Vercel project;
- no real credentials, accounts, signing keys, images, videos, or personal data;
- no login, authentication, profile, product schema, bucket, media, YouTube player, routine, workout, SQLite feature, rank, wallet, or deployment implementation;
- no direct work on `main`;
- no silent change to accepted product configurations or ADRs.

## Verdict

`COMPLETE`

Both required login experiences and their shared authentication/session behavior are fully planned and synchronized. The foundation remains the next bounded implementation task.