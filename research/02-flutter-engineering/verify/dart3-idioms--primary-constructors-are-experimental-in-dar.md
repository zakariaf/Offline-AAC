# dart3-idioms--primary-constructors-are-experimental-in-dar

> Phase: **verify** · Agent `a262932b9f48fdb4f` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Evidence:** Attempted refutation; all load-bearing assertions verified verbatim against primary sources.

1) dart.dev/blog/announcing-dart-3-12 (Connie Ooi, May 20, 2026) — section is titled "Primary constructors (experimental phase)" and states verbatim: "Primary constructors are launching as an experimental preview in Dart 3.12. Because this is a foundational shift in how Dart classes are defined, your real-world feedback is crucial. You can enable the feature using the primary-constructors flag when running your project:" followed by the exact code block `dart run --enable-experiment=primary-constructors bin/main.dart`. The intro also distinguishes them: "Concise new primitives like private named parameters, alongside experimental support for primary constructors". Both the flag name and the invocation in the claim's DETAIL match exactly. (Verified by raw HTML fetch, not just a summarizer.)

2) dart.dev/resources/language/evolution — lists ONLY private named parameters for 3.12 ("Dart 3.12 introduces private named parameters, which let you initialize private fields directly through initializing formal parameters"). Does NOT list primary constructors as introduced in any version through 3.12. No 3.13 section exists. Confirms the claim.

3) dart.dev/changelog — latest SDK listed is Dart 3.12 (2026-05-18). Dart 3.13 has NOT shipped as of 2026-07-15. Consistent with Flutter stable 3.44.0 pairing with Dart 3.12.

ADDITIONAL FINDING (strengthens the claim, not in the original): dart.dev/language/primary-constructors is itself a trap and likely the proximate cause of the blog errors. Raw page text shows NO experimental banner and NO mention of --enable-experiment. Its only version note reads "Primary constructors require a language version of at least 3.13" — a forward-looking note for an unreleased version, while the site footer says the docs reflect Dart 3.12.2. Read in isolation that page looks like docs for a shipped feature. So the claim's own source list is mildly self-undermining: the language page supports the conclusion only when read alongside the announcement. It does not contradict the claim — it confirms the feature is not stable in 3.12 and is targeted at 3.13.

NOT INDEPENDENTLY VERIFIED (immaterial to verdict): the characterization of specific recap posts (ecorpit, Medium) as "flatly stating" 3.12 adds primary constructors without qualification. The ecorpit URL slug (dart-3-12-primary-constructors-dot-shorthands-guide-2026) is consistent, but I did not read the bodies. The primary sources settle the substance regardless.

No version rot, no invented API, no overstated consensus. The engineering recommendation is sound: an experiment flag can change shape or be withdrawn before 3.13 stabilization, and requiring --enable-experiment=primary-constructors to build imposes a real cost on anyone picking up the repo. Note the stabilization target appears to be language version 3.13, so this decision is worth revisiting when 3.13 ships.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: Primary constructors are EXPERIMENTAL in Dart 3.12, not stable — multiple blog posts claiming Dart 3.12 'adds primary constructors' are misleading.
DETAIL: VERIFIED against dart.dev: the 3.12 announcement describes primary constructors as an experimental preview gated behind the `primary-constructors` flag (`dart run --enable-experiment=primary-constructors`). dart.dev/resources/language/evolution does NOT list primary constructors as introduced in any version through 3.12; it lists only *private named parameters* for 3.12. Several I/O 2026 recap posts (ecorpit, Medium recaps) flatly state 3.12 'adds primary constructors' — treat as wrong. Do not use in this project: experiments can change shape or be withdrawn, and a stranger picking up an abandoned repo should not need an experiment flag to build it.
CLAIMED SOURCES: https://dart.dev/blog/announcing-dart-3-12, https://dart.dev/resources/language/evolution, https://dart.dev/language/primary-constructors
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
