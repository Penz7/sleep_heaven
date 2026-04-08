# Phase 2: Reliability and Observability Baseline - Research

**Researched:** 2026-04-08  
**Domain:** Flutter runtime reliability, startup guardrails, and production observability for GetX service architecture  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Startup Guardrails
- **D-01:** Use hybrid startup policy: fail-open with degraded mode for non-critical services, fail-fast only for critical blockers.
- **D-02:** Startup must initialize services in explicit order with error classification: critical vs non-critical, then route app state accordingly.
- **D-03:** Non-critical initialization failures must surface user-safe fallback messaging and telemetry events, never silent no-op.

### IAP Reliability Scope
- **D-04:** Lock Phase 2 automated reliability coverage to 5 mandatory states: `not_purchased`, `purchased`, `restored`, `failed`, `offline_restore`.
- **D-05:** Tests must verify entitlement cache + stream reconciliation behavior, including startup restore behavior under offline/online transitions.
- **D-06:** Keep existing service contract (`IAPService` as app-lifetime singleton) and add deterministic test harness around it rather than refactor architecture in this phase.

### Audio Lifecycle Contract
- **D-07:** Keep single-owner callback contract for `SleepAudioHandler` where active controller owns `onPlayRequested`/`onPauseRequested`.
- **D-08:** Add explicit ownership handoff contract tests for `PlayerController` and `MixerController` to prevent orphan callbacks and stale control routing.
- **D-09:** Ownership transitions must preserve lock-screen/notification correctness and never leave handler in ambiguous state.

### Observability Direction
- **D-10:** Integrate one production crash/error reporting provider in this phase (planner may select specific vendor), with environment-aware toggles.
- **D-11:** Capture fatal + non-fatal startup/service errors with consistent domain tags (`startup`, `iap`, `audio`, `storage`, `permission`).

### Claude's Discretion
- Exact telemetry SDK selection and adapter layering details.
- Concrete error model type names and serialization shape.
- CI job split granularity for reliability suites.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

## Project Constraints (from `.cursor/rules/`)

- Glassmorphism should use `BackdropFilter + white.withOpacity(0.1)`. [VERIFIED: `.cursor/rules/stitchs-flutter.md`]
- Sliders should use `SliderTheme(trackHeight: 4)`. [VERIFIED: `.cursor/rules/stitchs-flutter.md`]
- Pulse animations should use `AnimatedContainer`. [VERIFIED: `.cursor/rules/stitchs-flutter.md`]
- UI sizing should read `MediaQuery.of(context).size`. [VERIFIED: `.cursor/rules/stitchs-flutter.md`]

## Summary

Phase 2 should keep the existing GetX singleton architecture and make reliability explicit at system boundaries, not by refactoring internals first. Current bootstrap in `main.dart` performs ordered initialization (`AudioService` -> `HiveProvider` -> `IAPService`) with no global crash capture and no startup classification path yet. [VERIFIED: `lib/main.dart`]

The most practical baseline is to add a lightweight reliability layer around startup and service boundaries: (1) global fatal/non-fatal capture (`FlutterError.onError` + `PlatformDispatcher.instance.onError`), (2) typed domain errors with domain/severity/recoverability metadata, and (3) health-reporting startup coordinator that decides fail-open vs fail-fast. Flutter docs explicitly document `FlutterError.onError` + `PlatformDispatcher.instance.onError` as the central mechanism for full error coverage. [CITED: https://github.com/flutter/website/blob/main/src/content/testing/errors.md]

For telemetry provider choice in this phase, use `sentry_flutter` because integration is single-SDK, supports explicit `environment`, and allows event filtering via `beforeSend` without requiring Firebase project provisioning in the same phase. [CITED: https://github.com/getsentry/sentry-dart/blob/main/packages/flutter/README.md] [VERIFIED: https://pub.dev/api/packages/sentry_flutter]

**Primary recommendation:** Implement a `StartupCoordinator` + `DomainError` + `TelemetryService` stack and lock reliability tests around `IAPService` state transitions and `SleepAudioHandler` ownership handoff contracts before any architecture refactor. [VERIFIED: codebase + roadmap]

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `sentry_flutter` | `9.16.1` (published 2026-04-07) | Fatal/non-fatal crash and exception reporting with env tags | Official Flutter SDK init path and option hooks (`environment`, `beforeSend`, manual capture APIs) fit Phase 2 requirements directly. [VERIFIED: pub.dev API] [CITED: getsentry docs] |
| `in_app_purchase` | `3.2.3` (published 2025-05-15) | Store purchase stream + restore lifecycle | Existing service already uses `purchaseStream` and `restorePurchases`; docs confirm required completion semantics. [VERIFIED: pub.dev API + codebase] [CITED: pub.dev in_app_purchase docs] |
| `get` | `4.7.3` (published 2025-11-24) | App-lifetime service wiring (`Get.put(..., permanent: true)`) | Matches current architecture and locked decision to preserve singleton `IAPService` contract. [VERIFIED: pub.dev API + codebase + context] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `audio_service` | `0.18.18` (published 2025-04-11) | Notification/lock-screen control surface | Continue using `SleepAudioHandler` as single ownership surface for player/mixer control handoff tests. [VERIFIED: pub.dev API + codebase] |
| `connectivity_plus` | `7.1.0` (published 2026-03-30) | Online/offline checks before restore attempts | Keep for `offline_restore` reliability path and startup reconciliation tests. [VERIFIED: pub.dev API + codebase] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `sentry_flutter` | Firebase Crashlytics | Crashlytics is strong but adds Firebase project/bootstrap requirements; Phase 2 can ship faster with Sentry unless Firebase is already mandatory org-wide. [ASSUMED] |

**Installation:**
```bash
flutter pub add sentry_flutter
```

## Architecture Patterns

### Recommended Project Structure
```text
lib/
├── core/errors/                 # DomainError model, domain enums, mappers
├── core/observability/          # telemetry service + sentry adapter
├── core/startup/                # startup coordinator, health check result model
└── core/services/               # existing GetX services (iap/audio/storage)
test/
├── startup/                     # startup coordinator + boot route smoke tests
├── services/iap/                # 5-state reliability matrix tests
└── services/audio/              # ownership handoff contract tests
```

### Pattern 1: Global Error Envelope at App Entry
**What:** Register framework and platform global error hooks before `runApp`, then route all captured failures to telemetry with domain tags. [CITED: Flutter errors docs]  
**When to use:** Always, before any async startup logic in `main()`.  
**Example:**
```dart
FlutterError.onError = (FlutterErrorDetails details) {
  FlutterError.presentError(details);
  telemetry.captureFatal(
    DomainError.startup(
      code: 'flutter_framework_error',
      message: details.exceptionAsString(),
      stackTrace: details.stack,
    ),
  );
};
PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
  telemetry.captureFatal(
    DomainError.startup(
      code: 'platform_dispatcher_error',
      message: error.toString(),
      stackTrace: stack,
    ),
  );
  return true;
};
```

### Pattern 2: Startup Coordinator with Criticality Map
**What:** Replace ad-hoc sequential startup with explicit service registration plan and per-step criticality (`critical`, `degraded`, `optional`). [VERIFIED: roadmap/context + codebase gap]  
**When to use:** Service initialization in `main.dart`.  
**Implementation hooks for this repo:**
- `SleepAudioHandler` init failure => critical blocker; route to fatal fallback screen. [ASSUMED]
- `HiveProvider` init failure => critical blocker because initial route depends on onboarding flag in Hive. [VERIFIED: `main.dart`]
- `IAPService` init failure => fail-open (non-critical), set entitlement to safe default and surface recoverable message. [VERIFIED: context D-01..D-03]

### Pattern 3: DomainError Normalization at Service Edges
**What:** Convert plugin/raw exceptions to typed `DomainError` with consistent fields (`domain`, `code`, `severity`, `recoverability`, `userMessage`, `cause`). [VERIFIED: phase deliverables]  
**When to use:** Every catch block in startup, IAP transitions, audio load/play path, permission checks, storage IO.  
**Concrete domains:** `startup`, `iap`, `audio`, `storage`, `permission`. [VERIFIED: D-11]

### Anti-Patterns to Avoid
- **String-only exceptions in controllers:** loses domain tags and breaks triage. Map to `DomainError` first, then UI/telemetry. [VERIFIED: current `Get.snackbar` + `debugPrint` patterns in controllers/services]
- **Silent startup fallback:** boot continues without user-safe state and without telemetry event. Must always emit both. [VERIFIED: D-03]
- **Controller-level direct telemetry calls everywhere:** creates duplicated instrumentation logic. Use centralized `TelemetryService` adapter. [ASSUMED]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Production crash backend | Custom HTTP log collector | `sentry_flutter` SDK | Native + Dart capture, event filtering, environment tagging already solved. [CITED: getsentry docs] |
| Purchase lifecycle transport | Custom billing channel wrappers | `in_app_purchase` stream + restore APIs | Store edge-cases and pending completion semantics are built in. [CITED: pub.dev in_app_purchase docs] |
| Global exception dispatch bus | Homegrown zone-only wrappers | `FlutterError.onError` + `PlatformDispatcher.instance.onError` | Flutter documents this as the unified app-level error capture path. [CITED: Flutter errors docs] |

**Key insight:** Hand-rolled reliability infrastructure fails at the exact boundaries (store/plugin/framework async callbacks) where standardized SDK hooks already exist and are battle-tested. [ASSUMED]

## Common Pitfalls

### Pitfall 1: IAP stream events are logged but not classified
**What goes wrong:** `IAPService` currently `debugPrint`s purchase stream errors and state changes without standardized error objects/tags. [VERIFIED: `lib/core/services/iap_service.dart`]  
**Why it happens:** Direct plugin callbacks are handled inline with ad-hoc prints. [VERIFIED: codebase]  
**How to avoid:** Introduce `_mapPurchaseError` -> `DomainError.iap(...)` and route through telemetry + state reconciler. [ASSUMED]  
**Warning signs:** Failed purchases have no dashboard grouping by state (`failed`, `offline_restore`, etc.). [ASSUMED]

### Pitfall 2: Ownership handoff race between Player and Mixer
**What goes wrong:** Both controllers set `onPlayRequested` and `onPauseRequested` on shared `SleepAudioHandler`; without contract tests, stale callback ownership can survive route transitions. [VERIFIED: `player_controller.dart` + `mixer_controller.dart` + `audio_handler.dart`]  
**Why it happens:** Shared mutable callback pointers with no ownership token/version guard. [VERIFIED: `audio_handler.dart`]  
**How to avoid:** Add handoff contract tests asserting latest owner wins and previous owner callbacks are no longer invoked. [VERIFIED: D-08/D-09]  
**Warning signs:** Notification play/pause controls trigger wrong controller after screen switch. [ASSUMED]

### Pitfall 3: Startup failures crash before telemetry is available
**What goes wrong:** `main.dart` currently runs async init directly; failures before app mount can terminate without standardized capture path. [VERIFIED: `main.dart`]  
**Why it happens:** No global handler or startup coordinator envelope around init chain. [VERIFIED: codebase]  
**How to avoid:** Register global handlers first, then wrap each startup step in coordinator with telemetry sink pre-initialized. [CITED: Flutter errors docs]  
**Warning signs:** Crash loops with no linked event in monitoring provider. [ASSUMED]

## Code Examples

Verified patterns from official sources:

### Global Flutter Error Capture
```dart
FlutterError.onError = (FlutterErrorDetails details) {
  FlutterError.presentError(details);
  myErrorsHandler.onErrorDetails(details);
};
PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
  myErrorsHandler.onError(error, stack);
  return true;
};
```
Source: Flutter docs error handling page. [CITED: https://github.com/flutter/website/blob/main/src/content/testing/errors.md]

### Sentry Initialization in Flutter
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://example@sentry.io/add-your-dsn-here';
    options.environment = const String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    options.beforeSend = (event, hint) => event;
  },
  appRunner: () => runApp(const MyApp()),
);
```
Source: Sentry Flutter README + option hooks from SDK docs. [CITED: https://github.com/getsentry/sentry-dart/blob/main/packages/flutter/README.md]

### IAP Purchase Stream Completion Contract
```dart
if (purchaseDetails.pendingCompletePurchase) {
  await InAppPurchase.instance.completePurchase(purchaseDetails);
}
```
Source: in_app_purchase API docs. [CITED: https://pub.dev/documentation/in_app_purchase/latest/in_app_purchase/InAppPurchase/purchaseStream.html]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Zone-only crash handling patterns | `PlatformDispatcher.instance.onError` plus `FlutterError.onError` | Flutter guidance updated in 3.3 era docs | Better coverage of framework + non-framework async exceptions. [CITED: Flutter docs archive/errors page] |
| Print-only service error handling | Structured telemetry + domain-tagged events | Active best practice in modern mobile observability | Faster diagnosis and lower MTTR for production incidents. [ASSUMED] |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Sentry is lower-friction than Crashlytics for this repo phase timeline. | Standard Stack | Could choose suboptimal provider if org already has Firebase rollout. |
| A2 | `SleepAudioHandler` init should be critical blocker while IAP init should be fail-open. | Architecture Patterns | Startup policy might misclassify criticality and degrade UX. |
| A3 | Centralized telemetry adapter is better than direct service-level SDK calls. | Architecture Patterns | Extra abstraction may slow delivery if overdesigned. |
| A4 | Warning signals listed (e.g., wrong callback firing) match actual field incidents. | Common Pitfalls | Test priorities may miss real highest-impact failure class. |

## Resolved Research Outcomes

1. **Provider finalization outcome: Sentry is locked for Phase 2**
   - Decision: Use `sentry_flutter` as the single telemetry provider in this phase. [CITED: getsentry docs]
   - Reason: Fastest integration path with explicit `environment` and `beforeSend` controls while satisfying D-10/D-11.
   - Planning implication: Plan artifacts must explicitly include provider adapter/config files and dependency lock in `pubspec.yaml`.

2. **Startup degraded UX outcome: route-level degraded notice contract**
   - Decision: Use a deterministic route-level degraded startup notice (`degraded_boot_notice.dart`) for non-critical startup failures.
   - Reason: Directly satisfies D-03 requirement for visible user-safe fallback messaging without ambiguity.
   - Planning implication: Add route boot smoke tests that assert normal, degraded, and fatal startup routing paths.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Build/test/run + startup smoke | ✓ | 3.38.8 | — |
| Dart SDK | test/runtime | ✓ | 3.9.0 (CLI), Flutter toolchain reports 3.10.7 | Use Flutter-managed Dart in CI |
| Git | CI + workflow | ✓ | 2.53.0 | — |
| Java | Android builds | ✓ | 17.0.12 | — |
| Node/npm | optional tooling/scripts | ✓ | Node 24.14.1 / npm 11.11.0 | — |

**Missing dependencies with no fallback:**
- None identified. [VERIFIED: local environment check]

**Missing dependencies with fallback:**
- None identified. [VERIFIED: local environment check]

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (from SDK) |
| Config file | none (default Flutter test conventions) |
| Quick run command | `flutter test test/widget_test.dart -r expanded` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| REL-01 | Startup errors captured + classified | unit/widget smoke | `flutter test test/startup/startup_coordinator_test.dart` | ❌ Wave 0 |
| REL-02 | Startup fail-open/fail-fast routing behavior | widget smoke | `flutter test test/startup/bootstrap_route_smoke_test.dart` | ❌ Wave 0 |
| REL-03 | IAP states (`not_purchased`,`purchased`,`restored`,`failed`,`offline_restore`) | unit | `flutter test test/services/iap/iap_service_reliability_test.dart` | ❌ Wave 0 |
| REL-04 | Audio callback ownership handoff player<->mixer | unit | `flutter test test/services/audio/audio_handoff_contract_test.dart` | ❌ Wave 0 |
| REL-05 | Telemetry ingestion for synthetic fatal/non-fatal | integration-ish unit with mock transport | `flutter test test/observability/telemetry_sink_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/widget_test.dart`
- **Per wave merge:** targeted reliability suite (`flutter test test/startup test/services test/observability`)
- **Phase gate:** Full suite green + synthetic handled/unhandled telemetry verification runbook

### Wave 0 Gaps
- [ ] `test/startup/startup_coordinator_test.dart` — covers REL-01/REL-02
- [ ] `test/services/iap/iap_service_reliability_test.dart` — covers REL-03
- [ ] `test/services/audio/audio_handoff_contract_test.dart` — covers REL-04
- [ ] `test/observability/telemetry_sink_test.dart` — covers REL-05
- [ ] Introduce SDK-agnostic telemetry interface fake for deterministic tests

## Security Domain

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No auth subsystem in current app scope. [VERIFIED: roadmap/state] |
| V3 Session Management | no | No user account session in app baseline. [VERIFIED: roadmap/state] |
| V4 Access Control | yes | Premium entitlement checks via `IAPService` + repository gates; must treat as policy boundary. [VERIFIED: `sound_repository.dart`, controllers] |
| V5 Input Validation | yes | Validate plugin/state inputs before side effects; map unknown errors to safe `DomainError`. [ASSUMED] |
| V6 Cryptography | yes | Use `flutter_secure_storage` and platform crypto primitives; do not hand-roll crypto or key storage. [VERIFIED: `iap_service.dart`] |

### Known Threat Patterns for Flutter + IAP/audio stack
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Entitlement desync (cache vs purchase stream) | Tampering | Reconcile cache with stream events at startup and after restore; test online/offline transitions. [VERIFIED: D-05 + `iap_service.dart`] |
| Silent startup exception | Repudiation/DoS | Global error hooks + telemetry + degraded-mode route fallback. [CITED: Flutter errors docs] |
| Overexposed crash payload (PII leakage) | Information Disclosure | `beforeSend` event scrubbing and strict tag-only context for service diagnostics. [CITED: Sentry SDK docs] |

## Sources

### Primary (HIGH confidence)
- Flutter official docs (Context7 `/flutter/website`) - error handling with `FlutterError.onError` and `PlatformDispatcher.instance.onError`:  
  https://github.com/flutter/website/blob/main/src/content/testing/errors.md
- Sentry Dart/Flutter official repo docs (Context7 `/getsentry/sentry-dart`) - `SentryFlutter.init`, options, capture APIs:  
  https://github.com/getsentry/sentry-dart/blob/main/packages/flutter/README.md
- In-app purchase official package docs (Context7 `/websites/pub_dev_in_app_purchase`) - `purchaseStream`, `restorePurchases`, `completePurchase`:  
  https://pub.dev/documentation/in_app_purchase/latest/
- Repo source-of-truth files:
  - `lib/main.dart`
  - `lib/core/services/iap_service.dart`
  - `lib/core/services/audio_handler.dart`
  - `lib/features/player/controllers/player_controller.dart`
  - `lib/features/mixer/controllers/mixer_controller.dart`
  - `test/widget_test.dart`

### Secondary (MEDIUM confidence)
- Pub.dev package API metadata for current latest versions and publish timestamps:
  - https://pub.dev/api/packages/sentry_flutter
  - https://pub.dev/api/packages/in_app_purchase
  - https://pub.dev/api/packages/get
  - https://pub.dev/api/packages/audio_service
  - https://pub.dev/api/packages/connectivity_plus

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - official docs + current package metadata + direct codebase fit.
- Architecture: HIGH - directly constrained by locked context decisions and current service topology.
- Pitfalls: MEDIUM - code evidence exists, but production incident frequency is inferred.

**Research date:** 2026-04-08  
**Valid until:** 2026-05-08 (30 days)
