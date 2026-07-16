import 'package:flutter/material.dart';

/// A [MaterialPageRoute] that is a true hard cut: no transition widget AND no
/// transition duration.
///
/// The app root's `_NoTransitions` builder already makes a push VISUALLY instant
/// by returning the child directly, but a default `MaterialPageRoute` still runs
/// a 300ms transition controller that ticks a frame the whole way — so the
/// screen looks settled while `hasScheduledFrame` stays true. Zeroing the
/// duration makes the push actually frame-quiet: the flash is one frame and
/// nothing animates.
///
/// A plain route SUBCLASS, deliberately, not a `PageRouteBuilder` — the latter
/// is the transition-shaped API the show screen bans, and keeping the zero here
/// keeps every `Duration` out of the show screen's own file.
class InstantPageRoute<T> extends MaterialPageRoute<T> {
  InstantPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}
