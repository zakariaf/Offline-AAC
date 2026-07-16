import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:offline_aac/ui/core/instant_route.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controls.dart'
    show SettingsBackButton;

/// The privacy policy, shown inside the app and offline. Apple 5.1.1(i) requires
/// the policy to be reachable from within the app, not only from store metadata;
/// this is that destination, opened as a hard-cut route like every screen in
/// Reed. The text is the bundled `legal/privacy-policy.md` asset — the same
/// source as the hosted page, so the two cannot drift.
///
/// A plain scrolling document: no dialog, no animation, and a back control at the
/// top so the hard-cut route is never a trap on iOS.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  /// A hard cut, like every route in Reed — no transition, no scheduled frame.
  static Route<void> route() =>
      InstantPageRoute<void>(builder: (_) => const PrivacyPolicyScreen());

  static const String _asset = 'legal/privacy-policy.md';

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Scaffold(
      backgroundColor: t.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(Geom.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SettingsBackButton(),
              Expanded(
                child: FutureBuilder<String>(
                  future: rootBundle.loadString(_asset),
                  builder: (context, snapshot) {
                    final text = snapshot.data;
                    // Null only in the one-frame gap before the bundled asset
                    // resolves; the back control above is already on screen, so
                    // the route is never a blank trap.
                    if (text == null) return const SizedBox.shrink();
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _policyBlocks(context, text),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the bundled markdown as plain, styled paragraphs — headings bold, the
/// effective-date line dim, body as body. No markdown package: Reed adds none it
/// does not need, and the policy is a handful of blocks split on blank lines.
List<Widget> _policyBlocks(BuildContext context, String markdown) {
  final t = AacTheme.of(context);
  final body = AacType.field.copyWith(color: t.ink);
  final heading = AacType.field.copyWith(
    color: t.ink,
    fontWeight: FontWeight.w800,
  );
  final caption = AacType.meta.copyWith(color: t.inkDim);

  final blocks = <Widget>[];
  for (final raw in markdown.trim().split('\n\n')) {
    final block = raw.trim();
    if (block.isEmpty) continue;

    final String content;
    final TextStyle style;
    final double top;
    if (block.startsWith('## ')) {
      content = block.substring(3);
      style = heading;
      top = 22;
    } else if (block.startsWith('# ')) {
      content = block.substring(2);
      style = heading;
      top = 0;
    } else if (block.startsWith('*') && block.endsWith('*')) {
      content = block.substring(1, block.length - 1);
      style = caption;
      top = 4;
    } else {
      content = block;
      style = body;
      top = 12;
    }
    blocks.add(
      Padding(
        padding: EdgeInsetsDirectional.only(top: top, bottom: 4),
        child: Text(content, style: style),
      ),
    );
  }
  return blocks;
}
