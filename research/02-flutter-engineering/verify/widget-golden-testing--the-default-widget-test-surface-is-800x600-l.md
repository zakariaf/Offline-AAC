# widget-golden-testing--the-default-widget-test-surface-is-800x600-l

> Phase: **verify** · Agent `a567c48e669afa8d3` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the practice, fix three things. (a) Drop "bigger than any phone" — it's wider (800 vs ~440) but SHORTER (600 vs ~915) than a real phone, so the default over-reports vertical overflow and under-reports horizontal; "near-worthless" should be "miscalibrated, axis-dependent". (b) The example is off by DPR: `physicalSize` takes PHYSICAL pixels. Use `tester.view.physicalSize = const Size(360*3, 800*3); tester.view.devicePixelRatio = 3.0;` — or set logical values with `devicePixelRatio = 1.0`. Writing `physicalSize = Size(320,568)` at default DPR 3.0 actually yields a 106.7x189.3 surface. (c) Prefer `tester.view.physicalSize`/`devicePixelRatio` over `setSurfaceSize` and don't present them as equivalent: setSurfaceSize resizes the layout box but leaves `MediaQuery.size` at 800x600. Always reset via `addTearDown(tester.view.reset)` (or `addTearDown(() => binding.setSurfaceSize(null))`) — the docs explicitly warn about leaking state into other tests, which the claim omits. Also soften "320x568 worst case": that's an iPhone SE 1st-gen/iPhone 5 profile and is a team choice, not something any primary source prescribes.

**Evidence:** I tried to refute this and mostly failed — the core is real, and I verified it by execution rather than recall.

VERIFIED BY RUNNING CODE (Flutter 3.41.2 SDK at /Users/zakariafatahi/development/flutter; built a throwaway package and ran `flutter test`):
- `tester.view.physicalSize` = Size(2400.0, 1800.0)
- `tester.view.devicePixelRatio` = 3.0
- `MediaQuery.of(context).size` = Size(800.0, 600.0)
Exactly the claimed numbers. Confirmed in source: `packages/flutter_test/lib/src/binding.dart:99` — `const Size _kDefaultTestViewportSize = Size(800.0, 600.0);`, consumed at binding.dart:2790 in `createViewConfigurationFor` via `_surfaceSize ?? _kDefaultTestViewportSize`.

API NAMES ALL REAL (this was my top suspicion — no invented signatures found):
- `TestFlutterView.physicalSize` (Size) and `.devicePixelRatio` (double) are genuine getter/setter pairs, with `resetPhysicalSize()` / `resetDevicePixelRatio()` / `reset()`.
- `TestWidgetsFlutterBinding.setSurfaceSize(Size? size)` exists with that exact signature; docs say "Set to null to use the default surface size."
No version rot: these are current on api.flutter.dev, nothing deprecated. The grid arithmetic also checks out (800/3 ≈ 267pt vs 360/3 ≈ 120pt).

THREE SPECIFICS THAT DO NOT SURVIVE:

1. "Bigger than any phone" is only true on ONE axis. 800pt wide beats any phone (widest ~440pt, Pixel Fold unfolded ~674pt), but 600pt TALL is far SHORTER than any modern phone (~915pt). So the default surface is more forgiving horizontally and STRICTER vertically. Since text-scale overflow is overwhelmingly a vertical failure, "near-worthless" is backwards for the most common case — an unpinned test is miscalibrated, not worthless, and it over-reports vertical overflow.

2. The prescription has a 3x unit bug as literally worded. `physicalSize` is in PHYSICAL pixels, so "set tester.view.physicalSize ... e.g. 320x568" is wrong. I ran it: `physicalSize = Size(320,568)` with default DPR 3.0 yields MediaQuery of **106.7 x 189.3** — a nonsense surface that would make tests fail for the wrong reason. You must multiply by DPR (`Size(320*3, 568*3)`) or set `devicePixelRatio = 1.0`.

3. The second cited source is the wrong tool for this job, and I found this empirically: `setSurfaceSize(Size(360,800))` resizes the RenderView/layout box to 360x800 but leaves `MediaQuery.size` reporting **800x600**. Any widget branching on `MediaQuery.of(context).size` silently sees the wrong screen. The `view.physicalSize` + `devicePixelRatio` route updates both consistently. So citing setSurfaceSize alongside physicalSize as interchangeable is a real trap.

Caveat stated plainly: I measured on 3.41.2, not 3.44.0 (the SDK on this machine). The 800x600 constant is longstanding and api.flutter.dev (current stable) agrees on every signature, so I have high confidence it holds — but the numbers above are 3.41.2-observed, not 3.44.0-observed.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "widget-golden-testing" made this claim, and a project decision depends on it.

CLAIM: The default widget-test surface is 800x600 logical — bigger than any phone — so an unpinned overflow test is near-worthless
DETAIL: flutter_test defaults to physicalSize 2400x1800 with devicePixelRatio 3.0 => 800x600 logical. A 3x4 grid at 800 logical width gives ~260pt-wide tiles; at a real 360pt phone the tiles are ~115pt. Text that fits at 200% scale in the default surface overflows on the real device. Every scale test must set tester.view.physicalSize/devicePixelRatio to a real profile (e.g. 320x568 as worst case, 412x915 Pixel).
CLAIMED SOURCES: https://api.flutter.dev/flutter/flutter_test/TestFlutterView-class.html, https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding/setSurfaceSize.html
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
