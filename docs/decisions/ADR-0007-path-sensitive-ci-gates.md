# ADR-0007: Path-sensitive CI gates

## Status

Accepted

- Date: 2026-08-08
- Type: Repository governance, verification, and CI resource policy
- Supersedes: The foundation workflow's unconditional execution of every runtime job
- Preserves: Pinned tools/actions, read-only CI permissions, exact restores, strict analysis, security boundaries, release thresholds, and final-head evidence

## Context

The foundation workflow originally ran Flutter, Android, the API 24 physical-profile scenario,
dashboard browser/build checks, and local Supabase for every pull request. That was safe while most
changes affected the entire foundation, but it makes documentation-only and isolated runtime changes
pay for unrelated gates. Repeated unrelated emulator and service work increases cost, latency, and
infrastructure-flake exposure without increasing evidence for the changed surface.

## Decision criteria

- required verification cannot be bypassed by an unclassified path;
- documentation-only changes receive repository/documentation validation only;
- client, database, and performance gates follow the systems a diff can affect;
- shared contracts still compile and test every consuming client;
- API 24 thresholds and application checks are never weakened;
- one final-head implementation candidate supplies authoritative CI evidence.

## Options considered

### Run every job for every change

Rejected because it spends the most time and runner capacity on unrelated work and amplifies
infrastructure flake exposure.

### Rely only on developer-selected workflow inputs or labels

Rejected because a mistaken label or omitted input could bypass a required gate.

### Classify changed paths in repository-owned code with a fail-closed default

Accepted. The classifier is unit tested, emits only fixed boolean outputs, and treats every unknown
path as requiring all runtime lanes.

## Decision

GitHub Actions classifies the exact base-to-head path set before runtime jobs start.

- Markdown-only diffs run repository, link, packet, audit, hygiene, and secret checks, but no client,
  emulator, browser-build, or database runtime job.
- Dashboard changes run strict Dart/Flutter checks, affected tests, dashboard goldens/Chrome, the Web
  release build, and the public-bundle credential scan.
- Database changes run local Supabase reset, migration replay, pgTAP, integration checks, and lint.
- Shared Dart contracts run their package tests and compile/test affected client consumers.
- Android release compilation runs for mobile or shared-contract changes.
- API 24 profiling runs only for mobile runtime, mobile rendering/navigation, shared mobile UI,
  rank assets, or another explicitly classified performance-sensitive path.
- Unknown paths fail closed into every runtime lane.
- Manual non-candidate dispatch remains a full verification path.

The workflow retains stable job names. A path-inapplicable job is reported as skipped; it is not
represented as executed. A final implementation commit is pushed once and receives one
path-appropriate final-head run. A clearly external infrastructure failure may rerun only the
failed job once without changing application thresholds.

## Consequences

- Documentation and isolated changes complete faster.
- API 24 and local Supabase capacity is used only when relevant.
- Classification code and its workflow wiring become security-relevant repository tooling and must
  remain covered by fail-closed tests.
- A new top-level runtime area initially runs every lane until deliberately classified.

## Security, privacy, data, and operational impact

CI retains read-only repository permission and persisted Git credentials remain disabled. The
classifier receives only repository paths and emits fixed booleans; it receives no secrets. Secret,
bundle, RLS, migration, and performance checks remain mandatory whenever their owning surface can
change.

## Scope boundaries

This decision changes verification scheduling only. It does not relax test assertions, performance
thresholds, authorization, production promotion, or task completion gates.

## Rollback or supersession rule

If path classification proves unreliable, revert to the full manual verification path immediately.
Any durable replacement must preserve fail-closed behavior and supersede this ADR explicitly.

## Activation evidence

`TASK-IMP-003A` adds the repository-owned classifier, unit tests, and workflow wiring. The
implementation pull request's final-head checks provide activation evidence without committing a
volatile run number.
