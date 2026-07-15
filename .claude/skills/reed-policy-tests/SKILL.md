---
name: reed-policy-tests
description: Source-grep policy tests under test/policy/ — the ~10-line greps that fail the suite on a banned string, covering TTS_SERVICE inside <queries>, android:allowBackup="false", package:http/firebase/sentry imports in lib/, pure 0xFFFFFFFF/0xFF000000 outside tokens.dart, AVAudioSessionCategory.playback, and the grid_slots composite primary key. Use when turning a never-do-X rule into an automated check, when adding a project-wide invariant, when a rule's only stated enforcement is code review, or when adding a file under test/policy/.
---

# Policy tests

A policy test greps source or config and fails the suite when a banned string appears. Each is ~10 lines. Each exists because a single line — one attribute, one import, one hex — silently destroys the product, and no analyzer rule, no type, and no widget test can see it.

## What earns a policy test

The bar is all three, or it does not belong here:

| Criterion | Meaning |
|---|---|
| **Textually decidable** | Provable by reading source or config. If it needs a running app, it is a widget or device test. |
| **Silent when broken** | The app builds, the suite is green, and the user finds out by tapping a tile and getting nothing. No telemetry exists; nobody will ever report it. |
| **One line to break** | The failure is a plausible copy-paste, a merge, or a 2am "cleanup" — not a rewrite. |

Everything else is code review. Do not turn taste into a grep: banning `TextOverflow.ellipsis` or a `default:` on a sealed type by string match produces false positives that get the whole directory deleted the first time someone is in a hurry. A policy test that cries wolf is worse than no policy test.

## Layout and invocation

One file per invariant under `test/policy/`, named for what it guards. Shared helpers in `test/policy/policy_support.dart`. These are pure Dart — import `package:test/test.dart`, not `flutter_test` — but run with the rest:

```
flutter test test/policy
```

`flutter test` sets the working directory to the package root, so relative paths (`lib`, `android/app/src/main/AndroidManifest.xml`) resolve. Never build a path from `Platform.script`.

## The support file — comments are the false-positive engine

Every one of these tests searches for a string that is *also* what a developer types when explaining why the string is banned. A grep over raw source fails the moment someone writes `// never use 0xFF000000 here`. Strip comments first, always.

```dart
// test/policy/policy_support.dart
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

Collect **all** offenders and fail once with the list. A test that `expect`s inside the loop reports offender #1 and hides the other four.

## The manifest — the highest-severity file in the repo

```dart
// test/policy/android_manifest_policy_test.dart
import 'dart:io';

import 'package:test/test.dart';

import 'policy_support.dart';

void main() {
  final String xml =
      xmlOf(File('android/app/src/main/AndroidManifest.xml'));

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

  test('auto-backup is disabled', () {
    expect(
      xml,
      contains('android:allowBackup="false"'),
      reason: 'android:allowBackup defaults to TRUE. Left alone, Android '
          'uploads the SQLite database — every vocalization the user has ever '
          'saved, the most intimate content they own — to Google Drive. We '
          'promise no network and no server. Restore is a deliberate, '
          'user-initiated export instead.',
    );
  });

  test('no INTERNET permission', () {
    expect(
      xml,
      isNot(contains('android.permission.INTERNET')),
      reason: 'The privacy promise is the product, and this audience reads '
          'manifests adversarially.',
    );
  });
}
```

Asserting the tag is *inside* `<queries>` and not merely somewhere in the file matters: the same intent string in a stray `<intent-filter>` grants no visibility and would make a whole-file `contains` pass while the app stays silent.

## Banned imports — match the import URI, not the file

Never search whole-file text for `http` — it hits `https://` in a doc comment and every `Uri` in a string. Parse the import lines:

```dart
// test/policy/banned_imports_test.dart
void main() {
  test('lib/ imports nothing that can reach the network or phone home', () {
    const List<String> banned = <String>[
      'package:http/', 'package:dio/', 'package:web_socket_channel/',
      'package:firebase_core/', 'package:firebase_crashlytics/',
      'package:sentry/', 'package:sentry_flutter/',
      'package:posthog_flutter/', 'package:mixpanel_flutter/',
      'package:amplitude_flutter/',
    ];
    final RegExp importUri = RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''',
        multiLine: true);

    final List<String> offenders = <String>[];
    for (final File f in dartFilesIn('lib')) {
      for (final Match m in importUri.allMatches(codeOf(f))) {
        final String uri = m.group(1)!;
        if (banned.any(uri.startsWith)) offenders.add('${f.path}: $uri');
      }
      if (codeOf(f).contains('HttpClient')) offenders.add('${f.path}: HttpClient');
    }

    expect(
      offenders,
      isEmpty,
      reason: 'No network, no server, no analytics — that is the product, not '
          'a preference. A crash reporter is the tempting one: we have no '
          'field signal and it looks like the fix. It is not. The crash log is '
          'on-device and exportable by the user.\n${offenders.join('\n')}',
    );
  });
}
```

`dart:io` is not banned — the database path and the crash-log file need it. `HttpClient` is the one symbol from it that has no legitimate use here, so name the symbol, not the library.

Package bans that are about architecture rather than silence (`provider`, `go_router`, `freezed`, `equatable`, `melos`) belong in a pubspec review, not here: they cannot ship a silent defect, and every entry in this list is a promise the test must keep forever.

## Pure neutrals — line-wise, with one narrow escape hatch

Zero-chroma neutrals are the tell that nobody chose anything. The palette is a warm ramp; the high-contrast theme is the *only* place a pure `#FFF`/`#000` may ever appear, and only because high contrast is a medical accommodation that outranks the look.

```dart
// test/policy/pure_neutral_test.dart
const String _hcTokens = 'lib/ui/core/tokens.dart';

void main() {
  test('no pure-neutral colour outside the high-contrast tokens', () {
    // Alpha FF only. 0x00000000 is fully transparent and is REQUIRED — it is
    // how splashColor/highlightColor kill the ink ripple.
    const List<String> pure = <String>['0XFFFFFFFF', '0XFF000000', '0XFF808080'];

    final List<String> offenders = <String>[];
    for (final File f in dartFilesIn('lib')) {
      final List<String> lines = f.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        // Uppercase: 0xffffffff is the same literal to the compiler.
        final String code =
            line.split('//').first.toUpperCase().replaceAll('_', '');
        if (!pure.any(code.contains)) continue;
        if (f.path.endsWith(_hcTokens) && line.contains('// hc:')) continue;
        offenders.add('${f.path}:${i + 1}  $line');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'The ramp is warm: ground #171411 / ink #DCD9D3 dark, ground '
          '#F4F2EE / ink #27221D light. Pure black on near-white is the '
          'clinical signal; warm-black on warm paper is letterpress, and it '
          'costs nothing legible. Only $_hcTokens may carry a pure neutral, '
          'only with a `// hc:` marker giving the reason.\n'
          '${offenders.join('\n')}',
    );
  });
}
```

Two deliberate details. `replaceAll('_', '')` catches `0xFF_FF_FF_FF`, which Dart accepts and a naive grep misses. The scan is line-wise rather than over `codeOf()` because the failure message must carry a line number — the price is that it does not understand a `/* */` block spanning lines, which is acceptable for a needle this specific.

This test is a backstop, not the boundary. `tokens.dart` is the only file permitted **any** colour literal at all; that separate rule is what keeps this one cheap.

## The audio session

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

State the scope honestly in review and in comments: this proves *our code passes `.playback` to the wrapper*. It is a value-level assertion. Whether `AVAudioSession` actually accepted the category is only knowable on a physical device with the ringer switch off — which is why that check is the first line of the pre-release ritual. The test still pays for itself: the regression it catches is someone editing the value, and that is the way it actually breaks.

## `grid_slots` — position is identity

```dart
// test/policy/grid_slots_schema_test.dart
void main() {
  test('grid_slots keeps its composite primary key and gains no surrogate id',
      () {
    final String tables = codeOf(File('lib/data/database/tables.dart'));
    final Match? body =
        RegExp(r'class GridSlots extends Table \{(.*?)\n\}', dotAll: true)
            .firstMatch(tables);
    expect(body, isNotNull, reason: 'GridSlots is gone or was renamed.');

    const String reason =
        'Position IS identity. A surrogate id plus an order column permits two '
        'rows claiming the same (row, col) and lets a delete reflow the grid. '
        'A tile that MOVES is worse than a tile that is missing: the user '
        'presses the square they always press and says the wrong sentence, '
        'mid-shutdown, out loud. With the composite PK, reflow is not '
        'prevented — it is unrepresentable.';

    expect(body!.group(1), contains('Set<Column> get primaryKey'), reason: reason);
    expect(body.group(1), contains('{boardId, rowIndex, colIndex}'), reason: reason);
    expect(body.group(1), isNot(contains('get id')), reason: reason);
    expect(body.group(1), isNot(contains('autoIncrement')), reason: reason);
  });
}
```

Scoping the match to the `GridSlots` class body is the whole trick — every other table in that file legitimately has `id => integer().autoIncrement()`, so a file-wide search would be permanently red. `autoIncrement()` will not compile beside a `primaryKey` override anyway; this test guards the *other* order of operations, where someone deletes the override first and the compiler goes quiet.

## Adding a new one

1. Check it against the three criteria. Textually decidable, silent when broken, one line to break. Two out of three means code review.
2. New file in `test/policy/`, named for the invariant.
3. Anchor the needle to a **structure** — an import URI, a class body, an XML element, a line — never a bare whole-file `contains`. Read through `codeOf`/`xmlOf` so the rule's own documentation cannot fail the rule.
4. Accumulate offenders; one `expect` at the end with every path and line number.
5. Write the `reason` for a stranger at 2am who is deciding whether to delete this test. Name the consequence to the person using the app, not the rule. "Fails the palette check" gets deleted; "every Android 11+ user gets a board that cannot speak" does not.
6. Put the same argument as a doc comment at the point of temptation — in `tables.dart`, in `tokens.dart`, in the manifest. The person about to break the rule is standing in that file, not in the test directory.
