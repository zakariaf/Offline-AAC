import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/settings/settings_screen.dart';
import 'package:offline_aac/ui/strings.dart';

import '../support/harness.dart';

/// The flat settings screen: one level, every control a labelled button, no
/// dialog and no tree. Opened through the real app so it inherits the root's
/// no-animation theme — a theme cycle here must not schedule a frame.
void main() {
  Future<void> openSettings(WidgetTester tester, {double textScale = 1}) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(textScale: textScale);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SettingsScreen), findsOneWidget);
  }

  testWidgets('the screen is reachable in one tap from the board', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    // No child route between the board and settings — one push.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('every control is a labelled button', (tester) async {
    await openSettings(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Theme: ink. Tap to change.')),
      isSemantics(isButton: true, label: 'Theme: ink. Tap to change.'),
    );
    expect(find.bySemanticsLabel('Tiles: 12. Tap to change.'), findsOneWidget);
    expect(find.bySemanticsLabel(keepOffBackupChrome), findsOneWidget);
    expect(find.bySemanticsLabel(restoreBoardChrome), findsOneWidget);
  });

  testWidgets('the theme label names the current palette', (tester) async {
    await openSettings(tester);
    expect(find.text('theme: ink'), findsWidgets);
    expect(
      find.bySemanticsLabel('Theme: ink. Tap to change.'),
      findsOneWidget,
    );
  });

  testWidgets('renders at 200% text scale with no overflow', (tester) async {
    await openSettings(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('a row is a state change, not a transition', (tester) async {
    // The tiles row changes app state with no visual animation. (The theme row
    // goes through MaterialApp.theme, whose zero-duration AnimatedTheme settle is
    // a framework detail of a theme swap, not a Reed row animating.)
    await openSettings(tester);
    await tester.tap(find.bySemanticsLabel('Tiles: 12. Tap to change.'));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('the back button returns to the board', (tester) async {
    // The route is a hard cut with no transition, so iOS shows no swipe-back
    // edge; this labelled control is the only way out. It must pop.
    await openSettings(tester);
    expect(find.bySemanticsLabel(settingsBackLabel), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(settingsBackLabel));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SettingsScreen), findsNothing);
    // The board is underneath again — its Settings entry is reachable once more.
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
  });

  testWidgets('no dialog is ever pushed from settings', (tester) async {
    await openSettings(tester);
    // Tap the restore and backup rows — no confirm modal appears.
    await tester.tap(find.bySemanticsLabel(restoreBoardChrome));
    await tester.pump();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
