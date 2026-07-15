# flutter-tts--on-android-you-can-reliably-force-offline-on

> Phase: **verify** · Agent `af32759595264d02b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** On Android you can *strongly prefer* offline-only voices, and flutter_tts already surfaces the needed fields — no fork required. That part is correct and the cited line numbers (FlutterTtsPlugin.kt:484, 621-624) are accurate. Three corrections:

1. Do NOT claim "no INTERNET permission = nothing leaves device." TTS synthesis runs in a separate engine app bound via android.intent.action.TTS_SERVICE (TextToSpeech.java:2424-2426), under its own UID and its own INTERNET permission. Your manifest cannot constrain it. Omitting INTERNET is still worth doing (it proves *your* code has no network surface) but the honest claim is narrower: "this app has no network code and no network permission; speech is synthesized by your device's system TTS engine, and we select only voices that declare they need no network connection." For a genuinely provable "nothing leaves device," you would need to bundle an in-process TTS engine (e.g. a Flutter FFI binding to Piper/eSpeak-NG or a sherpa-onnx model) rather than delegating to the system engine — that is a real MVP-scope decision this claim would have let you skip.

2. KEY_FEATURE_EMBEDDED_SYNTHESIS and KEY_FEATURE_NETWORK_SYNTHESIS are @Deprecated since API 21; the docs redirect to Voice#isNetworkConnectionRequired() + setVoice(). Drop them from the design. The recommended filter (network_required == '0' AND !features.contains(KEY_FEATURE_NOT_INSTALLED)) is the correct, non-deprecated approach.

3. "Reliably force" should be "prefer, with defensive checks." isNetworkConnectionRequired is an unenforced engine-declared hint. Handle two silent-fallback paths: the framework may "use a different voice" while voice data is still downloading (KEY_FEATURE_NOT_INSTALLED doc), and flutter_tts setVoice returns 0 with only a Log.d when its exact name+locale match fails — check that return value and surface a real error, or an AAC user mid-shutdown silently gets a network voice or no speech.

Also add to AndroidManifest for targetSdk 30+: <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>, or getEngines/getVoices will fail.

**Evidence:** The API-mechanics half of the claim is accurate and verified line-by-line against primary sources; the security/trust half is wrong.

CONFIRMED:
- AOSP Voice.java exposes getQuality(), getLatency(), isNetworkConnectionRequired() (line 157), getFeatures() (line 182). All four named methods are real.
- flutter_tts FlutterTtsPlugin.kt (master, 815 lines) lines 621-624 match their quote verbatim: map["quality"]=qualityToString(voice.quality); map["latency"]=latencyToString(voice.latency); map["network_required"]= if (voice.isNetworkConnectionRequired) "1" else "0"; map["features"]=voice.features.joinToString(separator="\t").
- Line 484 is exactly `if (v.locale == locale && !v.isNetworkConnectionRequired)`, and line 491 does `return (!features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED))`. Their line citations are precise.
- getEngines/setEngine/getDefaultEngine exist in Dart (flutter_tts.dart lines 466-507) and Kotlin. flutter_tts 4.2.5 published ~6 months ago, verified publisher, actively maintained. "No fork required" is CORRECT — the Dart-side filter (network_required=='0' AND features lacks KEY_FEATURE_NOT_INSTALLED) is implementable today.

REFUTED — the INTERNET-permission argument (the load-bearing error):
- TTS synthesis does NOT run in the app's process. TextToSpeech.java:2424-2426 does `Intent intent = new Intent(Engine.INTENT_ACTION_TTS_SERVICE); ... mContext.bindService(intent, this, Context.BIND_AUTO_CREATE)` — it binds to a SEPARATE engine app (e.g. com.google.android.tts). Android permissions are per-app/per-UID, so omitting INTERNET from your AndroidManifest constrains only your own process. The engine app holds its own INTERNET permission, and the user's text crosses a Binder IPC boundary into it. Omitting INTERNET therefore does NOT make "nothing leaves device" provable, and must not be used as a trust/marketing claim to this audience.

OUTDATED:
- KEY_FEATURE_NETWORK_SYNTHESIS (tts.java:635-636) and KEY_FEATURE_EMBEDDED_SYNTHESIS (tts.java:653-654) are both annotated @Deprecated: "Starting from API level 21, to select embedded synthesis, call getVoices(), find a suitable embedded voice (Voice#isNetworkConnectionRequired()) and pass it to setVoice(Voice)." Listing them as current offline-forcing feature keys is stale (harmless, since their actual filter doesn't use them). KEY_FEATURE_NOT_INSTALLED, KEY_FEATURE_NETWORK_TIMEOUT_MS, KEY_FEATURE_NETWORK_RETRIES_COUNT are NOT deprecated.

OVERSTATED — "reliably force":
- isNetworkConnectionRequired()'s complete doc is one line: "Does the Voice require a network connection to work." It is an engine-declared hint with zero framework enforcement; nothing guarantees a voice reporting false never makes network requests.
- Silent-fallback path #1: KEY_FEATURE_NOT_INSTALLED doc (tts.java:668-678) states that until voice data download completes, "each synthesis request will either report ERROR_NOT_INSTALLED_YET error, or use a different voice to synthesize the request."
- Silent-fallback path #2: flutter_tts setVoice (ftts.kt:514-526) matches on exact name+locale string equality; on no match it only does Log.d(tag, "Voice name not found: $voice") and result.success(0) — no exception. An unchecked 0 leaves the app on the default voice, potentially a network voice.

MISSED REQUIREMENT:
- tts.java:71-80 and 263-270: apps targeting Android 11+ must declare <queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries> in the manifest, or engine/voice enumeration fails. Not mentioned in the claim.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-tts". A product decision depends on it, so it must be right.

CLAIM: On Android you CAN reliably force offline-only, and flutter_tts already surfaces the needed fields — no fork required
THEIR DETAIL: The Voice class exposes isNetworkConnectionRequired(), getFeatures(), getQuality(), getLatency(). Feature keys: KEY_FEATURE_NOT_INSTALLED, KEY_FEATURE_EMBEDDED_SYNTHESIS (engine must synthesize on-device with no network requests), KEY_FEATURE_NETWORK_SYNTHESIS, KEY_FEATURE_NETWORK_TIMEOUT_MS, KEY_FEATURE_NETWORK_RETRIES_COUNT. Verified in flutter_tts's Kotlin source (FlutterTtsPlugin.kt ~line 621): getVoices returns per-voice map keys 'quality', 'latency', 'network_required' ('1'/'0' string), and 'features' (tab-joined string). So in Dart you filter to voices where network_required == '0' and features does NOT contain KEY_FEATURE_NOT_INSTALLED. The plugin's own isLanguageAvailable check already does `if (v.locale == locale && !v.isNetworkConnectionRequired)` (line 484). Engine selection via getEngines/setEngine/getDefaultEngine (Android-only) lets you prefer Google TTS vs Samsung TTS. Belt-and-braces: ship with no INTERNET permission at all in AndroidManifest — this makes 'nothing leaves device' provable and is a strong trust/marketing claim for this audience.
THEIR CLAIMED SOURCES: https://developer.android.com/reference/android/speech/tts/Voice, https://developer.android.com/reference/android/speech/tts/TextToSpeech, https://raw.githubusercontent.com/dlutton/flutter_tts/master/android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
