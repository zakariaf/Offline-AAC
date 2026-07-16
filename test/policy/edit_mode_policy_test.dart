import 'package:flutter_test/flutter_test.dart';

import 'policy_helpers.dart';

/// Edit mode's bans, as greps that outlast the reviewer who knows them. Each one
/// guards a top-severity, invisible failure: a hidden gesture no switch user can
/// reach, a drag that silently repoints muscle memory, or a default-set update
/// that eats a curated phrase. Comments are stripped first, so the prose that
/// explains a rule never trips it.
void main() {
  test('no hidden gesture or drag anywhere in lib', () {
    // A long-press collides with dwell input and is invisible; a drag is
    // unreachable by TalkBack and Switch Access. Any behaviour reachable by
    // touch must be reachable by a labelled, focusable control.
    final offenders = <String>[];
    const banned = <String>[
      'onLongPress',
      'onDoubleTap',
      'onPanStart',
      'onPanUpdate',
      'Draggable',
      'LongPressDraggable',
      'ReorderableGridView',
      'ReorderableListView',
      'Dismissible',
    ];
    for (final file in dartFilesUnder('lib')) {
      final code = stripComments(file.readAsStringSync());
      for (final needle in banned) {
        offenders.addAll(matchingLines(file, code, needle));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'a hidden gesture is unreachable by half this audience:\n'
          '${offenders.join('\n')}',
    );
  });

  test('the board and editor use no InkWell or InkResponse', () {
    // NoSplash kills the splash but InkResponse still mounts an InkHighlight with
    // a 200ms pressed fade and schedules a second frame — animation on a
    // zero-animation surface.
    final offenders = <String>[];
    for (final dir in <String>['lib/ui/board', 'lib/ui/edit']) {
      for (final file in dartFilesUnder(dir)) {
        final code = stripComments(file.readAsStringSync());
        for (final needle in <String>['InkWell', 'InkResponse']) {
          offenders.addAll(matchingLines(file, code, needle));
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('user_edited is never written back to false', () {
    // user_edited = 1 is the one-way latch that keeps a curated phrase from being
    // overwritten by a seed or default-set update. Any code that writes it false
    // reopens that hole, and no test but this one would catch it.
    final offenders = <String>[];
    for (final file in dartFilesUnder('lib')) {
      final code = stripComments(file.readAsStringSync());
      for (final needle in <String>[
        'userEdited: const Value<bool>(false)',
        'userEdited: Value<bool>(false)',
        'userEdited: Value(false)',
      ]) {
        offenders.addAll(matchingLines(file, code, needle));
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'writing user_edited=false surrenders a curated board to the next '
          'default-set update:\n${offenders.join('\n')}',
    );
  });
}
