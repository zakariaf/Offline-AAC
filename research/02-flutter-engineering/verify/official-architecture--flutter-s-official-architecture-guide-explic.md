# official-architecture--flutter-s-official-architecture-guide-explic

> Phase: **verify** · Agent `a795945b1e11b512e` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The quotes are real, but the conclusion inverts what the guide says. The audience paragraph states who the guide was written for; it does not scope out anyone else. The same guide says "The recommendations in this guide can be applied to most apps" and "This is the recommended way to build a Flutter app" — the latter being the sentence immediately after the "some libraries can be swapped out" quote, which the claim truncates. The "some parts don't apply" escape hatch is extended to VERY LARGE teams with unique complexity, not to solo devs. And "nothing in it is a rule — it is a menu" is contradicted by the Strongly Recommend tier on /app-architecture/recommendations: "You should always implement this recommendation if you're starting to build a new application," covering data/UI layer separation, repository pattern, MVVM, unidirectional data flow, immutable models, and DI — with no team-size condition. The defensible version: the guide is written with growing teams in mind and explicitly invites adaptation ("guidelines, not steadfast rules"), and its Domain/use-case layer is officially optional — so a solo dev with one screen can justifiably skip the optional layers and treat the rest as a strong default to deviate from deliberately. That is NOT the same as "outside its stated audience," and this claim should not be used to justify ignoring the Strongly Recommend items wholesale.

**Evidence:** The two direct quotes are ACCURATE and current as of 2026-07-15. https://docs.flutter.dev/app-architecture opens verbatim with: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application. If you're writing a Flutter app that has a growing team and codebase, this guidance is for you." The second quote is also verbatim: "Some libraries can be swapped out, and very large teams with unique complexity might find that some parts don't apply. In either case, the ideas remain sound." No version rot, no invented API, no dead package — the sourcing is clean.

What is REFUTED is the inference the researcher builds on top, which is the load-bearing part of the claim ("this project is outside its stated audience"; "nothing in the guide is a rule for a solo dev with one screen — it is a menu"). Three pieces of the guide's own text contradict it:

1. SELECTIVE QUOTATION. The claim stops the second quote one sentence early. The full passage on /app-architecture reads: "Some libraries can be swapped out, and very large teams with unique complexity might find that some parts don't apply. In either case, the ideas remain sound. This is the recommended way to build a Flutter app." The guide asserts universal recommendation status in the very sentence the claim truncates away. The escape hatch the claim leans on is offered to VERY LARGE teams (parts may not apply because they're too big), not to small ones.

2. THE GUIDE EXPLICITLY CLAIMS BROAD APPLICABILITY. https://docs.flutter.dev/app-architecture/guide states: "The recommendations in this guide can be applied to most apps, making them easier to scale, test, and maintain. However, they're guidelines, not steadfast rules, and you should adapt them to your unique requirements." "Most apps" is the opposite of the narrow scoping the claim asserts. The audience paragraph describes who the guide was WRITTEN FOR, not an eligibility boundary excluding everyone else.

3. "IT IS A MENU" IS FALSE AS STATED. https://docs.flutter.dev/app-architecture/recommendations grades recommendations into three tiers, and defines the top tier as: "Strongly recommend: You should always implement this recommendation if you're starting to build a new application." That is rule-shaped language explicitly keyed to NEW apps, with no team-size qualifier. Items in that tier include clearly defined data and UI layers, the repository pattern, MVVM, no logic in widgets, unidirectional data flow, immutable data models, dependency injection, abstract repository classes, and making fakes for testing. The genuinely optional/menu-like parts are marked as such — the Domain layer is explicitly labeled optional ("This layer is optional because not all applications or features within an application have these requirements"), with the guidance "add use-cases only when needed."

4. The "no separate 'small app' guide" sub-claim is accurate — docs.flutter.dev/app-architecture has index, concepts, guide, case-study, and recommendations pages, with no small-app variant. But the claim reads this absence as "therefore the guide doesn't address small apps," when the guide's own "most apps" + "adapt them to your unique requirements" framing reads the opposite way: one guide, scaled to fit.

Note: the docs pages themselves are the primary source here and were fetched directly. The flutter/website GitHub blob URLs returned 404 to my fetches (the content has moved under sites/docs/src/content/), so verbatim wording rests on two independent docs.flutter.dev fetches plus corroborating indexed search snippets, which agree exactly.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: Flutter's official architecture guide explicitly scopes itself to multi-developer teams and feature-rich apps — this project is outside its stated audience.
DETAIL: docs.flutter.dev/app-architecture opens with: "This is a guide for building scalable Flutter applications and was written for teams that have multiple developers contributing to the same code base, who're building a feature-rich application. If you're writing a Flutter app that has a growing team and codebase, this guidance is for you." It adds: "Some libraries can be swapped out, and very large teams with unique complexity might find that some parts don't apply. In either case, the ideas remain sound." There is no separate 'small app' guide. This is the single most important framing fact for this dimension: nothing in the guide is a rule for a solo dev with one screen — it is a menu.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture
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
