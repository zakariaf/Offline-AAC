# testing-strategy--vgv-s-actual-argument-for-100-coverage-is-a

> Phase: **verify** · Agent `ac8d37b2c6e00d64d` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The quotes are real but the attribution of motive is invented. VGV's stated primary rationale is delivery confidence and safe future change ("Your final goal should be to increase confidence in any future code change to deliver fast and safely"), with the exclusion/subjectivity problem offered as a supporting reason, not the load-bearing one. The source contains no mention of code review, negotiation, team size, or multiple developers. Because VGV's actual argument is confidence-under-change, it does NOT self-evidently fail to transfer to a solo dev — a solo dev refactoring their own code is precisely the case VGV describe. The researcher's conclusion (100% is a poor use of a 2-week solo budget) may well be correct on cost-benefit grounds, but it must be argued on its own terms, not sourced to VGV. Accurate restatement: "VGV concede 100% coverage doesn't mean 0% bugs and justify the target primarily by confidence in future change, secondarily because any lower threshold forces subjective decisions about what to exclude. They permit exceptions for auto-generated code. VGV do not address solo development; the judgment that the target is not worth a solo dev's 2-week budget is my own inference, not theirs."

**Evidence:** All four verbatim quotes in the claim were verified against the primary source (verygood.ventures/blog/road-to-100-test-coverage/): "100% test coverage doesn't mean 0% bugs" is present; the exclusion argument is present verbatim as "if you start defining a number lower than 100%, you need to start making the hard decision on what areas you will not be covering. Should you skip models? Should you skip UI?" (the claim's "third-party?" is actually "Should you skip external library usage?"); the generated-code exception is present ("auto generated code, for example, localized strings or assets since there is no added value about testing programmatically on those"); the button/bloc-event counter-example is present.

The claim's THESIS is not supported. The article never mentions code review, pull requests, arguments/negotiation between engineers, onboarding, team size, or multiple developers — not once, in any reason it gives. The "consultancy of many engineers on client codebases" framing appears only in VGV's boilerplate self-description ("the consultancy behind some of the world's most successful Flutter apps"), which the researcher promoted from a byline into a causal mechanism.

The article's own stated load-bearing reason is confidence in change, not coordination: "Your final goal should be to increase confidence in any future code change to deliver fast and safely" and "The more you test, the more you will control all your business logic." The second claimed source (verygood.ventures/blog/very-good-coverage/) gives exactly one rationale — "We recommend keeping the default min coverage of 100% for maximum confidence that every single line is covered" — again confidence-based, with zero team/code-review content. So the specific assertion "not a correctness argument" is contradicted by both cited sources.

The button counter-example is also mis-read. VGV do not use it to argue coverage measures the wrong thing and therefore the target is unsound; they use it to argue for test quality ALONGSIDE the target, concluding: "we have been putting all emphasis on prioritizing test quality over metrics, aiming for 100% test coverage, with a focus on comprehensive testing that ideally covers all scenarios."

No version-rot or API hazards apply here — the claim names no packages, APIs, or versions, so items 1-3 of the failure-mode list are not engaged. The failure mode present is #4 (cargo cult, inverted): a practice framed as team-specific when the source frames it as generally applicable.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: VGV's actual argument for 100% coverage is a TEAM-COORDINATION argument, not a correctness argument — and it therefore does not transfer to a solo dev
DETAIL: From the primary source (verygood.ventures/blog/road-to-100-test-coverage): VGV concede up front that '100% test coverage doesn't mean 0% bugs.' Their load-bearing reasoning is that any threshold below 100% forces you to DECIDE what to exclude (models? UI? third-party?), and those decisions are subjective and hard to defend. 100% is defensible precisely because it requires no negotiation. That is a mechanism for removing arguments in code review across a consultancy of many engineers on client codebases. A solo dev has no code review and no negotiation, so the benefit VGV is buying does not exist, while the cost (testing trivial code to hit a number, in a 2-week budget) is fully retained. VGV also explicitly permit exceptions for generated code: 'most of them are related to auto generated code... since there is no added value.' Notably their own counter-example — a button test that achieves coverage without verifying the bloc event fired — is an argument that coverage measures the wrong thing.
CLAIMED SOURCES: https://verygood.ventures/blog/road-to-100-test-coverage/, https://verygood.ventures/blog/very-good-coverage/
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
