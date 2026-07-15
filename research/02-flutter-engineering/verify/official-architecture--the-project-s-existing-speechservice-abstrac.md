# official-architecture--the-project-s-existing-speechservice-abstrac

> Phase: **verify** · Agent `a6362b3da38711649` · Run `wf_12b14467-451`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Correct framing: Google's Service is a stateless, side-effect-free, data-loading wrapper over a data source ("It's stateless, and its functions don't have side effects. Its only job is to wrap an external API"). SpeechService is an actuator with speak/stop plus AVAudioSession state, so only voices() maps cleanly — the mapping is partial, not 1:1, and Google's architecture has no named component for a device-actuating command wrapper. Do not call the QS Tile or the iOS 18 ControlWidget Services: per RESEARCH.md:524-525 they run with "No Flutter engine on this path" and read phrases from SharedPreferences/App Group, so no Dart class wraps them and they sit outside the Flutter architecture entirely as a parallel native app — the real architectural question there is shared-storage contract, not layering. Only the Personal Voice channel (~1 method, requestPersonalVoiceAuthorization) is channel-shaped. Google's only strong recommendation is "Use the repository pattern in the data layer" (Priority: Strongly recommend); Service has no standalone recommendation, so this cannot be a validation. Moving voice_filter up is a reasonable but new decision requiring a VoiceRepository that does not exist in the plan — and its setVoice return check is not transformation and has no home in Google's read-oriented data flow at all.

**Evidence:** QUOTE ACCURACY: survives. Every phrase the claim attributes to Google is verbatim on docs.flutter.dev/app-architecture/guide: "They wrap API endpoints and expose asynchronous response objects"; "They're only used to isolate data-loading, and they hold no state"; "Your app should have one service class per data source"; and the example list does include "The underlying platform, like iOS and Android APIs". The Repository line is also verbatim: "responsible for polling data from services, and transforming that raw data into domain models." No invented API names, no version rot — the guide is current and unchanged. That is where the claim's accuracy ends.

FAILURE 1 — the "1:1" mapping is 1-of-3, achieved by omitting the disqualifying clauses. The claim quotes "wrap API endpoints" and "hold no state" but drops the two clauses that decide the case. The guide says services are "only used to isolate data-loading." The data-layer case study (docs.flutter.dev/app-architecture/case-study/data-layer) is blunter: "A service class is the least ambiguous of all the architecture components. It's stateless, and its functions don't have side effects. Its only job is to wrap an external API." `SpeechService` is speak/stop/voices (RESEARCH.md:606). `speak(String)` and `stop()` are pure side effect and load no data — they are actuator commands. They contradict "its functions don't have side effects" and "only used to isolate data-loading" directly. Only `voices()` is a data-loading call on a data source. Google's Service is a read-path abstraction over a data source; TTS is a write-path actuator. The claim inverts this by quoting the noun ("the underlying platform, like iOS and Android APIs") while ignoring that it appears in a list of "endpoints that services might wrap" for data-loading.

FAILURE 2 — "hold no state" fails on the project's own spec. RESEARCH.md:854 (M1.3) assigns SpeechService the iOS audio session: ".playback + duckOthers + setSharedInstance". A configured shared AVAudioSession is process-wide state, and configuring it is neither stateless nor data-loading. Same for the flutter_tts completion/progress handler registration any real speak/stop wrapper needs.

FAILURE 3 — the platform channels are NOT Services, and RESEARCH.md refutes this itself. Google's Service is a Dart class in the Flutter app's data layer. RESEARCH.md:524 on the QS Tile: "Kotlin TileService. Speaks natively from SharedPreferences/DataStore. No Flutter engine on this path." RESEARCH.md:525/870 on the iOS Control: "Swift only... no Flutter on the speak path," reading phrases from an App Group. These are not platform channels at all and are not wrapped by any Dart class — they are separate native entry points that never enter the Dart VM. They sit outside Google's architecture entirely, as a parallel second application, not in its lowest layer. Calling them Services is a category error, not a validation. Only Personal Voice is genuinely channel-shaped (RESEARCH.md:523: ~1 method, `requestPersonalVoiceAuthorization` + surface `voiceTraits`) — and an authorization prompt is still a side-effecting command, not data-loading.

FAILURE 4 — "validation" overstates Google's own commitment. docs.flutter.dev/app-architecture/recommendations carries exactly one relevant item, "Use the repository pattern in the data layer" (Priority: Strongly recommend), which mentions services only in passing: "In practice, this means creating Repository classes and Service classes." There is no standalone "define a Service" recommendation and no priority attached to it. The concepts page says "Typically, applications are separated into 2 to 3 layers, depending on complexity." Google mandates the Repository; the Service is an implementation detail of it. You cannot be "validated" against a component the source never elevates to a requirement.

FAILURE 5 — the voice_filter half is the strongest part but still misfires. Google does assign repositories both "transforming that raw data into domain models" and "error handling," so moving voice filtering up is directionally defensible. But (a) the planned repositories are board_repository and settings_repository only (RESEARCH.md:597-598) and Google says "there is typically one repository class for each type of data" — acting on this requires inventing a VoiceRepository that no prior pass decided on, which makes this a change, not a validation; and (b) voice_filter is not only transformation — RESEARCH.md:158/609 scope it as "network_required/features + setVoice return check," and a setVoice return-value guard is a write-path failure check on a command. Google's data layer describes data flowing up (service → repository → domain model → view model); it has no defined home for verifying an actuator command took effect. That gap is the real finding here, and the claim never reaches it.

VERDICT: quotes real, headline conclusions wrong. CONFIDENCE "high" is unwarranted — the claim's own supporting document contradicts its second half.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a Flutter engineering-practices research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "official-architecture" made this claim, and a project decision depends on it.

CLAIM: The project's existing `SpeechService` abstraction is already exactly what Google calls a Service, and the platform channels (Personal Voice, QS Tile, ControlWidget) are Services too.
DETAIL: Google's Service definition — "wrap API endpoints", "hold no state", "one service class per data source", examples including "the underlying platform, like iOS and Android APIs" — maps 1:1 onto the already-decided `SpeechService` (speak/stop/voices) wrapping flutter_tts. This is a validation, not a change: the prior research pass independently arrived at Google's layer boundary. The `voice_filter` is the "transforming that raw data" step Google assigns to a Repository, which suggests it belongs one layer up from the raw flutter_tts wrapper rather than inside it.
CLAIMED SOURCES: https://docs.flutter.dev/app-architecture/guide
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
