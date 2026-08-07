# Stone Set Latest Handoff

Updated: 2026-08-07

## Current task result

```text
Task ID: TASK-IMP-002C
Title: Implement responsive dashboard shell and Overview
Verdict: PARTIAL — FINAL CI AND MERGE PENDING
Implementation branch: codex/task-imp-002c-dashboard-shell-overview
Draft pull request: #12
Verified base: 76cb3166d4008084900b53b691e4ea80bc0167e9
Phase 2B pull request: #10 — MERGED
Phase 2B final CI run: 31109946478 (PASS)
Packet result: TASK-IMP-002C IMPLEMENTED — FINAL CI AND MERGE PENDING
```

`TASK-IMP-002A` remains complete and merged through pull request #7. `TASK-IMP-002B` is complete and
merged through pull request #10 at `1ab0fc56543dbd64500a9319dd6a3f014c4ccc90`. Planning pull
request #11 merged at `76cb3166d4008084900b53b691e4ea80bc0167e9` and authorized the
fixture-only `TASK-IMP-002C` packet. The bounded dashboard implementation and local verification
are complete; reviewed Linux goldens, final-head GitHub Actions and merge remain required.

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
- a typed, path-based dashboard router with guarded direct links, safe not-found/error routes and
  compact/medium/expanded drawer, rail and labeled-sidebar shells;
- fixture-only Overview hierarchy, deterministic service/repository/controller fixtures, search,
  command palette, shortcut help, theme cycling, save/offline/conflict surfaces and a fixture gallery;
- reusable list-detail, supporting-pane, responsive-toolbar, filter, status, validation,
  confirmation, mobile-preview and reorder primitives in `packages/ui`;
- user-owned presentation state remains below the authenticated user-keyed provider boundary and is
  destroyed on logout or user-ID change.

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

Current `TASK-IMP-002C` local evidence includes 53 dashboard VM tests before the final idle-frame
addition, 22 focused feature tests, shared UI regressions, strict fatal-info analysis, a successful
standard Flutter Web release build and a bundle scan with no privileged credential markers. The
added idle-frame regression passes after navigation and a responsive-tier resize. Local Windows
Chrome test startup stalls before reporting progress, so the clean Linux/Chrome GitHub Actions job
is the authoritative browser gate. Candidate run `31159999651` regenerated all six
compact/medium/expanded light/dark baselines on Linux; the reviewed artifacts replaced the Windows
files before final-head CI.

Superseded PR run `31159992579` exposed only unrelated single-line formatting in two unchanged
Riverpod session generator files. Those files were restored to the fresh Linux generator's exact
pre-task output; provider hashes and behavior were unchanged. Final-head CI remains authoritative.

Current Ubuntu runners install emulator 37.1.11, whose default 7372.80 MB userdata partition exceeds
the observed 7100.76 MB free AVD space. Two attempts failed before boot or app installation. The
pinned action's supported `disk-size` input is now set to 4096 MB; API/device/ABI/skin/cores/RAM,
profile commands and performance thresholds are unchanged. Final-head CI must validate the fix.

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

The dashboard shell/Overview/search/palette is implemented only as fixture-driven presentation
infrastructure. Real exercise/guidance/media/routine persistence, schedules/week data, workout
start/logging/timers/results, SQLite/outbox synchronization, authoritative RR/XP/rank/wallet/
finalization, Storage, deployment and production provisioning also remain unimplemented.

## Exact next action

Complete final verification and merge for the implemented dashboard presentation packet:

```text
task: TASK-IMP-002C final verification
branch: codex/task-imp-002c-dashboard-shell-overview
packet: docs/tasks/TASK-IMP-002C.md
```

Pass every required final-head CI check on draft pull request #12, review the complete diff and
merge. Do not execute `TASK-IMP-003A` or any later packet until the post-merge planning stage.
