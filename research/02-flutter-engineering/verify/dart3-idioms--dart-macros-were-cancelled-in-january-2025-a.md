# dart3-idioms--dart-macros-were-cancelled-in-january-2025-a

> Phase: **verify** · Agent `a202ca050f739b021` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The claim is directionally right but wrong in four specifics. Corrections: (1) The ~1,400 upvotes belong to dart-lang/language#314 "Add data classes," NOT the macros tracking issue (which is #1482). #314 is a data-classes request; the official post cites it as the most-requested issue and the reason for pivoting toward bespoke data features. Do not cite it as demand for macros. (2) The stated cause is not "macros had to re-execute during incremental compilation to detect semantic changes." The official reason is (a) primarily non-convergence — "each time we solved a major technical hurdle, new ones popped up" — and (b) that the implementation "regresses both editing (e.g., static analysis and code completion) and incremental compilation (the first step of a hot reload)" because compile-time semantic introspection carried large compile-time costs. The analyzer/code-completion regression is co-equal with hot reload and must not be dropped; the re-execution mechanism is unsourced. (3) "Will never ship" overstates it — the post says stopping work, not converging "anytime soon," while remaining interested in metaprogramming long-term; #4271 "static enough metaprogramming" is an active successor. Say "cancelled/indefinitely shelved," not "never." (4) Drop dart.dev/resources/language/evolution as a citation — it does not mention macros or augmentations at all. The Shorebird and VGV posts support the cancellation but support NEITHER the upvote figure NOR the augmentations claim; only the official Dart post supports augmentations. Cite https://dart.dev/blog/an-update-on-dart-macros-data-serialization (dart.dev/language/macros now 301-redirects there). ADD: as of Dart 3.12 (2026-05-18, latest stable), augmentations has still not shipped — absent from both dart.dev/changelog and the language evolution page ~18 months after the announcement — and #4256 (closed/Done) scoped the feature down to only what code generators need. This strengthens rather than weakens the project conclusion: build_runner is not going anywhere, and drift/freezed should be evaluated on 2026 cost.

**Evidence:** CORE THESIS SUBSTANTIATED. The official Dart announcement (dart.dev/blog/an-update-on-dart-macros-data-serialization, published 2025-01-29) confirms: the Dart team stopped work on macros, and plans to ship augmentations — prototyped as part of macros — as a standalone feature that "will improve existing code generation." The old URL dart.dev/language/macros now 301-redirects to this post. The project consequence ("macros will kill build_runner soon" is dead; evaluate drift/freezed on 2026 cost) is CORRECT and in fact strengthened by current data.

FOUR SPECIFICS FAIL VERIFICATION:

(1) UPVOTE MISATTRIBUTION. The ~1,400 upvotes do NOT belong to the macros tracking issue. They belong to dart-lang/language#314, titled "Add data classes" — a data-classes feature request predating macros. The macros/static-metaprogramming tracking issue is #1482. The official post cites #314 as "the most requested issue" across Dart/Flutter trackers, and the pivot it announces is toward "more bespoke language features" for data support. Corroborated by occasionalflutter.substack.com: "a ticket related to improving data class support in Dart received approximately 1,400 upvotes." The claim uses the number as evidence of demand for macros; it is actually evidence of demand for data classes — i.e. for the thing the team pivoted TO, not the thing it cancelled.

(2) STATED CAUSE EMBELLISHED AND NARROWED. The claim's mechanism — macros "had to re-execute during incremental compilation to detect semantic changes" — appears in NO primary source. The official post says the implementation "regresses both editing (e.g., static analysis and code completion) and incremental compilation (the first step of a hot reload)," and that compile-time semantic introspection introduced "large compile-time costs which made it difficult to keep stateful hot reload hot." The claim (a) invents a re-execution mechanism, (b) omits the static-analysis/code-completion regression that the post treats as co-equal with hot reload, and (c) omits the PRIMARY stated reason: non-convergence — "each time we solved a major technical hurdle, new ones popped up... not seeing macros converging anytime soon toward a feature we are comfortable shipping."

(3) "WILL NEVER SHIP" OVERSTATES THE SOURCE. The post says work is stopping and macros are not converging "anytime soon"; the team explicitly remains interested in metaprogramming long-term. dart-lang/language#4271 ("static enough metaprogramming") is an active successor exploration. Indefinitely shelved is not the same as never.

(4) CITATIONS DO NOT SUPPORT THE LOAD-BEARING PARTS. dart.dev/resources/language/evolution — the first claimed source — does not mention macros or augmentations at all (verified by fetch; it covers Dart 2.0 through 3.12 features). The Shorebird post (shorebird.dev/blog/dart-macros, Eric Seidel, dated Jan 29 2025) mentions neither augmentations nor any upvote count. The VGV post mentions neither augmentations nor any upvote count. The augmentations claim rests on exactly one source — the official Dart post. The three-source list implies triangulation that does not exist.

MATERIAL UPDATE THE CLAIM MISSES (favors the researcher's conclusion): As of Dart 3.12 (released 2026-05-18), the latest stable, augmentations has STILL NOT SHIPPED — confirmed independently by dart.dev/changelog (no augmentations entry in any version) and dart.dev/resources/language/evolution (absent). That is ~18 months post-announcement with no delivery. Additionally, dart-lang/language#4256 ("Scoping augmentations down for code generators") is closed/Done, meaning augmentations was deliberately simplified — full original spec corners removed, keeping only what generators like built_value and json_serializable need. So build_runner's position in 2026 is even more entrenched than the claim asserts.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: Dart macros were cancelled in January 2025 and will never ship; augmentations are the replacement direction.
DETAIL: The Dart team dropped macros after ~2 years and ~1,400 upvotes on the tracking issue. Stated cause: macros had to re-execute during incremental compilation to detect semantic changes, which degraded hot reload past acceptable latency. The replacement is `augmentations` (splitting a class body across files with the `augment` keyword), which improves the ergonomics of generated code but does NOT remove build_runner. Consequence for this project: any plan premised on 'macros will kill build_runner soon' is dead. Codegen choices (drift, freezed) must be evaluated on their 2026 cost, not on a future that was cancelled.
CLAIMED SOURCES: https://dart.dev/resources/language/evolution, https://shorebird.dev/blog/dart-macros, https://www.verygood.ventures/blog/the-hard-thing-about-hard-things-macros-in-dart
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
