---
status: investigating
trigger: "Project: D:/workspaces/sleep_heaven (Flutter). Critical regression: floating playback bubble not visible at all now.
Relevant file: lib/core/widgets/floating_playback_bubble.dart (recently modified heavily: hitbox, intro pulse, idle timers, focus/expand states).
Need immediate diagnosis + fix plan.
Please inspect logic for visibility gates, intro pulse state, timers, and any condition that can keep widget hidden indefinitely."
created: 2026-04-09T00:45:21.8527438+07:00
updated: 2026-04-09T00:49:12.0000000+07:00
---

## Current Focus

hypothesis: Collapsed bubble render width no longer matches positioning width, then idle edge-offset pushes most/all of the bubble off-screen.
test: Compare clamp/snap/initial panel width calculations with actual collapsed child width and idle slide offset.
expecting: panelWidth uses 66 but rendered collapsed subtree is 94, causing persistent off-screen placement amplified by AnimatedSlide(0.68).
next_action: produce minimal patch strategy: synchronize collapsed dimensions, limit hidden offset, keep dock/tap behavior.

## Symptoms

expected: Floating playback bubble appears when audio session is active/minimized and remains interactable.
actual: Bubble is not visible at all.
errors: none reported
reproduction: Launch app, start playback, navigate to states where bubble should appear; bubble never appears.
started: after recent heavy modifications to hitbox/intro pulse/idle/focus-expand logic

## Eliminated

## Evidence

- timestamp: 2026-04-09T00:47:31+07:00
  checked: visibility gate in floating_playback_bubble.dart build branch
  found: bubble returns SizedBox.shrink only when neither player nor mixer has active session/playing, or when current route is source screen.
  implication: primary visibility gate is conditional but not permanently false by itself when playback session is active.

- timestamp: 2026-04-09T00:48:20+07:00
  checked: collapsed layout size vs position math
  found: positioning/clamp/snap uses collapsed width 66 (_bubbleSize), but _CollapsedBubble renders SizedBox width/height 94 (_bubbleSize + 28).
  implication: bubble is anchored using a smaller box than what is actually painted/hit-tested, creating systematic off-screen drift.

- timestamp: 2026-04-09T00:48:49+07:00
  checked: idle hidden transform
  found: when not focused/expanded/dragging, AnimatedSlide offset is 0.68 toward edge; with effective collapsed width 94 this adds ~64px translation toward outside.
  implication: combined with width mismatch, bubble can be pushed nearly entirely off-screen and appear missing indefinitely until rare edge tap.

## Resolution

root_cause: A regression in collapsed hitbox sizing introduced a width mismatch (rendered 94 vs positioned/clamped 66), and idle edge offset continues to translate by 68% of full child size, pushing the bubble mostly/fully outside viewport.
fix: Keep one canonical collapsed panel size used by both layout math and rendered widget; then reduce/derive idle offset from visible bubble size so docked state remains peeking but still visible/tappable.
verification: pending implementation
files_changed: []
