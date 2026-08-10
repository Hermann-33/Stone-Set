# Stone Set — Vercel Git import

This configuration lets Vercel import the whole `Hermann-33/Stone-Set` repository while building and hosting only the Flutter Web dashboard.

## Import settings

In Vercel:

1. Add New → Project.
2. Import `Hermann-33/Stone-Set`.
3. Keep **Root Directory** at the repository root (`.`). Do not select `apps/dashboard`; the dashboard uses shared workspace packages outside that folder.
4. Do not override Build Command, Install Command or Output Directory in the Vercel UI. The root `vercel.json` owns them.
5. Deploy.

No Vercel secret is required for the current private dashboard build. The client-facing Supabase URL and publishable key are already in `config/dart_defines.release.json` and are compiled into the Flutter Web client.

## What Vercel runs

Root `vercel.json` configures:

- install step: skipped;
- build: `bash tool/vercel/build-dashboard.sh`;
- output: `apps/dashboard/build/web`;
- SPA fallback: every application route rewrites to `/index.html`;
- ignored deployments: commits that do not touch dashboard/shared build inputs are skipped.

The build script:

1. reads the pinned Flutter version from `tool/tool_versions.json`;
2. reuses that exact Flutter version if already available, otherwise installs the matching Linux stable SDK;
3. restores the Dart workspace lockfile;
4. stages canonical rank assets;
5. runs only `flutter build web` for `apps/dashboard` with `config/dart_defines.release.json`;
6. verifies `apps/dashboard/build/web/index.html` exists.

It never runs `flutter build apk`, Gradle, Android tooling or the mobile build.

## Automatic deployments

Vercel may still clone the complete repository because the dashboard depends on shared workspace packages. That is expected.

`tool/vercel/ignore-build.sh` prevents a deployment when a commit changes none of the dashboard/shared build inputs. A mobile-only or documentation-only commit therefore does not rebuild the dashboard.

## Do not change these Vercel settings

- Do not set Root Directory to `apps/dashboard`.
- Do not add a Node framework preset.
- Do not replace the output directory with `public` or `dist`.
- Do not add Supabase service-role credentials to Vercel.

## Result

Vercel hosts only the static contents produced in:

```text
apps/dashboard/build/web
```

The Android application remains a separately built/sideloaded APK and is not deployed by Vercel.
