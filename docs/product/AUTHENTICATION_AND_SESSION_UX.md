# Stone Set Authentication and Session UX

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PD-010`

## Purpose

Both Stone Set clients require an explicit login experience:

- the Android Flutter app has a native mobile login screen;
- the Flutter Web dashboard has a responsive web login page.

Both clients authenticate against the same provisioned Supabase Auth accounts. Authentication is required before any private routine, exercise guidance, media, schedule, workout, rank, wallet, or history data is shown.

## Account model

- MVP begins with two administratively provisioned users.
- Account count is not hardcoded to two.
- Public signup is disabled.
- Social login, anonymous login, magic links, and public invitations are excluded from MVP.
- Supabase Auth owns passwords, sessions, access tokens, and refresh tokens.
- Application tables never store password hashes or plaintext passwords.
- Each Auth identity links to exactly one protected profile row.

## User-visible credentials

The login pages present:

```text
Username
Password
Sign in
```

The product remains username-oriented even though Supabase password authentication uses an email or phone identity internally.

For MVP provisioning:

- each username is normalized by trimming whitespace and converting to lowercase;
- the username is unique and immutable after provisioning unless an operator performs an audited account migration;
- the operator creates a confirmed Supabase Auth user with an internal sign-in email alias under the configured Stone Set authentication domain;
- both clients deterministically map the normalized username to that internal alias and call Supabase password sign-in;
- the internal alias is an implementation detail and is not presented as the user's contact email;
- no public username directory or username-lookup endpoint is exposed.

The authentication-domain value is public configuration, not a secret. Authentication security depends on the password, Supabase Auth controls, rate limits, and authorization—not on hiding the generated alias.

## Login-page requirements

Both login surfaces include:

- Stone Set identity and product name;
- username field;
- password field;
- show/hide password control;
- submit button;
- busy state that prevents duplicate submission;
- keyboard and Enter-key submission;
- accessible labels, focus order, contrast, and error announcement;
- generic authentication error messaging;
- no signup link.

The web login page is responsive and works with keyboard-only navigation. The Android login page supports password-manager autofill where the platform permits it.

## Login behavior

1. On launch, the client checks for a valid persisted session.
2. A valid session routes directly to the authenticated home surface.
3. No valid session routes to the client-specific login page.
4. The username is normalized locally.
5. The client derives the internal provisioned sign-in alias.
6. The client calls Supabase Auth password sign-in using the publishable project configuration.
7. On success, the client verifies that the linked profile exists and is active.
8. A disabled, missing, or mismatched profile signs out immediately and shows a generic access error.
9. A first-login password-change requirement routes to the password-change screen before any product data is accessible.
10. After successful authentication and any required password change, the user reaches the mobile home or dashboard home.

Authenticated users who navigate to the login route are redirected to their authenticated home unless they explicitly sign out first.

## First-login password change

- Provisioned accounts receive an operator-generated temporary password.
- The protected profile stores a server-controlled `must_change_password` flag.
- The first successful login must change the password before normal application access.
- The new password is submitted directly to Supabase Auth and never written to application tables or logs.
- The flag is cleared only after the password update succeeds.
- The password-change screen requires current authenticated session context, new password, confirmation, and clear validation feedback.

## Error and abuse behavior

Login failures use a generic message such as:

```text
Unable to sign in. Check your details and try again.
```

The UI must not reveal whether:

- the username exists;
- the password was wrong;
- the profile is disabled;
- an internal sign-in alias exists.

Rules:

- passwords and complete credential payloads are never logged, stored in analytics, or included in crash reports;
- repeated submissions are locally throttled while a request is active;
- Supabase Auth rate limits remain enabled;
- HTTP 429 responses produce a neutral retry-later message;
- CAPTCHA may be enabled during release hardening if abuse evidence or deployment policy requires it;
- no custom permanent client-side account lockout is used because it could be abused to deny service to a known username.

## Session behavior

### Android

- A valid Supabase session persists across ordinary app restarts.
- Token refresh is handled through the Supabase client session lifecycle.
- The app listens for sign-in, token-refresh, sign-out, password-recovery, and user-update state changes relevant to the implemented flow.
- Private cached profile, guidance, image, and workout data remains scoped to the authenticated user ID.

### Web dashboard

- A valid session persists in that browser until logout, expiry, revocation, or unrecoverable refresh failure.
- All protected routes use an authentication guard.
- Direct navigation to a protected URL redirects to `/login` and may preserve the intended route for post-login return after authorization succeeds.
- The dashboard never treats a hidden route as authorization; database and Storage RLS remain authoritative.

### Multiple clients

- The same provisioned account may have separate mobile and dashboard sessions.
- Logging out one client does not automatically revoke every other session unless the operator performs a global session-revocation action.
- Product writes still obey RLS, versioning, locking, and idempotency regardless of how many authenticated clients exist.

## Session expiry and revocation

When refresh fails or the account is revoked:

1. protected network requests stop;
2. the UI returns to an authentication-required state;
3. private in-memory state is cleared;
4. the dashboard clears private caches and returns to login;
5. the mobile app preserves any unsynchronized workout draft in a quarantined, user-scoped local state;
6. the draft is inaccessible until the same account reauthenticates;
7. another account can never read or submit that quarantined draft.

A session-expiry event must not silently discard an in-progress workout.

## Logout

### Dashboard logout

- sign out from Supabase Auth;
- clear private client caches and pending view state;
- stop media requests;
- route to `/login`;
- leave no private content visible through browser back navigation.

### Android logout

If no unsynchronized workout data exists:

- sign out;
- clear private caches and active user state;
- route to login.

If unsynchronized workout data exists, manual logout requires one explicit choice:

1. synchronize now;
2. remain signed in;
3. discard the local draft and log out.

The discard action requires confirmation. Logout cleanup removes cached private guidance media for that user.

## Password recovery

MVP does not expose a public `Forgot password` workflow because accounts are privately provisioned and the internal auth alias is not a user contact address.

Recovery is operator-managed:

1. verify the user's identity out of band;
2. set a temporary password through privileged administrative tooling;
3. revoke active sessions when appropriate;
4. set `must_change_password`;
5. provide the temporary password securely;
6. require password change at next login;
7. record an audit event without recording the password.

A later public-email recovery flow requires a separate accepted product and security decision.

## Required states

Both clients must test and visibly handle:

- checking existing session;
- signed out;
- submitting credentials;
- invalid credentials;
- rate limited;
- offline or network failure;
- authenticated and active;
- authenticated but first-password-change required;
- authenticated but profile missing or disabled;
- token refreshing;
- session expired;
- manual logout;
- mobile logout blocked by unsynchronized data.

## Security and privacy boundaries

- Publishable Supabase configuration may exist in clients; privileged keys may not.
- Passwords are sent only to Supabase Auth over HTTPS.
- Internal sign-in aliases are not treated as secrets.
- User-editable profile metadata never grants authorization.
- Every private database table and Storage object remains protected by RLS.
- Generic errors prevent avoidable username enumeration.
- No private screen flashes before session restoration and authorization checks complete.
- No user data is embedded into the static Vercel build.

## Implementation placement

Authentication UI and behavior belong in:

```text
TASK-IMP-002 — Identity, login, sessions, profiles, and ownership
```

`TASK-IMP-001` remains foundation-only and must not implement login or Supabase Auth behavior.

## Primary references

- Supabase Flutter `signInWithPassword` documentation.
- Supabase password-based authentication guidance.
- Supabase user-session guidance.
- Supabase Auth rate-limit guidance.
- Accepted `ADR-0002` for Auth, Postgres, RLS, and credential boundaries.