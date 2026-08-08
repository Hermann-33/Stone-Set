# TASK-PD-019 — Planning Group A: media, YouTube, routines and review

Status: `COMPLETE`
Date: 2026-08-08

## Objective

Verify the merged Phase 3A repository state, reconcile directly stale canonical authority and
record the grouped promotion order for the next two bounded implementation packets without
changing either packet's runtime scope.

## Verified starting state

```text
TASK-IMP-003A pull request  #14 — MERGED
Final implementation head  54d537208e3d44d57173328bf0c03470239a5a9d
Merge commit               eb59a3b4707ff12c154594408f1f7902555f39e0
Final-head CI              31258974949 — PASS
Phase 3A                   COMPLETE
Remote infrastructure      NONE
```

Final-head CI passed repository and path-classifier checks, generation freshness, formatting,
strict analysis, domain/data/mobile/dashboard tests, reviewed Linux dashboard goldens, Chrome,
Android release, Web release/bundle review and local Supabase reset/Auth/pgTAP/lint. The API 24
profile correctly skipped because the final diff did not affect mobile runtime performance.

## Planning Group A result

The dependency order is explicit:

1. `TASK-IMP-003B` — private exercise media and YouTube — is the next approved, executable packet.
2. `TASK-IMP-003C` — routine validation, review and publication — is approved for the group but
   remains blocked and non-executable until 003B completes and merges.

Grouping the planning record does not combine implementation PRs. Each capability retains its own
bounded branch, acceptance criteria, verification, rollback and merge gate. No later packet becomes
executable through this planning result.

## Compatibility and security findings

Current official Supabase Storage, Flutter Web, YouTube IFrame and pub.dev evidence was reviewed for
the new 003B surface. The approved direct dependency pins are:

```text
image          4.9.1
file_selector  1.1.0
web            1.1.1
```

The implementation preserves `supabase_flutter 2.17.1`, adds no second Storage client and uses no
YouTube wrapper. The packet requires a private `exercise-media` bucket, explicit Storage policies,
immutable `upsert: false` object paths, user-initiated official IFrame preview, and a documented
non-atomic Storage/Postgres reservation and compensation boundary. Browser-derived hashes,
dimensions and metadata-removal results are reconciliation evidence, not server attestation.

The 003C packet fixes the independent reviewer boundary, deterministic `routine-validator-v1`,
immutable submitted evidence and publication history, while remaining non-executable until 003B
merges. Both packets require implementation-start revalidation if current official evidence changes.

## Preserved boundaries

- 003A exercise definitions, structured guidance, immutable revisions and IndexedDB recovery are
  complete and remain authoritative prerequisites.
- 003B owns private Storage media, image processing/metadata/order/alt text and optional normalized
  YouTube references only.
- 003C owns routine drafts, validation, immutable submission, independent review and publication
  only after 003B merges.
- Public signup remains disabled and public clients receive no service-role, management or
  deployment credentials.
- No schedule, workout, reward, wallet, Progress, production deployment or remote infrastructure is
  authorized by Planning Group A.

## Documentation-only verification

Required checks are repository/document validation, relative-link/task validation,
`git diff --check`, secret/personal-data review, append-only audit validation and clean-tree review.
Android, browser, Web-build, golden and Supabase runtime lanes are not required for this
documentation-only planning diff under ADR-0007.

## Exact next action

```text
Execute TASK-IMP-003B
branch: codex/task-imp-003b-exercise-media-youtube
packet: docs/tasks/TASK-IMP-003B.md
```

Do not execute `TASK-IMP-003C` until `TASK-IMP-003B` completes and merges.
