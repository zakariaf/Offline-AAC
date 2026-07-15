---
name: diagnosing-tile-silence
description: The 28 enumerated ways a tile tap yields silence or the wrong phrase — voice_filter, setVoice/speak returning 0, network_required, notInstalled, .ambient vs .playback, PRAGMA foreign_keys, grid_slots.button_id, Quick Settings TileService. Use when a tile did nothing, wiring or reviewing a speech path, or auditing an onTap or catch block. Not for deciding whether a change needs a test or its suite budget — this is what you consult once a tap produced silence.
---

# The silent-failure catalogue

There is no telemetry and never will be. When this app fails in the field nobody finds out: a user in shutdown taps a tile, gets silence, and uninstalls. So the hostile environment must be enumerated a priori; this catalogue **is** that enumeration and it is the spine of the test strategy.

Reason against it as a closed list. When touching any listed mechanism, restore its mitigation. On discovering a 29th way to go silent, add it here **and** to `SpeechEnv` if the app can detect it.

**Tags:** **D** = testable in Dart · **I** = integration only, real device · **M** = manual only · **X** = structurally untestable.

---

## 1. Speech never happens

| # | Failure | Tag | Mitigation and mechanism |
|---|---|---|---|
| 1 | Android 11+ package visibility hides the TTS engine | **D** | Missing `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` → empty voice list, total silence, on **every Android 11+ device**, with only a `Log.d` to show for it. Read the manifest in a Dart policy test and assert the string is present. |
| 2 | No TTS engine installed at all | **D** | Fake returns `[]` → assert a visible fallback appears. |
| 3 | Engine present, zero voices | **D** | Same. |
| 4 | Only `network_required` voices — an offline app plus a network voice equals silence | **D** | Filter in `voice_filter`. Android sends the **STRING** `"1"`/`"0"`. `raw['network_required'] == true` is *always* false (String vs bool), and `"0"` is non-empty so it survives a truthiness check — a naive check **silently inverts the safety property**, in the direction that hurts. |
| 5 | `setVoice` returns 0 | **D** + one channel contract test | The plugin does `Log.d(tag, "Voice name not found: $voice"); result.success(0)`. It is `result.success`, **not** `result.error` — it never throws. Check `== 1` by hand; nothing in the type system does it. |
| 6 | Voice carries the `notInstalled` feature | **D** (filter) / **M** (behaviour) | `setVoice` returns **1 (success)** and synthesis then reports `ERROR_NOT_INSTALLED_YET` *or silently substitutes a different voice*. **The return-value check does not catch this.** Filter on `features.contains('notInstalled')`. Features arrive **TAB-separated**. |
| 7 | Stored voice uninstalled since last launch (Android GCs voice data) | **D** | The **most probable real-world silent failure.** Re-resolve the stored voice id against `voices()` at startup and fall back audibly. |
| 8 | `speak()` returns 0 | **D** | Check `== 1`. |
| 9 | `onTap: () => service.speak(p)` drops the Future | **X** structural | Caught by **no lint**. The arrow closure "returns" the Future, so `discarded_futures` considers it handled — but the target type is `VoidCallback`, so the Future *and its error* hit the floor. This is the most idiomatic way to wire a tile in Flutter. Fix by construction, not by test: a void-returning seam. |
| 10 | Engine reports success, emits no audio | **X** | No hook exists to capture PCM from `AVSpeechSynthesizer` or Android TTS. **Manual, permanently.** This single exclusion is the entire argument for the pre-release checklist. |
| 11 | `.ambient` audio session → the hardware silent switch mutes the app | **M** | flutter_tts's own README example uses `.ambient`. A Dart test can only assert *the code passed `.playback` to the wrapper* — a value-level assertion, not the real `AVAudioSession` category. Verify on a physical iPhone with the ringer switch OFF. |
| 12 | Audio focus denied (call in progress) | **M** | Checklist: incoming call during speech → speech stops; after the call the app still speaks. |
| 13 | Bluetooth yanked mid-utterance | **M** | Checklist. |
| 14 | TTS bind latency reads as silence | **M** | Warm the engine from `addPostFrameCallback`, never awaited. Binder IPC plus voice deserialization run **synchronously on the main thread** inside `OnInitListener`. |

## 2. The wrong thing is spoken

| # | Failure | Tag | Mitigation and mechanism |
|---|---|---|---|
| 15 | Tile speaks its **label** instead of its **vocalization** | **D** | The core board-format semantic, and nothing in the type system distinguishes two `String`s. Assert per tile: screen reader announces "Overwhelmed", the engine receives the sentence. |
| 16 | Stale closure — a fast re-tap speaks the *previous* tile's phrase | **D** | Never capture a `ref.watch` value from `build()` inside an `onTap` closure. Pass `(row, col)`; position is the primary key and cannot go stale. |
| 17 | Tile reflow → muscle memory hits the wrong tile | **D** | `PRIMARY KEY (board_id, row, col)` makes reflow structurally impossible. Pin it with a test anyway. |
| 18 | Quick Settings tile speaks a phrase deleted months ago | **I only** | See "The Quick Settings hole" below. |

## 3. The board is gone

Hand-curated boards are irreplaceable and unmergeable — months of someone's phrases, their voice. Everything here is a total loss, silently.

| # | Failure | Tag | Mitigation and mechanism |
|---|---|---|---|
| 19 | A migration produces the right schema and drops every row | **D** | `migrateAndValidate` extracts `CREATE` statements from `sqlite_schema` and compares them to a reference from `Migrator.createAll`. It is a **SHAPE comparison — it never looks at rows.** A migration that rebuilds `grid_slots` perfectly and copies zero rows passes green. Write rows at v1 through era-correct generated classes, read them back at v2, assert the phrases. |
| 20 | User skipped six months of updates: v1→v3 never tested | **D** | Nested loop over every (from, to) pair, ~10 lines. |
| 21 | Schema changed without bumping `schemaVersion` → no migration runs | **CI** | `schema dump` + `git diff --exit-code` over the committed schema dir. This loses boards without touching a line of migration code. |
| 22 | SQLite foreign keys are **OFF by default and are per-connection** | **D** | `grid_slots.button_id` is a nullable FK whose entire purpose is `onDelete: KeyAction.setNull`. With FKs off, SQLite **silently ignores the action** → dangling `button_id` → a blank-or-crashing tile. Assert `PRAGMA foreign_keys` returns `1` on the real database object, and pair it with a behavioural delete test. |
| 23 | Absolute image path dies on iOS reinstall/restore (the container UUID changes) | **D** | Store paths **relative** to the app documents dir. |
| 24 | A 12MP photo × 12 tiles → OOM kill on a 2GB phone | **D** | Downscale **at import**, ≤512px. An OOM is permanently invisible without telemetry. |

## 4. The failure exists but is not surfaced

| # | Failure | Tag | Mitigation and mechanism |
|---|---|---|---|
| 25 | Error caught and swallowed | **D** | The parameterized silence test below is the gate. |
| 26 | Crash log throws inside the error handler → recursion | **D** | Test that an error inside the logger does not re-enter the logger. |
| 27 | Crash log buffered, not flushed → the startup crash you needed is exactly the one lost | **D** | Write synchronously with `flush: true`. |
| 28 | Crash log leaks the user's vocalizations to whoever they email it to | **D** | The log is user-exportable and `record(msg, stack)` will happily capture phrase text. Redact, and test the redaction. |

---

## Migration mechanics that fail silently

`PRAGMA foreign_keys` **is a no-op inside a transaction** — it does not error, it does nothing. Disable FKs *outside* the transaction in `onUpgrade`, run `PRAGMA foreign_key_check` after, and re-enable **unconditionally in `beforeOpen`**, because the pragma is per-connection and must run on every open. Only seeding belongs inside `if (details.wasCreated)`.

Build the test database as the **real** `AppDatabase` over `NativeDatabase.memory()` so `beforeOpen` — and therefore FK enforcement — applies; a bare connection skips it and lets FK-violating code pass green. Pass `closeStreamsSynchronously: true`: drift keeps an unsubscribed query stream open for one event-loop iteration, which never arrives under a widget test's FakeAsync clock, leaving pending timers that leak into the next test.

**The thing that beats every migration test** is the pre-migration file backup — fifteen lines that cover the migration bug nobody enumerated, which without telemetry is the entire invisible category.

---

## The seam that closes #9

`speakNow` returns `void` **on purpose**. A void-returning seam makes the dropped-Future hole unreachable by construction: the callback never holds a Future, so there is nothing to drop. Do not "fix" it into `Future<void>`.

```dart
void speakNow(String phrase) {
  unawaited(
    _speak(phrase).catchError((Object e, StackTrace s) {
      // _speak is total, but stop() and the log can still throw. An uncaught
      // error here reaches PlatformDispatcher.onError and the user sees
      // nothing — the exact bug this class exists to prevent.
      _log.record('speakNow threw: $e', s);
      _showText(phrase);
    }),
  );
}
```

Inside `_speak`, `await _service.stop()` **before** speaking. A re-tap means "say it again / I need this NOW", so barge-in is required — and it is why speech is not wrapped in a Command whose `if (_running) return` would silently swallow the tap and manufacture the very silence forbidden here. Then switch over the sealed `SpeakOutcome` with **no `default:` and no `case _:`**, so a new `SpeakFailure` variant breaks the build. Every failure resolves identically: log the one-line `logLine`, show `spokenText` on screen.

`speak` is annotated `@useResult` and `unused_result` is promoted to `error`, because exhaustiveness forces a *branch*, not an *action* — `await speak(text);` discarding the outcome otherwise compiles clean. The honest guarantee is "compile-error on new variants + analyzer-error on discarded outcomes", not "silence is impossible". And nothing in the type system detects `setVoice` returning 0: that check is hand-written, and the detection gap is the actual root cause.

---

## The test that gates the whole class

Parameterize over `SpeechEnv.detectable` — every environment the app can actually detect — and assert, for each, that a tile tap yields **speech OR visible text, never neither**, with `tester.takeException()` null so the failure is handled rather than thrown. This is the highest-value test in the app for a structural reason: it is the only test in the suite **unsatisfiable by a code path that fails silently**. Every other test asserts a specific behaviour; this asserts the absence of a whole failure class. Adding a `SpeechEnv` value forces the UI to handle it or the build goes red.

`SpeechEnv.reportedSuccessButSilent` is excluded from `detectable` on purpose — there is no Dart-side signal for it. That exclusion is honest, not a gap to be plastered over with a mock.

Use a hand-written fake, not a mock: `implements` without a `noSuchMethod` superclass means adding a method to `SpeechService` **breaks the build**, and the risk here is *state* ("what happens when the voice vanished / `setVoice` returned 0"), which a fake models naturally.

---

## Do not mock the flutter_tts channel across the suite

`SpeechService` is already the seam — fake that. Channel mocks couple dozens of tests to the plugin's private method-name strings and untyped payloads, so an upgrade breaks them for reasons unrelated to what they assert, and they still prove nothing about audio. Keep exactly **one** contract file pinning the plugin's wire behaviour — that `setVoice` → `0` returns rather than throws, and that `getVoices` hands back `List<Object?>` of `Map<Object?, Object?>` so the naive `.cast<Map<String, String>>()` is a runtime `TypeError`. It is the only upgrade canary available. Call `TestWidgetsFlutterBinding.ensureInitialized()` first — a plain `test()` does not initialize the binding and the file fails to load — and null the mock handler in `tearDown` or handlers leak into later tests.

Parsing rules that keep #4 and #6 dead: iOS **omits** `network_required` entirely (absent means not-required); features are TAB-separated; `getVoices` can return **null** because the plugin catches a NullPointerException and calls `result.success(null)`.

---

## The Quick Settings hole

The QS `TileService` runs with **no Flutter engine** — that is the point, it is the fastest path to speech in the product. It also means **no Flutter test at any level can reach it**, and it is the crisis path. The obvious contract test does not work: `SharedPreferences.setMockInitialValues` is in-memory only, so a test asserting "edit a tile → the pref changed" asserts *a fake mutated a fake*, passing green while the Kotlin read path is broken. Two further landmines: `SharedPreferencesAsync` is backed by Jetpack DataStore, not `FlutterSharedPreferences.xml`, so Kotlin's `getSharedPreferences(...)` reads nothing; and the legacy API prefixes every key with `flutter.`.

Mitigation, all three parts required: own the contract with an explicit **versioned JSON file** written from Dart and read from Kotlin; an `integration_test` round-trip through the *real* native path asserting exact equality; and extract the logic out of `TileService` into a plain Kotlin class (read → validate non-empty → speak) that plain JUnit tests.

---

## Budget

Three integration tests, not a suite. They run on one emulator — zero device diversity — and **the Android emulator ships no TTS engine**, so CI can never verify speech at all.

Four of the highest-severity failures are unreachable by every automated means: `.ambient` muting on the silent switch, the engine reporting success while emitting no audio, the QS tile speaking a stale phrase, and Switch Access focus traps. The manual checklist is the deliberate replacement for tests that cannot exist — not a placeholder for tests not yet written.

---

## Every mitigation here looks like a mistake

A nullable FK inside a composite primary key reads as a normalization error. `.playback` instead of `.ambient` reads as an oversight. Checking a `setVoice` return value reads as paranoia. `speakNow` returning `void` reads as sloppy. A stranger — or the author in six months — will clean up every one, reintroduce the exact failure it prevents, and no test and no crash report will ever say so. Put the reasoning **where the temptation is**: a doc comment on the table definition, on the audio session config, on `speakNow`. The person about to add a surrogate `id` to `grid_slots` is standing in `tables.dart` when they get the idea.
