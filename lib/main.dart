// main.dart
//
// Placement stub — the real cold-launch sequence is E01-T06, which has a
// required order: error handlers before anything that can throw, theme before
// first paint, TTS warm-up post-frame and never awaited.
//
// For now this exists only so the toolchain has something to compile.
import 'package:flutter/material.dart';

void main() => runApp(const _Placeholder());

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: Center(child: Text('Reed'))));
}
