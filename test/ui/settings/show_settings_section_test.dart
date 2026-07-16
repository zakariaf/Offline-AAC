import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/settings/show_settings_section.dart';
import 'package:offline_aac/ui/strings.dart';

/// The three show-mode controls reflect the current settings. The write paths
/// (setShowPolarity writes 'matchTheme', an empty standing line is honoured) are
/// proven at the repository level; this holds that the controls DISPLAY the
/// stored state, and that their labels are the authored literals, unlowered.
void main() {
  Future<void> pumpSection(WidgetTester tester, ReedSettings settings) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          initialSettingsProvider.overrideWithValue(settings),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ShowSettingsSection()),
        ),
      ),
    );
  }

  testWidgets('the controls show the default settings', (tester) async {
    await pumpSection(tester, const ReedSettings.defaults());

    expect(find.text(showScreenSettingLabel), findsOneWidget);
    // The standing-line field is pre-filled with the default sentence.
    expect(find.widgetWithText(TextField, defaultStandingLine), findsOneWidget);
    // The standing-line toggle is on by default, stated in a non-colour label.
    expect(find.text('$standingLineSettingLabel: on'), findsOneWidget);
    // Bright is the selected segment.
    expect(
      tester.widget<SegmentedButton<ShowPolarity>>(
        find.byType(SegmentedButton<ShowPolarity>),
      ).selected,
      <ShowPolarity>{ShowPolarity.bright},
    );
  });

  testWidgets('an empty standing line shows an empty field, not the default', (
    tester,
  ) async {
    await pumpSection(
      tester,
      const ReedSettings.defaults().copyWith(standingLineText: ''),
    );
    expect(find.text(defaultStandingLine), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
  });

  testWidgets('matchTheme and a disabled line are reflected', (tester) async {
    await pumpSection(
      tester,
      const ReedSettings.defaults().copyWith(
        showPolarity: ShowPolarity.matchTheme,
        standingLineEnabled: false,
      ),
    );
    expect(
      tester.widget<SegmentedButton<ShowPolarity>>(
        find.byType(SegmentedButton<ShowPolarity>),
      ).selected,
      <ShowPolarity>{ShowPolarity.matchTheme},
    );
    expect(find.text('$standingLineSettingLabel: off'), findsOneWidget);
  });
}
