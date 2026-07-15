# a11y-testing--screen-reader-traversal-order-is-automatable

> Phase: **verify** · Agent `a88ba387d1b0a4010` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected claim: `SemanticsController.simulatedAccessibilityTraversal` is real and current in Flutter 3.44.0, accessed via `tester.semantics`. Use only the non-deprecated signature — `simulatedAccessibilityTraversal({FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`; the `start`/`end` FinderBase<Element> params were deprecated after v3.15.0-15.2.pre in favor of `startNode`/`endNode`. `SemanticsNode find(FinderBase<Element> finder)` also exists as claimed.

It automates SEMANTICS traversal order (Flutter's own tree, "as if by assistive technologies"), with a documented caveat that platform edge cases such as the last visible item in a scrollable list may be inconsistent with real platform behavior.

It is NOT a validated proxy for switch-scanning order, and no cited source claims it is:
- Android Switch Access's Point Scan is coordinate-based (no traversal order) and Group Selection is a nested binary narrowing, not a linear order. Only Auto Scan / Step Scanning are linear.
- Switch scanning targets actionable elements; semantics traversal also enumerates non-actionable nodes. Different element sets, not just different sequence.
- It is not the "only" automated signal: `FocusTraversalPolicy`/`FocusTraversalGroup` order, testable via `tester.sendKeyEvent(LogicalKeyboardKey.tab)` (see flutter/flutter's focus_traversal_test.dart), covers actionable-element order and is the closer analogue for switch scanning.

Recommended practice: pin semantics order with `simulatedAccessibilityTraversal(startNode: ..., endNode: ...)` AND pin actionable focus order with Tab-key traversal tests. Treat both as regression guards on ordering intent, not as evidence of switch-access conformance — that still requires manual testing with Switch Access / Switch Control on device. Downgrade confidence from high to low on the switch-scanning portion.

**Evidence:** SPLIT VERDICT. The API claim is accurate; the load-bearing inference the project decision rests on is unsourced and overstated.

WHAT CHECKS OUT (api.flutter.dev, verified verbatim):
1. `SemanticsController.simulatedAccessibilityTraversal` EXISTS with exactly the claimed parameter names and types: `Iterable<SemanticsNode> simulatedAccessibilityTraversal({FinderBase<Element>? start, FinderBase<Element>? end, FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`. No invented API here.
2. `SemanticsNode find(FinderBase<Element> finder)` EXISTS as stated.
3. Accessed via `tester.semantics` — confirmed (WidgetController.semantics property exists).
4. The quote "simulates a traversal of the currently visible semantics tree as if by assistive technologies" is verbatim from the docs.

DEFECT 1 — deprecated params reproduced without the annotation. The claim presents `start` and `end` as live parameters. Both carry @Deprecated: "Use startNode instead... This feature was deprecated after v3.15.0-15.2.pre." A researcher copying this signature into guidance for Flutter 3.44.0 would propagate params deprecated ~8 releases ago. Only `startNode`/`endNode` should be presented.

DEFECT 2 — the cited source does not support the switch-scanning claim at all. The SemanticsController page is the ONLY claimed source, and it says nothing about Switch Access, Switch Control, or switch scanning. docs.flutter.dev/ui/accessibility/accessibility-testing also contains zero mentions of switch access/control/scanning. The bridge from "screen-reader traversal" to "switch-scanning proxy" is entirely the researcher's inference, sourced to a page that doesn't make it. Confidence "high" is not warranted.

DEFECT 3 — "Switch Access ... scans in the same platform traversal order" is false for most of its modes. Android Switch Access has four navigation modes: Auto Scan, Step Scanning, Group Selection, and Point Scan. Point Scan is coordinate-based (moving crosshair lines to pick an X/Y location) and has NO traversal order whatsoever. Group Selection highlights nested GROUPS to binary-search down, not a linear reading sequence. So the premise holds, at best, for linear auto/step scanning — not as a general statement.

DEFECT 4 — "the ONLY automated signal you can get about switch scanning" is false. Flutter's keyboard focus system (FocusTraversalPolicy / ReadingOrderTraversalPolicy / OrderedTraversalPolicy / FocusTraversalGroup) governs the same actionable-element ordering and is automatable in widget tests via `tester.sendKeyEvent(LogicalKeyboardKey.tab)` — this is exercised extensively in flutter/flutter's own packages/flutter/test/widgets/focus_traversal_test.dart. This is arguably the CLOSER proxy: switch scanning enumerates actionable/focusable targets, whereas semantics traversal also walks non-actionable nodes (static text, labels) that a switch scanner never stops on. The two orders are over different element SETS, not just possibly-different sequences.

DEFECT 5 — the docs carry an accuracy caveat the claim omits. The API page itself warns that "edge cases that differ between platforms (such as how the last visible item in a scrollable list is handled) may be inconsistent with platform behavior." It simulates FLUTTER's semantics tree traversal, not any platform AT's actual behavior. Calling it the "best available proxy" for a third thing (switch scanning) is a judgment the source explicitly hedges against for its primary use case.

NET: use the API — it is real, current, and genuinely good for pinning semantics order. Do not build a switch-accessibility conformance decision on it, and do not cite the SemanticsController page as saying anything about switch scanning.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "a11y-testing" made this claim, and a project decision depends on it.

CLAIM: Screen-reader traversal order IS automatable via SemanticsController.simulatedAccessibilityTraversal — and it is the best available proxy for switch-scanning order.
DETAIL: Accessed as `tester.semantics`. Signature: `Iterable<SemanticsNode> simulatedAccessibilityTraversal({FinderBase<Element>? start, FinderBase<Element>? end, FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`. Also `SemanticsNode find(FinderBase<Element> finder)`. It simulates traversal 'as if by assistive technologies'. Because Android Switch Access and iOS Switch Control scan in the same platform traversal order the screen reader uses, pinning this order is the only automated signal you can get about switch scanning.
CLAIMED SOURCES: https://api.flutter.dev/flutter/flutter_test/SemanticsController-class.html
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
