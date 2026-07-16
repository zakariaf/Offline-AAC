import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// The behavioural anti-clamp check. The grep in `no_text_clamping_test` catches
/// the NAMED clamping APIs; this catches a clamp built by hand — a `FittedBox`, a
/// computed `fontSize`, a re-pumped MediaQuery. Contrast and tap-target both stay
/// green while the text quietly stops growing, so no guideline catches this and
/// nothing on the device would report it.
///
/// 'Yes' stays one line at both sizes, so its height is pure scale.
void main() {
  testWidgets('text scale is honored, never clamped', (tester) async {
    tester.useDevice(Device.small);

    await tester.pumpApp();
    final base = tester.getSize(find.text('Yes')).height;

    await tester.pumpApp(textScale: 2);
    final scaled = tester.getSize(find.text('Yes')).height;

    // 1.8, not 2.0: tolerate line-height rounding while failing hard on a clamp.
    expect(
      scaled,
      greaterThan(base * 1.8),
      reason:
          'text did not grow at 2.0x — someone clamped TextScaler to keep '
          'the fixed grid tidy; 200%+ must be honored',
    );
  });
}
