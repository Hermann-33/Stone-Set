# TASK-IMP-010 — Authoritative consistency multiplier

Updated: 2026-08-11
Status: `COMPLETE`
Branch: `codex/task-imp-010-consistency-multiplier`

## Merge and final verification evidence

```text
final implementation head   3e1e98e522d2d160e1bafca33b8a66bf0e468cb6
pull request                #34 — MERGED
merge commit               12eb3010064a7e17774c5c1ce564badce8b68d6a
Foundation CI              31460872770 — PASS
Private Release            31460872700 — PASS
production migration       20260811054519_authoritative_consistency_multiplier — DEPLOYED
```

The exact implementation head passed repository/docs, strict Flutter/Dart, Linux goldens, Android
release, Local Supabase reset/pgTAP/lint, API 24 profile and private-release artifact gates before
merge. `main` was synchronized and merge ancestry verified.

Production project `pjltldrernuvrjsnmcqg` was connected and verified healthy. Its existing migration
history used connector-recorded timestamps that differ from the repository filenames. After the
product owner explicitly authorized the connected migration-history operation, the exact tracked
SQL from `20260811045337_authoritative_consistency_multiplier.sql` (SHA-256
`CA70947000C10598A6C4392D2EB32485A1950CB5511BBD104413124437321DC3`) was applied once and recorded
remotely as `20260811054519_authoritative_consistency_multiplier`. No seed data was applied.

Credential-safe read-only verification confirms one production rank account at `1.00`, a JSON
number `1.00` in the server progress payload, exact `numeric(3,2)` type/default/constraint, enabled
RLS, authenticated select-only access, anonymous denial and no client-role execution privilege on
the private payload helper. No credential, token, password or user ID was printed or committed.

## Candidate evidence

```text
accepted starting main       adbc970088f5feee28c6214c4b2d03bf497837c9
implementation branch        codex/task-imp-010-consistency-multiplier
migration                    20260811045337_authoritative_consistency_multiplier.sql
domain tests                 35 passed
data tests                   61 passed
mobile non-golden tests      54 passed
affected data analysis       no issues
affected mobile analysis     no issues
generated-source freshness   passed
repository hygiene           passed
Windows golden comparison    renderer diff; Linux CI authoritative
local Supabase runtime       deferred — Docker/Podman unavailable
remote production change     committed migration deployed after merge
```

The candidate adds the server-owned exact-decimal field and payload value, strict Dart decoding,
live Home replacement, Progress presentation and focused pgTAP/widget/unit coverage. It assigns no
account above `1.00×`, calculates no streak and touches no weekly/swap implementation. The
engineering candidate is merged, all final-head gates pass and the controlled production migration
is deployed and verified. Final verdict: `COMPLETE`.

## Objective

Remove the authenticated Home multiplier fixture leak and expose an honest server-authoritative
base consistency multiplier through the existing progress account contract. A new/default and every
existing account starts at `1.00×` unless a future authoritative weekly evaluator legitimately
changes it.

This task distinguishes:

1. **Immediate presentation correctness:** authenticated Home and Progress render the live progress
   payload, never the standard fixture's `1.5×` value.
2. **Server-authoritative consistency state:** Postgres owns the multiplier field and returns it from
   `get_progress_v1`; Flutter only decodes and displays it.

## Authorization

The product owner explicitly authorized this bounded task on 2026-08-11. Implementation may modify
the repository and, only after the exact migration is merged and all required gates pass, deploy the
committed migration to the already-linked single production Supabase project using migration
history. Do not use ad-hoc production SQL and do not include `supabase/seed.sql`.

## Mandatory repository reads

Before implementation, read completely and in repository order:

1. `AGENTS.md`;
2. `docs/context/ACTIVE_CONTEXT.md`;
3. `docs/context/PROJECT_BRIEF.md`;
4. `docs/context/ARCHITECTURE.md`;
5. `docs/context/CODEBASE_MAP.md`;
6. `docs/context/ROADMAP.md`;
7. `docs/context/WORKFLOW.md`;
8. `docs/context/HANDOFF.md`;
9. `docs/product/RANK_SYSTEM.md`;
10. `docs/product/MOBILE_HOME_AND_RANK_PROGRESS_UI.md`;
11. `docs/product/APPLICATION_WORKFLOW.md`;
12. `docs/decisions/README.md` and every accepted ADR;
13. `docs/tasks/TASK-PD-022.md`;
14. this packet.

## Verified planning-time starting state

```text
accepted main                 9c09b359f5cd08e3f615cfa328f877e54e504209
TASK-IMP-009                  complete and merged through PR #31
HomeFixtureService.standard   Multiplier = 1.5× / Fixture state
mergeLiveProgressIntoHome     does not replace Multiplier
RankAccount                   no multiplier/streak field
rank_accounts                 RR, XP and rank only
get_progress_v1               no multiplier field
weekly evaluation history     insufficient for truthful rank-v6 streak reconstruction
production topology           one hosted Supabase project; no staging
```

Reverify these facts and a clean synchronized `main` before editing.

## Accepted product rule and bounded implementation

The rank-v6 ladder remains:

```text
0–4 perfect weeks    1.00×
5–9                  1.50×
10–14                2.00×
15+                  2.50×
```

An unprotected non-perfect week resets the streak; an accepted protected full week freezes it.
The current backend does not persist adequate immutable weekly evaluation/protection evidence.
Therefore this task must implement only authoritative base `1.00×`. It must not infer historical
perfect weeks, seed the owner at `1.50×`, or pretend the full evaluator exists.

## Exact scope

### Database

- create exactly one additive migration with the repository-pinned Supabase CLI;
- add a non-null exact-decimal server-owned multiplier column to `public.rank_accounts`, defaulting
  existing and future rows to `1.00`;
- constrain stored values to the accepted finite ladder (`1.00`, `1.50`, `2.00`, `2.50`) without
  assigning any value above `1.00` in this task;
- extend `private.progress_payload` so the account object contains
  `activeConsistencyMultiplier` as a JSON number;
- preserve every user ID, RR balance, lifetime XP, rank ID, RR/XP ledger row and workout row;
- retain RLS and the existing authenticated owner-select-only Data API grant; grant no client
  insert/update/delete access;
- keep function privileges narrow and `search_path` hardened;
- make clean replay deterministic and use safe constraint-existence handling where needed.

### Domain and data

- add an immutable `activeConsistencyMultiplier` field to `RankAccount`;
- decode it strictly in both progress and progression account payload paths;
- reject missing, nonnumeric, non-finite or unsupported values rather than silently substituting a
  fixture/default client value;
- keep the server value authoritative; do not calculate a streak or multiplier in Dart.

### Android

- make `mergeLiveProgressIntoHome` replace or add the `Multiplier` metric from
  `RankAccount.activeConsistencyMultiplier` with a clear live/server-owned label;
- render the same authoritative multiplier on Progress;
- keep the explicit fixture/preview repository path and its `1.5× / Fixture state` scenario intact;
- ensure authenticated standard Home cannot inherit the fixture multiplier after live progress
  loads;
- preserve responsive, 200% text, semantics, reduced-motion and TASK-IMP-009 presentation behavior.

### Production migration

After the implementation PR is merged and `main` is synchronized:

1. verify the linked project ref is exactly `pjltldrernuvrjsnmcqg` without printing credentials;
2. inspect local/remote migration status;
3. run a dry run where the pinned CLI supports it;
4. deploy only unapplied committed migrations with `supabase db push`, never seed data;
5. verify migration history and the owner account's multiplier through a read-only, credential-safe
   query or authenticated application flow;
6. report whether remote production data changed. Never print user IDs, tokens or credentials.

Stop before production deployment if the linked project, migration history or exact target is
ambiguous.

## Non-goals and protected behavior

- no complete streak evaluator, weekly finalizer, retroactive perfect-week history or protected-week
  derivation;
- no rank threshold, RR, XP, penalty, wallet, milestone, workout or ledger behavior change;
- no weekly schedule or swap UI/behavior change;
- do not modify `apps/mobile/lib/features/week/` except an unavoidable compile-only constructor
  update, which must be reported;
- no dashboard or exercise-media work;
- no Auth, identity, public-signup, Storage, routine-publication or release-topology change;
- no dependency, lockfile, generated-route, CI workflow or secret change;
- no service-role key, database password or operator token in clients, logs or committed files.

## Acceptance criteria

- a new/default account returns and displays `1.00×`;
- existing accounts migrate to legitimate `1.00×` without RR/XP/rank/ledger changes;
- authenticated Home never inherits the standard fixture's `1.5×`;
- explicit fixture/preview scenarios still show the intended fixture value;
- Home and Progress label the displayed live value honestly;
- both Dart account decoders require the authoritative field;
- clients cannot update the multiplier directly;
- migration reset/replay is clean and the accepted finite-value constraint is proven;
- no full streak behavior is claimed or implemented.

## Required tests and checks

### Database

- clean local Supabase reset and complete migration replay;
- focused pgTAP proof for default `1.00`, existing-row preservation, accepted/rejected values,
  anonymous/cross-user denial, authenticated owner read, direct client update denial and progress
  payload field/type/value;
- existing rank/RR/XP/ledger pgTAP regression suite;
- database lint with warnings fatal;
- migration status/idempotency inspection.

### Dart and Android

- domain/data tests for `1.00`, `1.50`, `2.00`, `2.50` decoding and malformed/missing rejection;
- Home mapper/widget tests proving live `1.00×` replaces fixture `1.5×`;
- explicit fixture preview regression retaining `1.5×`;
- Progress widget test for authoritative multiplier and 200% text;
- existing Home, Progress, rank, RR/XP and compile-contract regressions;
- formatting and generated-source freshness;
- fatal-info analysis;
- Android release build and bundle secret-marker review;
- API 24 profile because mobile Home/Progress runtime changes;
- complete final-head path-appropriate CI with no unexpected failure, cancellation or skip.

### Repository and security

- repository check, `git diff --check`, complete diff and clean-tree review;
- prove no changes under dashboard, media, weekly swap UI, dependencies, lockfiles or CI;
- no-secret and personal-data scan;
- verify audit append-only behavior.

## Required documentation updates

On the implementation branch, update only owned facts:

- this packet with completion evidence/status;
- `AGENTS.md`, `ACTIVE_CONTEXT.md`, `ROADMAP.md`, `HANDOFF.md`, `CODEBASE_MAP.md` and
  `docs/tasks/README.md` for current task state/next action;
- `RANK_SYSTEM.md` and `MOBILE_HOME_AND_RANK_PROGRESS_UI.md` only to distinguish the implemented
  authoritative base from the deferred full streak evaluator;
- active append-only `AUDIT_LOG_CONTINUED_3.md` with design, security, verification, production
  deployment and verdict evidence.

Do not rewrite historical audit entries or broad unrelated plans.

## Git requirements

```text
branch: codex/task-imp-010-consistency-multiplier
no work directly on main
no history rewriting or force push
all commits contain TASK-IMP-010
inspect complete diff
push branch
open a draft pull request
require exact final-head CI
merge only the verified exact head
sync main and prove ancestry
```

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-IMP-010
Branch:
Commit:
Pull request:
Files changed:
Database changes:
Domain/data changes:
Dashboard changes:
Mobile changes:
Remote production data changed:
Behavior intentionally unchanged:
Tests/checks:
CI result:
Secrets/personal-data review:
Remaining issues:
Exact next action:
```

`COMPLETE` requires the merged implementation, green final-head CI, synchronized `main`, safe
production migration deployment and verification that the authenticated production value comes
from server state. If production access is genuinely unavailable after all engineering gates pass,
report `PARTIAL` and the exact external action remaining.
