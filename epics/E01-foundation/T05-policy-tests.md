# E01-T05 — Policy tests

| | |
|---|---|
| **Epic** | E01 — Foundation |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-policy-tests` · `reed-code-bans` · `reed-speech-service`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Six of this app's failure modes are one line each, and every one of them builds clean, analyzes clean, and ships. A missing `<queries>` tag means every Android 11+ user gets an empty voice list and a board that cannot speak — flutter_tts logs a `Log.d` and returns, no exception. `android:allowBackup` defaults to **true**, which uploads the user's phrase database to Google Drive while the listing promises no network. There is no telemetry, so nobody will ever tell us any of this happened. Review is a person on a deadline; a test is not.

## Scope

Build `test/policy/` — one file per invariant, plus a shared support file. These are **pure Dart**: import `package:test/test.dart`, not `flutter_test`. They still run with the rest:

```
flutter test test/policy
```

`flutter test` sets the working directory to the package root, so relative paths (`lib`, `android/app/src/main/AndroidManifest.xml`) resolve. **Never build a path from `Platform.script`.**

### `test/policy/policy_support.dart`

Every needle below is also what a developer types when explaining why the needle is banned. Strip comments before matching, always.

```dart
import 'dart:io';

final RegExp _block = RegExp(r'/\*.*?\*/', dotAll: true);
final RegExp _line = RegExp(r'//[^\n]*');
final RegExp _xml = RegExp(r'<!--.*?-->', dotAll: true);

/// Dart source with comments removed, so a rule's own explanation cannot trip it.
/// Caveat: this also eats `//` inside string literals. Never write a policy test
/// whose needle can legitimately appear inside a URL-shaped string.
String codeOf(File f) =>
    f.readAsStringSync().replaceAll(_block, '').replaceAll(_line, '');

String xmlOf(File f) => f.readAsStringSync().replaceAll(_xml, '');

/// `.g.dart` is excluded: it is drift's output, we do not hand-edit it, and
/// scanning it only invites false positives on code nobody wrote.
Iterable<File> dartFilesIn(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));
```

### `test/policy/android_manifest_policy_test.dart`

Read once via `xmlOf(File('android/app/src/main/AndroidManifest.xml'))`. Three tests:

1. **`TTS_SERVICE` is declared inside `<queries>`.** Match `RegExp(r'<queries>(.*?)</queries>', dotAll: true)` first, assert the match is non-null (`reason: 'No <queries> element at all.'`), then assert `group(1)` `contains('android.intent.action.TTS_SERVICE')`. Asserting it is **inside** `<queries>` and not merely somewhere in the file is the point: the same intent string in a stray `<intent-filter>` grants no package visibility and would make a whole-file `contains` pass while the app stays silent.
2. **`android:allowBackup="false"` is present.** Whole-XML `contains`.
3. **No `android.permission.INTERNET`.** `isNot(contains(...))`.

`reason:` strings are the deliverable here, not decoration — write them for the stranger at 2am deciding whether to delete the test. Name the consequence to the person using the app: "Android 11+ package visibility HIDES the TTS engine without this. flutter_tts then returns an EMPTY voice list and logs a Log.d — no exception, no crash, green tests. Every Android 11+ user gets a board that cannot speak, on every device, and nobody will ever tell us." For backup: Android uploads the SQLite database — every vocalization the user has ever saved — to Google Drive; restore is a deliberate, user-initiated export instead.

### `test/policy/banned_imports_test.dart`

Match the **import URI**, never whole-file text — a bare search for `http` hits `https://` in a doc comment and every `Uri` in a string.

```dart
const List<String> banned = <String>[
  'package:http/', 'package:dio/', 'package:web_socket_channel/',
  'package:firebase_core/', 'package:firebase_crashlytics/',
  'package:sentry/', 'package:sentry_flutter/',
  'package:posthog_flutter/', 'package:mixpanel_flutter/',
  'package:amplitude_flutter/',
];
final RegExp importUri = RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''',
    multiLine: true);
```

Loop `dartFilesIn('lib')`, `banned.any(uri.startsWith)`, accumulate `'${f.path}: $uri'`. Also flag `HttpClient` as a bare symbol in `codeOf(f)`.

`dart:io` is **not** banned — the database path and the crash-log file need it. `HttpClient` is the one symbol from it with no legitimate use here, so name the symbol, not the library.

Explicitly OUT of this list: `provider`, `go_router`, `freezed`, `equatable`, `melos`, `google_fonts`, `dynamic_color`. Those bans are about architecture, not silence; they cannot ship a silent defect, and every entry here is a promise the test must keep forever. They stay a pubspec review item.

### `test/policy/pure_neutral_test.dart`

```dart
const String _hcTokens = 'lib/ui/core/tokens.dart';
// Alpha FF only. 0x00000000 is fully transparent and is REQUIRED — it is
// how splashColor/highlightColor kill the ink ripple.
const List<String> pure = <String>['0XFFFFFFFF', '0XFF000000', '0XFF808080'];
```

Scan **line-wise** over `f.readAsLinesSync()` for every file in `dartFilesIn('lib')`, so the failure carries a line number. Per line: `line.split('//').first.toUpperCase().replaceAll('_', '')`. Uppercasing catches `0xffffffff` (same literal to the compiler); `replaceAll('_', '')` catches `0xFF_FF_FF_FF`, which Dart accepts and a naive grep misses. Escape hatch: skip when `f.path.endsWith(_hcTokens) && line.contains('// hc:')`. Offender format: `'${f.path}:${i + 1}  $line'`.

The `reason` carries the ramp: ground `#171411` / ink `#DCD9D3` dark, ground `#F4F2EE` / ink `#27221D` light. Only `lib/ui/core/tokens.dart` may carry a pure neutral, only with a `// hc:` marker giving the reason — high contrast is a medical accommodation that outranks the look.

Accepted cost: line-wise scanning does not understand a `/* */` block spanning lines. Acceptable for a needle this specific. This test is a backstop, not the boundary — `tokens.dart` being the only file permitted **any** colour literal is the separate rule that keeps this one cheap.

### `test/policy/audio_session_policy_test.dart`

```dart
const String _config = 'lib/data/speech/audio_session_config.dart';
```

Two assertions in one test:

1. `codeOf(File(_config))` `contains('AVAudioSessionCategory.playback')`.
2. Over `dartFilesIn('lib')`: flag any file containing `AVAudioSessionCategory.ambient`; flag any file **other than** `_config` containing `AudioSessionConfiguration`.

Reason: `.ambient` obeys the hardware silent switch — the app goes MUTE while every test and every log says it spoke. `flutter_tts`'s own README example uses `.ambient`, so it is exactly what a copy-paste introduces.

State the scope honestly in the test's own comment: this proves *our code passes `.playback` to the wrapper*. It is a value-level assertion. Whether `AVAudioSession` accepted the category is only knowable on a physical device with the ringer switch off. The test still pays for itself — the regression it catches is someone editing the value, which is how it actually breaks.

### `test/policy/grid_slots_schema_test.dart`

Read `lib/data/database/tables.dart` through `codeOf`. Scope the match to the class body — this is the whole trick, because every other table in that file legitimately has `id => integer().autoIncrement()` and a file-wide search would be permanently red:

```dart
final Match? body =
    RegExp(r'class GridSlots extends Table \{(.*?)\n\}', dotAll: true)
        .firstMatch(tables);
expect(body, isNotNull, reason: 'GridSlots is gone or was renamed.');
expect(body!.group(1), contains('Set<Column> get primaryKey'), reason: reason);
expect(body.group(1), contains('{boardId, rowIndex, colIndex}'), reason: reason);
expect(body.group(1), isNot(contains('get id')), reason: reason);
expect(body.group(1), isNot(contains('autoIncrement')), reason: reason);
```

Reason: position IS identity. A surrogate id plus an order column permits two rows claiming the same (row, col) and lets a delete reflow the grid. A tile that MOVES is worse than a tile that is missing — the user presses the square they always press and says the wrong sentence, mid-shutdown, out loud. With the composite PK, reflow is not prevented, it is unrepresentable.

### Also do

Put the same argument as a doc comment **at the point of temptation** — in `tables.dart`, in `tokens.dart`, in the manifest, in `audio_session_config.dart`. The person about to break the rule is standing in that file, not in `test/policy/`.

### Out of scope

- Anything needing a running app: motion (`hasScheduledFrame == false` after one `pump()`), contrast matrix, tap targets. Those are widget tests.
- The `pumpAndSettle` grep over `test/` and the `withClampedTextScaling` / `textScaleFactor` grep over `lib/` — they belong with the testing tasks that own those matrices.
- Taste greps. Do **not** add a policy test banning `TextOverflow.ellipsis` or `default:` on a sealed type by string match. Both are review items; string matching them produces false positives that get the whole directory deleted the first time someone is in a hurry.

## Acceptance criteria

- [ ] `flutter test test/policy` passes on a clean tree.
- [ ] Deleting the `<queries>` block from `AndroidManifest.xml` fails `android_manifest_policy_test.dart`; moving `android.intent.action.TTS_SERVICE` into an `<intent-filter>` outside `<queries>` **also** fails it.
- [ ] Changing `android:allowBackup` to `"true"`, or removing the attribute, fails the suite.
- [ ] Adding `<uses-permission android:name="android.permission.INTERNET"/>` fails the suite.
- [ ] Adding `import 'package:sentry_flutter/sentry_flutter.dart';` to any file in `lib/` fails `banned_imports_test.dart` with that file's path in the message.
- [ ] Writing `// never use package:http here` in a `lib/` file does **not** fail anything.
- [ ] `Color(0xFF_FF_FF_FF)` and `Color(0xffffffff)` in `lib/ui/` both fail `pure_neutral_test.dart`, and the message names the file and 1-indexed line.
- [ ] `Color(0x00000000)` anywhere in `lib/` passes.
- [ ] A pure neutral in `lib/ui/core/tokens.dart` on a line carrying `// hc:` passes; the same line without the marker fails.
- [ ] Changing `.playback` to `.ambient` in `lib/data/speech/audio_session_config.dart` fails `audio_session_policy_test.dart` on both assertions.
- [ ] Constructing an `AudioSessionConfiguration` in any file other than `lib/data/speech/audio_session_config.dart` fails the suite.
- [ ] Adding `IntColumn get id => integer().autoIncrement();` to `GridSlots` fails `grid_slots_schema_test.dart`; the same line in any other table in `tables.dart` passes.
- [ ] Deleting the `Set<Column> get primaryKey` override from `GridSlots` fails.
- [ ] Every failing test names **all** offenders, not just the first — verified by breaking two files at once and reading one message with both paths.
- [ ] Every `reason:` names the consequence to the person using the app, not the rule that was broken.

## Traps

- **The rule's own documentation fails the rule.** Every needle here is a string a developer types while explaining the ban. `// never use 0xFF000000` in `tokens.dart` reds the suite; the fix is `codeOf`/`xmlOf`, not deleting the comment. Route every read through the support file.
- **`expect` inside the loop.** Reports offender #1 and hides the other four. Accumulate into a `List<String>`, one `expect(offenders, isEmpty)` at the end with every path and line number in the `reason`.
- **Whole-file `contains('android.intent.action.TTS_SERVICE')`.** Passes when the intent sits in an `<intent-filter>` instead of `<queries>`, which grants zero package visibility. The test goes green and every Android 11+ device is silent. Anchor to the `<queries>` element.
- **Grepping whole-file text for `http`.** Hits `https://` in doc comments and every `Uri` in a string. Match the import URI with the `^\s*import\s+['"]([^'"]+)['"]` regex and `startsWith` on `package:http/` — with the trailing slash, or `package:http_parser` gets caught too.
- **`codeOf` also strips `//` inside string literals.** Never add a policy test whose needle can legitimately appear inside a URL-shaped string.
- **A file-wide search for `autoIncrement`.** Permanently red, because other tables use it legitimately. Scope the regex to the `GridSlots` class body. And note what this test actually guards: `autoIncrement()` will not compile beside a `primaryKey` override, so the real defended order is someone deleting the override *first*, at which point the compiler goes quiet.
- **Scanning `.g.dart`.** Drift's output is not hand-edited; matching it produces failures against code nobody wrote and nobody can fix. `dartFilesIn` already excludes it — do not "simplify" that filter away.
- **`0x00000000` swept up with the pure neutrals.** It is fully transparent and **required** — it is how `splashColor`/`highlightColor` kill the ink ripple. Alpha `FF` only, which is why the needles are the four-byte literals and not `FFFFFF`.
- **Lowercase and underscored hex.** `0xffffffff` and `0xFF_FF_FF_FF` are the same literal to the compiler. Uppercase and strip `_` before matching or both walk through.
- **`Platform.script`-derived paths.** They break under `flutter test`'s working directory. Use relative paths from the package root.
- **Over-claiming the audio test.** It asserts a value in our source, not that `AVAudioSession` accepted the category. Anyone who believes it proves the silent switch is handled skips the physical-device check with the ringer off, which is the only real verification.
- **Deleting a policy test to make a build green.** Every one of these is the *only* enforcement available for its rule — no lint can do any of this. If a needle fires, the code is wrong, not the test.
- **A policy test that cries wolf is worse than no policy test.** Two out of three criteria — textually decidable, silent when broken, one line to break — means it is a code review item. Do not grow this directory with taste.

## Files

Creates:

- `test/policy/policy_support.dart`
- `test/policy/android_manifest_policy_test.dart`
- `test/policy/banned_imports_test.dart`
- `test/policy/pure_neutral_test.dart`
- `test/policy/audio_session_policy_test.dart`
- `test/policy/grid_slots_schema_test.dart`

Changes (doc comments at the point of temptation only, no behaviour):

- `android/app/src/main/AndroidManifest.xml`
- `lib/ui/core/tokens.dart`
- `lib/data/database/tables.dart`
- `lib/data/speech/audio_session_config.dart`

## Done when

`flutter test test/policy` is green, and each of the six invariants has been broken by hand in a scratch commit and observed to turn the suite red with a message that names the file, the line, and what it costs the user.
