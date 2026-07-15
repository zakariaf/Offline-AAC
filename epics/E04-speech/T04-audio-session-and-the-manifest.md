# E04-T04 — Audio session and the manifest

| | |
|---|---|
| **Epic** | E04 — Speech |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E04-T03 |
| **Blocks** | E10-T03 |

**Skills:** `reed-speech-service` · `reed-policy-tests` · `reed-manual-checklist`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Two one-line settings decide whether this app makes any sound at all. If the audio session category is `.ambient`, the hardware silent switch mutes the app — a user flips the ringer for a meeting, goes into shutdown in that meeting, taps a tile, and their voice is gone at the exact moment they need it. If `<queries>` does not declare `TTS_SERVICE`, Android 11+ package visibility hides the TTS engine, `flutter_tts` returns an empty voice list with only a `Log.d`, and **every** Android 11+ user has a board that cannot speak. Both build clean, both keep the suite green, and neither will ever be reported — a person who cannot speak does not file a bug.

## Scope

### 1. `lib/data/speech/audio_session_config.dart` — the only file that configures a session

Exactly three properties: **`.playback`** category, **`duckOthers`**, and **`setSharedInstance`**. Never `.ambient`.

This is the one file in `lib/` permitted to name `AudioSessionConfiguration`. Everything else calls into it. The policy test in step 3 enforces both halves of that.

Put the argument in the file, at the point of temptation — not only in the task, not only in the test. The person about to change this value is standing in this file:

```dart
// lib/data/speech/audio_session_config.dart

/// .playback, NOT .ambient. Category .ambient obeys the hardware silent switch:
/// a user flips the ringer for a meeting and the app goes MUTE while every test
/// and every log says it spoke. flutter_tts's own README example uses .ambient,
/// so this reads as an oversight to everyone who has not been bitten, and a
/// copy-paste from the plugin docs reintroduces it in one line.
```

Called from `main()` in the startup order fixed by `reed-speech-service` — after `AppDatabase` open + migration, **before** `runApp(...)`. It is not the post-frame warm-up; do not move it there and do not fold it into `SpeechService.warmUp()`.

### 2. `android/app/src/main/AndroidManifest.xml` — the queries entry

```xml
<!-- Without this, Android 11+ package visibility HIDES the TTS engine.
     flutter_tts returns an empty voice list with only a Log.d. Every Android
     11+ user gets a board that cannot speak, and we will never hear about it. -->
<queries>
  <intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>
</queries>
```

`<queries>` is a direct child of `<manifest>`, a sibling of `<application>` — not inside it, and not an `<intent-filter>`.

### 3. `test/policy/audio_session_policy_test.dart`

Pure Dart (`package:test/test.dart`, not `flutter_test`), reading through `codeOf()` from `test/policy/policy_support.dart` so the file's own explanatory comment cannot trip the grep. One test, two assertions, offenders accumulated and reported once:

```dart
// test/policy/audio_session_policy_test.dart
const String _config = 'lib/data/speech/audio_session_config.dart';

void main() {
  test('the session is .playback, and only one file configures it', () {
    expect(
      codeOf(File(_config)),
      contains('AVAudioSessionCategory.playback'),
      reason: 'Category .ambient obeys the hardware silent switch: the app '
          'goes MUTE while every test and every log says it spoke. '
          "flutter_tts's own README example uses .ambient, so it is exactly "
          'what a copy-paste introduces.',
    );

    final List<String> offenders = <String>[];
    for (final File f in dartFilesIn('lib')) {
      final String code = codeOf(f);
      if (code.contains('AVAudioSessionCategory.ambient')) {
        offenders.add('${f.path}: .ambient');
      }
      if (!f.path.endsWith(_config) &&
          code.contains('AudioSessionConfiguration')) {
        offenders.add('${f.path}: configures a session outside $_config');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
```

State the scope honestly in the test's own comment: this proves *our code passes `.playback` to the wrapper*. It is a value-level assertion, not the real `AVAudioSession` category. It still pays for itself — the regression it catches is someone editing the value, and that is how it actually breaks.

### 4. `test/policy/android_manifest_policy_test.dart` — the `TTS_SERVICE` test

If this file does not exist yet, create it; if it exists, add the test beside the `allowBackup` and INTERNET-permission tests. Read the XML through `xmlOf()`. Scope the assertion to the **inside of `<queries>`**, never a whole-file `contains`:

```dart
final String xml = xmlOf(File('android/app/src/main/AndroidManifest.xml'));

test('TTS_SERVICE is declared inside <queries>', () {
  final Match? queries =
      RegExp(r'<queries>(.*?)</queries>', dotAll: true).firstMatch(xml);

  expect(queries, isNotNull, reason: 'No <queries> element at all.');
  expect(
    queries!.group(1),
    contains('android.intent.action.TTS_SERVICE'),
    reason: 'Android 11+ package visibility HIDES the TTS engine without '
        'this. flutter_tts then returns an EMPTY voice list and logs a '
        'Log.d — no exception, no crash, green tests. Every Android 11+ '
        'user gets a board that cannot speak, on every device, and nobody '
        'will ever tell us.',
  );
});
```

### 5. The manual checklist entries

Neither of these is provable in Dart. Add to the **Audio** section of `CHECKLIST.md` (the tracked copy of `assets/CHECKLIST.md`), which runs first because everything else is cosmetic if the app does not speak:

- [ ] **Ringer switch OFF / silent mode ON for the whole pass**, physical phone, release build. Tap a tile → it speaks. If it goes quiet, the category is `.ambient`.
- [ ] **Music playing → speech ducks it, and the music resumes afterwards.**
- [ ] **Incoming call during speech → speech stops, and the app still speaks after the call ends.** The "still speaks after" half is the one that regresses: a focus request never re-acquired leaves the app permanently mute with no error anywhere.
- [ ] **Voice list is non-empty on an Android 11+ device.** An empty list with the app otherwise healthy is the missing `<queries>` entry.

### Out of scope

- `SpeakOutcome`, the `setVoice`/`speak` return checks, `voice_filter` — E04-T03.
- `SpeechService.warmUp()` and the post-frame startup ordering.
- Bluetooth routing, engine-uninstalled, and airplane-mode checks — other checklist entries, other tasks.
- Any attempt to assert the real OS category from Dart. It does not exist. Do not build a `MethodChannel` mock to fake it.

## Acceptance criteria

- [ ] `flutter test test/policy` passes, and includes both `audio_session_policy_test.dart` and the `TTS_SERVICE is declared inside <queries>` test.
- [ ] `grep -rn "AVAudioSessionCategory.ambient" lib/` returns nothing.
- [ ] `grep -rln "AudioSessionConfiguration" lib/` prints exactly one path: `lib/data/speech/audio_session_config.dart`.
- [ ] `audio_session_config.dart` contains `AVAudioSessionCategory.playback`, `duckOthers`, and `setSharedInstance`.
- [ ] Temporarily changing `.playback` to `.ambient` makes `flutter test test/policy` fail — verify this once, then revert.
- [ ] Temporarily deleting the `<queries>` block makes `flutter test test/policy` fail — verify this once, then revert.
- [ ] Moving the `TTS_SERVICE` action into an `<intent-filter>` outside `<queries>` still fails the test.
- [ ] `CHECKLIST.md` carries the four Audio entries above, in the Audio section.
- [ ] `flutter analyze` is clean.

## Traps

- **Copying the plugin README.** `flutter_tts`'s own example uses `.ambient`. It is the blessed-looking configuration and it ships the worst bug in the product. This is not a hypothetical regression path; it is the documented one.
- **Believing the Dart test.** It asserts a value was passed to a wrapper. It cannot know whether `AVAudioSession` accepted the category. Green here plus a ringer switch off equals silence. The device check is not optional redundancy — it is the only evidence.
- **Whole-file `contains` on the manifest.** The same `TTS_SERVICE` string sitting in a stray `<intent-filter>` grants zero package visibility, and a file-wide `contains` passes while the app stays mute. Anchor to the `<queries>` element.
- **The rule's own comment failing the rule.** The banned needle is exactly what a developer types when explaining why it is banned. `// never use AVAudioSessionCategory.ambient` fails a raw grep. Read through `codeOf()`/`xmlOf()` — always.
- **`expect` inside the offender loop.** It reports offender #1 and hides the rest. Accumulate, then one `expect` at the end with every path.
- **Testing with the ringer on.** Silent mode is the *default state* of a person having a bad day in public. A pass run with the ringer on hides the top-severity bug in the app and tells you nothing.
- **Emulator.** The Android emulator ships no TTS engine. Every check here is about audio. An emulator run and a device-farm run are both worth zero.
- **Configuring the session somewhere convenient.** A second `AudioSessionConfiguration` in `main.dart` or inside `SpeechService` means two categories race and the last writer wins, invisibly. One file, enforced by the policy test.
- **Deleting the "paranoid" `.playback` line during a cleanup.** It reads as an oversight to everyone who has not been bitten. The comment at the point of temptation is what stops the 2am deletion — the test directory is not where that person is standing.
- **Dropping `<queries>` in a manifest merge.** Manifest conflicts get resolved by taking one side wholesale. The policy test is the only thing that notices.

## Files

- `lib/data/speech/audio_session_config.dart` — new.
- `lib/main.dart` — call the config after DB open + migration, before `runApp`.
- `android/app/src/main/AndroidManifest.xml` — add the `<queries>` block with the comment.
- `test/policy/audio_session_policy_test.dart` — new.
- `test/policy/android_manifest_policy_test.dart` — new or extended with the `TTS_SERVICE` test.
- `test/policy/policy_support.dart` — used, not changed (unless `codeOf`/`xmlOf`/`dartFilesIn` do not exist yet).
- `CHECKLIST.md` and `assets/CHECKLIST.md` — four Audio entries.

## Done when

`.playback` + `duckOthers` + `setSharedInstance` are pinned in one file, `TTS_SERVICE` is inside `<queries>`, `flutter test test/policy` fails if either is edited away, and the ringer-off device check is on the Audio section of the checklist.
