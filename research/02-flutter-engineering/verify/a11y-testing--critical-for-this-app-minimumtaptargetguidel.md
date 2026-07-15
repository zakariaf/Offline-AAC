# a11y-testing--critical-for-this-app-minimumtaptargetguidel

> Phase: **verify** · Agent `a0b3ca14f36fab4ee` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** I attempted to refute this against the primary source and every specific checked out. `packages/flutter_test/lib/src/accessibility.dart` on BOTH `master` and `stable` (i.e. not version rot — this is live in the 3.44.0-era stable branch), plus api.flutter.dev confirming the public class name.

1. VIEW-EDGE SKIP — quoted verbatim, exactly as claimed. The `_traverse` method ends with:
   final Rect viewRect = Offset.zero & view.physicalSize;
   if (_isAtBoundary(paintBounds, viewRect)) {
     return result;
   }
   It returns `result` (an unmodified pass) with no diagnostic. "Silently skips" is accurate — the size comparison below it never runs.

2. `_isAtBoundary` SEMANTICS — the claim's description ("returns true unless the child has a gap > _kMinimumGapToBoundary (0.001) on ALL four sides") is exactly right, including the constant's value:
   static const double _kMinimumGapToBoundary = 0.001;
   static bool _isAtBoundary(Rect child, Rect parent) {
     if (child.left - parent.left > _kMinimumGapToBoundary &&
         parent.right - child.right > _kMinimumGapToBoundary &&
         child.top - parent.top > _kMinimumGapToBoundary &&
         parent.bottom - child.bottom > _kMinimumGapToBoundary) {
       return false;
     }
     return true;
   }
   The conjunction means ANY single side flush with the boundary → skip. Confirmed.

3. SCROLLABLE-ANCESTOR SKIP — confirmed, with the source's own comment agreeing with the claim's reading:
   // skip node if it is touching the edge scrollable, since it might
   // be partially scrolled offscreen.
   if (current.flagsCollection.hasImplicitScrolling &&
       _isAtBoundary(paintBounds, current.rect)) {
     return result;
   }
   `flagsCollection` is the current API (this is the post-SemanticsFlags-migration form, not the old `data.hasFlag(SemanticsFlag.hasImplicitScrolling)`) — so the claim is quoting the CURRENT source, not a stale one. This is an additive risk for a GridView-based grid: it can skip tiles at the scroll viewport edge on top of the view-edge skip.

4. shouldSkipNode CONDITIONS — all three confirmed, no invented members:
   bool shouldSkipNode(SemanticsNode node) {
     final SemanticsData data = node.getSemanticsData();
     if ((!data.hasAction(ui.SemanticsAction.longPress) &&
             !data.hasAction(ui.SemanticsAction.tap)) ||
         data.flagsCollection.isHidden) {
       return true;
     }
     if (data.flagsCollection.isLink) {
       return true;
     }
     return false;
   }
   (The isLink skip is indeed the WCAG target-size carve-out for inline links.)

5. isMergedIntoParent — confirmed, and the claim's gloss is correct. `if (node.isMergedIntoParent) { return result; }` sits AFTER `node.visitChildren(...)`, so descendants are still traversed and the merged parent is the node actually measured. The claim correctly calls this desired behavior for a tile rather than a bug.

6. ARITHMETIC — 3x4 = 12 tiles; interior = (3-2) x (4-2) = 2; perimeter = 10. Correct.

7. API NAME — api.flutter.dev confirms `MinimumTapTargetGuideline` in the `flutter_test` library, extending `AccessibilityGuideline`, with `size`, `link`, `shouldSkipNode`, and `evaluate` members. No invented signature.

The failure modes I was hunting for are all absent: no version rot (present in stable today, using the modern flagsCollection API), no dead package (flutter_test is first-party SDK), no invented API, no cargo cult (the claim is sourced to code, not to a blog post's opinion).

ONE NUANCE, not a refutation — the word "full-bleed" is load-bearing and the researcher correctly conditioned on it. The skip triggers only within 0.001 PHYSICAL pixels of the view edge. Any real inset — SafeArea, a Scaffold AppBar pushing the top row down, even 1 logical px of GridView padding — removes the gap on that side and the tile IS measured. So the "10 of 12 skipped" worst case requires genuinely zero padding on all outer sides, which in a Scaffold-with-AppBar layout typically won't hold for the top row. This makes the hazard real but layout-dependent rather than automatic. The mitigation follows directly from the source: add a non-zero outer padding to the grid (or assert on measured node count) so no tile is flush with the view rect, and the guideline will actually measure every tile.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: CRITICAL FOR THIS APP: MinimumTapTargetGuideline silently skips every tappable node whose bounds touch the view edge — a full-bleed 3x4 grid would make the tap-target test pass vacuously on the edge tiles.
DETAIL: Source: `final Rect viewRect = Offset.zero & view.physicalSize; if (_isAtBoundary(paintBounds, viewRect)) { return result; }` where `_isAtBoundary` returns true unless the child has a gap > `_kMinimumGapToBoundary` (0.001) on ALL four sides. It also skips nodes touching a scrollable ancestor's edge (`current.flagsCollection.hasImplicitScrolling && _isAtBoundary(...)`). In a 3x4 grid that reaches the screen edges, the 10 perimeter tiles are skipped and only the 2 interior tiles are actually measured. The test goes green while checking almost nothing. Additional skips in `shouldSkipNode`: nodes with neither tap nor longPress action, `isHidden` nodes, and `isLink` nodes (per WCAG target-size). Nodes with `isMergedIntoParent` are skipped too (the merged parent gets checked instead, which is the desired behavior for a tile).
CLAIMED SOURCES: https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart
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
