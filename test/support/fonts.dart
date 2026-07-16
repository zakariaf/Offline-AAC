import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real typeface into the test renderer, once per process.
///
/// Widget tests default to Ahem, a fixed-width test font whose glyphs are far
/// wider than Atkinson Hyperlegible Next. That used to matter only for tests
/// that assert on TEXT METRICS. It now matters for EVERY board test: the grid
/// chooses its column count by measuring labels, and Ahem's fat glyphs collapse
/// the board to one scrolling column even at the default text size — pushing
/// tiles off-screen and making a plain tile tap "miss". So the harness loads
/// the real face before it pumps, and the whole suite renders the font the
/// device ships.
///
/// Idempotent: the engine keeps a font registered for the life of the process,
/// so re-registering it every pump is wasted work and this returns early.
Future<void> loadAppFonts() async {
  if (_loaded) return;
  final loader = FontLoader('AtkinsonHyperlegibleNext')
    ..addFont(rootBundle.load('assets/fonts/AtkinsonHyperlegibleNext-VF.ttf'));
  await loader.load();
  _loaded = true;
}

bool _loaded = false;
