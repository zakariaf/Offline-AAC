import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/speech/speech_service.dart';

/// flutter_tts normalises speech rate so that 0.5 is normal speed (its Android
/// code doubles the value before handing it to the engine). Reed's rate is a
/// plain multiplier where 1.0 is normal, so [ttsSpeechRate] must halve it — or a
/// voice preview at the default rate plays at 2x and cannot be understood.
void main() {
  test('the default rate reaches the engine as normal, not double', () {
    expect(ttsSpeechRate(kDefaultRate), 0.5);
    expect(ttsSpeechRate(1), 0.5);
  });

  test('the multiplier is preserved across the range', () {
    expect(ttsSpeechRate(2), 1.0, reason: 'Reed 2x -> engine 1.0 -> double');
    expect(ttsSpeechRate(kMinRate), 0.125, reason: 'Reed 0.25 -> quarter');
    expect(ttsSpeechRate(kMaxRate), 1.0);
  });
}
