# riverpod--riverpod-3-pauses-providers-whose-only-liste

> Phase: **verify** · Agent `a32618ca456080dcb` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The pause mechanism is described accurately (TickerMode detection, default-on, cascading to upstream providers, Ref.isPaused added in 3.2.0 — all verified exactly), but the claim's central assertion is wrong: this is NOT a silent-failure vector. Riverpod explicitly buffers events emitted while a subscription is paused and replays the LAST one on resume — ProviderSubscription documents "Upon resuming the subscription, if any event was sent while paused, the last event will be sent to the listener," implemented via the `_missedCalled` field in provider_subscription.dart (_notifyData/_notifyError store instead of dropping; resume() replays, then calls _listenedElement.flush()). So a ref.listen(voiceAvailabilityProvider, ...) on the grid screen fires when the fullscreen route pops and the grid resumes; the user does not return to a stale/absent warning, and no speech-less tap results from this mechanism. Accurate statement: pausing DEFERS ref.listen callbacks until resume (coalescing intermediate events to the last one), it does not drop them. The recommendation to put safety-critical checks at the speak() call site in SpeechService rather than a screen-scoped ref.listen is still good engineering — a screen-scoped listener is the wrong home for a call-site invariant, and the deferral does mean no warning shows while the route is covering the grid — but it must not be justified by a silent-failure mechanism that does not exist. Confidence should be downgraded from "high" to moderate, and the decision should not rest on constraint #4 being triggered here.

**Evidence:** MECHANISM CLAIMS: CONFIRMED. (1) Auto-pause of non-visible listeners is real and default-on in Riverpod 3 — riverpod.dev/docs/whats_new: "Riverpod uses that to natively pauses listeners when the widget is not visible. In practice what this means is: Providers that are not used by the visible widget tree are paused." (2) TickerMode is the detection mechanism — riverpod CHANGELOG 3.0.0-dev.16 (2025-06-20): "Use TickerMode instead of Visibility for pausing out-of-view widgets"; docs confirm TickerMode can be set true/false to forcibly resume/pause. (3) Cascading is real — CHANGELOG 3.0.0-dev.12: "A provider is now considered 'paused' if all of its listeners are also paused." (4) Ref.isPaused version is EXACTLY right — CHANGELOG 3.2.0 (2026-01-17): "Added `Ref.isPaused` to check if there are any active/non-paused listeners." Not an invented API. (5) Package is alive: flutter_riverpod 3.3.2, publisher dash-overflow.net (verified), published ~35 days ago, Flutter Favorite, not discontinued.

THE LOAD-BEARING FAILURE CLAIM IS REFUTED BY SOURCE. The claim states the ref.listen callback "does not fire while paused — the user returns to the grid with a stale/absent warning," i.e. a silent-failure vector. The implementation contradicts this: Riverpod buffers the missed event and replays it on resume. From packages/riverpod/lib/src/core/provider_subscription.dart (master):

  /// Upon resuming the subscription, if any event was sent while paused,
  /// the last event will be sent to the listener.

  ({(OutT?, OutT)? data, (Object, StackTrace)? error})? _missedCalled;
  /// Whether an event was sent while this subscription was paused.
  /// This enables re-rending the last missing event when the subscription is resumed.

  void _notifyData(OutT? prev, OutT next) {
    if (isPaused) { _missedCalled = (data: (prev, next), error: null); return; }
    _listenedElement.container.runBinaryGuarded(_listener, prev, next);
  }

  void resume() {
    _listenedElement.onSubscriptionResumeOrReactivate(this, () {
      final wasPaused = _isPaused;
      super.resume();
      if (wasPaused && !isPaused) {
        if (_missedCalled?.data case final event?) { _missedCalled = null; _notifyData(prev, next); }
        else if (_missedCalled?.error case final event?) { _missedCalled = null; _notifyError(error, stackTrace); }
      }
    });
    _listenedElement.flush();
  }

Corroborating: element.dart _notifyListeners contains no isPaused check — pausing works by halting recomputation and pausing the upstream source subscription (element.dart:191 `_cancelSubscription?.pause?.call()`), not by dropping listener callbacks. On resume, `_listenedElement.flush()` re-runs the provider if a dependency changed or invalidateSelf was called.

CONSEQUENCE FOR THE STATED SCENARIO: when the fullscreen "show text" route pops and the grid resumes, the ref.listen(voiceAvailabilityProvider, ...) callback DOES fire with the missed value. The user does not return to a stale/absent warning. Errors are buffered/replayed identically. This is deferral, not silent failure, so it is not "constraint #4."

SURVIVING CAVEATS: only the LAST event is replayed (intermediate transitions coalesce — immaterial for a boolean availability flag), and the callback is DELAYED until resume, so no warning surfaces while the fullscreen route is up.

DOCS GAP WORTH NOTING: neither whats_new nor 3.0_migration states the resume/replay semantics; the pub.dev dartdoc for ProviderSubscription.pause()/resume() is terse ("Pauses the subscription."). The replay guarantee is documented on the ProviderSubscription.isPaused member via the {@template riverpod.pause} macro and in source. A researcher reading only the two CLAIMED SOURCES could plausibly reach the claim's wrong conclusion — which is likely how this error arose.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "riverpod" made this claim, and a project decision depends on it.

CLAIM: Riverpod 3 pauses providers whose only listeners are invisible widgets. This is a silent-failure vector for ref.listen-based safety warnings.
DETAIL: Providers used only by widgets that are not visible are paused by default, detected via Flutter's TickerMode. Pausing cascades: a provider listened to only by paused providers is itself paused. Concretely for this app: when the 'show text' fullscreen route covers the grid, the grid's providers pause. If a voice-availability warning is implemented as `ref.listen(voiceAvailabilityProvider, ...)` on the grid screen, that callback does not fire while paused — the user returns to the grid with a stale/absent warning and taps a tile that produces no speech. This is exactly constraint #4. Mitigation is architectural, not configurational: safety-critical checks belong at the speak() call site inside SpeechService, not in a screen-scoped ref.listen. `Ref.isPaused` (3.2.0+) exists if you need to reason about it; TickerMode can force resume.
CLAIMED SOURCES: https://riverpod.dev/docs/whats_new, https://riverpod.dev/docs/3.0_migration
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
