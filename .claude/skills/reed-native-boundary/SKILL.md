---
name: reed-native-boundary
description: MethodChannel placement and the native speak path — channels under lib/native/, the Android Quick Settings TileService, iOS ControlWidget/AppIntent, home_widget as a data bridge, and the versioned JSON mirror contract Kotlin and Dart must both own. Use when adding a MethodChannel, a Quick Settings tile, a home screen widget or Control, or a write path that must republish the mirror. Not for the SpeechService interface, voice filtering, or audio session category.
---

# The native boundary

**The speak path is native and reads from shared storage. Flutter owns the editor and the in-app UI.**

That sentence is an architectural fact, not an implementation detail. Everything below is a consequence of it. The Quick Settings tile is a parallel app that happens to ship in the same APK.

## Why the boundary sits here

`QuickPhraseTileService.onClick()` starts **no Flutter engine**. It reads a phrase from a shared file and calls Android's `TextToSpeech` directly. It skips FlutterActivity, engine init, Dart VM snapshot load, drift open, migration, and first frame. It is the fastest path to speech in the product and it is reachable from the **lock-screen shade** — `unlockAndRun()` is only required for *sensitive* actions, and speaking a stored phrase is not sensitive.

This makes time-to-first-word a **native code budget**, not a Flutter engine-start budget. Protect that property in every change.

**Never make the native speak path depend on the Dart side being alive.** No engine handle, no background isolate, no `MethodChannel` callback into Dart, no waiting on a Flutter-owned lock or database. The Dart process is normally dead when the user taps that tile — that is the whole point. If a change means the tile needs Dart to be running, the change is wrong.

Corollary: **never put a migration or a DB open on the tile path.** The no-Flutter-engine design guarantees this structurally today; keep it that way.

## The three consequences — state them plainly, do not soften them

**(a) No Flutter test of any level can reach the tile.** Not unit, not widget, not `integration_test`. This is the crisis path and it has zero Dart-side coverage, by design. That is not a gap to fix; it is the price of the latency budget.

The mitigation is shape, not tooling: `onClick()` is ~5 lines that immediately delegate to `QuickTileSpeaker` — a plain Kotlin class doing read → validate non-empty → speak — which plain **JUnit** tests with a fake TTS. **No Robolectric**: `TileService` is lifecycled by SystemUI and has no first-class shadow. Keep `QuickPhraseTileService.kt` too small to hold a bug. Everything that can be wrong lives in `QuickTileSpeaker.kt`.

What JUnit cannot cover is manual-checklist territory by design. Write the checklist step; do not fake the test.

**(b) The shared-storage format is a cross-language contract with zero compiler enforcement.** It gets exactly one owner per side and no others:

| Side | Sole owner |
|---|---|
| Dart | `lib/native/quick_tile_bridge.dart` — the only writer of the contract file |
| Kotlin | `QuickTileContract.kt` — mirrors the Dart file **by hand** |

Rename a key in one without the other and the tile speaks nothing, in the one code path the user reaches mid-shutdown. Nothing catches it: no compiler, no analyzer, no test, and no crash report — there is no telemetry, and a user who cannot speak does not file a bug. Any edit to one file is an edit to both, in the same commit.

**(c) It is a versioned JSON file we own — not `shared_preferences`.** Two independent traps make the obvious choice wrong:

- `SharedPreferencesAsync` is backed by **Jetpack DataStore**, not `FlutterSharedPreferences.xml`. Kotlin's `getSharedPreferences(...)` reads **nothing**.
- The legacy API prefixes every key with `flutter.`, so `getString("phrase")` returns null — the actual key is `flutter.phrase`.

Both failures are silent and both land on the crisis path. An explicit file with a schema version sidesteps both, survives a `shared_preferences` major version bump, and is readable by a stranger with `cat`.

## The mirror invariant

Every board edit republishes the tile file. The write-through is fan-out from the same repository call that hits SQLite:

```
BoardRepository.setSlotButton(row, col, buttonId)
   ├─→ drift UPDATE grid_slots ... → stream emits → grid rebuilds
   └─→ QuickTileBridge.publish(vocalization) → versioned JSON file
                                                    ╎ no Flutter engine
                                                    ▼
                                             QuickTileSpeaker (Kotlin)
```

**A phrase deleted in the app but stale in the mirror speaks something the user retracted** — out loud, to a stranger, on behalf of someone who cannot correct it verbally. That write-through is not an optimization; it is the correctness of the crisis path. Deletes and clears republish exactly as hard as saves do.

### The test that looks right and is worthless

`SharedPreferences.setMockInitialValues` is **in-memory only**. A Dart unit test asserting "edit a tile → the stored value changed" asserts *a fake mutated a fake*: green while the Kotlin read path is broken. That is manufactured false confidence in precisely the silent failure it claims to guard.

The mirror invariant requires an **`integration_test`** that writes from Dart and reads back through the real native path. Never accept a unit test in its place.

## home_widget: data bridge only, or not at all

`home_widget` does not let you write widgets in Flutter — its own docs say so. It is a data bridge (App Groups on iOS, SharedPreferences on Android) plus an update trigger. The widget UI is hand-written **SwiftUI/WidgetKit** or **Jetpack Glance** regardless. Glance is **not** Compose; many Compose features do not work there.

**Never route the speak path through it.** Its iOS interactive path goes through `HomeWidgetBackgroundWorker` — a Flutter **background isolate** — and the `ForegroundContinuableIntent` variant **boots the whole Flutter app via the main entrypoint**. Both add latency and failure modes on the one path that must be instant. `AudioPlaybackIntent` already routes the intent into the app's native process, so route around Flutter entirely: App Group phrases + `AVSpeechSynthesizer`, pure Swift, zero Dart.

Use `home_widget` as a data bridge only, or skip it and hand-roll the App Group / shared-file read. If it appears anywhere near `perform()`, delete it.

Reject `glance_widget` and similar "zero-native-code widgets" packages: young, unproven, and a shipping feature must not bet on them.

## Surfaces, cost, and what each actually requires

| Surface | Why Flutter cannot | Cost |
|---|---|---|
| **Android Quick Settings tile** | Kotlin `TileService`. Speaks natively from the shared file. No Flutter engine on this path. | S–M |
| **iOS 18 Control (`ControlWidget`)** | Swift only. App Group phrases + `AVSpeechSynthesizer` + `AudioPlaybackIntent` conformance + `authenticationPolicy = .alwaysAllowed` (the default). | M |
| **Personal Voice (iOS)** | `flutter_tts` never calls `requestPersonalVoiceAuthorization` and never exposes `voiceTraits`. Personal Voice only appears in `speechVoices()` *after* authorization, so an unmodified app will never see one. | ~1 method |
| **Warm-up / singleton synthesizer** | `flutter_tts` has no warm-up API. Only if a latency probe demands it. | XS |
| **Route detection** | `AVAudioSession.currentRoute`. | XS |

Two hard platform facts that decide designs:

- **iOS home screen widget buttons are inactive on a locked device** — "the system doesn't perform actions unless a person authenticates and unlocks their device." No workaround. Controls (`ControlWidget`) are a *different* surface and are **not** gated: `AppIntent.authenticationPolicy` defaults to `.alwaysAllowed`. Do not conflate them.
- **Cold-launching the app to run an intent is reported as several seconds.** A widget button is a fast path only when the app is already resident — exactly not the mid-shutdown case. If a surface must be instant, its speak path is pure native or it is a lie.

Keep the Quick Settings tile action **UI-free**: `showDialog()` will not render under the lock screen. OEM skins and the user's lock-screen QS setting can restrict shade access; that is a known, accepted limit, not a bug to code around.

If the shared code for an iOS intent is not a member of **both** the app target and the widget extension target, it works in the Simulator and fails on device. Verify target membership before believing a green Simulator run.

## Rules for writing this code

**Every `MethodChannel` in the app lives under `lib/native/`. Nothing else may create one.** Today that is `quick_tile_bridge.dart` and `personal_voice_channel.dart`. A channel created inside a widget, a repository, or a controller is a defect regardless of how well it works.

**Do not make the tile a plugin, federated or otherwise.** Federation exists so a domain expert can extend someone else's published plugin. One dev owns all of this and the tile has **no Dart at all** — a plugin buys a platform_interface, version lockstep, and a publishing story in exchange for nothing.

**Abstract exactly what cannot run in a test — nothing more.** That rule yields exactly two abstractions in this app: `SpeechService` and the Personal Voice channel. `BoardRepository` stays concrete because it runs against real in-memory SQLite. Do not add an interface over native glue "for symmetry."

**Personal Voice is strictly progressive enhancement, never a dependency.** iOS-only, no Android equivalent, and an undiagnosable failure path (`.denied` on unsupported devices, with no deep link to the toggle). Anything that stops working when Personal Voice is unavailable is a bug. Also guard `synthesizeToFile` with `voiceTraits.contains(.isPersonalVoice)` — with a Personal Voice it does not fail, it **speaks aloud while writing a silent file**.

**Warm-up fails silently; `speak()` fails loudly.** Those are opposite error policies on the same service and the asymmetry is deliberate. A failed warm-up costs latency; a failed `speak()` costs the user their voice and must surface as full-screen text.

## Right vs wrong

```dart
// WRONG — a fake mutated a fake. Green while Kotlin reads nothing.
test('edit republishes', () async {
  SharedPreferences.setMockInitialValues({});
  await repo.setSlotButton(0, 0, id);
  expect((await SharedPreferences.getInstance()).getString('phrase'), 'Hi');
});
```
```dart
// RIGHT — integration_test: write from Dart, read back through the real native path.
testWidgets('mirror round-trips through native', (tester) async { ... });
```

```kotlin
// WRONG — logic in the SystemUI-lifecycled class. Untestable anywhere.
override fun onClick() {
  val json = File(...).readText()
  val phrase = JSONObject(json).getString("vocalization")
  TextToSpeech(this) { ... }.speak(phrase, QUEUE_FLUSH, null, null)
}
```
```kotlin
// RIGHT — ~5 lines, delegates immediately. QuickTileSpeaker is plain-JUnit testable.
override fun onClick() = speaker.speakStoredPhrase()
```

```dart
// WRONG — the mirror silently rots; the tile speaks a retracted phrase forever.
Future<void> clearSlot(int row, int col) => _db.clearSlot(row, col);
```
```dart
// RIGHT — the mirror is part of the write, not a follow-up someone remembers.
Future<void> clearSlot(int row, int col) async {
  await _db.clearSlot(row, col);
  await _tileBridge.publish(null);
}
```

## Before finishing native work, confirm

- The speak path touches no Dart, no isolate, no engine, no DB open, no migration.
- Both contract owners changed together, or neither did.
- Every write path that can change a mirrored phrase — save, clear, delete, reorder, import — republishes.
- Kotlin logic sits in a plain class with JUnit tests; the `TileService` subclass is a delegate.
- The invariant that only a device can prove has a manual-checklist step written for it.
- No `MethodChannel` was born outside `lib/native/`.
