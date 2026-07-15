# flutter-design-capability--roundedsuperellipseborder-flutter-3-32-is-th

> Phase: **verify** · Agent `a17b50d06b1ea6a56` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** RoundedSuperellipseBorder (3.32+) is the best-available Apple-squircle approximation in Flutter and the only one in the SDK with an Impeller GPU geometry implementation on iOS/Android — but it is not "the only correct" one, and two specifics in the claim are wrong.

1. Do NOT write `RoundedSuperellipseInputBorder` — it does not exist and will not compile. PR #177220 shipped in 3.44 as the generic `ShapedInputBorder`. For the type-to-speak field use:
   InputDecoration(border: ShapedInputBorder(shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(12))))

2. The web fallback is fixed. RSuperellipse has rendered as a true superellipse on web since PR #171489 (merged 2025-07-12, ~3.35); issue #163718 is closed. Only platform views still fall back to RRects. Irrelevant to Android-first, but drop it from the corpus.

3. Downgrade "the only correct Apple squircle" to "the closest published approximation to iOS .continuous, reverse-engineered (flutter.dev/go/apple-squircles) and still being refined — see #164755 and #180453." Apple has never published the curve; correctness here is asserted by visual overlay in a self-published study (rydmike/squircle_study, dated 3.32, May 2025), not measured against a specification. That study is fine as a shape survey and its 2.3529 / TIE-fighter findings on ContinuousRectangleBorder hold — just don't cite it for a superlative.

Design impact: the recommendation (use RoundedSuperellipseBorder, avoid ContinuousRectangleBorder) survives. The API name for the text field does not.

**Evidence:** CONFIRMED PARTS (verified on api.flutter.dev, stable):
- RoundedSuperellipseBorder (painting library) exists. Docs: "mimics the rounded rectangle style commonly seen in iOS design."
- ClipRSuperellipse (widgets) exists. Docs: "clips its child using a rounded superellipse... resembles the RoundedRectangle shape in SwiftUI with the .continuous corner style."
- Canvas.drawRSuperellipse(RSuperellipse, Paint) -> void — exists.
- Canvas.clipRSuperellipse(RSuperellipse, {bool doAntiAlias = true}) -> void — exists.
- Path.addRSuperellipse(RSuperellipse) -> void — exists.
- Shipped in 3.32 (RoundedSuperellipseBorder merged 2025-04-08). Correct.
- 2.3529 multiplier is real and correctly derived: rydmike quotes "ContinuousRectangleBorder requires a borderRadius of ~24 to resemble the RoundedRectangle with a cornerRadius of ~10.2" (24/10.2 = 2.3529), sourced to flutter/flutter#91523. "TIE-fighter" is a real term from Flutter source limit checks.
- PR #180453 (dkwingsmt, "Improve the algorithm for rounded superellipse paths to work better at very large ratio") is real and in 3.44.

DEFECT 1 — INVENTED API NAME (compile-breaking, and the claim's load-bearing recommendation). There is NO `RoundedSuperellipseInputBorder` in Flutter. https://api.flutter.dev/flutter/material/RoundedSuperellipseInputBorder-class.html returns HTTP 404. PR #177220 opened under that title but evolved during review and MERGED (2026-01-28, commit e4925ec) as the generic `ShapedInputBorder` in packages/flutter/lib/src/material/input_border.dart. The 3.44.0 release notes still list the PR's ORIGINAL title ("feat: add RoundedSuperellipseInputBorder by @rkishan516") — the claim read a release-note line item as an API name. Verified live: https://api.flutter.dev/flutter/material/ShapedInputBorder-class.html exists, extends InputBorder, "allows any ShapeBorder to be used as an input decorator border" while preserving the floating-label gap, and lists RoundedSuperellipseBorder under "See also" as usable "with this border for iOS-style shapes."

DEFECT 2 — STALE PLATFORM CLAIM (~1 year out of date). "On web it silently falls back to a circular RoundedRectangleBorder / only supports VM builds" was true at 3.32 and is what rydmike's README says — but that study is dated 2025-05-21 (Flutter 3.32.0). Issue flutter/flutter#163718 "[Web] Implement RSuperellipse on Web" is CLOSED, resolved by PR #171489, merged 2025-07-12 (lands ~3.35). Web now renders RSuperellipse as real superellipse paths with a uniform-radius cache. Only platform views still fall back to RRects. Immaterial to an Android-first app, but the corpus statement is false as written.

DEFECT 3 — SOURCE INFLATION + "correct" overstated. rydmike's squircle_study is one practitioner's visual-overlay comparison (self-published README, no methodology section, not peer-reviewed) — usable as a shape survey, not as authority for a superlative. Its actual quotes are narrower than the claim: "It is the only **super ellipse** shape that matches the one used in iOS on UI elements" (scoped to superellipse shapes, and "matches" by visual overlay) and "It is the only shape that has GPU implementation support in Flutter SDK" (SDK-scoped; trivially, RoundedRectangleBorder also has GPU support — he means among squircle candidates). The claim upgrades these to "the only CORRECT Apple squircle in the Flutter ecosystem." Flutter's own docs never say "exact" — they say "mimics" and "resembles ... SwiftUI .continuous." Apple has never published the formula; Flutter's shape is a reverse-engineered fit (design doc flutter.dev/go/apple-squircles) approximated with conic/cubic curves, revised repeatedly (#164755 v3 "Ultrawideband heuristic formula" discarded the flawed max-ratio approximation; #180453 in 3.44 replaced one cubic with two conics because it was STILL wrong at large ratios). A shape that needed a fidelity fix in the very release the claim cites is the best-available approximation, not "correct."
Also: "GPU-implemented" is platform-scoped. The Impeller GPU geometry path is iOS/Android; the web implementation (#171489) is CPU path tessellation. Fine for Android-first, but the unqualified phrasing is wrong.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: RoundedSuperellipseBorder (Flutter 3.32+) is the only correct Apple squircle in the Flutter ecosystem, and it is GPU-implemented.
DETAIL: Flutter 3.32 shipped RoundedSuperellipseBorder (ShapeBorder), ClipRSuperellipse (widget), plus low-level Canvas.drawRSuperellipse, Canvas.clipRSuperellipse, Path.addRSuperellipse. Per rydmike's squircle_study: it is 'the only super ellipse shape that is a match for the one used in iOS' and 'the only known shape that can handle all edge cases correctly', maintaining continuous curvature at all radii and degrading gracefully to stadium. It is the ONLY shape with GPU implementation support in the SDK. Supported on iOS and Android (VM builds); on web it silently falls back to a circular RoundedRectangleBorder — irrelevant for this Android-first app. By contrast ContinuousRectangleBorder is a poor approximation: it needs its radius multiplied by ~2.3529 to approach an iOS squircle, and still exhibits 'TIE-fighter' breakdown at higher radii. Flutter 3.44 added RoundedSuperellipseInputBorder (#177220) — directly usable for the type-to-speak field — and improved the superellipse path algorithm at very large ratios (#180453).
CLAIMED SOURCES: https://api.flutter.dev/flutter/widgets/ClipRSuperellipse-class.html, https://github.com/rydmike/squircle_study/blob/master/README.md, https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e, https://docs.flutter.dev/release/release-notes/release-notes-3.44.0
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
