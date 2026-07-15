# widget-golden-testing--overflow-only-reports-if-the-widget-actually

> Phase: **verify** · Agent `a4b0d85e975e1ba92` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Replace "Anything Offstage, inside a lazy list beyond the viewport, or clipped away never reports" with: "Anything Offstage, or scrolled outside a viewport (lazy OR non-lazy — RenderViewportBase._paintContents culls on child.geometry!.visible, not on whether it was built), never reports. CLIPPED CONTENT STILL REPORTS: RenderClipRect.paint passes super.paint into context.pushClipRect, so the child paints inside the clip layer; and RenderFlex explicitly calls paintOverflowIndicator AFTER pushing its own clip when clipBehavior != Clip.none. Clipping hides the yellow/black stripes' extent, not the console report — see open issue flutter/flutter#100789. The docs' 'clip with a ClipRect' advice works only when applied to the CHILD before it enters the flex, which shrinks the child so no overflow occurs at all; it is not a way to silence an existing overflow."

**Evidence:** CORE MECHANISM: CONFIRMED. The cited file is real and says what the researcher claims. DebugOverflowIndicatorMixin exposes paintOverflowIndicator(PaintingContext context, Offset offset, Rect containerRect, Rect childRect, {List<DiagnosticsNode>? overflowHints}) — exact signature verified, no invented API. In flex.dart, performLayout() only silently records `_overflow = math.max(0.0, -sizes.mainAxisFreeSpace);` and the report fires from paint(), inside an assert block (debug-only). So "reports from paint(), not performLayout()" is correct.

OFFSTAGE: CONFIRMED. api.flutter.dev/RenderOffstage: "Lays the child out as if it was in the tree, but without painting anything, without making the child available for hit testing, and without taking any room in the parent." Child is laid out (so _overflow is computed) but never painted, so no report.

LAZY LIST BEYOND VIEWPORT: CONFIRMED, AND UNDERSTATED. The claim attributes this to laziness, but the culling lives in the viewport, not the builder. RenderViewportBase._paintContents gates on visibility, not on whether the child was built:
  for (final RenderSliver child in childrenInPaintOrder) {
    if (child.geometry!.visible) { context.paintChild(child, offset + paintOffsetOf(child)); }
  }
A NON-lazy ListView(children: [...]) — all children built and laid out — also will not report overflow for off-screen children. The blind spot is wider than claimed.

"CLIPPED AWAY NEVER REPORTS": REFUTED. This is the one specific that fails. RenderClipRect.paint passes `super.paint` as the callback into context.pushClipRect(...) — the child still paints, just inside a clip layer. Painting occurs, so the report fires. RenderFlex is even more explicit: when it overflows with clipBehavior != Clip.none, it pushes the clip AND THEN still calls paintOverflowIndicator immediately after:
  _clipRectLayer.layer = context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint, clipBehavior: clipBehavior, oldLayer: _clipRectLayer.layer);
  assert(() { paintOverflowIndicator(context, offset, Offset.zero & size, overflowChildRect, overflowHints: debugOverflowHints); return true; }());
This is corroborated by open Flutter issues #100789 ("Overflow warnings are impossible to disable") and #136503 ("ClipRect doesn't work with a Column") — developers actively want the behavior the claim asserts already exists, and cannot get it. Clipping suppresses the visual extent of the stripes, not the console report.

LIKELY ROOT OF THE ERROR: docs.flutter.dev/testing/common-errors advises "consider clipping it with a ClipRect widget BEFORE putting it in the flex" — that works by shrinking the CHILD so the flex never overflows in the first place, which is a different operation from wrapping the flex in a ClipRect (which does nothing to the report). Conflating the two plausibly produced the bad specific.

PROJECT-DECISION IMPACT: The actionable conclusion survives intact — the fullscreen 'show text' mode and edit mode do need their own pumped tests and will not be covered by a board test, because Offstage/unpainted subtrees genuinely never report. But the clipping error is not harmless: anyone triaging with "that subtree is clipped, so it can't be the source of this overflow" will chase the wrong widget. Correct rule is: painted => reports; clipping does not make a widget unpainted.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: Overflow only reports if the widget actually PAINTS
DETAIL: The report fires from paint(), not performLayout(). Anything Offstage, inside a lazy list beyond the viewport, or clipped away never reports. For this app's fixed, fully-painted 3x4 grid this is fine — but it means the 'show text' fullscreen mode and edit mode need their own pumped tests; they will not be covered by a board test.
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/rendering/debug_overflow_indicator.dart
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: pub.dev package pages (for real current versions, publisher, and maintenance status), api.flutter.dev (for real API signatures), dart.dev, docs.flutter.dev, and the actual GitHub repos (for whether something is archived/discontinued).

The failure modes you are hunting for, in order of likelihood:
1. **Version rot** — the claim was true in 2023. APIs get deprecated and removed; `setMockMethodCallHandler` moved; `window` was deprecated; formatters changed.
2. **Dead packages presented as alive** — golden_toolkit, dart_code_metrics, isar, hive, mockito-vs-mocktail. CHECK THE REPO: is it archived? When was the last publish? Does pub.dev show it as discontinued?
3. **Invented or misremembered API signatures.** If the claim names a method, class, or parameter, VERIFY IT EXISTS with that exact name on api.flutter.dev or the package docs. LLM-plausible API names are a specific hazard here.
4. **Cargo cult** — presenting a team practice or a large-app practice as universal, when the actual source doesn't say that.
5. **Overstated consensus** — "the community recommends X" when it's one blog post.

Default to refuted=true if you cannot independently substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + a correction if directionally right but wrong in specifics (name the exact right version/API). UNVERIFIABLE if no source settles it — and say that plainly rather than guessing.
````

</details>
