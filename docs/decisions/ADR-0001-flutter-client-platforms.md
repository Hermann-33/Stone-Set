# ADR-0001: Flutter mobile and web client platforms

## Status

Accepted

- Date: 2026-08-04
- Type: Client architecture
- Supersedes: None
- Preserves: Product discovery boundaries and server-authoritative reward behavior

## Context

Stone Set requires:

- a mobile application for workout execution and logging;
- a browser-based dashboard for each user to manage their own future routine versions;
- a small maintenance surface for an initial two-user product;
- shared domain logic without falsely sharing every UI concern;
- no implementation in the current planning task.

The mobile application was explicitly selected as Flutter. The dashboard framework had not been selected.

## Decision criteria

- one small development and maintenance stack;
- strong mobile support;
- acceptable internal-dashboard behavior;
- code sharing for domain models and Supabase access;
- testability;
- low operational overhead;
- reversible deployment choices;
- no requirement for SEO or public content rendering.

## Options considered

### Option A — Flutter mobile and Flutter Web dashboard

Advantages:

- one primary language and framework;
- shared domain, validation, repository, and Supabase integration packages;
- lower context-switching and maintenance cost;
- appropriate for a private two-user dashboard.

Disadvantages:

- Flutter Web is heavier than a conventional HTML-first dashboard;
- form behavior and accessibility require deliberate testing;
- public-site SEO and content rendering would be weaker, though they are not requirements.

### Option B — Flutter mobile and a separate JavaScript web framework

Advantages:

- more conventional browser forms, tables, and accessibility primitives;
- broader web-specific ecosystem.

Disadvantages:

- two language and framework stacks;
- duplicated models and validation;
- higher maintenance burden for a two-user private product.

### Option C — One responsive Flutter application for mobile and dashboard

Advantages:

- maximum UI sharing;
- one application target.

Disadvantages:

- forces workout execution and management workflows into one navigation and release surface;
- increases coupling;
- weakens separation between mobile execution and web management.

## Decision

Stone Set will use:

- a Flutter mobile application;
- a separate Flutter Web dashboard;
- shared Dart packages for domain models, validation, repository interfaces, Supabase adapters, and design tokens where appropriate.

The two applications remain separate products inside one repository. They may share non-UI logic and selected reusable widgets, but they must not force incompatible mobile and desktop workflows into one screen architecture.

The recommended Flutter architecture is layered:

- views and view models in the UI layer;
- repositories and services in the data layer;
- use cases only for complex or reused domain transitions.

No state-management, routing, dependency-injection, or local-database package is selected by this ADR.

## Consequences

### Positive

- one primary client language;
- shared product rules and validation;
- smaller maintenance burden;
- independent mobile and dashboard release cycles;
- clearer surface responsibilities.

### Negative

- Flutter Web bundle and browser behavior require performance testing;
- web accessibility and keyboard navigation cannot be assumed;
- careless UI sharing could create poor mobile or desktop experiences;
- Flutter-specific client architecture increases migration cost if a later public web product is required.

## Security, privacy, data, and operational impact

- Both clients are untrusted public clients.
- Neither client may contain a Supabase service-role or secret key.
- Both clients use authenticated sessions and publishable credentials only.
- Server-authoritative reward and ledger transitions cannot be implemented solely in Dart clients.
- User-owned data remains protected by database authorization, not hidden UI controls.

## Scope boundaries

This ADR does not authorize:

- application scaffolding;
- package installation;
- a specific state-management library;
- a specific router;
- dashboard hosting;
- mobile store release;
- local offline persistence technology;
- analytics, telemetry, or external integrations;
- any product change to `rank-v5` or `schedule-v2`.

## Rollback or supersession rule

A later ADR may replace the dashboard with a conventional web framework if Flutter Web creates unacceptable accessibility, performance, or maintenance cost.

The mobile Flutter selection may be superseded only by an ADR that includes migration cost, lost code sharing, release impact, and data compatibility.

## Activation evidence

`TASK-PL-001` records this architecture decision. No runtime activation exists yet.
