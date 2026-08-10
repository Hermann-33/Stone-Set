# Stone Set private release

Updated: 2026-08-11
Audience: the Stone Set users and the operator maintaining the private deployment.

## Release shape

Stone Set intentionally uses the smallest release topology:

```text
Android APK (private sideload) ─┐
                               ├─> one hosted Supabase project
Flutter Web dashboard ─────────┘
```

There is no staging environment, Play Store release, public signup, analytics stack or custom email system.

Production dashboard:

```text
https://stone-set.vercel.app
```

## 1. Hosted Supabase

Production project:

```text
Project: Stone Set
Ref: pjltldrernuvrjsnmcqg
URL: https://pjltldrernuvrjsnmcqg.supabase.co
```

The repository migration chain through the private-release migration and the direct-routine-publication migration must be present. Do not run `supabase/seed.sql` against this project.

Release-specific state:

- `exercise-media` bucket exists, is private, and accepts only JPEG/PNG/WebP up to 5 MB;
- a current `production` row exists in `client_compatibility_config`;
- Auth/RLS/private Storage policies remain enabled;
- `public.publish_routine_draft_v1` is the active routine publication RPC;
- legacy routine submission/review RPCs are retired from authenticated application users.

### One-time Auth settings

In the Supabase Dashboard, keep this private:

1. Disable public user signup.
2. Disable anonymous signup.
3. Do not configure public password recovery or email signup for this build.

## 2. Provision users

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
```

Do **not** grant `routine_reviewer` merely to publish routines. Routine publication no longer requires reviewer capability, a second user, submission, approval, or rejection.

On first login, the app requires the user to replace the temporary password.

## 3. Routine publication — active policy

The old TASK-IMP-003C submission/review/approval workflow is superseded.

Current flow:

```text
Create/Edit → Save → Validate → Publish
```

Rules:

- the routine owner publishes their own valid draft directly;
- no submission step exists in the active product;
- no review queue is required;
- no independent reviewer is required;
- no approve/reject step is required;
- publication is owner-scoped, expected-revision checked, server-validated and idempotent;
- publication creates an immutable `routine_versions` snapshot;
- published versions are changed only by creating/editing a new draft and publishing a new immutable version.

Canonical architecture note:

```text
docs/context/DIRECT_ROUTINE_PUBLICATION.md
```

Active RPC:

```text
public.publish_routine_draft_v1(routine_draft_id, expected_revision, idempotency_key)
```

Legacy `routine_submissions` and `routine_reviews` tables may remain as inert history/backward-compatibility structures. Do not use them for new product behavior.

## 4. Production client configuration

The tracked public client config used directly by private release builds is:

```text
config/dart_defines.release.json
```

It contains only values shipped to every Flutter client anyway:

- production environment name;
- synthetic login alias domain;
- Supabase project URL;
- Supabase publishable key;
- build/schema contract numbers.

Never add a service-role key, database password, Vercel token or other secret to this tracked file.

## 5. Build the private release

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

### Convenience: GitHub Actions

Run the `Private Release` workflow manually. It uploads:

- `stone-set-private-apk`
- `stone-set-dashboard-web`

The runner APK uses the runner's debug signer. It is suitable for a fresh private install, but do not rely on different GitHub runs to update an already-installed APK. For update continuity use the Windows script above.

## 6. Install Android

On each Android device:

1. Transfer `app-release.apk` privately.
2. Allow installation from the selected file source if Android asks.
3. Install the APK.
4. For future updates, install an APK produced by the same Windows machine/account.

No Play Store or AAB is required.

## 7. Dashboard deployment to Vercel

The repository is configured for direct Git import at the repository root.

Root `vercel.json` controls the deployment:

- normal Vercel install command is skipped;
- `bash tool/vercel/build-dashboard.sh` installs/uses pinned Flutter and builds Flutter Web;
- output is `apps/dashboard/build/web`;
- SPA routes rewrite to `index.html`;
- Android/Gradle is not built by Vercel.

For a fresh import:

1. Vercel → Add New → Project.
2. Import `Hermann-33/Stone-Set`.
3. Leave Root Directory at repository root.
4. Use Framework Preset `Other` if Vercel asks.
5. Do not override Build Command, Install Command or Output Directory.
6. Deploy.

Current production dashboard:

```text
https://stone-set.vercel.app
```

No Supabase secret environment variables are required because the Flutter Web build contains only the public Supabase URL and publishable client key.

## 8. Minimal smoke check

Perform this after a meaningful release change. Stop if an earlier step fails.

### Identity

- User logs into Android or dashboard with username + password.
- First-password-change flow completes when required.
- Each user sees only their own private data.

### Exercise/guidance

- Create or open an exercise.
- Publish guidance with a private image or YouTube reference if desired.

### Routine publication

- Create or open a seven-day routine draft.
- Save it.
- Resolve any validation errors.
- Press `Publish`.
- Confirm a new immutable routine version appears immediately.
- Confirm no second user, review queue, approval or reviewer capability is required.

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

## 9. Rollback

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

## 10. Backup

Use the managed backup capability available on the Supabase plan. For this private phase, no custom backup pipeline or scheduled logical export is required.

Before a risky manual data operation, taking a one-off database backup/export is sensible. A formal restore drill is outside the minimal private release scope.

## 11. What is intentionally not part of this release

- staging;
- Play Store;
- custom Android signing infrastructure;
- custom email delivery;
- routine review/approval workflow;
- enterprise logging/alerting;
- performance/security certification;
- formal disaster-recovery exercises;
- new feature work unrelated to the private app.