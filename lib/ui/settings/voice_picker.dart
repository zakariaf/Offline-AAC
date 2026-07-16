import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/speech/speech_service.dart';
import 'package:offline_aac/model/speak_outcome.dart';
import 'package:offline_aac/ui/board/board_controller.dart'
    show currentVoiceProvider, speechServiceProvider;
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/settings/settings_controller.dart';
import 'package:offline_aac/ui/strings.dart';

/// The offline-safe voices, already filtered by `offlineSafeVoices` inside the
/// service. This screen re-filters nothing: a network voice in this list is a
/// user tapping a tile in a dead zone and getting silence, and that rule has one
/// tested home.
final FutureProvider<List<Voice>> voicesProvider =
    FutureProvider<List<Voice>>((ref) => ref.watch(speechServiceProvider).voices());

/// The voice picker — the epic. Each row is audible BEFORE it is chosen: a tap
/// speaks a sample in that voice through the real preview path (so a voice that
/// reports success and says nothing is caught here, not at the next shutdown),
/// and the same tap commits it on success. Every failure lands as one inline
/// sentence, never a dialog. Pitch shifts the voice because no free offline
/// engine ships a middle-pitch voice, and the caption says so rather than let
/// someone hunt for one that does not exist.
class VoicePicker extends ConsumerStatefulWidget {
  const VoicePicker({super.key});

  @override
  ConsumerState<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends ConsumerState<VoicePicker> {
  late double _pitch = ref.read(settingsProvider).pitch;
  late double _rate = ref.read(settingsProvider).rate;

  /// The inline failure line and the voice it sits under. Non-blocking, in place.
  String? _error;
  String? _errorVoiceName;

  Future<void> _select(Voice voice) async {
    final speech = ref.read(speechServiceProvider);
    try {
      // Barge-in: stop before speak, always. A re-tap means "say it again".
      await speech.stop();
      final outcome = await speech.preview(
        voicePreviewText,
        voice: voice,
        pitch: _pitch,
        rate: _rate,
      );
      if (!mounted) return;
      // Exhaustive over the sealed outcome — no default:, no case _:, so a new
      // variant is a compile error here, not a silent miss.
      switch (outcome) {
        case SpokeAloud():
          ref.read(settingsProvider.notifier).setVoiceId(voice.name);
          ref.read(currentVoiceProvider).value = voice;
          setState(() {
            _error = null;
            _errorVoiceName = null;
          });
        case VoiceNotInstalled():
          _showError(voice, voiceNotInstalledError);
        case VoiceUnavailable() || NoVoiceSelected():
          _showError(voice, voiceUnavailableError);
        case EngineTimedOut() || EngineRejected():
          _showError(voice, voiceEngineError);
      }
    } on Object {
      if (mounted) _showError(voice, voiceEngineError);
    }
  }

  void _showError(Voice voice, String message) {
    setState(() {
      _error = message;
      _errorVoiceName = voice.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final voices = ref.watch(voicesProvider);
    final selectedId = ref.watch(settingsProvider.select((s) => s.voiceId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 14, bottom: 6),
          child: Text(
            voiceSectionChrome,
            style: AacType.meta.copyWith(
              color: t.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        voices.when(
          // A brief nothing, never a spinner — the row area fills the instant
          // voices resolve, and it resolves in a frame.
          loading: () => const SizedBox.shrink(),
          error: (_, _) => _NoVoices(),
          data: (list) => list.isEmpty
              ? _NoVoices()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final voice in list)
                      _VoiceRow(
                        voice: voice,
                        selected: voice.name == selectedId,
                        error: _errorVoiceName == voice.name ? _error : null,
                        onTap: () => unawaited(_select(voice)),
                      ),
                  ],
                ),
        ),
        _ProsodySlider(
          label: pitchSliderChrome,
          value: _pitch.clamp(kMinPitch, kMaxPitch),
          min: kMinPitch,
          max: kMaxPitch,
          onChanged: (v) => setState(() => _pitch = v),
          onChangeEnd: (v) => ref.read(settingsProvider.notifier).setPitch(v),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8),
          child: Text(
            pitchCaption,
            style: AacType.meta.copyWith(color: t.inkDim),
          ),
        ),
        _ProsodySlider(
          label: rateSliderChrome,
          value: _rate.clamp(kMinRate, kMaxRate),
          min: kMinRate,
          max: kMaxRate,
          onChanged: (v) => setState(() => _rate = v),
          onChangeEnd: (v) => ref.read(settingsProvider.notifier).setRate(v),
        ),
      ],
    );
  }
}

/// One voice row. Selection goes through semantics (a checked state), not colour
/// alone, plus a visible non-colour mark. The name is allowed to wrap — voice
/// ids are long (`en-gb-x-gbb-local`) and an ellipsis makes an identifier
/// unreadable, which is worse than a tall row.
class _VoiceRow extends StatelessWidget {
  const _VoiceRow({
    required this.voice,
    required this.selected,
    required this.error,
    required this.onTap,
  });

  final Voice voice;
  final bool selected;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    return Semantics(
      container: true,
      button: true,
      checked: selected,
      label: voice.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // The non-colour selected mark: a filled vs hollow dot.
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: t.ink,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        voice.name,
                        style: AacType.field.copyWith(
                          color: t.ink,
                          fontWeight: bold || selected
                              ? FontWeight.w800
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4, start: 28),
                    child: Text(
                      error!,
                      style: AacType.meta.copyWith(color: t.ink),
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

/// The zero-offline-voices state: a statement, not a dialog, not an empty shrug.
class _NoVoices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
      child: Text(noOfflineVoices, style: AacType.field.copyWith(color: t.ink)),
    );
  }
}

/// A pitch or rate slider. Persists on `onChangeEnd`, never on every drag frame —
/// that would hammer the DB and stutter overlapping utterances. `Slider` already
/// carries semantics; it gets a label. Never a custom-painted slider.
class _ProsodySlider extends StatelessWidget {
  const _ProsodySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AacType.meta.copyWith(
            color: t.ink,
            fontWeight: MediaQuery.boldTextOf(context) ? FontWeight.w800 : null,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          label: label,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
