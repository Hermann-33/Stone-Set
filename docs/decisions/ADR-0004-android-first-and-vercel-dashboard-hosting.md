# ADR-0004: Android-first mobile release and Vercel dashboard hosting

## Status

Accepted

- Date: 2026-08-04
- Type: Client release and deployment architecture
- Supersedes: None
- Preserves: ADR-0001 separate Flutter clients and private two-user MVP scope

## Context

Stone Set needs one mobile execution client and one browser-based management dashboard. The current development environment is Windows-based, while Flutter iOS release work requires macOS and Xcode. Supporting two mobile platforms before validating the first workflow would double device, signing, release, and regression obligations.

The Flutter Web dashboard compiles to static files and does not require a custom application server. It needs reliable Git-based previews, production rollbacks, HTTPS, custom-domain support, and single-page-application routing.

## Decision criteria

- smallest credible initial release matrix;
- compatibility with the current development environment;
- reproducible builds;
- low hosting and operational burden;
- preview deployments before production;
- no server secrets in a static client;
- clear future path to iOS;
- simple rollback.

## Options considered

### Mobile Option A — Android and iOS together

Advantages:

- maximum mobile reach at launch.

Disadvantages:

- iOS requires macOS, Xcode, Apple signing, App Store Connect, and additional testing;
- doubles platform-specific release work before product validation.

### Mobile Option B — Android first

Advantages:

- directly supported by the current development environment;
- one device and signing matrix for MVP;
- iOS can be added later without changing backend contracts.

Disadvantages:

- iPhone users cannot use the initial mobile client.

### Dashboard Option A — Firebase Hosting

Advantages:

- documented Flutter Web deployment path;
- mature static hosting.

Disadvantages:

- adds another platform relationship to a Supabase-based product.

### Dashboard Option B — Vercel static deployment

Advantages:

- GitHub preview deployments;
- production deployment from `main`;
- static output and CDN delivery;
- straightforward monorepo root configuration;
- instant rollback to an earlier deployment.

Disadvantages:

- Flutter is not a Vercel auto-detected framework;
- build and output configuration must be explicit.

### Dashboard Option C — GitHub Pages

Advantages:

- minimal additional service setup.

Disadvantages:

- weaker preview and environment workflow;
- less convenient production promotion and rollback.

## Decision

### Mobile release

Stone Set is Android-first.

- Initial platform: Android only.
- Minimum supported Android API: 24.
- Initial Flutter mobile scaffold contains only the Android platform.
- First two-user distribution uses a signed release APK through a private channel.
- Signing material is created outside the repository and never committed.
- Google Play internal testing may be added during release hardening.
- iOS is deferred and no iOS platform directory is generated in `TASK-IMP-001`.

An iOS implementation is triggered only when:

1. an initial or approved future user requires iOS;
2. a maintained macOS/Xcode build environment exists;
3. signing and TestFlight/App Store operations are accepted;
4. iOS-specific integration tests are added.

### Dashboard hosting

Stone Set uses Vercel for the Flutter Web dashboard.

- The dashboard is one Vercel project rooted at `apps/dashboard`.
- Flutter builds use `flutter build web --release`.
- The generated `build/web` contents are deployed as static output.
- Path-based Flutter navigation requires a rewrite fallback to `index.html`.
- Pull-request and non-production branches receive preview deployments.
- `main` is the production branch.
- Production promotion occurs only after repository CI succeeds.
- Rollback re-points production to a previously verified deployment; it does not rebuild an unknown artifact.

### Build responsibility

GitHub Actions builds and tests the dashboard with the repository-pinned Flutter SDK, then deploys a prebuilt Vercel artifact.

This avoids downloading and configuring Flutter ad hoc inside an opaque hosting build.

Required deployment behavior:

1. build once;
2. test the exact build candidate;
3. package static output for Vercel;
4. create a preview deployment;
5. promote the verified artifact to production.

Vercel CLI versions are pinned in the repository tool lockfile. CI never installs an unbounded `latest` version.

### Environment and secret boundary

The Flutter Web bundle may contain only values safe for a public client:

- Supabase project URL;
- Supabase publishable key;
- non-secret build metadata.

It must never contain:

- service-role or secret keys;
- database passwords;
- Supabase access tokens;
- Vercel deployment tokens;
- backup credentials.

Deployment credentials remain CI secrets.

## Consequences

### Positive

- one mobile platform can be validated deeply before expansion;
- no macOS/Xcode dependency blocks the first release;
- dashboard previews and rollbacks are built into the deployment model;
- static hosting has no custom server patching burden;
- mobile and dashboard release cycles remain independent.

### Negative

- iOS users are deferred;
- private APK distribution requires controlled updates;
- Flutter Web SPA rewrites and cache behavior require verification;
- Vercel configuration and CI credentials add operational setup later.

## Security, privacy, data, and operational impact

- The dashboard remains a public static client protected by Supabase Auth and RLS, not by obscurity.
- Preview deployments must use non-production Supabase configuration.
- Production data is not connected to arbitrary branch previews.
- Deployment tokens are encrypted CI secrets.
- Android signing keys and passwords remain outside Git.
- Release artifacts are checksummed and traceable to a commit.

## Scope boundaries

This ADR does not authorize:

- Vercel project creation;
- production deployment;
- Android signing-key creation;
- Play Store enrollment;
- iOS scaffolding;
- Vercel Functions;
- server-side rendering;
- analytics or telemetry;
- domain purchase.

## Rollback or supersession rule

A later ADR may add iOS after the trigger conditions are met.

A later ADR may replace Vercel if Flutter Web build performance, accessibility, cost, or operational reliability is unacceptable. The replacement must preserve static SPA routing, preview isolation, production rollback, and public-client secret boundaries.

## Activation evidence

`TASK-PL-002` accepts this release and hosting architecture. Project creation and deployment remain future implementation work.