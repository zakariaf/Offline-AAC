import 'package:audio_session/audio_session.dart';

/// The audio session, configured once at startup.
///
/// The category is `playback` and it must never become `ambient`.
///
/// `ambient` respects the hardware silent switch. A user flips their ringer
/// switch before a meeting, later taps a tile mid-shutdown, and produces
/// NOTHING — at the exact moment they most need a voice. There is no error, no
/// crash, and no telemetry to report it. It is the worst bug this app can have,
/// and it is one word.
///
/// `flutter_tts`'s own README example uses `.ambient`, so copying the example
/// ships that bug. A policy test asserts this file says `playback` and does not
/// say `ambient`; the comment is here because the test can only prove the value
/// was passed, never that the OS applied it. That check is on the device
/// checklist, ringer switch off.
Future<void> configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.voicePrompt,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.assistanceAccessibility,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    ),
  );
}
