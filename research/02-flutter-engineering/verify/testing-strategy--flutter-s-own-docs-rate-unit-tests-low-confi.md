# testing-strategy--flutter-s-own-docs-rate-unit-tests-low-confi

> Phase: **verify** · Agent `ac9e597df5026e621` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The table values are exactly as claimed and current — build on them with confidence. Drop the inference. Correct statement: "Flutter's docs rate unit tests Low confidence and widget tests Higher while rating both Quick on execution speed, meaning widget tests do not cost extra RUNTIME for their added confidence. They do cost more on the other two axes: Maintenance cost rises Low→Higher and Dependencies rise Few→More at the unit→widget step. Flutter presents this table as the basis for its advice that a well-tested app has 'many unit and widget tests ... plus enough integration tests to cover all the important use cases' — it groups unit and widget as co-equal bulk rather than ranking unit above widget, but it does not claim widget tests are free relative to unit tests, and it never mentions the test pyramid at all."

For the project decision: the defensible finding is narrower but still useful — Flutter's docs give no runtime-speed reason to prefer unit over widget tests, and treat both as the bulk of a suite. That does NOT license "widget tests are strictly better than unit tests" or "the pyramid doesn't apply to Flutter." If the decision rests on the pyramid being invalidated by this table, the table does not support it. Cite the maintenance-cost and dependencies rows honestly. Also update the source path to sites/docs/src/content/testing/overview.md.

**Evidence:** TABLE TRANSCRIPTION: FULLY CONFIRMED. Verified twice — against the rendered page at docs.flutter.dev/testing/overview and against the primary repo source (note: the file has MOVED to flutter/website `sites/docs/src/content/testing/overview.md`; the previously-cited `src/content/testing/overview.md` path now 404s after a repo restructure — a minor citation-rot flag, not a content issue).

Verbatim from source:

| Tradeoff             | Unit   | Widget | Integration |
|----------------------|--------|--------|-------------|
| **Confidence**       | Low    | Higher | Highest     |
| **Maintenance cost** | Low    | Higher | Highest     |
| **Dependencies**     | Few    | More   | Most        |
| **Execution speed**  | Quick  | Quick  | Slow        |

The guidance sentence is also verbatim correct: "Generally speaking, a well-tested app has many unit and widget tests, tracked by [code coverage][], plus enough integration tests to cover all the important use cases."

The claim is right that Confidence is Low/Higher/Highest, that Execution speed is Quick/Quick/Slow, and that the docs group unit and widget together rather than ranking unit above widget. No version rot, no invented API, no dead package. The 2023-era table is unchanged as of 2026-07-15.

WHERE IT BREAKS — the interpretive load-bearing part:

1. "The only real cost cliff is integration" is contradicted by the claim's OWN cited row. Maintenance cost goes Low → **Higher** at widget, before integration. The claim lists this row correctly in DETAIL and then reasons as if it said "Low/Low/Highest."

2. The claim silently OMITS the Dependencies row (Few → **More** → Most), a second cost axis that also rises at the unit→widget step. Two of four rows show widget costing more than unit.

3. "Widget tests buy strictly more confidence at the same speed class" — true on the speed row only. They do not buy it at the same *cost*. The pyramid's economic argument is about total cost of ownership, not solely wall-clock runtime; the table preserves that argument on the maintenance and dependency axes rather than invalidating it.

4. The word "pyramid" appears nowhere in the document. The docs neither endorse nor rebut the test pyramid, so they cannot "invalidate" it. More decisively, the page explicitly frames the table as the JUSTIFICATION for the many-unit-and-widget-tests guidance, not as a subversion of it: "This advice is based on the fact that there are trade-offs between different kinds of testing, seen below." The claim inverts the document's own stated logical direction.

Failure mode present: #5 (overstated consensus) in the form of over-reading — a real primary source is cited accurately and then made to support a conclusion it explicitly disclaims.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: Flutter's own docs rate unit tests LOW confidence and widget tests HIGHER, while rating both 'Quick' — which invalidates the pyramid's core economic argument in Flutter
DETAIL: The exact tradeoff table at docs.flutter.dev/testing/overview: Confidence — Unit: Low, Widget: Higher, Integration: Highest. Execution speed — Unit: Quick, Widget: Quick, Integration: Slow. Maintenance cost — Low/Higher/Highest. The pyramid exists because fidelity normally trades against speed; here widget tests buy strictly more confidence at the same speed class. The only real cost cliff is integration. Flutter's guidance sentence is 'a well-tested app has many unit and widget tests, tracked by code coverage, plus enough integration tests to cover all the important use cases' — it deliberately does not rank unit above widget.
CLAIMED SOURCES: https://docs.flutter.dev/testing/overview
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
