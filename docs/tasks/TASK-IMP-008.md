# TASK-IMP-008 — Minimal private release

Updated: 2026-08-10
Status: `APPROVED — EXECUTABLE`
Mode: `FAST TWO-USER PRIVATE RELEASE`
Branch: `codex/task-imp-008-minimal-release`

## Goal

Make the already-complete Stone Set product usable by its two known users with the smallest practical release surface.

This is not a production-hardening programme. It is a private deployment packet.

## Required result

```text
accepted main
  -> one hosted Supabase backend
  -> one production client configuration
  -> one private Android APK build path
  -> one dashboard web build/deploy path
  -> two provisioned users
  -> short smoke check
```

## In scope

### Hosted backend
- use the existing single `Stone Set` Supabase project;
- apply the accepted repository migration chain without synthetic seed data;
- create the private `exercise-media` bucket;
- create the current `production` compatibility row;
- retain existing Auth, RLS, Storage policies and server-authoritative RPCs.

### Android
- build a release APK with production Dart defines;
- private sideload only;
- current debug signing is acceptable for this two-user build;
- prefer the same Windows machine for future APK updates so the signer remains stable.

### Dashboard
- build the existing Flutter Web SPA with the same production Dart defines;
- retain the existing `vercel.json` SPA rewrite;
- one Vercel project only when linked/deployed.

### Provisioning
- public signup disabled;
- anonymous signup disabled;
- two users created by an operator/admin only;
- synthetic `@stone-set.invalid` aliases are acceptable because this private build sends no user email.

### Verification
- use existing Foundation CI for code quality;
- use only a small release-build sanity check for 008-specific changes;
- smoke the main user journey after deployment.

## Deliberately excluded

Do not add any of the following for this private release:

- staging or a second Supabase project;
- Play Store distribution;
- AAB publishing;
- production keystore automation or key rotation;
- iOS;
- public signup or password-recovery email infrastructure;
- custom email domain;
- broad security/threat-model work;
- ASVS/MASVS programme;
- API 24 matrix;
- golden expansion;
- enterprise observability or alerting;
- multi-region/HA;
- formal RPO/RTO targets;
- formal restore drills;
- complex backup automation;
- analytics or crash-reporting SDKs;
- new product features.

## Accepted shortcuts

1. The Supabase URL and publishable key are public client configuration and may be committed in `config/dart_defines.release.json`. Never commit a service-role or secret key.
2. Android uses the existing debug signing configuration for private sideloading. Build future update APKs on the same Windows machine where practical.
3. Vercel needs only one project. No preview/staging environment is required.
4. User provisioning may use the Supabase Dashboard plus SQL/operator functions instead of building another admin UI.
5. Managed Supabase backups are sufficient for this phase; no custom backup pipeline is required.

## Exit gate

008 is complete when:

- hosted Supabase contains the accepted schema and production compatibility config;
- private media bucket exists and is not public;
- production client defines are committed;
- Android release APK can be built with those defines;
- dashboard release can be built with those defines;
- the private release runbook is complete;
- one Vercel project can be linked/deployed without code changes;
- no unresolved 008-specific compile/config defect remains.

## Codex rule

Codex does not plan, redesign, deploy Supabase, create Vercel infrastructure, or redo existing verification.

Use Codex only if a concrete local production build/signing failure remains after external CI/release checks. Its loop is:

```text
reproduce named failure -> narrow fix -> targeted build -> commit -> push -> stop
```
