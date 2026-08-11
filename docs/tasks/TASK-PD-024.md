# TASK-PD-024 — Approve private Android automatic distribution

Status: `COMPLETE`
Date: 2026-08-11
Branch: `codex/task-pd-024-approve-imp-012`

## Objective

Approve permanent, private, path-sensitive Android distribution without changing app behavior.

## Verified starting state

- clean synchronized `main` at `d1ad274a6fb63092a150f8e07be67c6f88dc8ffa`, no open PR;
- app ID `io.github.hermann33.stoneset`, mobile version `0.1.0+1`, debug release signer;
- Private Release is PR/manual-only, builds both clients, and does not distribute to Firebase;
- no Firebase repository configuration, GitHub release secret, Firebase CLI, or gcloud auth;
- repository is public, so it is not the private APK channel;
- TASK-IMP-011's approved-content boundary is independent.

## Decision

Accept ADR-0009 and approve TASK-IMP-012: one permanent external JKS, fingerprint enforcement,
increasing workflow-derived versionCode, private Firebase group, short-lived GitHub OIDC auth, and
release only for exact verified trusted main when the fail-closed classifier enables mobile build.

## Findings

Firebase supports signed APKs, exact package registration, service-account ADC and tester groups.
Google recommends WIF over long-lived keys. Android requires increasing positive version codes and
documents 2,100,000,000 as the ceiling. GitHub privileged workflow jobs must never check out or
consume untrusted PR code/artifacts. The first permanent signer cannot update a debug-signed install.

## Planning verification

Mandatory repository/release/ADR/workflow reads, official primary-source review, clean Git/open-PR/
secret/tool inspection, Markdown/packet/audit/diff/secret validation.

## Exact next action

```text
Execute TASK-IMP-012
branch: codex/task-imp-012-private-android-distribution
packet: docs/tasks/TASK-IMP-012.md
```
