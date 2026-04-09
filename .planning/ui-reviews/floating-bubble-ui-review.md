# Floating Bubble UI Review (Re-run)

**Audited:** 2026-04-09  
**Scope:** `lib/core/widgets/floating_playback_bubble.dart`  
**Method:** Code-only audit (no live screenshots; no local dev server detected on 3000/5173/8080)

---

## Pillar Scores (1-4)

| Pillar | Score | Key Finding |
|---|---:|---|
| 1. Copywriting | 3/4 | Action labels are explicit (`Pause playback`, `Stop playback`, `Open source screen`), but bubble hints remain interaction-dense. |
| 2. Visuals | 3/4 | Expanded panel now exposes a visible open action icon, improving affordance hierarchy. |
| 3. Color | 3/4 | Color usage is coherent and themed; no conflicting hardcoded palette spikes in the bubble flow. |
| 4. Typography | 3/4 | Type scale is consistent (11/14) and readable at default scale. |
| 5. Spacing | 3/4 | Spacing rhythm is mostly consistent (`6/8/10` spacing and compact padding), with no arbitrary values. |
| 6. Experience Design | 3/4 | Drag/snap/idle behavior is more stable with timer cancellation, `mounted` guards, and pan-cancel handling. |

**Overall:** 18/24

---

## Verified Improvements

1. **Semantic accessibility + tooltip:** implemented on collapsed bubble, expanded disc, and action chips via `Tooltip` + `Semantics`.
2. **Discoverable open action:** implemented with explicit open icon chip (`Icons.open_in_new_rounded`) in expanded panel.
3. **Interaction stability:** improved through `_idleTimer`/`_introTimer` cancellation, `mounted` checks, and explicit `onPanCancel` handling.

---

## Remaining Blockers Only

1. **Collapsed-state discoverability remains partially hidden (blocker).**  
   Core route-open shortcut still depends on double-tap in collapsed mode, which is low-discoverability for many users and inconsistent with explicit-action UX.

2. **No keyboard/focus activation path for the main bubble control (blocker).**  
   Semantics labels are present, but bubble activation is still gesture-centric (`GestureDetector`) without explicit focus/keyboard action wiring, which can limit non-touch accessibility.

---

## Ship Recommendation

**Fail (hold release).**

Reason: accessibility and discoverability are substantially improved, but two blockers remain for consistent, inclusive interaction in collapsed mode.
