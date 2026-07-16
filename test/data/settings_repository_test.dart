import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/aac_palette.dart';
import 'package:offline_aac/ui/strings.dart';

/// Settings is the one place a byte on disk becomes app behaviour, and disk is
/// where corruption, truncation, and a previous version's format all live. Every
/// test here asks the same question: does a bad value land somewhere safe, or
/// does it leave a user without a voice or on a theme they cannot read?
void main() {
  late AppDatabase db;
  late SettingsRepository settings;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(db);
  });
  tearDown(() => db.close());

  test('a database with no settings rows loads the defaults', () async {
    final loaded = await settings.load();
    const d = ReedSettings.defaults();
    expect(loaded.palette, d.palette);
    expect(loaded.pitch, d.pitch);
    expect(loaded.output, d.output);
    expect(loaded.gridSize, d.gridSize);
    expect(loaded.haptics, d.haptics);
    expect(loaded.voiceId, isNull);
  });

  test('setting a value twice upserts, leaving exactly one row', () async {
    await settings.setPitch(1.2);
    await settings.setPitch(1.4);
    final rows = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('pitch'))).get();
    expect(
      rows,
      hasLength(1),
      reason: 'a second write must update the row, not add one or throw',
    );
    expect((await settings.load()).pitch, closeTo(1.4, 1e-9));
  });

  test('an enum stores its NAME, not its index', () async {
    await settings.setPalette(AacPalette.paper);
    final row = await (db.select(
      db.settings,
    )..where((s) => s.key.equals('theme'))).getSingle();
    // Assert the raw column, not the round trip. Round-tripping an index would
    // pass and still repoint every install the next time the enum is reordered.
    expect(
      row.value,
      equals('paper'),
      reason: 'the literal name must be on disk, never "0"',
    );
  });

  group('garbage stored values fall back and never throw', () {
    // One case per keyed preference. The stored value is written raw, bypassing
    // the typed setters, to model exactly what a corrupt file contains.
    Future<ReedSettings> withRaw(String key, String value) async {
      await db
          .into(db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: key, value: value),
          );
      return settings.load();
    }

    test('empty theme -> default', () async {
      expect((await withRaw('theme', '')).palette, AacPalette.ink);
    });
    test('trailing-space theme is not a match -> default', () async {
      expect((await withRaw('theme', 'ink ')).palette, AacPalette.ink);
    });
    test('non-numeric pitch -> default', () async {
      expect((await withRaw('pitch', 'NaN')).pitch, kDefaultPitch);
    });
    test('out-of-range pitch is clamped, not accepted', () async {
      final loaded = await withRaw('pitch', '99999');
      expect(
        loaded.pitch,
        kMaxPitch,
        reason:
            '99999 must clamp to the synthesizer max, never reach it: a '
            'pitch the engine rejects is silence',
      );
    });
    test('unknown output mode -> default', () async {
      expect((await withRaw('output_mode', '2')).output, OutputMode.speak);
    });
    test('unknown grid size -> default', () async {
      expect((await withRaw('grid_size', 'jumbo')).gridSize, GridSize.phone);
    });
    test('non-bool haptics -> default', () async {
      expect((await withRaw('haptics', 'maybe')).haptics, isTrue);
    });
  });

  test('watch emits the new settings when a value changes', () async {
    final seen = <AacPalette>[];
    final sub = settings.watch().listen((s) => seen.add(s.palette));
    await Future<void>.delayed(Duration.zero);
    await settings.setPalette(AacPalette.paper);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(
      seen.last,
      AacPalette.paper,
      reason: 'the theme switcher writes here and the app must follow',
    );
  });

  group('the standing line, and absent-vs-empty', () {
    test('a missing row resolves to the default sentence', () async {
      expect((await settings.load()).standingLineText, defaultStandingLine);
    });

    test('a present empty row is honoured as empty, not re-defaulted', () async {
      // The one that a `?? defaultStandingLine` on the parsed value gets wrong:
      // clearing the line is a deliberate choice, and the app must not silently
      // put the sentence back.
      await settings.setStandingLineText('');
      expect(
        (await settings.load()).standingLineText,
        isEmpty,
        reason: 'absent means "never chose"; empty means "chose nothing"',
      );
    });

    test('the text is stored verbatim — no trim, no transform', () async {
      const messy = '  Give me A Minute…  ';
      await settings.setStandingLineText(messy);
      expect((await settings.load()).standingLineText, messy);
    });

    test('enabled defaults on, and a garbage value falls back to on', () async {
      expect((await settings.load()).standingLineEnabled, isTrue);
      await db.into(db.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(key: 'standing_line_enabled', value: 'nope'),
      );
      expect((await settings.load()).standingLineEnabled, isTrue);
    });

    test('disabling writes the literal false and reads back false', () async {
      await settings.setStandingLineEnabled(enabled: false);
      expect((await settings.load()).standingLineEnabled, isFalse);
    });
  });

  group('output mode', () {
    test('defaults to speak on a file that has never been written', () async {
      expect((await settings.load()).output, OutputMode.speak);
    });

    test('round-trips through a fresh repository over the same file', () async {
      await settings.setOutputMode(OutputMode.both);
      // Reconstruct the repository over the same db — the value is on disk.
      final reloaded = await SettingsRepository(db).load();
      expect(reloaded.output, OutputMode.both);
    });

    for (final garbage in <String>['', 'Speak ', 'silent', '2']) {
      test('garbage "$garbage" falls back to speak', () async {
        await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'output_mode', value: garbage),
        );
        expect((await settings.load()).output, OutputMode.speak);
      });
    }
  });

  group('low stimulus', () {
    test('defaults to false on a fresh database', () async {
      expect((await settings.load()).lowStimulus, isFalse);
    });

    test('setLowStimulus(true) stores the literal string "true"', () async {
      await settings.setLowStimulus(enabled: true);
      final row = await (db.select(
        db.settings,
      )..where((s) => s.key.equals('low_stimulus'))).getSingle();
      expect(row.value, 'true');
      expect((await settings.load()).lowStimulus, isTrue);
    });

    for (final garbage in <String>['', 'True ', '1', 'yes']) {
      test('a garbage value "$garbage" falls back to false', () async {
        await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'low_stimulus', value: garbage),
        );
        expect((await settings.load()).lowStimulus, isFalse);
      });
    }

    test('toggling it never writes theme or grid_size', () async {
      // The mode DERIVES; it must not clobber the preferences it overrides.
      await settings.setGridSize(GridSize.large);
      await settings.setPalette(AacPalette.paper);
      final gridBefore = await _raw(db, 'grid_size');
      final themeBefore = await _raw(db, 'theme');

      await settings.setLowStimulus(enabled: true);
      await settings.setLowStimulus(enabled: false);

      expect(await _raw(db, 'grid_size'), gridBefore);
      expect(await _raw(db, 'theme'), themeBefore);
    });
  });

  group('high-contrast polarity', () {
    test('defaults to hcInk', () async {
      expect((await settings.load()).hcPolarity, AacPalette.hcInk);
    });

    test('setHcPolarity writes the literal name and round-trips', () async {
      await settings.setHcPolarity(AacPalette.hcPaper);
      final row = await (db.select(
        db.settings,
      )..where((s) => s.key.equals('hc_polarity'))).getSingle();
      expect(row.value, 'hcPaper');
      expect((await settings.load()).hcPolarity, AacPalette.hcPaper);
    });

    for (final garbage in <String>['', 'ink', 'paper', 'hcpaper']) {
      test('a non-HC value "$garbage" falls back to hcInk', () async {
        await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'hc_polarity', value: garbage),
        );
        expect((await settings.load()).hcPolarity, AacPalette.hcInk);
      });
    }
  });

  group('the show polarity', () {
    test('defaults to bright', () async {
      expect((await settings.load()).showPolarity, ShowPolarity.bright);
    });

    for (final garbage in <String>['', '2', 'Bright ', 'matchtheme']) {
      test('garbage "$garbage" falls back to bright and never throws', () async {
        await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: 'show_polarity', value: garbage),
        );
        expect((await settings.load()).showPolarity, ShowPolarity.bright);
      });
    }

    test('setShowPolarity writes the literal name "matchTheme"', () async {
      await settings.setShowPolarity(ShowPolarity.matchTheme);
      final row = await (db.select(
        db.settings,
      )..where((s) => s.key.equals('show_polarity'))).getSingle();
      // Assert the raw column, not the round trip: a stored index would pass a
      // round trip and repoint on the next enum reorder.
      expect(row.value, 'matchTheme');
      expect((await settings.load()).showPolarity, ShowPolarity.matchTheme);
    });
  });
}

/// The raw stored string for a key, or null if absent — for asserting the
/// on-disk value directly rather than a round trip.
Future<String?> _raw(AppDatabase db, String key) async {
  final row = await (db.select(
    db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull();
  return row?.value;
}
