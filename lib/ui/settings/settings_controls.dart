import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/settings_repository.dart';
import 'package:offline_aac/data/speech/speech_service.dart' show OutputMode;
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/portability_controller.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/strings.dart';

/// The settings row idiom, in one place: a labelled, focusable button with the
/// visible face excluded from semantics so the label is announced once. Never an
/// `InkWell`/`ListTile` — `NoSplash` kills the splash but `InkResponse` still
/// mounts a 200ms highlight fade and schedules a second frame. No long-press, no
/// swipe, no key. The whole rect is the target.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    super.key,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The visible face of a value control: `prefix` then each option, the selected
/// one bold — a non-colour channel, so it survives invertColors and Grayscale.
/// The text wraps; nothing here clamps or ellipsizes.
class _ValueFace extends StatelessWidget {
  const _ValueFace({
    required this.options,
    required this.selected,
    this.prefix,
  });

  final String? prefix;
  final List<String> options;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    final base = AacType.field.copyWith(color: t.ink);
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          if (prefix != null) TextSpan(text: '$prefix  ', style: base),
          for (var i = 0; i < options.length; i++) ...<TextSpan>[
            if (i > 0) TextSpan(text: '  ·  ', style: base),
            TextSpan(
              text: options[i],
              style: base.copyWith(
                fontWeight: i == selected
                    ? FontWeight.w800
                    : (bold ? FontWeight.w800 : null),
                color: i == selected ? t.ink : t.inkDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A plain chrome-text face, for the stubs and the on/off rows.
class _TextFace extends StatelessWidget {
  const _TextFace(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    return Text(
      text,
      style: AacType.field.copyWith(
        color: t.ink,
        fontWeight: bold ? FontWeight.w800 : null,
      ),
    );
  }
}

/// Which cycle position the live palette sits at, and its visible name.
String themeChromeFor(AacPalette palette) => switch (palette) {
  AacPalette.paper => themePaperChrome,
  AacPalette.ink => themeInkChrome,
  AacPalette.hcInk || AacPalette.hcPaper => themeHighContrastChrome,
};

/// The theme control. Shows the CURRENT palette and cycles on tap
/// (`paper → ink → high contrast → paper`), persisting the new palette. Lives on
/// the board chrome AND in settings — the same widget reading the same state.
class ThemeControl extends ConsumerWidget {
  const ThemeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final chrome = themeChromeFor(palette);
    return SettingsRow(
      semanticLabel: 'Theme: $chrome. Tap to change.',
      onTap: () {
        // Resolve current INSIDE the callback via the cycle, never a value
        // captured from build() — a rebuild between build and tap would step the
        // cycle from a stale position.
        ref.read(paletteProvider.notifier).cycle();
        final next = ref.read(paletteProvider);
        ref.read(settingsProvider.notifier).setPalette(next);
      },
      child: _TextFace('theme: $chrome'),
    );
  }
}

/// The tile-count segmented control: 12 (phone) · 6 (large). Tap cycles.
class TileCountControl extends ConsumerWidget {
  const TileCountControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.watch(
      settingsProvider.select((s) => s.gridSize),
    );
    final is12 = gridSize == GridSize.phone;
    return SettingsRow(
      semanticLabel: 'Tiles: ${is12 ? '12' : '6'}. Tap to change.',
      onTap: () => ref.read(settingsProvider.notifier).setGridSize(
        is12 ? GridSize.large : GridSize.phone,
      ),
      child: _ValueFace(
        prefix: 'Tiles:',
        options: const <String>['12', '6'],
        selected: is12 ? 0 : 1,
      ),
    );
  }
}

/// The haptics on/off row. Tap cycles. Turning haptics OFF fires no confirming
/// pulse — the last thing someone turning it off should receive is a haptic.
class HapticsControl extends ConsumerWidget {
  const HapticsControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider.select((s) => s.haptics));
    return SettingsRow(
      semanticLabel: 'Haptics: ${on ? 'on' : 'off'}. Tap to change.',
      onTap: () =>
          ref.read(settingsProvider.notifier).setHaptics(enabled: !on),
      child: _TextFace(on ? hapticsOnChrome : hapticsOffChrome),
    );
  }
}

/// The low-stimulus on/off row: undyed tiles and the 2-column layout. Named for
/// what changes on the screen, never `calm`/`panic`/`sensory`/`overwhelm` mode —
/// those narrate an emotional state the app does not know.
class LowStimulusControl extends ConsumerWidget {
  const LowStimulusControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider.select((s) => s.lowStimulus));
    return SettingsRow(
      semanticLabel: 'Low stimulus: ${on ? 'on' : 'off'}. Tap to change.',
      onTap: () =>
          ref.read(settingsProvider.notifier).setLowStimulus(enabled: !on),
      child: _TextFace(on ? lowStimulusOnChrome : lowStimulusOffChrome),
    );
  }
}

/// Output mode: speak · show · both, three first-class values. `show` is a
/// CHOSEN silent mode, not the speech-failure path — that words-on-screen
/// guarantee holds unconditionally in all three modes and is a different
/// mechanism. Selecting a mode NEVER speaks a preview. Tap cycles.
class OutputModeControl extends ConsumerWidget {
  const OutputModeControl({super.key});

  static const List<OutputMode> _order = <OutputMode>[
    OutputMode.speak,
    OutputMode.show,
    OutputMode.both,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.output));
    return SettingsRow(
      semanticLabel: switch (mode) {
        OutputMode.speak => 'Output: speak. Speaks aloud.',
        OutputMode.show => 'Output: show. Shows the words.',
        OutputMode.both => 'Output: both. Speaks aloud and shows the words.',
      },
      onTap: () {
        final next = _order[(_order.indexOf(mode) + 1) % _order.length];
        ref.read(settingsProvider.notifier).setOutputMode(next);
      },
      child: _ValueFace(
        prefix: 'Output:',
        options: const <String>['speak', 'show', 'both'],
        selected: _order.indexOf(mode),
      ),
    );
  }
}

/// High-contrast polarity: dark · light, a set-once preference (never a fourth
/// switcher position). Changing it while the palette in force is not HC stores
/// the value and touches nothing on screen; while it IS HC it applies on the
/// same frame. Both handled in [SettingsController.setHcPolarity].
class HcPolarityControl extends ConsumerWidget {
  const HcPolarityControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polarity = ref.watch(settingsProvider.select((s) => s.hcPolarity));
    final isDark = polarity == AacPalette.hcInk;
    return SettingsRow(
      semanticLabel:
          'High contrast: ${isDark ? 'dark' : 'light'}. Tap to change.',
      onTap: () => ref.read(settingsProvider.notifier).setHcPolarity(
        isDark ? AacPalette.hcPaper : AacPalette.hcInk,
      ),
      child: _ValueFace(
        prefix: 'High contrast:',
        options: const <String>['dark', 'light'],
        selected: isDark ? 0 : 1,
      ),
    );
  }
}

/// The `Keep my board off cloud backup` row. The `android:allowBackup` behaviour
/// behind it is release work; the row and its blunt copy belong here.
class KeepOffBackupControl extends StatelessWidget {
  const KeepOffBackupControl({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      semanticLabel: keepOffBackupChrome,
      onTap: () {},
      child: const _TextFace(keepOffBackupChrome),
    );
  }
}

/// The `Restore previous board` row — a labelled control, not a hidden gesture.
/// The restore mechanism itself is release work.
class RestoreBoardControl extends StatelessWidget {
  const RestoreBoardControl({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      semanticLabel: restoreBoardChrome,
      onTap: () {},
      child: const _TextFace(restoreBoardChrome),
    );
  }
}

/// `Export my board` — build the zip and hand it to the OS share sheet. Calls a
/// VOID controller method: an `onTap: () => controller.export()` arrow would drop
/// the Future and its error against the VoidCallback target, and the user would
/// tap and get silence — the worst bug here.
class ExportBoardControl extends ConsumerWidget {
  const ExportBoardControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsRow(
      semanticLabel: exportBoardChrome,
      onTap: () =>
          ref.read(portabilityControllerProvider.notifier).exportBoard(),
      child: const _TextFace(exportBoardChrome),
    );
  }
}

/// `Import a board` — pick a file and import it as a NEW board, never over the
/// board already here. Void method, same reason as export.
class ImportBoardControl extends ConsumerWidget {
  const ImportBoardControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsRow(
      semanticLabel: importBoardChrome,
      onTap: () =>
          ref.read(portabilityControllerProvider.notifier).importBoard(),
      child: const _TextFace(importBoardChrome),
    );
  }
}

/// The inline result line for an export or import — statement, then the next
/// action, never a modal. Absent (zero height) when there is nothing to say, so
/// it never occupies space or reads as an instruction before the user acts.
class PortabilityResult extends ConsumerWidget {
  const PortabilityResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(portabilityControllerProvider);
    if (message == null) return const SizedBox.shrink();
    final t = AacTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 14),
      child: Text(message, style: AacType.field.copyWith(color: t.ink)),
    );
  }
}

/// A compact chrome control — an icon and a word — for the board's top bar. Not
/// an InkWell: the whole rect is the target and nothing animates.
class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    required this.semanticLabel,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 20, color: t.ink),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AacType.meta.copyWith(
                      color: t.ink,
                      fontWeight: bold ? FontWeight.w800 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The board-chrome theme control — the SAME state and cycle as [ThemeControl],
/// in the compact chrome form. This is the one-tap-from-the-grid path the theme
/// escape hatch needs; settings only mirrors it.
class ThemeChrome extends ConsumerWidget {
  const ThemeChrome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final chrome = themeChromeFor(palette);
    return _ChromeButton(
      semanticLabel: 'Theme: $chrome. Tap to change.',
      icon: Icons.contrast_rounded,
      label: 'theme: $chrome',
      onTap: () {
        ref.read(paletteProvider.notifier).cycle();
        ref.read(settingsProvider.notifier).setPalette(ref.read(paletteProvider));
      },
    );
  }
}

/// The settings screen's back control, at the top-left where a back affordance
/// is expected. The route is a hard cut with no transition, so iOS offers no
/// swipe-back edge — without this the settings screen is a trap on iOS. A plain
/// gesture target, never an InkWell: no splash, no 200ms fade, nothing animates.
class SettingsBackButton extends StatelessWidget {
  const SettingsBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        container: true,
        button: true,
        label: settingsBackLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Pops the settings route back to the board. A back button owns its
          // own navigation — there is no chrome-to-screen import knot to avoid,
          // unlike the forward SettingsButton.
          onTap: () => Navigator.of(context).pop(),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.arrow_back_rounded, size: 22, color: t.ink),
                  const SizedBox(width: 8),
                  Text(
                    settingsBackChrome,
                    style: AacType.field.copyWith(
                      color: t.ink,
                      fontWeight: bold ? FontWeight.w800 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The board-chrome settings entry. One tap to the flat settings list.
class SettingsButton extends StatelessWidget {
  const SettingsButton({required this.onOpen, super.key});

  /// Pushes the settings route. Passed in so this widget need not import the
  /// screen and create a chrome-to-screen import knot.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _ChromeButton(
      semanticLabel: 'Settings',
      icon: Icons.tune_rounded,
      label: settingsChrome,
      onTap: onOpen,
    );
  }
}
