import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';

import '../../support/fake_speech_service.dart';
import '../../support/harness.dart';
import '../../support/tiles.dart';

/// The press haptic is gated on the setting, read at press time, and the gate
/// wraps ONLY the pulse — speech is outside it, always. A gate that early-returns
/// past speech turns every tile into a dead rectangle for anyone who turned
/// haptics off: the worst bug in the app.
void main() {
  late List<String> haptics;

  setUp(() {
    haptics = <String>[];
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String? ?? '');
          }
          return null;
        });
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));

  Finder aTile() => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == kByPriority.first.row && w.col == kByPriority.first.col,
  );

  testWidgets('with haptics on, a press fires exactly one selectionClick', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech); // haptics default on

    await tester.tap(aTile());
    await tester.pump(const Duration(milliseconds: 200));

    expect(haptics, <String>['HapticFeedbackType.selectionClick']);
    expect(speech.spoken, isNotEmpty, reason: 'the phrase still speaks');
  });

  testWidgets('with haptics off, a press fires no pulse but still speaks', (
    tester,
  ) async {
    // The silence guard: turning haptics off must NEVER turn off speech.
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);
    container(tester).read(settingsProvider.notifier).setHaptics(enabled: false);
    await tester.pump();

    await tester.tap(aTile());
    await tester.pump(const Duration(milliseconds: 200));

    expect(haptics, isEmpty);
    expect(
      speech.spoken,
      isNotEmpty,
      reason: 'a gate that swallows speech is the worst bug in the app',
    );
  });

  testWidgets('the haptic fires on press-down, the speech on release', (
    tester,
  ) async {
    // The ordering is dispatch order: haptic on contact, speech on the winning
    // tap. Proven through the gesture phases rather than a shared log.
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    final gesture = await tester.startGesture(tester.getCenter(aTile()));
    await tester.pump();
    expect(haptics, <String>['HapticFeedbackType.selectionClick']);
    expect(speech.calls, isEmpty, reason: 'nothing spoken yet on press-down');

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(speech.calls, contains('speak'));
  });

  testWidgets('the haptics setting is read at press time, not build time', (
    tester,
  ) async {
    // Toggle after the board built; the very next tap must obey the new value.
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.tap(aTile());
    await tester.pump(const Duration(milliseconds: 200));
    expect(haptics, hasLength(1));

    container(tester).read(settingsProvider.notifier).setHaptics(enabled: false);
    await tester.pump();
    await tester.tap(aTile());
    await tester.pump(const Duration(milliseconds: 200));
    expect(haptics, hasLength(1), reason: 'no new pulse after turning it off');
  });
}
