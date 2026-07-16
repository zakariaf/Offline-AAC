import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/strings.dart';

/// The show-mode controls: polarity, the standing-line toggle, and its text.
///
/// A section, not a screen — E08 owns the settings scaffold and places this
/// inside it. Names first, no prose caption, no "we", no praise, no exclamation,
/// and never a text transform: `.toLowerCase()` is a rule about all text, and a
/// standing line is text a user wrote. The labels are authored lowercase in the
/// string table for that reason.
class ShowSettingsSection extends ConsumerWidget {
  const ShowSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(showScreenSettingLabel),
        SegmentedButton<ShowPolarity>(
          segments: const <ButtonSegment<ShowPolarity>>[
            ButtonSegment<ShowPolarity>(
              value: ShowPolarity.bright,
              label: Text('bright'),
            ),
            ButtonSegment<ShowPolarity>(
              value: ShowPolarity.matchTheme,
              label: Text('match my theme'),
            ),
          ],
          selected: <ShowPolarity>{settings.showPolarity},
          onSelectionChanged: (selection) =>
              unawaited(controller.setShowPolarity(selection.first)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(standingLineSettingLabel),
          value: settings.standingLineEnabled,
          onChanged: (enabled) =>
              unawaited(controller.setStandingLineEnabled(enabled: enabled)),
        ),
        _StandingLineField(
          // Keyed by the persisted value so an external change (a reset, a
          // restore) re-seeds the field; ordinary typing does not rebuild it.
          key: ValueKey<String>(settings.standingLineText),
          initialText: settings.standingLineText,
          onChanged: (value) =>
              unawaited(controller.setStandingLineText(value)),
        ),
      ],
    );
  }
}

/// The standing-line editor. Uncapped — the 16-character limit belongs to a tile
/// label, not to a frame-control sentence — and it accepts the empty string as a
/// deliberate choice: no refusal, no re-fill with the default, no "recommended"
/// nudge, no placeholder that reads as an instruction.
class _StandingLineField extends StatefulWidget {
  const _StandingLineField({
    required this.initialText,
    required this.onChanged,
    super.key,
  });

  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<_StandingLineField> createState() => _StandingLineFieldState();
}

class _StandingLineFieldState extends State<_StandingLineField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}
