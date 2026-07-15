# tile-grid-design--side-margins-of-24dp-are-a-hard-constraint-n

> Phase: **verify** · Agent `a1471ba1e14a969c5` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** For a grid of TAP-ONLY tiles, this is not a hard constraint at all — it is taste. The platform guarantees taps reach the app inside the gesture band, so a 3x4 AAC tile grid with 16dp (or 8dp, or 0dp) side margins loses no taps and steals no back-gestures. Choose side margins on ergonomic and aesthetic grounds (thumb reach, edge-slop misfires, visual breathing room), not because Android forces you.

The constraint becomes real only if tiles carry horizontal press-drag-release interactions — swipe-to-delete, drag-to-reorder started by a plain drag, or a paged/carousel grid. Only in that case do you need a remedy, and margin still isn't the only one:
- Long-press-to-reorder is SAFE: the Flutter docs explicitly state long-press-initiated gestures are still delivered. Gating drag behind a long press dissolves the conflict with no margin at all — the standard Flutter ReorderableGridView/drag-handle pattern already does this.
- setSystemGestureExclusionRects / Modifier.systemGestureExclusion works fine for the small subset of regions that genuinely need it. The 200dp cap does bite for a 500dp grid, and honoring is bottom-up, so the bottom rows win and the top rows silently lose — a real gotcha, but it argues for excluding only the draggable strips, not for abandoning the API.
- Margin is a legitimate third option, not the only one.

Keep the API advice: reading MediaQuery.systemGestureInsets rather than hardcoding 20dp is correct, since the value tracks the user's back-sensitivity setting and OEM variation. Just note it reports zero on iOS, so don't let a raw read drive cross-platform layout.

Restated honestly: "Android reserves ~20dp bands at the left/right edges for the back gesture. Taps pass through them unharmed, so tap-only tiles need no margin. If tiles are horizontally draggable, prefer long-press-initiated drags or targeted gesture-exclusion rects — and be aware the system honours at most 200dp of vertical exclusion per edge, counted from the bottom, so a tall grid cannot be fully excluded."

**Evidence:** Every discrete NUMBER in this claim checks out. The INFERENCE built on them does not, and it fails on the one premise the design decision actually rests on.

WHAT SURVIVES:
1. "20dp each" — CONFIRMED, with a caveat. Chris Banes, "Gesture Navigation: handling gesture conflicts (III)" (the cited Medium post): "the left/right gesture zones are comparatively small in width (default: 20dp each)." Note this is a 2019 Android Developers blog post, not reference documentation — the figure appears in no AOSP reference page. Treating it as a spec constant is already a mistake, which is why the claim's own advice to read the inset rather than hardcode is correct.
2. "200dp limit on the VERTICAL extent" — CONFIRMED, verbatim, and the phrasing is near-quoted from the source. AOSP javadoc for WindowInsets.getSystemGestureInsets(): "Note: the system will put a limit of 200dp on the vertical extent of the exclusions it takes into account. The limit does not apply while the navigation bar is stickily hidden, nor to the input method and home activity." It is per-edge, and per Banes, when exceeded "the system will only honor the bottom-most 200dp which you requested."
3. "MediaQuery.systemGestureInsets" — CONFIRMED. MediaQueryData.systemGestureInsets exists on api.flutter.dev, is not deprecated as of Flutter 3.44, and MediaQuery.maybeSystemGestureInsetsOf exists alongside it. No API rot. (Caveat: it is Android-fed; iOS reports zero.)

WHAT COLLAPSES — the load-bearing premise:
"Tiles placed in that band will either eat back-gestures or HAVE THEIR TAPS EATEN" is false, and both cited primary sources say so explicitly.

AOSP javadoc, WindowInsets.getSystemGestureInsets(), verbatim: "Simple taps are guaranteed to reach the window even within the system gesture insets, as long as they are outside the getTappableElementInsets() system window insets."

The claim's OWN cited Flutter page (api.flutter.dev MediaQueryData/systemGestureInsets) says: "Taps and long-press-initiated gestures are still delivered to the app," and only "simple press-drag-release swipes" within the area may be intercepted. It further states that visual elements can safely appear there — the guidance is "apps should avoid locating GESTURE DETECTORS within the system gesture insets area," not "avoid placing tap targets there."

An AAC tile is a tap target. Taps in the 20dp band are guaranteed to reach it. Nor does the tile "eat back-gestures": a tap-only widget does not consume a horizontal swipe, so the system takes the swipe and nothing is lost. There is no conflict to resolve.

THE 200dp ARGUMENT IS A NON-SEQUITUR:
The reasoning "grid is 500dp tall > 200dp cap, therefore exclusion is impossible, therefore margin is the only solution" inverts the situation. You never need exclusion rects for a tap grid, so the cap never binds. The cap doesn't make exclusion impossible — it makes it unnecessary. The exclusion API exists for drag/swipe widgets; the cited Banes article's worked example is a SeekBar, and DrawerLayout/SeekBar opt out automatically for exactly that reason.

THE 24dp NUMBER IS INVENTED:
No cited source states a >=24dp side margin, and none supports it. M3's stated standard margin for the compact window size class is 16dp (m3.material.io, Applying layout) — which is BELOW the claimed 20dp hazard band, and M3 does not treat gesture zones as a margin driver, precisely because taps pass through. "24dp" appears to be 20dp plus an arbitrary safety pad, reverse-engineered to sound like a derived constant.

"MARGIN IS THE ONLY AVAILABLE SOLUTION" is also refuted by the cited article itself, which offers margin as the SIMPLEST of several options alongside exclusion rects and layout restructuring — and only for drag-based widgets.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Side margins of >=24dp are a HARD constraint, not taste — and gesture-exclusion APIs cannot rescue you
DETAIL: Android's left/right back-gesture zones have a default width of 20dp each. Tiles placed in that band will either eat back-gestures or have their taps eaten. Critically: the system imposes a 200dp limit on the VERTICAL extent of exclusions it will honour via setSystemGestureExclusionRects(). A 3x4 grid of ~120dp tiles is ~500dp+ tall, so you CANNOT exclude the grid from back-gestures programmatically — the cap makes it impossible. Margin is the only available solution. Flutter exposes MediaQuery.systemGestureInsets; read it rather than hardcoding 20dp, since OEMs vary and users can adjust back-gesture sensitivity.
CLAIMED SOURCES: https://medium.com/androiddevelopers/gesture-navigation-handling-gesture-conflicts-8ee9c2665c69, https://developer.android.com/develop/ui/views/touch-and-input/gestures/gesturenav, https://api.flutter.dev/flutter/widgets/MediaQueryData/systemGestureInsets.html
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>
