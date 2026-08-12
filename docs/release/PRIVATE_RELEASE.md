# Stone Set private release

Updated: 2026-08-11
Audience: the two Stone Set users and the operator maintaining their private deployment.

## Release shape

Stone Set intentionally uses the smallest release topology:

```text
Android APK (private Firebase distribution) ─┐
                               ├─> one hosted Supabase project
Flutter Web dashboard ─────────┘
```

There is no staging environment, Play Store release, public signup, analytics stack or custom email system.

## 1. Hosted Supabase

Production project:

```text
Project: Stone Set
Ref: pjltldrernuvrjsnmcqg
URL: https://pjltldrernuvrjsnmcqg.supabase.co
```

The repository migration chain through TASK-IMP-007 plus `private_release_config` must be present. Do not run `supabase/seed.sql` against this project.

Release-specific state:

- `exercise-media` bucket exists, is private, and accepts only JPEG/PNG/WebP up to 5 MB;
- a current `production` row exists in `client_compatibility_config`;
- Auth/RLS/private Storage policies remain enabled.

### One-time Auth settings

In the Supabase Dashboard, keep this private:

1. Disable public user signup.
2. Disable anonymous signup.
3. Do not configure public password recovery or email signup for this build.

## 2. Provision exactly two users

The app maps a username to an internal email alias using:

```text
<username>@stone-set.invalid
```

This is intentional. No mail is sent to this domain.

For each user:

1. In Supabase Dashboard → Authentication → Users, create the user manually.
2. Use `<username>@stone-set.invalid` as the email.
3. Set a temporary password and mark the account confirmed.
4. Copy the generated Auth user UUID.
5. In the SQL Editor, run the following with that UUID and chosen username/display name:

```sql
select public.operator_link_identity(
  '<AUTH_USER_UUID>'::uuid,
  '<normalized_username>',
  '<Display Name>',
  'Asia/Kuala_Lumpur'
);

select public.operator_set_active(
  '<AUTH_USER_UUID>'::uuid,
  true
);

update public.account_capabilities
set is_enabled = true
where user_id = '<AUTH_USER_UUID>'::uuid
  and capability_code = 'routine_reviewer';
```

Enabling reviewer capability for both users is acceptable because self-review is denied by the server; each user can review the other user's routine.

On first login, the app requires the user to replace the temporary password.

## 3. Production client configuration

The tracked public client config used directly by private release builds is:

```text
config/dart_defines.release.json
```

It contains only values that are shipped to every Flutter client anyway:

- production environment name;
- synthetic login alias domain;
- Supabase project URL;
- Supabase publishable key;
- build/schema contract numbers.

The file is intentionally named as release configuration rather than a secret-bearing production file so repository hygiene checks remain meaningful. Never add a service-role key, database password, Vercel token or other secret to this tracked file.

## 4. Build and distribute private Android releases

`Private Android Distribution` is the sole phone-delivery workflow. It runs after successful
Foundation CI for an exact current `main` commit when the fail-closed classifier reports that the
Android binary can be affected. An owner may also dispatch the exact current `main` manually.

The workflow restores locked dependencies, stages rank assets, calculates
`versionCode = 1,000,000 + workflow run_number`, reconstructs the permanent JKS from the protected
GitHub environment, verifies its certificate, builds once, verifies the APK package/version/signer,
records size and SHA-256, and sends that exact APK to private Firebase group `stone-set-testers`.

The repository is public. APKs, keystores, credentials and service-account files are not GitHub
Releases or workflow artifacts. Firebase App Distribution is the private binary channel.

Expected permanent signing certificate SHA-256:

```text
D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829
```

First verified Firebase release:

```text
main commit       357cb3361176d3a58aab1f129e760e3b0c70d835
workflow run      31557166241
Firebase release 5j1j4rhquebu0
version/build     0.1.0 (1000062)
APK bytes         56892303
APK SHA-256       959208B776408E162F7A8270F381E83160D16684248B6193DC85D96168193021
```

The CI identity uses Google Workload Identity Federation and a keyless service account with only
Firebase App Distribution Admin. Admission is restricted to the numeric Stone Set repository and
owner IDs on `refs/heads/main`; no service-account JSON key exists.

Dashboard, documentation, Supabase/content-only and media-data changes do not create an APK. The
dashboard remains deployed independently through Vercel.

## 5. Install Android

### One-time migration from the debug-signed app

Before uninstalling, use the existing mobile state to confirm all three facts:

1. no active workout needs preservation (`Continue workout` is absent);
2. no workout reports `Pending sync` (use `Sync workout` and wait for `Synced` if present);
3. recent workout history is visible from the authoritative server state.

Then uninstall the old debug-signed Stone Set, accept the Firebase tester invitation, open the
release on the Android device, allow installation from that source if Android asks, and install.
Sign in and verify Home, Week, Progress, Profile and server workout history.

This is the final signing-driven uninstall. Future Firebase releases keep application ID
`io.github.hermann33.stoneset`, the permanent certificate and a higher versionCode, so Android
installs them as updates. No Play Store or AAB is used.

### Signing-key recovery

The original JKS and passwords never enter Git. Keep two independent encrypted/operator-controlled
copies and the passwords in a password manager. Verify a backup by listing the certificate and
matching the repository-recorded SHA-256 fingerprint; do not generate a replacement key. If the key
is unavailable, stop distribution rather than signing an incompatible update.

## 6. Deploy the dashboard to Vercel

Only one Vercel project is needed.

One-time:

1. Create a Vercel project named `stone-set` (or another clear private name).
2. Build the dashboard with `private-release.ps1`.
3. From `apps/dashboard/build/web`, link/deploy the static output with the Vercel CLI or upload that directory through the chosen Vercel flow.
4. Deploy to Production.

The built directory contains the SPA rewrite configuration so Flutter routes resolve to `index.html`.

No preview/staging project is required. No Supabase secrets are required by Vercel because the dashboard embeds only the public Supabase URL and publishable key at Flutter build time.

## 7. Minimal smoke check

Perform this once after the first deployment. Stop if an earlier step fails.

### Identity
- User A logs into Android with username + password.
- User B logs into the dashboard.
- First-password-change flow completes when required.
- Each user sees only their own private data.

### Authoring/review
- Create or open an exercise.
- Publish guidance with a private image or YouTube reference if desired.
- Create a seven-day routine.
- Submit it.
- The other user can approve it.
- Publish the approved routine.

### Training
- Current Week appears on Android.
- A swap works; paid RR fallback is only relevant after free credits are gone.
- Start a workout.
- Log at least one set and submit.
- Guidance/media can open without losing workout state.

### Progress
- Home rank/XP loads.
- Progress history shows the submitted workout.
- Progression settings load.
- Protection/substitution/correction screens can read their server state.

If these pass, the private release is accepted.

## 8. Rollback

### Android
Stop automatic distribution and fix forward with the same signer and a higher versionCode. Android
normally blocks version-code downgrade. Never uninstall while an active or pending-sync workout
needs preservation.

### Dashboard
Promote/redeploy the previous known-good Vercel deployment.

### Backend
Do not manually reverse historical migrations. For an urgent client freeze, set the current production compatibility row to maintenance/read-only rather than editing product tables ad hoc.

Example emergency maintenance switch:

```sql
update public.client_compatibility_config
set maintenance_mode = true,
    message_code = 'maintenance',
    message_text = 'Stone Set is temporarily unavailable.'
where environment = 'production'
  and is_current;
```

Restore with `maintenance_mode = false`, `message_code = 'available'`, and `message_text = null`.

## 9. Backup

Use the managed backup capability available on the Supabase plan. For this two-user phase, no custom backup pipeline or scheduled logical export is required.

Before a risky manual data operation, taking a one-off database backup/export is sensible. A formal restore drill is outside TASK-IMP-008.

## 10. What is intentionally not part of this release

- staging;
- Play Store;
- Play Store publication;
- a custom in-app updater or silent installation;
- public APK distribution;
- custom email delivery;
- enterprise logging/alerting;
- performance/security certification;
- formal disaster-recovery exercises;
- new feature work.
