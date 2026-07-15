# performance-startup--tts-engine-binding-not-flutter-startup-domin

> Phase: **verify** · Agent `abbebc5441c633c32` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Directionally defensible, wrong evidence and overstated. Corrected version:

"Android TextToSpeech engine initialization is a real and often-overlooked cold-start cost that Flutter-side profiling doesn't surface by default. flutter_tts PR #594 (open, unmerged as of 2026-07) documents that binder IPC and voice deserialization run synchronously on the main thread inside `OnInitListener`, producing ANRs and crashes on the cold-start path. Budget for TTS init as a distinct term, initialize the engine eagerly and off the critical path, and await the first `speak()` rather than assuming it's instant."

Do NOT cite issue #235 for this — it was closed by its reporter as non-reproducible with no diagnosis. Cite **PR #594** instead, which contains the actual stack traces and root-cause analysis.

Drop "dominates," "larger than the entire Flutter term," and "invisible to every Flutter profiling tool" — none are sourced, and the last is wrong (measure the awaited channel call from Dart; use Perfetto/systrace for the native side). The "5+ seconds" figure has no methodology behind it; if the project decision depends on magnitude, measure on your actual target hardware rather than relying on a 2021 anecdote.

Keep the manifest requirement verbatim — it is correct and is the one hard, actionable fact in the claim.

**Evidence:** The load-bearing citation does not say what the claim says it says.

**Issue #235 is misrepresented.** It exists (opened 2021-05-18 by "maares", "Android tts delays on speech start"), and does contain the words "it takes 5 or more seconds to actually start" + "does not happen on simulator". But:
- It has exactly **2 comments**, no labels, and **zero diagnosis**. Nobody ever attributed it to TextToSpeech service bind/init. That attribution is the researcher's, not the source's.
- The maintainer (dlutton) never engaged technically — his only comment, ~5 months later (2021-11-02), was "I apologize I didn't reply... Were you able to solve this, is it no longer applicable?"
- **The reporter closed it as non-reproducible** (2021-11-03): *"it's no longer applicable, It seems this happens with older android versions. Tested again after a few tries with another android phone and did not get the delay on tts start speech."* So the "not reproducible on emulator" contrast collapses — it also wasn't reproducible on other physical hardware.
- The delay described is on a `speak()` call in an already-running app, **not time-to-first-word from cold start**. The reporter's own posted code re-registers `setProgressHandler` inside `playTts()` on every call and uses `awaitSpeakCompletion(false)`, so caller-side bugs were never excluded.

A single unreproduced 2021 anecdote, closed by its own author, with no measurement methodology, cannot carry a "dominates" claim at "high" confidence. That is failure mode #4/#5 (one data point presented as an established finding).

**"Invisible to every Flutter profiling tool" is false.** The `speak()`/init platform-channel round-trip is awaited from Dart and is directly measurable in the DevTools timeline; the native binder work is visible in Perfetto/systrace and Android Studio's profiler; the ANRs surface in Play Console. Overstated.

**The ~few-hundred-ms-to-1.5s Flutter startup figure is unsourced.** Neither cited source contains it; docs.flutter.dev publishes no such number. Startup depends on device, JIT vs AOT, deferred components, and plugin registration. Unverifiable as stated, and it's the denominator of the "larger than the entire Flutter term" comparison — so that comparison is unsubstantiated in both terms.

**What IS confirmed:**
1. *The manifest requirement — exactly right, including the XML.* developer.android.com states apps targeting Android 11 that interact with a TTS engine must add `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>`; flutter_tts's README says the same. Package visibility filtering does break engine discovery without it. "Fails outright" is slightly stronger than the README's "should declare," but Android's package-visibility docs support the substance.
2. *The mechanism is real — but the claim cites the wrong issue.* Open PR **#594** ("Fix ANRs and concurrency issues during TTS initialization", 2025-07-02, still **unmerged** as of 2026-07-15) documents the actual thing: "Binder IPC and Java deserialization (ObjectInputStream / Voice.<init>) were happening synchronously on the main (UI) thread during OnInitListener." Its crash stack explicitly shows `TextToSpeech$Connection$SetupConnectionAsyncTask.onPostExecute` → `dispatchOnInit` — genuine TTS service binding on the cold-start path. Related open reports: #220 ("speak() not work first time in android"), #323 ("After setVoice it takes a while until speaking starts"), #408.

**No version rot / no dead package:** flutter_tts is alive — v4.2.5 published 2026-01-05, publisher eyedeadevelopment.com (verified), not discontinued, not retracted, repo not archived, pushed 2026-01-05 (213 open issues). The claim's package-health assumptions hold.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "performance-startup" made this claim, and a project decision depends on it.

CLAIM: TTS engine binding, not Flutter startup, dominates time-to-first-word on Android
DETAIL: flutter_tts issue #235 documents 5+ seconds before speech actually starts on real Android devices (not reproducible on emulator) — this is Android TextToSpeech service bind/init, not Flutter. For comparison, Flutter engine init + Dart VM snapshot load + first frame on a low-end device is a few hundred ms to ~1.5s. The TTS term is larger than the entire Flutter term and is invisible to every Flutter profiling tool. Apps targeting Android 11+ must also declare <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> in the manifest or engine discovery fails outright.
CLAIMED SOURCES: https://github.com/dlutton/flutter_tts/issues/235, https://pub.dev/packages/flutter_tts
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
