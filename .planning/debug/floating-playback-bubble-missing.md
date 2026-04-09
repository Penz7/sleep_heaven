---
status: fixing
trigger: "Regression: floating playback bubble no longer shows at all after recent changes."
created: 2026-04-09T00:00:00Z
updated: 2026-04-09T00:10:00Z
---

## Current Focus

hypothesis: Bubble can be permanently suppressed when visibility relies only on hasActiveSession and when reactive tracking is skipped before controllers are available/active.
test: Relax visibility gate to include active playback signals and evaluate source-aware route hide logic in bubble state resolution path.
expecting: Bubble appears whenever player/mixer is actively playing or has explicit active session, except on the same source route.
next_action: patch floating_playback_bubble.dart visibility and route-hide conditions

## Symptoms

expected: Floating playback bubble appears when audio is active and user is not on player/mixer route.
actual: Bubble never appears.
errors: none reported
reproduction: Start playback then navigate app; bubble does not show.
started: after recent changes introducing hasActiveSession flags, route hiding, draggable behavior.

## Eliminated

## Evidence

- timestamp: 2026-04-09T00:05:00Z
  checked: lib/core/widgets/floating_playback_bubble.dart
  found: bubble visibility is currently gated by hasActiveSession only via _resolveState and returns hidden when false.
  implication: if hasActiveSession is stale/never set in a playback path, bubble never appears even while audio is playing.

- timestamp: 2026-04-09T00:06:00Z
  checked: lib/features/player/controllers/player_controller.dart and lib/features/mixer/controllers/mixer_controller.dart
  found: hasActiveSession is toggled only in play/playAll and stop/stopAll, while playback state also exists independently as isPlaying/isPlayingRx streams.
  implication: session flag and true playback can diverge, making hasActiveSession-only gating brittle.

- timestamp: 2026-04-09T00:07:00Z
  checked: lib/core/widgets/floating_playback_bubble.dart
  found: route hide condition hides on either /player or /mixer regardless of active source.
  implication: mixed-source scenarios can hide unnecessarily; source-aware hide is safer.

## Resolution

root_cause:
fix:
verification:
files_changed: []
