# testing-strategy--with-zero-animation-pumpandsettle-should-be

> Phase: **verify** · Agent `aae7ec95876644936` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the practice, fix the reasoning and the specifics. (a) Do not cite dcm.dev for a ban — it says the opposite ("perfect for waiting for finite animations or navigation transitions"). No cited source recommends banning; Flutter's doc says "better practice," so this is a defensible LOCAL team convention for a zero-animation app, not a documented Flutter recommendation. Presenting it as sourced consensus is the error. (b) Drop "pump() is always sufficient." pump() does not advance the fake clock; Timer/Future.delayed/debounce/Timer.periodic still need pump(duration) or fakeAsync. The rule should be "pump() for state changes, pump(duration) for time-based async" — zero animation eliminates animation waits, not asynchrony waits. (c) Downgrade the assertion's claimed power: `expect(tester.binding.hasScheduledFrame, isFalse)` is a valid spot check (it is provably the exact exit condition of pumpAndSettle's own loop) but it is NOT proof the zero-animation rule holds — it misses Timer-driven repaints, at-rest implicit animations, and untapped InkWells. It catches a stray InkWell only if the test taps it. (d) Fix the InkWell remedy: splashFactory: NoSplash.splashFactory disables ONLY the splash. InkResponse.updateHighlight() independently creates an InkHighlight with a 200ms pressed fade (50ms hover/focus per getFadeDurationForType). To actually reach zero animation you must also neutralize the highlight — e.g. overlayColor/highlightColor: Colors.transparent (or WidgetStateProperty.all(Colors.transparent)) — or avoid InkWell entirely and use GestureDetector.

**Evidence:** EVERY CITED FACT CHECKS OUT — unusual for this corpus. api.flutter.dev confirms the exact signature `Future<int> pumpAndSettle([Duration duration = const Duration(milliseconds: 100), EnginePhase phase = EnginePhase.sendSemanticsUpdate, Duration timeout = const Duration(minutes: 10)])`, the 10-minute default, the verbatim quote ("In general, it is better practice to figure out exactly why each frame is needed, and then to pump exactly as many frames as necessary. This will help catch regressions where, for instance, an animation is being started one frame later than it should."), and the documented throw on infinite animations ("if there is an indeterminate progress indicator spinning, this method will throw"). flutter/flutter#84966 is real, titled "`flutter test` stack traces are truncated when `pumpAndSettle` timeouts", filed 2021-06-21, STILL OPEN, P2/framework/tests — root cause is TestAsyncUtils.guard future chaining interacting with --chain-stack-traces. No invented APIs: `SchedulerBinding.hasScheduledFrame` exists (`bool get hasScheduledFrame`, "Whether this scheduler has requested that handleBeginFrame be called soon") and `NoSplash.splashFactory` exists (`static const InteractiveInkFeatureFactory splashFactory`).

THE MECHANISM IS SOUNDER THAN THE RESEARCHER ARGUED. Source in packages/flutter_test/lib/src/widget_tester.dart shows pumpAndSettle's loop literally is: `do { if (binding.clock.now().isAfter(endTime)) { throw FlutterError('pumpAndSettle timed out'); } await binding.pump(duration, phase); count += 1; } while (binding.hasScheduledFrame);`. So asserting `!tester.binding.hasScheduledFrame` after `pump()` is exactly equivalent to asserting "pumpAndSettle would have pumped exactly once." The inversion is coherent, not cargo cult.

FOUR DEFECTS.

(1) SOURCE INVERTED — the dcm.dev article contradicts the claim it is cited for. It does NOT recommend banning pumpAndSettle; it says pumpAndSettle "is perfect for waiting for finite animations or navigation transitions to complete," and never mentions hasScheduledFrame. Flutter's own doc says "better practice," not "ban." The ban is the researcher's own inference dressed in three sources' authority — overstated consensus (failure mode 5).

(2) "await tester.pump() is always sufficient" is FALSE. Per api.flutter.dev, pump() without a duration does not advance the fake clock — "If duration is set, then advances the clock by that much first." Zero animation does NOT imply zero asynchrony: Timer, Timer.periodic, Future.delayed, debounces, and retry backoff all still require pump(duration). The stated syllogism ("zero animation -> every state change settles in ONE frame -> pump() always sufficient") is invalid.

(3) THE ASSERTION IS A SPOT CHECK, NOT AN INVARIANT. hasScheduledFrame is instantaneous state ("requested that handleBeginFrame be called soon"). It only catches animation in flight at the instant of the check. It MISSES: Timer-driven repaints (EditableText's blinking cursor schedules no frame between ticks); implicit animations (AnimatedContainer) sitting at rest; and any stray InkWell the test never taps. It cannot prove "the zero-animation rule holds" — only that nothing was animating at one sampled moment.

(4) THE INKWELL FIX IS INCOMPLETE. Source in packages/flutter/lib/src/material/ink_well.dart shows InkResponse creates InkHighlight independently of the splash, in updateHighlight(), with `getFadeDurationForType()` returning 200ms for _HighlightType.pressed and `widget.hoverDuration ?? const Duration(milliseconds: 50)` for hover/focus. splashFactory does not govern the highlight. So `splashFactory: NoSplash.splashFactory` leaves a 200ms pressed-highlight fade animating — a tapped InkWell with the recommended fix STILL schedules frames and STILL fails the proposed assertion.

Ironically, the cursor-blink case strengthens the anti-pumpAndSettle argument: pumpAndSettle advances the clock 100ms per pump, firing the ~500ms blink timer, which setStates and reschedules forever — a genuine hang that pump() avoids.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "testing-strategy" made this claim, and a project decision depends on it.

CLAIM: With zero animation, pumpAndSettle should be BANNED as a wait — and repurposed as an ASSERTION that the zero-animation rule holds
DETAIL: pumpAndSettle repeatedly pumps until no frames are scheduled, with a 10-minute default timeout; its entire purpose is waiting out animations. Flutter's own API docs say 'it is better practice to figure out exactly why each frame is needed, and then pump exactly as many frames as necessary.' It times out on infinite animations/repeating timers, and flutter/flutter#84966 documents that its stack traces are truncated on timeout — making failures hard to diagnose. In an app with zero animation, every state change settles in ONE frame, so `await tester.pump()` is always sufficient and pumpAndSettle can only add flake. The inversion: after pump(), `tester.binding.hasScheduledFrame` should be false. If it's true, an animation was accidentally introduced. Note Material's InkWell/ripple animates by default — this test would catch a stray InkWell (fix: splashFactory: NoSplash.splashFactory).
CLAIMED SOURCES: https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpAndSettle.html, https://github.com/flutter/flutter/issues/84966, https://dcm.dev/blog/2025/07/30/navigating-hard-parts-testing-flutter-developers/
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
