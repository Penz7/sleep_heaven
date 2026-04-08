# Phase 3: Performance and Architecture Refactor - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in `03-CONTEXT.md`.

**Date:** 2026-04-08
**Phase:** 03-performance-and-architecture-refactor
**Areas discussed:** Mixer list strategy, Blur policy, Module split strategy, Catalog externalization

---

## Mixer List Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| A | `ListView.builder` + extracted tile widgets + stable keys | ✓ |
| B | Sliver-first architecture now | |

**User's choice:** A (recommended)
**Notes:** Optimize highest-jank hotspot first with lower regression risk.

---

## Blur Policy

| Option | Description | Selected |
|--------|-------------|----------|
| A | Adaptive degrade by perf-tier/profile evidence | ✓ |
| B | Full blur always on all devices | |

**User's choice:** A (recommended)
**Notes:** Keep visual quality where safe, protect frame budget where constrained.

---

## Module Split Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| A | Section-first split of large view files | ✓ |
| B | Deep feature-slice refactor immediately | |

**User's choice:** A (recommended)
**Notes:** Minimize behavior drift during performance refactor phase.

---

## Catalog Externalization

| Option | Description | Selected |
|--------|-------------|----------|
| A | JSON schema-first + backward-compatible loader/cache | ✓ |
| B | Hardcoded fallback + incremental migrate later | |

**User's choice:** A (recommended)
**Notes:** Enables no-code catalog updates with CI-enforced schema integrity.

---

## Deferred Ideas

- Mixer background playback + lock-screen controls parity with player (separate future phase; out of Phase 3 scope).
