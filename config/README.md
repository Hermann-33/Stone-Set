# Stone Set client configuration

The partial identity applications require public runtime configuration. Copy
`dart_defines.example.json` to an ignored environment-specific file and pass it with
`--dart-define-from-file`; the committed example cannot connect to a service.

Only public client values belong in Dart defines:

- `APP_ENV` identifies the non-secret environment name.
- `STONE_SET_ALIAS_DOMAIN` is the public controlled internal-alias domain. The committed local
  example is intentionally non-routable and must not be used for staging or production
  provisioning.
- `SUPABASE_URL` is the public project URL.
- `SUPABASE_PUBLISHABLE_KEY` is the public client key.

Never place service-role or secret keys, database passwords, Supabase access tokens, Vercel
tokens, backup credentials, signing material, account identifiers, or personal data in these
files. The committed example contains non-routable placeholders only.

Staging and production account provisioning must remain disabled until the selected alias domain
is controlled by the operator or an officially supported custom/no-op email-delivery hook is in
place. Normal username/password sign-in must not depend on successful email delivery, and the
internal alias must never be presented as a contact address.
