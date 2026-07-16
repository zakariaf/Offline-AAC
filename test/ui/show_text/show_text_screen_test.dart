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
import '../../support/harness.dart';

/// The show screen: the surface the user is not looking at. These tests hold the
/// two things that matter — the stranger can read it (warm light regardless of
/// palette, no chrome, no clip) and the user can leave it without looking (any
/// pixel exits, one frame, no animation).
void main() {
  const phrase = 'I can’t talk right now but I’m okay.';

  Future<void> enterShow(
    WidgetTester tester, {
    String says = phrase,
    AacPalette palette = AacPalette.ink,
    ReedSettings? settings,
    double textScale = 1,
  }) async {
    await loadAppFonts();
    tester.useDevice(Device.small);
    await tester.pumpWidget(
      ProviderScope(
        // A fresh key remounts cleanly when a test enters show mode more than
        // once, so a later pump gets a new Navigator rather than one that still
        // has an earlier show route pushed.
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
                      Navigator.of(context).push(ShowTextScreen.route(says)),
                  child: const Text('open show'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open show'));
    // The push builds on the next frame; the route itself is zero-duration, so
    // this settles it — never pumpAndSettle, which would mask an animation.
    await tester.pump();
    await tester.pump();
  }

  AacTheme themeOf(WidgetTester tester) =>
      AacTheme.of(tester.element(find.byType(ShowTextScreen)));

  ColoredBox ground(WidgetTester tester) => tester.widget<ColoredBox>(
    find
        .descendant(
          of: find.byType(ShowTextScreen),
          matching: find.byType(ColoredBox),
        )
        .first,
  );

  // With the standing line off, the poster's RichText is the only one in the
  // tree, so it can be targeted without ambiguity.
  final noStanding = const ReedSettings.defaults().copyWith(
    standingLineEnabled: false,
  );

  testWidgets('under the ink palette the poster is warm-light, not dark', (
    tester,
  ) async {
    await enterShow(tester, settings: noStanding);
    final t = themeOf(tester);

    expect(
      ground(tester).color,
      t.showGround,
      reason: 'the poster must be #FFFCF7 even when the app palette is dark',
    );

    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ShowTextScreen),
        matching: find.byType(RichText),
      ),
    );
    final ink = _firstInk(richText.text);
    expect(ink, t.showInk, reason: 'the type is warm ink, not the dark palette');
    expect(ink, isNot(t.ink));
  });

  testWidgets('a tap on any pixel exits — corners, standing line, and type', (
    tester,
  ) async {
    const size = Device.small;
    final points = <Offset>[
      const Offset(6, 6),
      Offset(size.width - 6, 6),
      Offset(6, size.height - 6),
      Offset(size.width - 6, size.height - 6),
      Offset(size.width / 2, 40), // over the standing line
      Offset(size.width / 2, size.height / 2), // over the type
    ];

    for (final point in points) {
      await enterShow(tester);
      expect(find.byType(ShowTextScreen), findsOneWidget);
      await tester.tapAt(point);
      await tester.pump();
      expect(
        find.byType(ShowTextScreen),
        findsNothing,
        reason: 'a tap at $point did not exit — that pixel is a dead zone',
      );
    }
  });

  testWidgets('entering schedules no animation frame', (tester) async {
    await enterShow(tester);
    expect(
      tester.binding.hasScheduledFrame,
      isFalse,
      reason: 'the flash is a frame, not a transition — nothing may animate',
    );
  });

  testWidgets('the exit target is a labelled dismiss button', (tester) async {
    await enterShow(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel(showDismissLabel)),
      isSemantics(isButton: true, label: showDismissLabel),
    );
  });

  testWidgets('all four palettes render the SAME warm-light poster', (
    tester,
  ) async {
    // What the four-palette golden was for: polarity is forced, so the poster is
    // #FFFCF7 under every palette, not just the light ones. Read from the theme,
    // never a literal — the CI contrast gate walks these fields per palette.
    for (final palette in AacPalette.values) {
      await enterShow(tester, palette: palette, settings: noStanding);
      final t = themeOf(tester);
      expect(
        ground(tester).color,
        t.showGround,
        reason: 'under $palette the poster must still be the bright ground',
      );
    }
  });

  testWidgets('there is no chrome of any kind', (tester) async {
    await enterShow(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('system back still pops the route', (tester) async {
    await enterShow(tester);
    expect(find.byType(ShowTextScreen), findsOneWidget);
    // Nothing blocks the back gesture — no PopScope(canPop: false).
    final popped = await tester.binding.handlePopRoute();
    await tester.pump();
    expect(popped, isTrue);
    expect(find.byType(ShowTextScreen), findsNothing);
  });

  testWidgets('a paragraph too long to seat degrades to a 32pt scroll', (
    tester,
  ) async {
    const paragraph =
        'There is a great deal I would like to say to you right now and none '
        'of the words are arriving in the order that I need them to arrive in '
        'so please bear with me for a little while longer than usual today.';
    await enterShow(tester, says: paragraph, settings: noStanding);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ShowTextScreen),
        matching: find.byType(RichText),
      ),
    );
    expect(
      (richText.text as TextSpan).style?.fontSize,
      AacType.showSizeMin,
      reason: 'the degraded block is uniform 32pt',
    );
  });
}

/// The colour of the first text-bearing span, walking through the wrapper span
/// that `Text.rich` inserts for the ambient default style.
Color? _firstInk(InlineSpan span) {
  if (span is TextSpan) {
    if ((span.text?.isNotEmpty ?? false) && span.style?.color != null) {
      return span.style!.color;
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      final found = _firstInk(child);
      if (found != null) return found;
    }
  }
  return null;
}
