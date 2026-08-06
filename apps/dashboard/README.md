# Stone Set dashboard

Partial Web-only Flutter client sources for the bounded Stone Set identity and session slice. They
are not accepted runtime behavior until the dependency blocker and every 002A verification gate pass.

The intended client restores and revalidates sessions, supports username/password sign-in,
enforces the first-password-change gate, handles maintenance and compatibility
states, and protects its current placeholder route. Product dashboard workflows,
editors, and operator account provisioning remain out of scope.

Runtime configuration is supplied with public Dart defines:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `STONE_SET_ALIAS_DOMAIN`
- `APP_ENV`

Only a Supabase publishable key is accepted by this client boundary. Service-role,
management, database, and operator credentials must never enter Dart defines,
browser bundles, assets, logs, CI artifacts, or committed files.

## Verification

Run from this directory after restoring the root Pub workspace:

```text
flutter test --platform chrome
flutter build web --release --dart-define-from-file=../../config/dart_defines.local.json
```

Create the ignored local define file from `config/dart_defines.example.json` and
replace only its documented public placeholders.

CI also scans the release bundle for service-role and management credential
markers. A successful build is not evidence that login works until the local
Supabase identity migration and bootstrap RPCs are running.
