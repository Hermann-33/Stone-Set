# Stone Set Latest Handoff

Updated: 2026-08-06

## Current task result

```text
Task ID: TASK-PD-015
Title: Correct the TASK-IMP-002A dependency baseline
Verdict: COMPLETE
Branch: codex/task-pd-015-identity-dependency-baseline
Blocked implementation task: TASK-IMP-002A — PARTIAL
Blocked implementation branch: codex/task-imp-002a-identity-sessions
Blocked pull request: #7 — OPEN DRAFT
Blocked pull request head: 7b383c1ca1fee083dfc23da755d594cf2f4c0f29
Resolution: exact dependency family approved; implementation may resume
```

Merged `main` remains at the Phase 1 foundation state. Identity behavior is not merged or complete.
Draft pull request #7 contains a partial implementation and remains draft and unmerged.

## Original blocker

The previously approved dependency family could not resolve:

```text
riverpod_generator 4.0.8  -> analyzer ^13.0.0
riverpod_lint 3.1.8       -> analyzer ^13.0.0
build_runner 2.16.0       -> analyzer >=13.3.0 <15.0.0
test 1.31.0               -> analyzer >=8.0.0 <13.0.0
```

CI run `31059367454` reproduced this conflict in both the repository and Flutter/Dart jobs. Local
Supabase passed. A local disposable worktree based on pull request #7 head reproduced the same Pub
solver failure.

Upgrading only `test` is not valid: Flutter 3.44.7 pins `flutter_test` to test_api 0.7.11, while test
1.31.1 requires test_api 0.7.12. No Flutter/Dart SDK upgrade or dependency override was accepted.

## Approved coordinated pins

```text
flutter_riverpod       3.3.2
riverpod_annotation    4.0.3
riverpod_generator     4.0.4
riverpod_lint          3.1.4
go_router              17.4.0
go_router_builder      4.4.0
supabase_flutter       2.17.1
build_runner           2.15.1
```

Proven root resolution:

```text
analyzer                 12.1.0
test                     1.31.0
test_api                 0.7.11
build                    4.0.7
source_gen               4.2.4
riverpod                 3.3.2
riverpod_analyzer_utils  1.0.0-dev.10
```

The vendor utility is a non-retracted transitive dependency of the selected stable Riverpod
releases, not a direct project pin. No dependency override or retracted package is used, and the
proof produced one root lockfile with no member lockfiles.

## Alternatives evaluated

- Minimum coordinated fallback: selected; it preserves generated Riverpod providers, typed routes,
  lint coverage and the fixed Flutter/test boundary.
- Remove Riverpod generation: rejected; pull request #7 uses generated providers/controllers across
  both clients, the generation attempt fails without annotation/generator support, and adoption
  would require a material runtime rewrite while dropping the approved lint plugin.
- Upgrade test/toolchain: rejected; test 1.31.1 conflicts with Flutter's pinned test_api 0.7.11 and a
  broader Flutter/Dart upgrade is outside this task.

## Verification evidence

The selected set was verified in disposable worktrees only:

```text
official package metadata/retraction review       PASS
real Pub solver restore                           PASS
pub deps/outdated review                          PASS
one root lockfile; no overrides                   PASS
Riverpod provider generation                      PASS
typed go_router generation                        PASS
second generation pass, zero outputs              PASS
format check                                      PASS
strict analysis                                   PASS
root Dart tests                                   PASS
domain Dart tests                                 PASS
data/UI/mobile/dashboard Flutter tests            PASS
```

Generation also succeeds against the full pull request #7 source. That partial source still has
unrelated analysis/test defects that belong to resumed `TASK-IMP-002A`; this planning task neither
fixed nor accepted them.

## Planning-task boundaries

- documentation only on the planning branch;
- no application/package runtime change;
- no committed manifest or lockfile change;
- no Supabase, migration, workflow or operator-tool change;
- no remote infrastructure change;
- no pull request #7 modification, merge or closure.

## Exact next action

Resume `TASK-IMP-002A` on its existing branch and draft pull request:

```text
branch: codex/task-imp-002a-identity-sessions
packet: docs/tasks/TASK-IMP-002A.md
pull request: #7 — OPEN DRAFT
```

Apply the approved exact pins, retain existing `package:test` coverage, regenerate the single root
lockfile, run both client generators to a zero-output freshness pass, fix the remaining source
analysis/test failures, and complete every packet gate. Do not execute `TASK-IMP-002B` or
`TASK-IMP-002C` yet.
