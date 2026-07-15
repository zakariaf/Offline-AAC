---
name: reed-a11y-coding
description: Semantics(button:true), semanticLabel, and 200%-text survival authored into the widget as you write it — display-label-not-vocalization, OrdinalSortKey traversal from priority, boldText honoured, no clamping. Use when adding a GestureDetector or tap target, adding an Icon or Image, reaching for withClampedTextScaling, FittedBox, textScaleFactor or TextOverflow.ellipsis to fit a label, building PhraseTile or the 3x4 grid, or exposing lit/speaking state.
---

# Accessibility is a coding standard, not a checklist

This app ships no telemetry. Nobody will ever learn it failed in the field, and a user who cannot speak does not file a bug report. An inaccessible accessibility app is a total failure, so accessibility is a correctness property here — the same tier as "the phrase actually gets spoken."

**There is no lint for any of this.** `flutter_lints` and `very_good_analysis` ship zero a11y rules, and the only free candidate (`accessibility_lint`) is abandoned. Enforcement is the widget itself, review of your own diff, and `test/ui/`. Nothing else is coming.

## Where a11y state comes from

Platform a11y state is read **from `BuildContext` at build time**, never through Riverpod:

```dart
final boldText = MediaQuery.boldTextOf(context);
final highContrast = MediaQuery.highContrastOf(context);
```

`MediaQuery` is already an `InheritedWidget` with correct-by-construction invalidation. Pushing it through a provider trades a compiler-guaranteed rebuild for a manual push-and-sync that is stale for one frame — in the one area where being wrong is total failure. **App state comes from Riverpod. Platform a11y state comes from context.**

`MediaQuery.highContrastOf` is **iOS-only and always false on Android** (`AccessibilityFeatures.highContrast` is documented "Only supported on iOS"). Android-first means the in-app palette switcher is not a convenience — it is the only mechanism that works on the target platform. Read the flag opportunistically; never gate anything on it. `disableAnimations` is moot: there are no animations to disable. `invertColors` is a system compositing filter — do not reimplement it; just never encode meaning in colour alone, or an inverted screen changes what the UI says.

## The rule table

| Rule | Why |
|---|---|
| Every interactive node gets `Semantics(button: true, label: ...)` | A custom-painted grid with raw `GestureDetector`s and no semantics silently locks out every switch and screen-reader user. Correct semantics nodes make TalkBack, VoiceOver, Switch Access and Switch Control work **for free** — this is the cheapest possible win and it is definition-of-done, never a backlog ticket. |
| Every `Icon` and `Image` gets a `semanticLabel`, or is wrapped in `ExcludeSemantics` because it is decorative | There is no third option. An unlabelled `Icon` is invisible to a screen reader. |
| Never `MediaQuery.withClampedTextScaling`. Never `textScaleFactor` | Banned; a source-grep test over `lib/` enforces it. See below. |
| Never `TextOverflow.ellipsis` on a phrase label | Turns "the label doesn't fit at 200%" from a loud test failure into a truncated word a user in crisis cannot read. |
| Never `FittedBox`/auto-shrink to make a label fit a tile | Same bug wearing a disguise. |
| Semantic `label` is the **display label**, never the vocalization | Nothing in the type system distinguishes these two `String`s. A scanning user must hear "Overwhelmed", not the whole sentence, on every step. |
| Honour `boldText` | Hardcoding `fontWeight` throws the setting away. |
| Traversal order is authored with `sortKey`, never inherited from layout | See below. |
| Assert with `isSemantics(...)`, not `containsSemantics(...)` | The latter is deprecated after v3.40.0-1.0.pre. |

## The tile, wrong and right

```dart
// ============================ WRONG ============================
class PhraseTile extends StatelessWidget {
  const PhraseTile({super.key, required this.button, required this.onTap});
  final Button? button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(   // (1) BANNED
      maxScaleFactor: 1.3,
      child: InkWell(                            // (2) animates
        onTap: onTap,
        child: Column(
          children: [
            const Icon(Icons.warning),           // (3) no semanticLabel
            Text(
              button?.label ?? '',               // (4) no Semantics: no button
              style: const TextStyle(            //     role, and an empty slot
                fontSize: 18,                    //     announced as tappable
                fontWeight: FontWeight.normal,   // (5) ignores boldText
              ),
              overflow: TextOverflow.ellipsis,   // (6) HIDES the overflow bug
            ),
          ],
        ),
      ),
    );
  }
}
```

1. `withClampedTextScaling` is **the single most dangerous API in this app**. It is the one-line "fix" a future contributor reaches for when an overflow test goes red, and it silently defeats the entire text-scale matrix *while contrast and tap-target guidelines still pass green*.
2. Ink ripples are animation, which is banned outright. `splashFactory: NoSplash.splashFactory` kills only the splash — `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade.
3. An unlabelled `Icon` is invisible to a screen reader.
4. No `Semantics` → no button role → `labeledTapTargetGuideline` has nothing to check.
5. Hardcoded weight ignores `boldText`.
6. `ellipsis` converts a loud test failure into unreadable text on a device, in a shutdown.

```dart
// ============================ RIGHT ============================
class PhraseTile extends StatelessWidget {
  const PhraseTile({super.key, required this.slot, required this.onSpeak});

  final GridSlot slot;
  final void Function(int row, int col) onSpeak;

  @override
  Widget build(BuildContext context) {
    final boldText = MediaQuery.boldTextOf(context);
    final highContrast = MediaQuery.highContrastOf(context);
    // textScaler is deliberately NOT read and NOT clamped. Text scales itself.
    // The job here is a layout that survives it.

    final button = slot.button;

    if (button == null) {
      // Ground, nothing else: no fill, no keyline, no target, and NO semantics
      // node — ExcludeSemantics, not `enabled: false`. Excluding it means
      // TalkBack and Switch Access SKIP it instead of burning a scan step on
      // nothing; under linear autoscan at 1s/step every wasted step is real
      // time. The empty cell still HOLDS ITS SPACE — it never collapses and
      // pulls the next tile into its position. Reflow is the bug the fixed
      // schema exists to prevent.
      // In EDIT MODE the same cell becomes a full target with a keyline, a `+`
      // and full semantics. Make the exclusion mode-dependent or the editor is
      // unusable via switch access.
      return const ExcludeSemantics(child: SizedBox.expand());
    }

    return Semantics(
      container: true,
      button: true,
      label: button.label,                    // display label, NOT vocalization
      sortKey: OrdinalSortKey(button.priority.toDouble()),  // priority, not layout
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,     // the whole cell is the target
        // Resolve at TAP time from the immutable (row, col) primary key.
        // Capturing button.vocalization into this closure speaks a STALE
        // sentence on a fast re-tap — the wrong words, out loud, on behalf of
        // someone who cannot verbally correct it.
        onTap: () => onSpeak(slot.row, slot.col),
        child: ExcludeSemantics(
          // _TileFace renders the label visually; the Semantics node above
          // already announces it. Without this it is said twice.
          child: _TileFace(
            label: button.label,
            bold: boldText,
            highContrast: highContrast,
          ),
        ),
      ),
    );
  }
}
```

## Text scale: the instinct is the bug

The reflex when a fixed 3×4 grid overflows at 200% is to *disable text scaling for layout stability*. That reflex is the defect. Auto-shrinking text to fit — `FittedBox`, a computed `fontSize`, `maxLines` + `ellipsis` — is the identical bug wearing a disguise: the layout stays tidy and the user's setting stops working, silently, with every guideline still passing.

- Honour `MediaQuery.textScalerOf(context)` by *not touching it*. Flutter text widgets already scale.
- `textScaleFactor` is deprecated in favour of `TextScaler` precisely to support Android 14's nonlinear scaling. Its use is almost always a clamping hack.
- Build **intrinsic and flexible heights**; let text wrap to as many lines as it needs. Tiles compute to roughly 89–106 × 125–146dp on real phones, and the label block needs ~124dp at 200% — a hardcoded tile height is the wrong constraint. The real constraint is `tileHeight = (viewport − chrome) / rows`, with CI asserting the label fits inside it at every scale.
- Let overflow scream in tests. A red-and-yellow overflow stripe in a widget test is the feedback loop; a truncated word on a device is a product failure nobody will report.

## Traversal order is a design decision

The lower-centre arc holds the highest-priority phrases — a thumb-reach optimisation. Combined with Flutter's default row-major semantic traversal it means **"I need to leave" is the 8th-to-11th thing TalkBack reads**, and 8–11 seconds away under Switch Access linear autoscan at 1s/step. The thumb optimisation *actively pessimises* every screen-reader and switch user. Inheriting traversal from layout is not a decision; it is an accident.

The fix costs one argument: `sortKey: OrdinalSortKey(priority.toDouble())` decouples traversal from visual position. Lower-centre thumb placement **and** first-in-traversal. Author it from priority, and assert `sortKey` order equals priority order — not layout order — in a test.

Know the limits so the test is not oversold: Switch Access *group* selection reaches any of 12 items in ⌈log₂12⌉ = 4 presses regardless of order, so only linear scanners depend on `sortKey`. Flutter publishes no Switch Access support statement and no API simulates scanning, group selection, or point scanning. The traversal test is a regression guard on *intent*, never conformance evidence. Real-device passes with TalkBack and Switch Access are the only evidence there is.

Focus rings serve keyboard and TalkBack only — Switch Access draws its own highlight, user-configurable in colour and thickness, and in group selection the highlighter colours change on every press. **Touch, switch, and screen reader are three different channels.** Design for all three or state plainly which one was dropped.

## Never state through colour alone

The lit/speaking tile is a real state: it is the thing talking, and tapping it stops speech. Expose it through `Semantics` — a `value`/`hint` describing that it is speaking, or a `liveRegion` announcement — never through the luminance step alone. Colour-only state is invisible under `invertColors`, under Android's Grayscale colour-correction mode, and to every screen-reader user. Feedback is never single-channel: pair the visual step with `HapticFeedback.selectionClick`. Guard the lit latch with a timeout that force-clears it — `flutter_tts` completion-handler reliability varies by OEM, and a stuck-lit tile is both a lie about what the app is doing and a stale semantic value.

## Definition of done for any widget with a tap target

1. `Semantics` node with `button: true`, a display-only label, and an authored `sortKey`.
2. Every `Icon`/`Image` labelled or explicitly excluded.
3. No clamp, no `FittedBox`, no `ellipsis` on a phrase label; renders at `TextScaler.linear(2.0)` without overflow.
4. `boldText` honoured; no hardcoded `fontWeight` on user-facing text.
5. Non-colour channel for every state.
6. A test asserting the semantics with `isSemantics(...)`, and traversal against priority order.
