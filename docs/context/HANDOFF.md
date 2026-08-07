# Stone Set Latest Handoff

Updated: 2026-08-07

## Current task result

```text
Task ID: TASK-PD-017
Title: Verify Phase 2B merge and approve dashboard shell/Overview
Verdict: COMPLETE
Planning task: TASK-PD-017
Planning branch: codex/task-pd-017-approve-imp-002c
Verified base: 1ab0fc56543dbd64500a9319dd6a3f014c4ccc90
Phase 2B pull request: #10 — MERGED
Phase 2B final CI run: 31109946478 (PASS)
Packet result: TASK-IMP-002C APPROVED — NOT EXECUTED
```

`TASK-IMP-002A` remains complete and merged through pull request #7. `TASK-IMP-002B` is complete and
merged through pull request #10 at `1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`. `TASK-PD-017`
verified that result, corrected stale canonical facts and approved the fixture-only
`TASK-IMP-002C` dashboard shell/Overview packet. This planning result adds no runtime or remote
infrastructure.

## Implemented boundary

- coordinated exact Riverpod/go_router/Supabase/build dependency family with Analyzer 12.1.0,
  `test` 1.31.0 and `test_api` 0.7.11;
- one root Dart lockfile, no overrides, reproducible generated providers and typed routes;
- private provisioned Auth only, deterministic username aliases and no client signup surface;
- Android and Web login, required-password-change, bootstrap, refresh/revalidation, disabled/revoked,
  expiry, logout and cache-clearing flows;
- local profiles, preferences, capabilities, compatibility, session/revocation and password-proof
  schema with explicit object grants, RLS and function execution grants;
- trusted, dry-run-first operator provisioning, reset, disable and revocation tooling;
- local-only migrations, pgTAP security matrices, runtime signup denial and real Auth password-update
  lifecycle proof;
- shared system/light/dark semantic themes, motion/state tokens and the packet-bounded reusable UI
  primitives;
- a typed go_router stateful Home/Week/Progress/Profile shell that preserves identity guards and
  resets user-owned router state on logout or user-ID change;
- fixture-only Home repository/service/controller, all accepted today/week/metric states, an explicit
  20-rank asset resolver and full-circle rank hero with event-driven/reduced motion;
- deterministic unit, widget, semantics, lifecycle, golden and API 24 profile verification.

## Verification evidence

Final identity GitHub Actions run `31093560109` remains passing. Final `TASK-IMP-002B` verification
on run `31109946478` includes:

```text
locked restore / tool and repository checks       PASS
formatting / strict analysis                       PASS locally and in CI before golden comparison
shared UI tests                                    14/14 PASS
mobile non-golden tests                            34/34 PASS
dashboard release Web build                       PASS locally
Linux golden candidate generation                 PASS; 12 reviewed baselines committed
Android release + 20-entry rank bundle            PASS in CI
Android API 24 physical 360x800 profile            PASS; build 2.095/7.596 ms avg/worst;
                                                    raster 9.560/16.560 ms avg/worst
dashboard Chrome tests / release Web build         PASS in CI
local Supabase lifecycle/security                  PASS in CI
```

This Windows host passed the locally available restore, second-pass zero-output generation,
analysis, unit/widget and Web build gates. It lacks an Android SDK, so the required Android release
and API 24 profile evidence is owned by CI. Existing Supabase/Auth/security gates remain unchanged.

## Security and operational boundaries

- global public signup and anonymous signup are disabled; email/password remains enabled so
  operator-provisioned users can sign in;
- a client cannot directly clear `must_change_password`; completion consumes server-side Auth audit
  evidence bound to the authenticated identity and a live application session;
- Postgres does not inspect passwords; the proof confirms an accepted Auth password-update event,
  not password contents or same-client origin;
- Data API object access, RLS row authorization and function `EXECUTE` are independently granted and
  tested;
- JWTs are not claimed to invalidate instantly; local expiry is one hour and protected bootstrap/RPC
  paths revalidate active profile and application-session state;
- service-role/management credentials remain trusted-tool environment inputs and never enter Flutter
  clients, bundles, committed files or logs;
- non-local provisioning is blocked without a controlled alias domain or supported delivery hook;
- no remote Supabase, Vercel or production account was created or changed.

## Explicitly not implemented

The dashboard shell/Overview/search/palette remains unimplemented until `TASK-IMP-002C` executes.
Real exercise/guidance/media/routine persistence, schedules/week data, workout
start/logging/timers/results, SQLite/outbox synchronization, authoritative RR/XP/rank/wallet/
finalization, Storage, deployment and production provisioning also remain unimplemented.

## Exact next action

After the `TASK-PD-017` planning pull request merges, execute the approved dashboard presentation
packet:

```text
task: TASK-IMP-002C
branch: codex/task-imp-002c-dashboard-shell-overview
packet: docs/tasks/TASK-IMP-002C.md
```

Do not execute `TASK-IMP-003A` or any later packet yet.
