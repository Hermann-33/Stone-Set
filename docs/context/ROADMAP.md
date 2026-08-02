# Stone Set Roadmap

Updated: 2026-08-03

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

Convert the personal app idea into a precise, bounded, and evidence-backed product definition before selecting technology or generating code.

### Required outcomes

- repository governance system established;
- specific problem statement;
- primary user workflow;
- minimum viable scope;
- non-goals and deferred ideas;
- platform and operational constraints;
- privacy and security constraints;
- measurable first-version success criteria;
- evaluated architecture options;
- accepted initial ADRs;
- first implementation phase and task packet.

### Completion criteria

Phase 0 is complete only when all required outcomes are documented and no material product or architecture ambiguity blocks implementation.

## Phase 1 — Foundation

Status: `BLOCKED BY PHASE 0`

Expected scope will be defined only after platform and architecture decisions are accepted. It may include repository layout, application scaffolding, quality gates, testing baseline, configuration handling, and CI.

## Phase 2 — First complete user workflow

Status: `UNDEFINED`

This phase must deliver one end-to-end workflow rather than disconnected screens or mocked controls.

## Later phases

Undefined. They will be derived from validated product scope rather than invented in advance.

## Current position

`Phase 0 — Product discovery and governance`

## Reopening rule

A completed phase must be reopened when a later finding invalidates its completion evidence, accepted requirements, or architecture assumptions.
