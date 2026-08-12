# Stone Set Latest Handoff

Updated: 2026-08-13

## Current task

```text
TASK-IMP-013A — Cached mobile shell, synchronization and Home refresh
ADR-0010
branch: agent/task-imp-013a-offline-cache
PR: #47
status: PARTIAL
```

The runtime implementation is complete. Exact implementation head
`51474a6e8d3157bfbdad9c9e1de3fa57a468a758` passed Foundation CI run `31621647343` (#365),
including mobile tests, deterministic mobile goldens, Android release APK verification and Android
API 24 profile.

The task is still `PARTIAL` because documentation is being finalized, PR #47 has not merged, the
exact resulting `main` commit and fresh private Android distribution have not yet been verified, and
physical airplane-mode acceptance requires a real tester device.

## Implemented behavior

TASK-IMP-013A adds an owner-scoped offline-first Android read shell after one prior successful online
sign-in/bootstrap:

- existing `stone_set_workout.db` migrates v1→v2 while preserving active workout/set draft tables;
- owner-scoped schema-versioned bootstrap, Week and Progress snapshots persist in SQLite;
- synchronization metadata/generation is persisted separately;
- same-owner cached bootstrap can render the authenticated shell before network refresh;
- wrong-owner/protected cached bootstrap states cannot authorize access;
- Home, Week and Progress render the latest good cached authoritative snapshots offline;
- one single-flight synchronization coordinator revalidates auth, synchronizes supported pending
  workout edits, fetches authoritative Week/wallet and Progress/rank/history, validates ownership and
  commits a coherent generation;
- Home native pull-to-refresh awaits real synchronization;
- mounted Home observes the new generation, so rank/RR updates without restart;
- Week and Progress manual refresh share the coordinator;
- startup/resume/workout completion trigger best-effort synchronization;
- logout/session loss preserves owner-scoped pending workout work rather than silently deleting it.

No Supabase migration or new dependency was introduced. Server authority, rank-v6, schedule-v3,
routine publication, Android signer/application identity and Firebase release architecture remain
unchanged.

## Exact green implementation evidence

```text
candidate head                    51474a6e8d3157bfbdad9c9e1de3fa57a468a758
Foundation CI                     31621647343 (#365) — PASS
Documentation/repository checks   PASS
Generated source                  PASS
Formatting                        PASS
Strict analysis                   PASS
Mobile goldens                    PASS
Mobile tests                      PASS
Android release APK               PASS
Android rank asset bundle         PASS
Android API 24 profile            PASS
```

The mounted Home regression specifically proves PLATINUM II / 1910 RR can become PLATINUM III /
2100 RR after a real pull gesture while the same `StatefulNavigationShell` remains mounted.

## Exact next action

1. Finish canonical documentation and append-only audit evidence on
   `agent/task-imp-013a-offline-cache`.
2. Wait only for the new exact documentation head to receive a successful Foundation CI result.
3. Mark PR #47 ready for review.
4. Merge PR #47 only with the exact green expected head.
5. Verify Foundation CI success on the exact resulting `main` SHA.
6. Verify the mobile-relevant merge triggers a fresh Private Android Distribution run.
7. Record the new version/build/Firebase release ID and verify signer fingerprint/application ID are
   unchanged.
8. On the real tester phone, complete the airplane-mode kill/relaunch/offline-refresh/internet-restore
   acceptance sequence.

Do not report historical release `0.1.0 / 1000062 / 5j1j4rhquebu0` as fresh TASK-IMP-013A
evidence.

## Remaining physical TASK-IMP-013A gate

A real Android device must show:

```text
online sign-in + initial load
→ airplane mode
→ kill/relaunch
→ cached Home/Week/Progress usable
→ offline Home refresh preserves cache
→ restore internet
→ Home pull refresh updates authoritative rank/RR without restart
```

Emulator/API-24 CI is required engineering evidence but does not substitute for this physical gate.

## Protected boundary for TASK-IMP-013B

Offline creation of a new workout session is **not** part of TASK-IMP-013A. ADR-0003 still requires
a server-authoritative online workout start. Any offline-start/reconciliation design needs a separate
TASK-IMP-013B decision before implementation.

## Independent residual work

`TASK-IMP-011` remains partial only at approved exercise-media content population. Never fabricate,
scrape or invent images/YouTube selections.

`TASK-IMP-012` remains partial only at independent signer backup and one-time phone migration/install
confirmation. Permanent signing and private Firebase App Distribution are already proven.

## Current production/release topology

```text
dashboard              https://stone-set.vercel.app
Supabase project        pjltldrernuvrjsnmcqg
Firebase project        stone-set
Android Firebase app    1:263990431224:android:fe2bf52c3f622047225a0d
tester group            stone-set-testers
signer SHA-256           D2FCB14AB458AE0F77D3CC7528E09D0D3C4514A7CAA9981C7F26AD87908C2829
```

Direct owner routine publication remains authoritative:

```text
Create/Edit → Save → Validate → Publish
```

Do not reintroduce the retired independent review/approval lifecycle without a new explicit product
decision.
