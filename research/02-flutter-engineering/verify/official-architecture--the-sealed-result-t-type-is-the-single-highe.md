# official-architecture--the-sealed-result-t-type-is-the-single-highe

> Phase: **verify** · Agent `a16fe4b57c7e5b283` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The Result type is worth lifting, and every fact the researcher states about the file is accurate — but the stated justification does not hold, and the project decision should not rest on it.

Correct mechanism: `sealed` + exhaustiveness makes it a compile error to write a switch that MISSES a branch. It does NOT make it a compile error to ignore the Result entirely. `await speechService.speak('x');` discards the Result silently, with no error and no lint. Result converts "unhandled exception" into "ignorable return value" — a real improvement in discoverability, but NOT the "silent failure becomes a compile-time error" that the claim asserts.

To actually get the claimed property, you must add what Compass omits: annotate with `@useResult` from package:meta (api.flutter.dev/flutter/meta/UseResult-class.html) so the analyzer flags discarded Results. That is a one-line addition (`@useResult` on the returning method, plus `import 'package:meta/meta.dart';`) and it is where the real value against silent failure lives — not in `sealed`. Note this is still an ANALYZER diagnostic, not a compiler error; it is only as strong as your CI treating analyzer warnings as blocking.

Also correct the causal story on constraint #4: Result does not detect `setVoice` returning 0. You must hand-write the check that turns that 0 into a `Result.error`. Result only guarantees the error PROPAGATES once detected. The detection gap is the actual root cause of the bug class, and Result does not close it.

Net: keep the plan, downgrade the rationale from "single highest-value / compile-time error" to "cheap, zero-dependency, improves error propagation — but only pays off combined with @useResult + enforced analyzer warnings + hand-written failure detection at the flutter_tts boundary." Downgrade confidence from high to medium.

**Evidence:** EVERY DESCRIPTIVE DETAIL IS CORRECT. I could not break any of them:

- `compass_app/app/lib/utils/result.dart` exists at the claimed path on `main`, is ~45 lines, has ZERO imports (no package:meta, no dependencies). Confirmed by fetching raw source.
- `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._` and `const factory Result.error(Exception error) = Error._`. Confirmed.
- `final class Ok<T> extends Result<T>` (field `value`, `toString()` -> `'Result<$T>.ok($value)'`) and `final class Error<T> extends Result<T>` (field `error`, `toString()` -> `'Result<$T>.error($error)'`), both via private `._` constructors. Confirmed.
- `Result.error` is typed to `Exception`, NOT `Object`. Confirmed — the wrapping caveat in the claim is real and correctly stated.
- Exhaustiveness: dart.dev/language/branches confirms it "reports a compile-time error if it's possible for a value to enter a switch but not match any of the cases," and that this applies to sealed types in switch STATEMENTS, not just switch expressions. The claim is right here too. No version rot: this is Dart 3 behavior, current as of Flutter 3.44.0.

THE CLAIM FAILS ON ITS CENTRAL MECHANISM. This sentence is false:

  "If SpeechService.speak() returns Future<Result<void>>, the compiler will not let the call site ignore the Error branch."

Dart's exhaustiveness checker only fires IF you write a switch on the value. Nothing in Dart requires a call site to CONSUME a return value. This compiles clean, with no error and no analyzer warning:

  await speechService.speak('hello');   // Result discarded. Silent failure. Zero diagnostics.

Exhaustiveness guarantees only: *if* you switch, you cover both branches. It does not guarantee anyone switches. The claim upgrades a conditional guarantee into an unconditional one, and that upgrade is the entire stated basis for the "single highest-value" ranking.

This is not fixable by adopting Compass's file as-is. The mechanism that WOULD force consumption is `@useResult` from package:meta (api.flutter.dev/flutter/meta/UseResult-class.html) — the analyzer "provides feedback when the value obtained by a method, field, getter ... annotated with @useResult is not used." Compass's result.dart carries NO such annotation and imports no package:meta. So copying it verbatim buys you exactly nothing against the ignore-the-return-value path.

SECOND, INDEPENDENT PROBLEM — the detection step is still manual. Constraint #4 is `flutter_tts.setVoice` returning 0 with only a `Log.d`. Result is a PROPAGATION mechanism, not a DETECTION mechanism. Someone must still hand-write the code that inspects the `0` and constructs `Result.error(...)`. The type system cannot see that failure until a human maps it. If that mapping is never written, `speak()` returns `Result.ok(null)` on a failed setVoice and the bug is fully intact — now with a reassuring type signature on top. Result cannot convert an undetected failure into a compile-time error; it can only carry an already-detected one.

THIRD — docs.flutter.dev does not support the strong reading. The official page (docs.flutter.dev/app-architecture/design-patterns/result) says Result "forces the developer implementing the view model to unwrap the Result" — that is design-level/social pressure, not compiler enforcement, and the page never claims the compiler enforces it. The page also explicitly points to third-party alternatives ("result_dart, result_type, and multiple_result"), framing Result as one option among several rather than the canonical must-lift. Treating it as THE highest-value extraction is the researcher's inference, not the source's position.

MINOR: Compass names its failure class `Error`, which shadows `dart:core`'s `Error` in any library importing result.dart. A real ergonomic cost worth pricing into an adoption decision.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: The sealed `Result<T>` type is the single highest-value thing to lift from the official guidance, because it converts this project's worst bug class (silent failure) into a compile-time error.
DETAIL: Compass's `lib/utils/result.dart` is ~45 lines with no dependencies: `sealed class Result<T>` with `const factory Result.ok(T value) = Ok._` and `const factory Result.error(Exception error) = Error._`, plus `final class Ok<T>` (field `value`) and `final class Error<T>` (field `error`). Because it is `sealed`, Dart's exhaustiveness checker makes `switch (result) { case Ok(): ... case Error(): ... }` a compile error if a branch is missing. This is the mechanism that maps directly onto constraint #4: `flutter_tts.setVoice` returning 0 with only a `Log.d` is precisely a failure the type system cannot see today. If `SpeechService.speak()` returns `Future<Result<void>>`, the compiler will not let the call site ignore the Error branch. Note that `Result.error` is typed to `Exception`, not `Object` — errors that aren't Exceptions need wrapping.
CLAIMED SOURCES: https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart, https://docs.flutter.dev/app-architecture/design-patterns
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
