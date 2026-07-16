import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_aac/data/board_repository.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/board_controller.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/strings.dart';

/// The whole editor: two fields, and nothing else.
///
/// "What you see" is the tile handle, hard-capped at 16 characters — the tile is
/// a HANDLE for the utterance, which is what makes a cap safe. "What it says" is
/// the spoken sentence, uncapped, collapsed by default and mirroring the label
/// until the user opens it, because most users never will. There is no colour
/// picker, no image picker, no delete, no undo, and no confirmation dialog — the
/// editor fits in one screen because every feature it turns down is a feature
/// the incumbent shipped.
///
/// A plain form the platform IME can dictate into: no custom input client,
/// nothing that hides the keyboard's own mic key.
class TileEditor extends ConsumerStatefulWidget {
  const TileEditor({required this.row, required this.col, super.key});

  final int row;
  final int col;

  @override
  ConsumerState<TileEditor> createState() => _TileEditorState();
}

class _TileEditorState extends ConsumerState<TileEditor> {
  static const int _labelMax = 16;

  late final TextEditingController _label;
  late final TextEditingController _says;
  Tile? _tile;
  int? _boardId;

  /// Whether "What it says" has been opened. Once open, mirroring stops for good
  /// and the vocalization is written for real; while closed, it mirrors the
  /// label and the vocalization persists as NULL — the schema's own fallback,
  /// so a later label edit never strands a stale sentence behind it.
  bool _saysOpened = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    final grid = ref.read(gridProvider).valueOrNull;
    _boardId = grid?.boardId;
    _tile = grid?.tileAt(widget.row, widget.col);

    _label = TextEditingController(text: _tile?.label ?? '');
    // A tile whose spoken text already differs from its label has an explicit
    // vocalization, so open "What it says" prefilled. Otherwise it is mirroring.
    final diverges = _tile != null && _tile!.vocalization != _tile!.label;
    _saysOpened = diverges;
    _says = TextEditingController(text: diverges ? _tile!.vocalization : '');

    // Refresh the counter and the collapsed mirror on every label keystroke.
    _label.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _label
      ..removeListener(_onChange)
      ..dispose();
    _says.dispose();
    super.dispose();
  }

  void _openSays() {
    setState(() {
      // Mirroring stops permanently. Seed the field with the label the user has
      // been mirroring, so opening it never blanks their sentence.
      if (_says.text.isEmpty) _says.text = _label.text;
      _saysOpened = true;
    });
  }

  Future<void> _save() async {
    final label = _label.text;
    // NOT NULL, 1..16. The cap refuses at input; this catches the empty case,
    // which the formatter cannot. No modal — an inline line, stated plainly.
    if (label.isEmpty) {
      setState(() => _saveFailed = true);
      return;
    }
    // Collapsed OR opened-but-emptied ⇒ NULL, and the schema falls back to the
    // label. Never a copy of the label into vocalization.
    final says = _saysOpened && _says.text.isNotEmpty ? _says.text : null;

    final repo = ref.read(boardRepositoryProvider);
    final board = _boardId;
    final tile = _tile;
    try {
      if (tile != null) {
        await repo.editTileText(
          tile.buttonId,
          label: label,
          vocalization: says,
        );
      } else if (board != null) {
        await repo.placeTile(
          board,
          widget.row,
          widget.col,
          label: label,
          vocalization: says,
        );
      }
      if (!mounted) return;
      ref.read(boardControllerProvider.notifier).closeEditor();
    } on Object {
      if (!mounted) return;
      setState(() => _saveFailed = true);
    }
  }

  void _cancel() => ref.read(boardControllerProvider.notifier).closeEditor();

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    final bold = MediaQuery.boldTextOf(context);
    final used = _label.text.characters.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(Geom.margin),
        // A scroll view, so the form survives 200% text without clamping the
        // user's setting — it grows and scrolls, never shrinks.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _EditorButton(
                    label: editCancelChrome,
                    semanticLabel: 'Cancel',
                    onTap: _cancel,
                    bold: bold,
                  ),
                  _EditorButton(
                    label: editSaveChrome,
                    semanticLabel: 'Save',
                    onTap: _save,
                    bold: bold,
                  ),
                ],
              ),
              const SizedBox(height: Geom.gapRow),

              _FieldLabel(whatYouSeeLabel, bold: bold),
              TextField(
                controller: _label,
                // The mic key belongs to the user's own keyboard; nothing here
                // suppresses it. The cap REFUSES at 16 (accept-and-stop), never
                // truncates after the fact — an ellipsis on an AAC utterance is a
                // different utterance.
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(_labelMax),
                ],
                style: AacType.field.copyWith(color: t.ink),
              ),
              const SizedBox(height: 4),
              // A plain statement of the count. No exclamation, no error
              // register, no red — there is no red in Reed. At the cap the field
              // simply stops accepting input.
              Semantics(
                liveRegion: true,
                child: Text(
                  '$used of $_labelMax characters',
                  style: AacType.meta.copyWith(color: t.inkDim),
                ),
              ),
              const SizedBox(height: Geom.gapRow),

              _FieldLabel(whatItSaysLabel, bold: bold),
              if (_saysOpened)
                TextField(
                  controller: _says,
                  // Uncapped by design: it holds the whole sentence, so NO
                  // formatter and NO counter ever go on this field.
                  maxLines: null,
                  style: AacType.field.copyWith(color: t.ink),
                )
              else
                _MirrorPreview(
                  text: _label.text,
                  onOpen: _openSays,
                  bold: bold,
                ),

              if (_saveFailed) ...<Widget>[
                const SizedBox(height: Geom.gapRow),
                Text(
                  editSaveFailed,
                  style: AacType.meta.copyWith(color: t.ink),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.bold});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 6),
      child: Text(
        text,
        style: AacType.meta.copyWith(
          color: t.ink,
          fontWeight: bold ? FontWeight.w800 : null,
        ),
      ),
    );
  }
}

/// The collapsed "What it says": it mirrors the label and offers to open.
class _MirrorPreview extends StatelessWidget {
  const _MirrorPreview({
    required this.text,
    required this.onOpen,
    required this.bold,
  });

  final String text;
  final VoidCallback onOpen;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            style: AacType.field.copyWith(color: t.inkDim),
          ),
        ),
        const SizedBox(width: 12),
        _EditorButton(
          label: openWhatItSaysChrome,
          semanticLabel: 'Set what it says',
          onTap: onOpen,
          bold: bold,
        ),
      ],
    );
  }
}

/// A labelled, focusable tap target — not an InkWell, no splash, no fade.
class _EditorButton extends StatelessWidget {
  const _EditorButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    required this.bold,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = AacTheme.of(context);
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
            child: Text(
              label,
              style: AacType.meta.copyWith(
                color: t.ink,
                fontWeight: bold ? FontWeight.w800 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
