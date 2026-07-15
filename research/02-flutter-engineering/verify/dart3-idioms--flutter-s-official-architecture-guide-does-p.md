# dart3-idioms--flutter-s-official-architecture-guide-does-p

> Phase: **verify** · Agent `a48645f591b90f65c` · Run `wf_12b14467-451`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the claim as written. One scoping caveat for downstream use: flutter/website#11606's actual content concerns StackTrace loss (the Error class does not preserve a StackTrace) and the fact that Result-wrapped errors bypass FlutterError.onError unless explicitly logged — it requests a StackTrace field and Crashlytics-integration guidance. It does NOT raise variant naming or the Exception-typed error arm. The claim only asserts that #11606 "requests improvements to this doc", which is accurate; but citing #11606 as upstream endorsement of the naming/typing critique specifically would overreach. Those two critiques stand on their own technical merits (Dart's silent non-platform-over-dart:core shadowing; Exception's lack of declared subtypes), not on #11606. Separately, the Ok/Err and Success/Failure recommendation is the researcher's engineering judgment, not a documented Flutter/Dart position — it follows soundly from the verified shadowing behavior, but should not be presented as sourced guidance.

**Evidence:** Attempted refutation on every axis; the claim survives.

1. CODE IS VERBATIM-EXACT. docs.flutter.dev/app-architecture/design-patterns/result publishes precisely: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._;` and `const factory Result.error(Exception error) = Error._;`, plus `final class Ok<T> extends Result<T>` (field `final T value`) and `final class Error<T> extends Result<T>` (field `final Exception error`). Single type parameter <T>. Every specific in the DETAIL matches character-for-character.

2. NO VERSION ROT. Cross-checked against the upstream source of truth: flutter/samples/compass_app/app/lib/utils/result.dart on branch main is identical (BSD header, "The Flutter team", 2024). Doc and sample agree, and both are live as of 2026-07-15 under Flutter 3.44.0. This is not a 2023-era claim that decayed.

3. EFFECTIVE DART RULE EXISTS AS QUOTED. "DON'T explicitly catch Error or types that implement it" is a real rule in the Error handling section of dart.dev/effective-dart/usage. Not invented, not paraphrased.

4. ISSUE #11606 IS REAL AND OPEN. flutter/website#11606, "Enhancements to the Result Pattern Documentation", created 2025-01-19, status open.

5. SHADOWING MECHANIC IS TECHNICALLY REAL. Dart resolves a name imported from a non-platform library over the same name from dart:core, silently and without diagnostic. Importing this Result rebinds `Error` from dart:core.Error to the Result variant in that file, with no warning. The interaction with the Effective Dart rule is therefore a genuine hazard, not rhetoric.

6. EXHAUSTIVENESS ARGUMENT IS SOUND. `Exception` is a bare marker interface with no declared subtypes, so `sealed` yields exhaustiveness only across Ok/Error, never across failure modes. Adding a new failure mode produces no compile error. The claim's characterization is correct.

No invented API names, no dead packages, no overstated consensus, no cargo cult. Sources are primary and authoritative.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "dart3-idioms" made this claim, and a project decision depends on it.

CLAIM: Flutter's official architecture guide does publish a concrete sealed Result class — but its error arm is typed `Exception` and its variants are named `Ok`/`Error`, which shadows `dart:core.Error`.
DETAIL: The guide's Result (from the Compass App sample) is: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._;` and `const factory Result.error(Exception error) = Error._;`, plus `final class Ok<T> extends Result<T>` and `final class Error<T> extends Result<T>`. Two real defects for this project. (1) Naming: the `Error` variant shadows `dart:core.Error` in any file that imports it — and Effective Dart's rule 'DON'T explicitly catch Error or types that implement it' becomes hard to reason about when `Error` means two things. There is an open flutter/website issue (#11606) requesting improvements to this doc. Use `Ok`/`Err` or `Success`/`Failure`. (2) Typing: `Exception` as the error arm gives you zero exhaustiveness — `case Err(:final e)` tells you nothing about WHICH failure, so the compiler cannot force you to handle a new failure mode. That is precisely the guarantee this app needs.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/design-patterns/result, https://github.com/flutter/website/issues/11606
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
