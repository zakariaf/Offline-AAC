import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/settings/privacy_policy_screen.dart';
import 'package:offline_aac/ui/strings.dart';

import '../../support/harness.dart';

/// Apple 5.1.1(i) requires the privacy policy to be reachable from inside the
/// app, and a link that 404s is worse than absent. This proves the settings
/// entry exists, is a labelled button, opens the policy screen, and that the
/// screen offers a way back (a hard-cut route is a trap without one).
void main() {
  Future<void> openSettings(WidgetTester tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('the privacy policy link is a labelled button in settings', (
    tester,
  ) async {
    await openSettings(tester);
    final link = find.bySemanticsLabel(privacyPolicyLabel);
    expect(link, findsOneWidget);
    expect(
      tester.getSemantics(link),
      isSemantics(isButton: true, label: privacyPolicyLabel),
    );
  });

  testWidgets(
    'tapping it opens the policy, and the policy is not a dead link',
    (
      tester,
    ) async {
      await openSettings(tester);

      final link = find.bySemanticsLabel(privacyPolicyLabel);
      await tester.ensureVisible(link);
      await tester.pump();
      await tester.tap(link);
      await tester.pump();
      await tester.pump();

      // The destination mounts (the link is not dead)...
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      // ...and the way back is present, so the hard-cut route is not a trap.
      expect(find.bySemanticsLabel(settingsBackLabel), findsOneWidget);
    },
  );
}
