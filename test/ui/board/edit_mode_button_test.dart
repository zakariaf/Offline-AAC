import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/board/edit_mode_button.dart';
import 'package:offline_aac/ui/strings.dart';

import '../../support/harness.dart';

/// The visible toggle. Every other AAC board hides editing behind a long-press
/// that collides with dwell input and is unreachable by switch and screen-reader
/// users; this is a labelled, focusable button whose announcement changes with
/// the mode it puts you in.
void main() {
  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));

  testWidgets('tapping flips edit mode false -> true -> false', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    final container = containerOf(tester);

    expect(container.read(boardControllerProvider).editing, isFalse);

    await tester.tap(find.byType(EditModeButton));
    await tester.pump();
    expect(container.read(boardControllerProvider).editing, isTrue);

    await tester.tap(find.byType(EditModeButton));
    await tester.pump();
    expect(container.read(boardControllerProvider).editing, isFalse);
  });

  testWidgets('the label states the mode the tap puts you in', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();

    expect(
      tester.getSemantics(find.byType(EditModeButton)),
      isSemantics(isButton: true, label: editBoardLabel),
      reason: 'a fixed label lies to a screen reader about what the tap does',
    );

    await tester.tap(find.byType(EditModeButton));
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(EditModeButton)),
      isSemantics(isButton: true, label: doneEditingLabel),
    );
  });

  testWidgets('a tap schedules no animation frame', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();

    await tester.tap(find.byType(EditModeButton));
    await tester.pump();

    expect(
      tester.binding.hasScheduledFrame,
      isFalse,
      reason: 'entering edit mode is a state change, not a transition',
    );
  });

  testWidgets('both modes render at 200% text scale with no overflow', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(textScale: 2);
    expect(tester.takeException(), isNull);

    await tester.pumpApp(textScale: 2, editing: true);
    expect(tester.takeException(), isNull);
  });
}
