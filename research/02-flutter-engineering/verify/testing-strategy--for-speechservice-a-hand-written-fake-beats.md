# testing-strategy--for-speechservice-a-hand-written-fake-beats

> Phase: **verify** · Agent `ab484620424320bc6` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Keep the decision, replace the reasoning and the citations.

The right justification for a hand-written fake is architectural, and Flutter's own guidance states it directly. docs.flutter.dev/app-architecture/case-study/testing demonstrates exactly this pattern with a bare-implements fake:

  class FakeBookingRepository implements BookingRepository {
    List<Booking> bookings = List.empty(growable: true);
    @override
    Future<Result<void>> createBooking(Booking booking) async { ... }
  }

and reserves package:mocktail for external dependencies (e.g. routers) outside the core layers. That is the same fake-for-owned-services / mock-for-external split the claim advocates, from a primary source that actually says it — cite this instead of Fowler.

Specific corrections:
- DROP the Fowler citation for this argument. His article predates Dart, never mentions noSuchMethod, and his stated objection to mocks is implementation coupling ("Mockist tests are thus more coupled to the implementation of a method"), not silent absorption. If you cite him, cite him for the classicist state-verification preference — which supports reason two, not reason one.
- DROP or flag the Code with Andrea citation: paywalled, unverifiable, and a single course lesson cannot establish community consensus.
- CORRECT the mechanism claim: mocktail does not silently absorb an un-stubbed new method returning Future<void>/Future<bool>/List<Voice>. It throws a TypeError ("type 'Null' is not a subtype of type 'Future<void>'"). Silent absorption applies only to sync void methods. Reason one is therefore weak on the merits, not decisive.
- CORRECT the fake/mock framing: mocktail's Fake class uses noSuchMethod too and throws UnimplementedError on un-overridden members. The compile-time safety you want comes from `implements` without a noSuchMethod superclass — not from the word "fake."
- Demote confidence from HIGH to MEDIUM. The conclusion is right; the argument as written would not survive review.

Current-as-of-2026-07-15 package facts (these were correct in the claim): mocktail 1.0.5, publisher felangel.dev, active, not discontinued. For reference, mockito is 5.7.0, publisher dart.dev, also active — its repo now lives under github.com/dart-lang/build (the old dart-archive/mockito location is the stale one).

**Evidence:** The CONCLUSION (use a fake for SpeechService) survives. The DECISIVE REASON given for it does not, and two of the three cited sources do not say what they are claimed to say. Because the claim explicitly stakes a project decision on that reason ("the decisive reason is..."), the load-bearing part is refuted.

WHAT CHECKS OUT
1. The noSuchMethod mechanism is real and current. Dart induces noSuchMethod forwarders for any concrete class with a non-trivial noSuchMethod inherited from a class other than Object ("If a class C has a noSuchMethod forwarded signature then an implicit method implementation implementing that method signature is induced in C" — dart-lang/language, archive/feature-specifications/nosuchmethod-forwarding.md). So `class MockSpeechService extends Mock implements SpeechService` does keep compiling when SpeechService grows a 4th method. CONFIRMED.
2. `class FakeSpeechService implements SpeechService` (plain `implements`, no noSuchMethod base) does fail to compile when the interface grows. CONFIRMED.
3. Package facts are current, not rotted. mocktail 1.0.5, verified publisher felangel.dev, last publish ~3 months ago, NOT discontinued; github.com/felangel/mocktail is not archived (releases as recent as Apr 2026). No version rot here.

WHAT IS REFUTED
4. "Mocks silently absorb un-stubbed calls" is materially wrong for this codebase's realistic case, and this is the claim's decisive reason. Under sound null safety, mocktail's unstubbed methods return null, and returning null where a non-nullable type is expected throws a LOUD runtime TypeError ("type 'Null' is not a subtype of type 'Future<void>'" — felangel/mocktail issue #78 exists precisely for this). mocktail's README documents this as a migration hazard: porting from mockito requires adding a `when(...)` stub for each previously-unstubbed method. mocktail also ships MissingStubError, "thrown when no stub is found which matches the arguments of a real method call on a mock object." A SpeechService whose methods return Future<void> / Future<bool> / List<Voice> will make an unstubbed mock FAIL, loudly, on the very first call. Silent absorption is confined to sync void-returning methods. So "silently absorbing calls" is not mocktail's "defining feature," and the philosophical-backwardness argument rests on behavior mocktail largely does not exhibit.
5. Martin Fowler's mocksArentStubs.html does not support this argument and cannot — it is a language-agnostic 2007 article that predates Dart's public release (2013) and never mentions noSuchMethod. It does not compare fakes to mocks at all; it compares mocks to stubs. Its definitions are Meszaros's (fake = "objects actually have working implementations, but usually take some shortcut which makes them not suitable for production"; mock = "objects pre-programmed with expectations which form a specification of the calls they are expected to receive"). Its actual criticism of mocks is coupling, not silence: "Mockist tests are thus more coupled to the implementation of a method. Changing the nature of calls to collaborators usually cause a mockist test to break." That is close to the opposite of the claim — Fowler's complaint is that mocks break TOO eagerly on change, not that they absorb it. This is a misattribution.
6. The Code with Andrea link is PAYWALLED ("To get access to this lesson, you'll need to purchase the course"). It cannot be independently verified, and it is a mocktail tutorial, not a fake-over-mock argument. It cannot carry a "high confidence" verdict.
7. Terminology conflation. The claim cites pub.dev/packages/mocktail as a source for a fake-beats-mock argument, but mocktail ships its own Fake class — and mocktail's Fake ALSO uses noSuchMethod ("Fake uses noSuchMethod, which is a form of runtime reflection"), defaulting every un-overridden member to throw UnimplementedError. So "a fake" in mocktail's own vocabulary does NOT fail to compile when the interface grows. The compile-time break the claim relies on comes from choosing bare `implements`, not from fake-ness. Notably, mocktail's Fake already delivers loud-failure-on-new-method without abandoning mocktail — which dissolves the claimed dilemma.

WHAT IS UNVERIFIABLE
8. Reasons two (state vs interaction) and three (fake as executable documentation) are design judgments, not factual claims. No primary source settles them. They are reasonable but uncited.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: For SpeechService, a hand-written FAKE beats a mock — and the decisive reason is that mocks silently absorb interface changes via noSuchMethod, which is the exact failure mode this project cannot tolerate
DETAIL: A mocktail mock is `class MockSpeechService extends Mock implements SpeechService`. Because Mock implements noSuchMethod, adding a 4th method to SpeechService does NOT break the mock at compile time — the mock silently returns null/throws at runtime, and any un-stubbed call is absorbed. A fake (`class FakeSpeechService implements SpeechService`) fails to COMPILE when the interface grows. In a project whose stated worst bug class is silent failure, adopting a test double whose defining feature is silently absorbing calls is philosophically backwards. Second reason: the risk here isn't 'was speak() called' but 'what happens when the voice vanished / setVoice returned 0 / engine is absent' — those are STATE, and a fake models state naturally where a mock needs whenever+side-effect gymnastics. Third: for the open-source exit plan, the fake IS the executable documentation of the SpeechService contract. Use mocktail only for genuine interaction questions (e.g. does tapping tile B call stop() before speak()) — and even there a fake that records calls (i.e. a spy) is sufficient.
CLAIMED SOURCES: https://pub.dev/packages/mocktail, https://martinfowler.com/articles/mocksArentStubs.html, https://pro.codewithandrea.com/flutter-foundations/06-testing-part1/12-testing-dependencies-mocktail-package
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
