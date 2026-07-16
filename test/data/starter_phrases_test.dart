import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/app_database.dart';
import 'package:offline_aac/data/seed/starter_phrases.dart';
import 'package:offline_aac/model/stock.dart';

/// The starter set is the board a stranger meets on first launch, and the
/// content IS the product here. These assertions guard the two things that make
/// pre-filling someone's voice defensible: the phrases obey the rules the tile
/// and the utterance depend on, and every one carries visible provenance.
void main() {
  group('the list itself', () {
    test('has exactly twelve entries', () {
      expect(kStarterPhrases, hasLength(12));
    });

    test('every label fits the 16-character tile cap', () {
      for (final p in kStarterPhrases) {
        // characters, not code units: an emoji or accented letter must count as
        // one, or the cap lies about what fits.
        expect(
          p.label.runes.length,
          lessThanOrEqualTo(16),
          reason: '"${p.label}" is ${p.label.runes.length} characters',
        );
      }
    });

    test(
      'no label ends with a period; no straight apostrophe or bang anywhere',
      () {
        for (final p in kStarterPhrases) {
          expect(
            p.label.endsWith('.'),
            isFalse,
            reason:
                'a period on a tile handle reads as institutional: '
                '"${p.label}"',
          );
          for (final text in [p.label, p.says]) {
            // U+0027, the typewriter apostrophe. Curly only — the difference is
            // the cheapest craft in the system and its absence is the tell of a
            // database dump.
            expect(
              text.contains("'"),
              isFalse,
              reason: 'straight apostrophe in "$text"',
            );
            // An AAC utterance in caps or with a bang reads as shouting, which is
            // catastrophic when the phrase is "I need a minute".
            expect(
              text.contains('!'),
              isFalse,
              reason: 'exclamation mark in "$text"',
            );
          }
        }
      },
    );

    test('priorities are unique and cover 1..12', () {
      final priorities = kStarterPhrases.map((p) => p.priority).toList();
      expect(priorities.toSet(), hasLength(12), reason: 'a priority repeats');
      expect(
        priorities.toSet(),
        equals({for (var i = 1; i <= 12; i++) i}),
        reason: 'priorities must be exactly 1 through 12',
      );
    });

    test('placements are unique across the 4x3 grid', () {
      final cells = kStarterPhrases.map((p) => '${p.row},${p.col}').toSet();
      expect(cells, hasLength(12), reason: 'two phrases share a cell');
      for (final p in kStarterPhrases) {
        expect(p.row, inInclusiveRange(0, 3));
        expect(p.col, inInclusiveRange(0, 2));
      }
    });

    test('no stock is over-used or lonely', () {
      // A board of one stock is plain; a stock used once reads as an accent
      // rather than a category. Two to four keeps the woven look.
      for (final stock in Stock.values) {
        final count = kStarterPhrases.where((p) => p.stock == stock).length;
        expect(
          count,
          inInclusiveRange(2, 4),
          reason: '${stock.name} appears $count times',
        );
      }
    });
  });

  group('provenance', () {
    test('every phrase is dated and annotated', () {
      for (final p in kStarterPhrases) {
        expect(p.note.trim(), isNotEmpty, reason: '"${p.label}" has no note');
        expect(p.dated, equals('2026-07'), reason: '"${p.label}" is undated');
      }
    });

    test('exactly the three attested phrases are marked attested', () {
      final attested = kStarterPhrases
          .where((p) => p.evidence == Evidence.attested)
          .map((p) => p.label)
          .toSet();
      // These three are the only one-tap phrases part-time AAC users actually
      // reported. Everything else is honestly labelled an assumption.
      expect(attested, equals({'Too loud', 'I need a break', 'I want to go'}));
    });
  });

  group('the repair phrase', () {
    test('is the one and only system phrase, on oxblood, bottom-centre', () {
      final system = kStarterPhrases.where((p) => p.isSystem).toList();
      expect(system, hasLength(1), reason: 'there must be exactly one');
      final repair = system.single;
      expect(repair.label, equals('Wrong one'));
      expect(repair.stock, equals(Stock.oxblood));
      expect(repair.row, equals(3));
      expect(repair.col, equals(1));
    });
  });

  group('seeding a fresh database', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('yields 12 buttons and 12 slots, all filled', () async {
      final buttons = await db.select(db.buttons).get();
      final slots = await db.select(db.gridSlots).get();
      expect(
        buttons,
        hasLength(12),
        reason: 'onCreate did not seed 12 buttons',
      );
      expect(
        slots,
        hasLength(12),
        reason: 'a 4x3 board must hold exactly 12 slot rows',
      );
      expect(
        slots.where((s) => s.buttonId == null),
        isEmpty,
        reason: 'every starter slot is filled; none is empty',
      );
    });

    test('the slot at (3, 1) holds the system phrase', () async {
      final slot = await (db.select(
        db.gridSlots,
      )..where((s) => s.rowIndex.equals(3) & s.colIndex.equals(1))).getSingle();
      expect(slot.buttonId, isNotNull);
      final button = await (db.select(
        db.buttons,
      )..where((b) => b.id.equals(slot.buttonId!))).getSingle();
      expect(
        button.isSystem,
        isTrue,
        reason: 'the repair phrase must sit bottom-centre for the thumb',
      );
      expect(button.label, equals('Wrong one'));
    });

    test('the seed does not re-run when the same file is reopened', () async {
      // onCreate fires once in the life of the FILE, not once per open. A memory
      // DB is a fresh file each time, so this shares one executor across two
      // AppDatabase instances to model reopening the same file.
      final shared = NativeDatabase.memory();
      final first = AppDatabase.forTesting(shared);
      await first.select(db.buttons).get(); // force onCreate
      final second = AppDatabase.forTesting(shared);
      final buttons = await second.select(second.buttons).get();
      expect(
        buttons,
        hasLength(12),
        reason:
            're-seeding on reopen would double the board and bury the '
            'user under duplicates',
      );
      await first.close();
    });
  });
}
