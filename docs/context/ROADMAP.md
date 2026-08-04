# Stone Set Roadmap

Updated: 2026-08-04

## Completion rule

A phase is complete only when every applicable track is implemented, verified, documented, committed, and pushed.

Applicable tracks may include:

1. product behavior;
2. user interface and accessibility;
3. application and service behavior;
4. persistence and synchronization;
5. security and privacy;
6. testing, static checks, and build;
7. documentation, decisions, and handoff.

## Phase 0 — Product discovery and governance

Status: `ACTIVE`

### Goal

Convert the personal muscle-growth app idea into a precise, bounded, and evidence-backed product definition before selecting technology or generating code.

### Completed outcomes

- repository governance system established;
- initial product direction established;
- limited-equipment hypertrophy routine baseline accepted;
- strict 60-minute workout-session constraint accepted;
- workout effort, rest, progression, and adjustment rules documented;
- lifetime XP and rank RR tracks defined;
- 20-rank ladder from Bronze I to Adonis defined;
- Adonis calibrated to `5,500 RR`;
- resettable consecutive-perfect-week multiplier defined;
- 1.50x, 2.00x, and 2.50x unlocks defined for Weeks 5, 10, and 15;
- milestone-week RR top-up behavior defined;
- non-perfect-week consistency reset behavior defined;
- valid PR rewards and anti-farming rules defined;
- perfect-week and protected-pause rules defined;
- streak milestone rewards recalibrated for the compressed ladder;
- direct penalties defined for every unprotected missed scheduled workout;
- failed-week rank-local decay recalibrated for the compressed ladder;
- same-week day swapping defined;
- two-swap weekly limit defined;
- paid-swap cost of `5 RR` defined;
- monthly grant of two free-swap credits defined;
- free-swap credits defined as non-expiring and uncapped;
- explicit credit-versus-RR payment choice defined;
- grant idempotency, timezone boundary, restoration, and anti-exploit behavior defined;
- day-locking, no-retroactive-swap, recovery-warning, and schedule-integrity rules defined;
- `rank-v5` and `schedule-v2` accepted;
- defined decent consistency remains an approximately ten-month Adonis target;
- nutrition, sleep, and university scheduling explicitly excluded from current product scope.

### Remaining required outcomes

- complete weekly-schedule-to-workout-completion user workflow;
- minimum viable application scope;
- workout-log data requirements and correction behavior;
- rest-timer and session-timer behavior;
- PR detection and validation flow;
- provisional session RR and weekly consistency top-up presentation;
- free-swap wallet, monthly grant, and payment-selection presentation;
- reset, award, swap-payment, and missed-session transaction feedback;
- exact swap UI, confirmation, warning, lock, and correction states;
- weekly finalization behavior;
- progression recommendation and override rules;
- substitution, pain, protected-interruption, and unavailable-equipment flows;
- historical rank and scheduling configuration migration policy;
- platform and operational constraints;
- privacy and security constraints;
- measurable first-version success criteria;
- evaluated architecture options;
- accepted initial ADRs;
- first implementation phase and task packet.

### Completion criteria

Phase 0 is complete only when all remaining outcomes are documented and no material product or architecture ambiguity blocks implementation.

## Phase 1 — Foundation

Status: `BLOCKED BY PHASE 0`

Expected scope will be defined only after platform and architecture decisions are accepted. It may include repository layout, application scaffolding, quality gates, testing baseline, configuration handling, and CI.

## Phase 2 — First complete user workflow

Status: `UNDEFINED`

This phase must deliver one end-to-end weekly scheduling, free-swap grant and consumption, optional paid swap, workout execution, logging, PR validation, RR award, multiplier milestone, reset, missed-session finalization, and penalty workflow rather than disconnected screens or mocked controls.

## Later phases

Undefined. They will be derived from validated product scope rather than invented in advance.

## Current position

`Phase 0 — Product discovery and governance`

Current workstream: define the complete application workflow around the accepted workout, rank, consistency, scheduling, and free-swap baselines.

## Reopening rule

A completed phase or accepted product baseline must be reopened when later evidence invalidates its completion evidence, requirements, or assumptions.
