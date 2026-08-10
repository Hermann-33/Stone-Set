# TASK-IMP-008 code map

Mode: `FAST TWO-USER PRIVATE RELEASE`

## Files owned by 008

| Path | Purpose |
| --- | --- |
| `supabase/migrations/20260810210900_private_release_config.sql` | Create the private media bucket and activate production compatibility. |
| `config/dart_defines.release.json` | Tracked public production Flutter configuration used by private release builds. |
| `.github/workflows/private-release.yml` | Manual narrow production artifact build. |
| `tool/release/private-release.ps1` | Preferred repeatable Windows release build using the same local Android debug signer. |
| `docs/release/PRIVATE_RELEASE.md` | Two-user provisioning, build, deploy, smoke and rollback runbook. |
| `docs/tasks/TASK-IMP-008.md` | Executable scope authority. |
| `docs/context/ACTIVE_CONTEXT.md` | Current release state. |
| `docs/context/HANDOFF.md` | Final handoff. |
| `docs/context/ROADMAP.md` | Final phase/completion state. |

## Existing seams reused unchanged

- `apps/mobile/lib/app/mobile_client_configuration.dart`
- `apps/dashboard/lib/src/bootstrap/dashboard_bootstrap.dart`
- `apps/mobile/android/app/build.gradle.kts`
- `apps/dashboard/vercel.json`
- the accepted Supabase migration chain through TASK-IMP-007
- existing Foundation CI

## Intentionally no implementation work

008 must not add:

- a second backend environment;
- a new auth system;
- a deployment backend/service;
- a dashboard admin/provisioning UI;
- Play signing/AAB support;
- background monitoring;
- release analytics;
- new feature code.

## External one-time actions

These are not Codex tasks:

1. Supabase Dashboard: disable public and anonymous signup.
2. Supabase Dashboard: create exactly two auth users and link/activate their profiles using the runbook SQL.
3. Vercel: create/link one project if dashboard hosting is desired.
4. Windows: run `tool/release/private-release.ps1` for a stable private Android update signer.
