---
name: reed-motion-policy
description: "Reed's zero-motion policy — no Duration, Curve, Tween, or transition; NoSplash.splashFactory, pageTransitionsTheme, themeAnimationStyle AnimationStyle.noAnimation; GestureDetector never InkWell; reduce-motion means Duration.zero. Use when adding AnimatedContainer, AnimatedOpacity, AnimationController, Hero, or PageRouteBuilder; when setting splashColor, highlightColor, or overlayColor; when a test calls pumpAndSettle or hasScheduledFrame goes red; when reviewing a diff for fades, ripples, shimmer, skeletons, or celebration effects."
---

# Motion policy: there is none

Reed animates nothing. Not "sparingly", not "subtly" — nothing. This document is the whole policy; there is no exception list to consult and no threshold to tune.

## The two reasons, both load-bearing

**1. Latency.** The product's entire premise is instant speech. Someone taps a tile mid-shutdown and the phrase must leave the speaker. Every millisecond of animation is a millisecond the app spends decorating instead of speaking. This reason always holds and never decays.

**2. Sensory.** Distress- and trauma-informed guidance warns against sudden or unexpected motion for sensitised nervous systems, and the users are people whose speech has already gone.

**Be honest about the second one.** It is design judgment, not a proven mechanism. The commonly-cited empirical support (Kaaresoja on tactile/visual feedback latency) does not reach this conclusion: it measured feedback *onset*, never tested a no-animation condition, and its guideline has a 30ms *lower* bound. Never cite it in a comment, a commit message, or a code review as evidence that zero animation is empirically optimal. Zero animation is a decision. Argue it from latency, which is arithmetic, and from judgment about the audience, which is defensible on its own terms. Do not launder judgment through fake evidence — someone will fact-check it and then reopen the whole ban.

## The rules

| Rule | Detail |
|---|---|
| No duration | Not >~100ms, not ~100ms. Zero. A "quick 80ms fade" is still a fade. |
| No implicit animations | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedAlign`, `AnimatedDefaultTextStyle`, `AnimatedSwitcher`, `TweenAnimationBuilder` — all banned. |
| No explicit animations | `AnimationController`, `TickerProvider`, `SingleTickerProviderStateMixin`, `Tween`, `CurvedAnimation`, any `Curve`. |
| No route motion | `Hero`, `PageRouteBuilder` with a transition, `SlideTransition`, `FadeTransition`. |
| No effects vocabulary | Bounce, parallax, shimmer, skeleton loaders, pulse, breathing, confetti, celebration, "success" flourishes. |
| No physics | Spring physics, shape morph, M3 Expressive's motion system. |
| No self-caused change | Nothing appears, vanishes, collapses, or expands on its own. Optimistic UI is banned partly for this: a state that appears then reverts is a visual change the user did not cause. |

## Theme-root enforcement

Three switches, and all three are required. Each kills a different animation that Material mounts by default.

```dart
class _NoTransitions extends PageTransitionsBuilder {
  const _NoTransitions();
  @override
  Widget buildTransitions<T>(PageRoute<T>? r, BuildContext? c, Animation<double> a,
      Animation<double> s, Widget child) => child;
}

ThemeData(
  splashFactory: NoSplash.splashFactory,
  splashColor: const Color(0x00000000),
  highlightColor: const Color(0x00000000),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: _NoTransitions(),
    TargetPlatform.iOS: _NoTransitions(),
  }),
  // ...
)

MaterialApp(
  theme: aacThemeData(current),
  themeAnimationStyle: AnimationStyle.noAnimation,
  home: const BoardScreen(),
)
```

**Why `themeAnimationStyle` matters even with a step-function `lerp`.** `MaterialApp` mounts an `AnimatedTheme` and interpolates `ThemeData` over `kThemeAnimationDuration` (200ms) by default. The `ThemeExtension.lerp` is a hard cut (`t < 0.5 ? this : (other ?? this)`) — so without `themeAnimationStyle`, the tiles *snap* at the midpoint while the surrounding `ColorScheme` crossfades around them. That is worse than either behaviour alone. Do both or neither works.

Keep `lerp` as a step function rather than `return this`: if a theme change ever did animate, `this` would never arrive at the new palette. `t < 0.5` lands on the correct endpoint.

## `NoSplash.splashFactory` is not enough — the folklore is wrong

`splashFactory: NoSplash.splashFactory` kills only the **splash**. `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade, which the splash factory never touches. "We don't animate" becomes false the moment anyone drops in a Material button.

```dart
// WRONG — animates despite NoSplash at the theme root.
InkWell(onTap: onTap, child: face)

// RIGHT — no ink, no animation, no second frame scheduled.
GestureDetector(
  behavior: HitTestBehavior.opaque,  // the whole cell is the target
  onTap: onTap,
  child: face,
)
```

Use `GestureDetector`. The theme-root transparency settings are belt-and-braces for Material widgets that slip through elsewhere (buttons in settings, list tiles) — they are not permission to use `InkWell`.

## Reduce-motion means zero, not gentler

`MediaQuery.disableAnimationsOf(context)` and `MediaQuery.accessibleNavigationOf(context)` resolve to `Duration.zero`. Never to a shorter duration, never to a "gentler" curve. A user who has asked the OS to stop animations has asked for stop, not slow.

In practice `disableAnimations` is **moot here** — there is nothing to disable. If a code path is reading it in order to choose between two durations, that path already violates the policy: delete the animation, not the flag check.

`accessibleNavigation` (Switch Access / TalkBack / VoiceOver active) never selects a different motion behaviour either. It may legitimately change *layout* or *semantics*, never timing.

When a Material widget insists on animating and offers no opt-out flag, pass `AnimationStyle.noAnimation` to whatever `*AnimationStyle` parameter it exposes. If it exposes none, replace the widget.

## The lit state is a step, not a transition

Pointer-down lights the tile; it stays lit until TTS completes. One state, two triggers — press feedback and the speaking indicator are the same signal.

| | value |
|---|---|
| duration | **zero** |
| fill | `stockLit` (OKLCH L ±0.09 toward the ink) |
| keyline | 1 physical px → **2dp**, colour → `ink` |
| minimum hold | **120ms**, so a fast tap is never imperceptible |
| trigger | `Listener.onPointerDown` — **not** `onTap` |
| order | haptic → `setState(lit)` → TTS |

The **120ms minimum hold is not an animation** and must never be implemented as one. It is a floor on how long a discrete state persists — a `Timer` that clears a boolean, not a fade-out. Do not "smooth" it.

`onTap` fires on pointer *up*, delaying all feedback by the entire press duration. `onPointerDown` plus Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands feedback at ~30–55ms with no artificial delay. This fires before gesture disambiguation, which is safe **only because the grid never scrolls** — that rule is load-bearing, not aesthetic.

Guard the lit latch with a timeout that force-clears it. `flutter_tts` completion-handler reliability varies by OEM, and a stuck-lit tile is a lie about what the app is doing. Nobody will report it: a user who cannot speak does not file bugs, and there is no telemetry.

## The show-mode flash

Entering show mode from the `ink` theme jumps L 0.19 → 0.98 in one frame. **It flashes. Instantly. No ramp.** The user deliberately pressed a control and is turning the phone away from their own face at that moment — that is the mitigation. A ramp is *longer* exposure to the transition and costs latency in the one moment where latency is a social cost.

The escape hatch is a setting (`Show screen: bright · match my theme`), not a fade. A user who cannot tolerate the flash chooses `match my theme` and knowingly pays the stranger-legibility cost. That is their call to make, and offering it as a preference respects them; ramping it for everyone does not.

Same logic for theme persistence: restore the saved palette **before first paint**. A flash of the wrong polarity is a sudden luminance change — exactly the event the ban exists to prevent — and it is one the user did not choose.

## Tests: `pump()`, never `pumpAndSettle()`

`pumpAndSettle`'s only job is waiting out animations that do not exist here. It carries a 10-minute default timeout and truncates its stack trace on timeout, so in this app it can contribute nothing but flake with an unreadable failure.

```dart
// WRONG
await tester.tap(find.bySemanticsLabel('Thank you'));
await tester.pumpAndSettle();

// RIGHT — zero animation means one frame settles it.
await tester.tap(find.bySemanticsLabel('Thank you'));
await tester.pump();
```

**Do not overstate the rule.** `pump()` does *not* advance the fake clock. `Timer`, `Future.delayed`, debounces, and the 120ms lit-state floor still need `pump(duration)` or `fakeAsync`. The convention, which is local to this project and not something Flutter recommends generally:

> Ban `pumpAndSettle` as an *animation* wait. Use `pump()` for state changes and `pump(duration)` for time-based async.

A grep test over `test/` enforces the ban, because no lint can.

## The enforcement test, and what it misses

```dart
expect(tester.binding.hasScheduledFrame, isFalse,
    reason: 'Tapping "${t.label}" scheduled another frame => something animates.');
```

Assert this after a single `pump()` following a tap on each tile. **Honest scope: this is a spot check, not proof.** It misses `Timer`-driven repaints and at-rest implicit animations, and it catches a stray `InkWell` only on tiles that are actually tapped. When it goes red, find the animating widget. Never fix it by reaching for `pumpAndSettle`, which makes the symptom disappear and the bug ship.

## The aesthetic consequence — not an apology

Motion is unavailable, so beauty comes from **composition, type, colour, and edge**. This constraint *produces* the design language rather than limiting it. Reed is a swatch book: twelve chips of dyed paper stock, each printed with one line of type, in fixed order behind a fine keyline. Flat, opaque, still. Depth comes from tonal steps (`ground → container → stock → stockLit`) and the keyline — never shadow, blur, or elevation.

The loudest instrument left is **scale contrast**: tile → show is 1:5 at the top end (15 → 140 across the app is 1:9.3). That jump *is* the aesthetic. Posters are beautiful because of scale contrast, and this app cannot use motion, so protect it — every additional type role erodes the jump that carries the whole thing.

Never write "unfortunately we can't animate this" in a comment or a review. The correct framing when a design feels flat: reach for tone, weight, scale, or the keyline. Those are the tools.

## M3 Expressive

Take the corner ladder (`0 / 4 / 8 / 12 / 16 / 20 / 28 / 32 / 48 / full`). Decline the 35-shape library, shape-morph, and motion physics — the shapes exist to morph, morph is animation. Flutter ships none of it today (`flutter/flutter#168813`), so declining costs nothing now. When the decoupled `material_ui` package eventually ships it, these arrive as tempting *defaults*, possibly with no opt-out flag. **Verify at migration time; do not assume the switches above still hold.**
