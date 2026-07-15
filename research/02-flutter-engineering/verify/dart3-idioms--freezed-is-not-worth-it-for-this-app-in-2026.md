# dart3-idioms--freezed-is-not-worth-it-for-this-app-in-2026

> Phase: **verify** · Agent `aaa98abc876a74dc5` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Two small refinements, neither undermining the decision: (1) The Dart macros cancellation was announced in JANUARY 2025, not February 2025 — Freezed 3.0 shipped 2025-02-25, roughly a month after, so "shipped alongside" is loose sequencing (the "Feb 2025" date correctly applies to Freezed 3.0 itself). (2) The drift-redundancy argument is valid specifically for drift's DEFAULT generated row classes. Per drift's own documentation, custom row classes declared with @UseRowClass do NOT get generated copyWith/equality, and drift explicitly recommends freezed or json_serializable in that case. Since this app uses drift-generated row classes, the conclusion stands — but adopting @UseRowClass later would flip the calculus and is the tripwire worth recording alongside the decision.

**Evidence:** Every load-bearing fact independently substantiated against primary sources; no refutation available.

1. VERSION — pub.dev/packages/freezed shows 3.2.5, published ~5 months before 2026-07-15 (≈Feb 2026), matching the claim exactly. Publisher: dash-overflow.net (verified). NOT discontinued, NOT unlisted. Flutter Favorite; 4.5k likes; 2.4M downloads. Prerelease 4.0.0-dev.3 exists. No version rot. Notably the claim does NOT present a dead package as alive — it affirmatively states freezed is healthy, which is correct.

2. API SIGNATURE — freezed changelog confirms 3.0.0 released 2025-02-25 and introduced "Mixed mode" with precisely the described shape: plain classes, normal constructors, final fields, no mandatory private subclass, no mandatory factory. Documented example: `@freezed class Usual with _$Usual { Usual({this.a}); final int a; }`. The API named in the claim is real, not LLM-plausible confabulation.

3. CORE ARGUMENT (drift redundancy) — drift's own primary docs (drift.simonbinder.eu/dart_api/rows) state generated row classes have "built-in equality, hashing, and basic serialization support. They also include a copyWith method for easy modification." Example shows hashCode via Object.hash(), operator==, toString(). drift is at 2.34.2, published ~1 day ago, publisher simonbinder.eu (verified) — actively maintained. The overlap the claim describes is real; two build_runner generators would produce genuinely redundant ==/hashCode/toString/copyWith.

4. NOT CARGO CULT — the claim is scoped to "this app" with a stated premise (persisted types are drift row classes; remaining types are 1-3 field sealed classes), not presented as a universal rule. It does not overstate consensus; it cites no community mandate.

5. DART 3 SEMANTICS — sealed hierarchies matched via exhaustive switch rather than compared genuinely do not require value equality, so the "@immutable + const ctor + final fields" alternative is coherent.

MINOR IMPRECISIONS (do not change the verdict):
(a) The macros cancellation was announced January 2025, not February 2025. Freezed 3.0 shipped 2025-02-25, ~1 month later. "Feb 2025" correctly labels Freezed 3.0 itself; "shipped alongside the macros cancellation" is loose sequencing, not a factual error about either date.
(b) The redundancy holds for drift's DEFAULT generated row classes only. Per drift's docs, custom row classes via @UseRowClass do NOT receive generated copyWith/equality, and drift explicitly recommends freezed or json_serializable for that case. The claim's premise makes this moot today, but it is the condition under which the decision reverses.

OUT OF SCOPE FOR VERIFICATION: the "~4 lines" estimate and the diff-churn / build_runner-in-the-loop / abandoned-repo-onboarding costs are engineering judgment, not factual assertions; no source confirms or refutes them, and the claim is entitled to them.

The researcher's stated "high" confidence is warranted.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: freezed is NOT worth it for this app in 2026. Current version 3.2.5 (published ~Feb 2026); it is alive and maintained, but redundant here because drift already generates == and copyWith.
DETAIL: VERIFIED on pub.dev: freezed 3.2.5, published ~5 months before 2026-07-15. Freezed 3.0 (Feb 2025, shipped alongside the macros cancellation) added 'mixed mode': plain classes with normal constructors and final fields, no mandatory `_User` private subclass, no mandatory factory. It is healthy. But: this app's persisted types (boards/buttons/grid_slots/images/sounds/settings) are drift row classes, and drift's generator ALREADY emits value-equality, hashCode, toString, and copyWith for them. Putting freezed on top means a second build_runner generator producing overlapping output. The remaining hand-written types are a handful of sealed outcome/state classes — sealed hierarchies with 1-3 final fields, where `@immutable` + `const` constructor + final fields is ~4 lines and needs no equality at all (they are switched on, not compared). Cost avoided: build_runner in the loop, .freezed.dart churn in diffs, and one more thing a stranger must install to build an abandoned repo.
CLAIMED SOURCES: https://pub.dev/packages/freezed, https://alperenderici.medium.com/dart-macros-discontinued-freezed-3-0-released-why-it-happened-whats-new-and-alternatives-385fc0c571a4
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
