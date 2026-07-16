import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/show_text/show_text_screen.dart';
import 'package:offline_aac/ui/strings.dart';

import '../../support/fonts.dart';

/// The standing line and the polarity — the two things E06-T03 adds on top of
/// the fitter. This line, not the 140pt type, is what keeps a phone held up at a
/// cashier from reading as *weird*; and the polarity is the escape hatch for a
/// user who cannot take the flash. Both are read from settings here, with the
/// budget and colour consequences the show screen owns.
void main() {
  const phrase = 'I can’t talk right now but I’m okay.';

  Future<void> enterShow(
    WidgetTester tester, {
    ReedSettings? settings,
    AacPalette palette = AacPalette.ink,
    Size logicalSize = const Size(360, 800),
    double dpr = 3,
    double textScale = 1,
  }) async {
    await loadAppFonts();
    tester.view.physicalSize = logicalSize * dpr;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // A fresh key forces a full remount when a test enters show mode twice,
        // so the second pump gets a clean Navigator rather than reusing the one
        // that still has the first show route pushed onto it.
        key: UniqueKey(),
        overrides: <Override>[
          if (settings != null)
            initialSettingsProvider.overrideWithValue(settings),
        ],
        child: MaterialApp(
          theme: aacThemeData(palette),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).push(ShowTextScreen.route(phrase)),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();
  }

  ColoredBox ground(WidgetTester tester) => tester.widget<ColoredBox>(
    find
        .descendant(
          of: find.byType(ShowTextScreen),
          matching: find.byType(ColoredBox),
        )
        .first,
  );

  // The largest fitted size anywhere in the poster. The standing line is exactly
  // 18pt, so the maximum across every span is always the poster's biggest line,
  // whether or not the standing line is present.
  double posterMaxSize(WidgetTester tester) {
    var max = 0.0;
    for (final rt in tester.widgetList<RichText>(
      find.descendant(
        of: find.byType(ShowTextScreen),
        matching: find.byType(RichText),
      ),
    )) {
      void walk(InlineSpan span) {
        if (span is TextSpan) {
          final s = span.style?.fontSize;
          if (s != null && s > max) max = s;
          span.children?.forEach(walk);
        }
      }

      walk(rt.text);
    }
    return max;
  }

  test('the default standing line uses a real apostrophe, U+2019', () {
    expect(defaultStandingLine.contains('’'), isTrue);
    expect(defaultStandingLine.contains("'"), isFalse);
    expect(defaultStandingLine.codeUnits, contains(0x2019));
  });

  testWidgets('default settings render the standing line', (tester) async {
    await enterShow(tester);
    expect(find.text(defaultStandingLine), findsOneWidget);
  });

  testWidgets('disabling the line removes the widget entirely', (tester) async {
    await enterShow(
      tester,
      settings: const ReedSettings.defaults().copyWith(
        standingLineEnabled: false,
      ),
    );
    expect(find.text(defaultStandingLine), findsNothing);
  });

  testWidgets('an empty line builds no widget and no empty text box', (
    tester,
  ) async {
    await enterShow(
      tester,
      settings: const ReedSettings.defaults().copyWith(standingLineText: ''),
    );
    // Not a zero-height SizedBox, not an empty Text: the widget is not built, so
    // the only text in the tree is the poster.
    expect(find.text(''), findsNothing);
    expect(find.text(defaultStandingLine), findsNothing);
  });

  testWidgets('clearing the line hands its height back to the poster', (
    tester,
  ) async {
    // 360x440: a viewport short enough that the standing line's height is the
    // difference between a 3-line and a 4-line poster. This is the assertion
    // that proves the budget is actually returned, not merely that a widget
    // vanished.
    await enterShow(
      tester,
      logicalSize: const Size(360, 440),
      settings: const ReedSettings.defaults(),
    );
    final withLine = posterMaxSize(tester);

    await enterShow(
      tester,
      logicalSize: const Size(360, 440),
      settings: const ReedSettings.defaults().copyWith(standingLineText: ''),
    );
    final withoutLine = posterMaxSize(tester);

    expect(
      withoutLine,
      greaterThan(withLine),
      reason: 'the poster must grow into the space the empty line gave back',
    );
  });

  testWidgets('the standing line is exit surface, not a dead zone', (
    tester,
  ) async {
    await enterShow(tester);
    expect(find.byType(ShowTextScreen), findsOneWidget);
    await tester.tap(find.text(defaultStandingLine));
    await tester.pump();
    expect(find.byType(ShowTextScreen), findsNothing);
  });

  testWidgets('bright keeps the warm ground under a dark palette', (
    tester,
  ) async {
    await enterShow(
      tester,
      settings: const ReedSettings.defaults(),
    );
    final t = AacTheme.of(tester.element(find.byType(ShowTextScreen)));
    expect(ground(tester).color, t.showGround);
  });

  testWidgets('matchTheme uses the palette ground under a dark palette', (
    tester,
  ) async {
    await enterShow(
      tester,
      settings: const ReedSettings.defaults().copyWith(
        showPolarity: ShowPolarity.matchTheme,
      ),
    );
    final t = AacTheme.of(tester.element(find.byType(ShowTextScreen)));
    expect(ground(tester).color, t.ground);
    expect(ground(tester).color, isNot(t.showGround));
  });

  testWidgets('at 200% text scale the standing line holds and nothing overflows', (
    tester,
  ) async {
    await enterShow(tester, textScale: 2);
    expect(find.text(defaultStandingLine), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
