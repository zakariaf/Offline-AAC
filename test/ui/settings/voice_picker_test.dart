import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/ui/settings/voice_picker.dart';
import 'package:offline_aac/ui/strings.dart';

import '../../support/fake_speech_service.dart';
import '../../support/harness.dart';

/// The voice picker: the one screen where a user finds out what they sound like
/// BEFORE a stranger does. A tap auditions and commits; every failure is one
/// inline sentence; zero voices is a real state stated in words, not an empty
/// list.
void main() {
  Future<void> openPicker(
    WidgetTester tester, {
    required FakeSpeechService speech,
    double textScale = 1,
  }) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech, textScale: textScale);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump(); // let the voices FutureProvider resolve
    expect(find.byType(VoicePicker), findsOneWidget);
  }

  testWidgets('only-network voices ⇒ zero rows and the no-voices statement', (
    tester,
  ) async {
    await openPicker(
      tester,
      speech: FakeSpeechService(env: SpeechEnv.onlyNetworkVoices),
    );
    expect(find.bySemanticsLabel('v'), findsNothing);
    expect(find.text(noOfflineVoices), findsOneWidget);
  });

  testWidgets('only-not-installed voices ⇒ zero rows', (tester) async {
    await openPicker(
      tester,
      speech: FakeSpeechService(env: SpeechEnv.onlyNotInstalledVoices),
    );
    expect(find.bySemanticsLabel('v'), findsNothing);
    expect(find.text(noOfflineVoices), findsOneWidget);
  });

  testWidgets('every voice row is a labelled button', (tester) async {
    await openPicker(tester, speech: FakeSpeechService());
    expect(
      tester.getSemantics(find.bySemanticsLabel('v')),
      isSemantics(isButton: true, label: 'v'),
    );
  });

  testWidgets('selecting a voice that works marks it selected via semantics', (
    tester,
  ) async {
    // reportedSuccessButSilent ⇒ preview returns SpokeAloud, so selection sticks.
    await openPicker(tester, speech: FakeSpeechService());
    await tester.tap(find.bySemanticsLabel('v'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester.getSemantics(find.bySemanticsLabel('v')),
      isSemantics(
        isButton: true,
        label: 'v',
        hasCheckedState: true,
        isChecked: true,
      ),
      reason: 'selection is exposed through semantics, not colour alone',
    );
  });

  testWidgets('a setVoice failure lands as one inline line and no dialog', (
    tester,
  ) async {
    await openPicker(
      tester,
      speech: FakeSpeechService(env: SpeechEnv.setVoiceReturnsZero),
    );
    await tester.tap(find.bySemanticsLabel('v'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(voiceUnavailableError), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('preview barges in: one tap is stop then speak', (tester) async {
    final speech = FakeSpeechService();
    await openPicker(tester, speech: speech);

    await tester.tap(find.bySemanticsLabel('v'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(speech.calls, <String>['stop', 'speak']);

    await tester.tap(find.bySemanticsLabel('v'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(speech.calls, <String>['stop', 'speak', 'stop', 'speak']);
  });

  testWidgets('a long voice name is present in full at 200%, no overflow', (
    tester,
  ) async {
    const longName = 'en-gb-x-gbb-network-local-female-variant-two';
    await openPicker(
      tester,
      textScale: 2,
      speech: FakeSpeechService(
        voicesOverride: const <Voice>[
          Voice(
            name: longName,
            locale: 'en-GB',
            networkRequired: false,
            features: <String>{},
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(longName), findsOneWidget);
    // The honest pitch caption is present, not clamped away.
    expect(find.text(pitchCaption), findsOneWidget);
  });
}
