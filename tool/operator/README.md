# Stone Set trusted identity operator

This Node 24 CLI is the candidate account-provisioning boundary in the partial `TASK-IMP-002A`
implementation. It is not imported by Flutter, shipped in browser/mobile bundles, or exposed
through the operator dashboard. It is not accepted for real provisioning until database replay,
integration tests and CI pass.

## Security boundary

- Never commit `STONE_SET_SERVICE_ROLE_KEY`, management credentials, aliases, passwords or tokens.
- Set `STONE_SET_SUPABASE_URL` and `STONE_SET_SERVICE_ROLE_KEY` only in the trusted operator process.
- Never pass a password, token, key or database URL on the command line; the parser rejects those
  argument names.
- Commands are dry-run by default. Execution requires `--execute`; production additionally requires
  `--confirm-production`.
- Generated temporary passwords are displayed once only after a successful provision/reset. Transfer
  them using the approved controlled handoff and clear the terminal.
- Status output omits email aliases, tokens, password values, IP addresses and user agents.
- Within the packet's identity objects, `service_role` can execute only the public operator wrappers
  and their private helpers. The private
  schema is not exposed through the Data API.
- Public email signup and anonymous signup must remain disabled in every environment. Before staging
  or production provisioning, verify the deployed Auth settings and a rejected public signup attempt;
  never assume the committed local setting changed a remote project. Executed provisioning fails
  closed unless the running Auth settings report both global signup and anonymous identities disabled.
- Auth database audit-log persistence is a provisioning precondition. If it is disabled or its
  pinned payload changes, stop rather than weakening password-change proof.

## Alias strategy

Local development defaults to `username@local.stone-set.invalid`, a synthetic non-routable test value.
Before staging or production provisioning, set both public non-secret settings:

```text
STONE_SET_ALIAS_STRATEGY=controlled_domain | noop_email_hook
STONE_SET_ALIAS_DOMAIN=<configured internal alias domain>
```

`controlled_domain` means Stone Set controls delivery for the domain. `noop_email_hook` means the
environment has a documented supported Send Email hook that intentionally handles these internal
aliases. Normal login never depends on email delivery, and the alias is never a contact email.
Reserved non-routable/test domains (`.invalid`, `.test`, `.example`, `.localhost`, and the IANA
example domains) are rejected outside local development, regardless of the selected strategy.

## Commands

Run from the repository root. Omit `--execute` first to inspect the safe dry-run plan.

```powershell
node tool/operator/stone-set-operator.mjs provision --environment local --username test_user --display-name "Test User"
node tool/operator/stone-set-operator.mjs status --environment local --username test_user
node tool/operator/stone-set-operator.mjs set-active --environment local --username test_user --active false
node tool/operator/stone-set-operator.mjs revoke --environment local --username test_user --scope selected --session-id <uuid>
node tool/operator/stone-set-operator.mjs revoke --environment local --username test_user --scope global
node tool/operator/stone-set-operator.mjs reset-password --environment local --username test_user
```

For an authorized local execution, set the uncommitted environment values and append `--execute`.
Never paste their values into documentation, shell history, issues, logs or CI output.

## Provisioning and reset behavior

Provisioning creates a confirmed Auth user, links an inactive profile/preferences/security state,
and activates the profile only after linkage succeeds. A failed provision attempts to delete the
newly created Auth user, whose application rows cascade away.

Password reset captures the previous password-audit event and deactivates the profile before changing
Auth. It waits for a new `user_updated_password` audit event, establishes a new requirement marker and
global Stone Set session cutoff, then restores the prior active state. Any failure leaves the profile
disabled and does not display the generated password. The operator can safely repeat the reset.

Password-change completion proves only that Supabase Auth recorded a matching update by the current
identity after the server requirement marker. PostgreSQL never sees or inspects a password. Auth
database audit storage must remain enabled; audit delivery can be delayed, so clients keep a pending
state and retry. Evidence must be newer than the requirement marker and no more than 24 hours old;
each Auth audit event can be consumed once. The implementation must be revalidated if the pinned Auth
audit payload changes.

## Revocation boundary

Selected revocation records the documented Auth `session_id`; global revocation records a per-user
cutoff. Every protected Stone Set RLS policy/RPC must use the shared live-session helper. This denies
Stone Set data deterministically, but an already-issued JWT can remain cryptographically valid until
its configured expiry (currently one hour). The clients detect denial during bootstrap/foreground
revalidation and clear local session state; the tool never claims immediate Auth token destruction.

## Verification

```powershell
node --test tool/operator/operator.test.mjs supabase/tests/config/auth_config.test.mjs
node tool/operator/stone-set-operator.mjs provision --environment local --username test_user --display-name "Test User"
```

After a clean local Supabase start, run the runtime signup proof with the local public URL and anon
key supplied through the process environment. The test rejects non-loopback URLs and never prints the
key or response body:

```powershell
$env:STONE_SET_RUN_SUPABASE_INTEGRATION='1'
$env:STONE_SET_SUPABASE_URL='http://127.0.0.1:54321'
$env:STONE_SET_SUPABASE_ANON_KEY='<local public anon key from the trusted environment>'
node --test supabase/tests/integration/signup_disabled.integration.test.mjs
```

Clear those process variables after the test. Database migrations, pgTAP, and this runtime proof
require a Docker-capable local Supabase executor or CI.
