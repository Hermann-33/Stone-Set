# Stone Set client configuration

The foundation applications build without configuration. Later implementation packets may copy
`dart_defines.example.json` to an ignored environment-specific file and pass it with
`--dart-define-from-file`.

Only public client values belong in Dart defines:

- `APP_ENV` identifies the non-secret environment name.
- `SUPABASE_URL` is the public project URL.
- `SUPABASE_PUBLISHABLE_KEY` is the public client key.

Never place service-role or secret keys, database passwords, Supabase access tokens, Vercel
tokens, backup credentials, signing material, account identifiers, or personal data in these
files. The committed example contains non-routable placeholders and is not used by the foundation
shells.
