import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/aac_palette.dart';

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
}
