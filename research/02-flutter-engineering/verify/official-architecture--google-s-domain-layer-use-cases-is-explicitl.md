# official-architecture--google-s-domain-layer-use-cases-is-explicitl

> Phase: **verify** · Agent `acb8a77e910d54987` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** Two specifics need fixing, neither of which affects the verdict. (1) The file count is wrong: Compass has 111 .dart files in app/lib (155 including tests, 186 across the whole compass_app directory), not 169. The correct and more striking ratio is 2 use-cases out of 111 files in app/lib; note also that roughly half of domain/ is freezed/.g.dart codegen, so hand-written counts are lower throughout. (2) "An AAC app with 12 tiles and an edit mode is a CRUD app by this definition" should be labeled as inference, not citation - the Flutter docs never mention AAC apps. The inference follows soundly from the docs' own CRUD definition, but it is an application of the guidance rather than a quote of it.

**Evidence:** Attempted refutation on all four vectors; none landed.

1. QUOTE ACCURACY (recommendations): Fetched https://docs.flutter.dev/app-architecture/recommendations live on 2026-07-15. "Use a domain layer" is rated Conditional. Quoted text is verbatim-exact, including the original's typo "exceeding complex logic": "A domain layer is only needed if your application has exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead." Use case column: "Use in apps with complex logic requirements."

2. TIER CONTEXT CHECK: The page defines exactly three tiers - "Strongly recommend", "Recommend", "Conditional" (the last defined as "This practice can improve your app in certain circumstances"). Conditional is genuinely the weakest tier. The researcher is not spinning a mid-tier rating downward.

3. QUOTE ACCURACY (concepts): Fetched https://docs.flutter.dev/app-architecture/concepts live. Verbatim match: "Logic layer - Implements core business logic, and facilitates interaction between the data layer and UI layer. Commonly known as the 'domain layer'. The logic layer is optional, and only needs to be implemented if your application has complex business logic that happens on the client. Many apps are only concerned with presenting data to a user and allowing the user to change that data (colloquially known as CRUD apps). These apps might not need this optional layer."

4. COMPASS USE-CASE COUNT: Verified against live flutter/samples repo via GitHub API. compass_app/app/lib/domain/use_cases/ contains exactly two files: booking/booking_create_use_case.dart and booking/booking_share_use_case.dart. Remainder of domain/ is models only (activity, booking, booking_summary, continent, destination, itinerary_config, user - roughly half of which are freezed/.g.dart codegen). The "even the reference app barely uses the layer it demonstrates" observation is factually correct.

5. VERSION ROT CHECK: Negative. Both pages are current on docs.flutter.dev as of 2026-07-15 against Flutter stable 3.44.0. This is live first-party guidance, not stale 2023 advice.

6. CARGO CULT / OVERSTATED CONSENSUS CHECK: Negative. This is not a blog post generalized into "the community" - it is Google's own first-party architecture guidance, quoted accurately, and independently corroborated by the behavior of Google's own reference implementation.

TWO NON-FATAL SPECIFICS ARE OFF:
(a) The "169 files" denominator matches no scope of the repo. Actual: 111 .dart files in compass_app/app/lib; 155 in compass_app/app/ (lib+test); 186 across all of compass_app. Correct ratio is 2 of 111.
(b) "An AAC app with 12 tiles and an edit mode is a CRUD app by this definition" is the researcher's inference, not a documented statement - the docs never mention AAC apps. The inference is reasonable (presenting data + letting the user change it is precisely the doc's CRUD definition) but it is the one link in the chain that is argument rather than citation, and is the only point worth contesting if a project decision rests on it.

The load-bearing claim - that Google rates the domain layer Conditional and explicitly says it adds unnecessary overhead in most apps - stands fully.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: Google's domain layer (use-cases) is explicitly conditional and the docs recommend against it for most apps.
DETAIL: /app-architecture/recommendations rates "Use a domain layer" as **Conditional**: "A domain layer is only needed if your application has exceeding complex logic that crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps, use-cases are useful, but in most apps they add unnecessary overhead." /app-architecture/concepts adds: "The logic layer is optional, and only needs to be implemented if your application has complex business logic... Many apps are only concerned with presenting data to a user and allowing the user to change that data (colloquially known as CRUD apps). These apps might not need this optional layer." An AAC app with 12 tiles and an edit mode is a CRUD app by this definition. Note that Compass itself only has TWO use-cases (booking_create, booking_share) out of 169 files — even the reference app barely uses the layer it demonstrates.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/recommendations, https://docs.flutter.dev/app-architecture/concepts
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
