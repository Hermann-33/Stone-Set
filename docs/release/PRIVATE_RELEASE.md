# Stone Set private release

Updated: 2026-08-10
Audience: the two Stone Set users and the operator maintaining their private deployment.

## Release shape

Stone Set intentionally uses the smallest release topology:

```text
Android APK (private sideload) ─┐
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

## 4. Build the private release

### Preferred: Windows release build

Use the same Windows account/machine for repeat Android update builds so the existing debug signing key remains stable.

From PowerShell:

```powershell
.\tool\release\private-release.ps1
```

Outputs:

```text
apps/mobile/build/app/outputs/flutter-apk/app-release.apk
apps/dashboard/build/web/
```

The script also copies `vercel.json` into the built dashboard directory.

### Convenience: GitHub Actions

Run the `Private Release` workflow manually. It uploads:

- `stone-set-private-apk`
- `stone-set-dashboard-web`

The runner APK uses the runner's debug signer. It is suitable for a fresh private install, but do not rely on different GitHub runs to update an already-installed APK. For update continuity use the Windows script above.

## 5. Install Android

On each of the two Android devices:

1. Transfer `app-release.apk` privately.
2. Allow installation from the selected file source if Android asks.
3. Install the APK.
4. For future updates, install an APK produced by the same Windows machine/account.

No Play Store or AAB is required.

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
Keep the previous known-good APK from the same signer. If an update is bad, reinstall the prior compatible APK where Android permits downgrade; otherwise uninstall/reinstall and sign in again. Local unsynced workout data can be lost on uninstall, so submit/sync active workouts first.

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
- custom Android signing infrastructure;
- custom email delivery;
- enterprise logging/alerting;
- performance/security certification;
- formal disaster-recovery exercises;
- new feature work.
