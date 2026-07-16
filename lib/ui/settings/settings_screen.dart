import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/ui/core/instant_route.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controls.dart';
import 'package:offline_aac/ui/settings/show_settings_section.dart';
import 'package:offline_aac/ui/settings/voice_picker.dart';

/// One flat, scrollable screen — no tree, no sub-page, no accordion, no dialog.
///
/// This is the surface a user may open WHILE in trouble, to turn off the thing
/// that is currently hurting them. Every level of nesting is a decision demanded
/// of the person whose decision-making is exactly what is impaired, so there is
/// one level and every control is reachable by scrolling. Rows are intrinsic
/// height and wrap; the column scrolls; nothing clamps the text scale.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// A hard cut, like every route in Reed — no transition, no scheduled frame.
  static Route<void> route() =>
      InstantPageRoute<void>(builder: (_) => const SettingsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AacTheme.of(context);

    return Scaffold(
      backgroundColor: t.ground,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(Geom.margin),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // The way back. On iOS the hard-cut route offers no swipe-back
                // edge, so this is the only exit; on Android it beats hunting for
                // the system gesture. First in reading and traversal order.
                SettingsBackButton(),
                // Haptics and low stimulus first — the two a person reaches for
                // while in the state that made them open settings.
                HapticsControl(),
                LowStimulusControl(),
                // The voice — a voice is the sound of a person, so it is a
                // first-class section, above theme and tile count, not a submenu.
                VoicePicker(),
                OutputModeControl(),
                ThemeControl(),
                HcPolarityControl(),
                TileCountControl(),
                ShowSettingsSection(),
                KeepOffBackupControl(),
                // Export/import — the whole durability story once cloud backup
                // is off. The result line sits directly beneath the two rows.
                ExportBoardControl(),
                ImportBoardControl(),
                PortabilityResult(),
                RestoreBoardControl(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
