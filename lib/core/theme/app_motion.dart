import 'package:flutter/material.dart';

/// Centralized motion configuration (req 8.1, 8.3, 8.4).
///
/// All animations in the app must source their durations from here so
/// Property 9 (duration clamp) holds: every micro-animation lives in
/// `[100, 400]` ms and every page transition in `[200, 400]` ms.
class AppMotion {
  AppMotion._();

  /// Micro-animation duration (counters, haptics visual cue, etc.).
  static const Duration micro = Duration(milliseconds: 200);

  /// Page transition duration.
  static const Duration page = Duration(milliseconds: 250);

  /// Skeleton shimmer cycle.
  static const Duration shimmer = Duration(milliseconds: 1200);

  /// Press feedback overlay duration.
  static const Duration press = Duration(milliseconds: 180);

  /// Standard ease for content motion.
  static const Curve ease = Curves.easeOutCubic;

  /// Resolve the reduced-motion flag from a [BuildContext].
  ///
  /// Returns `true` when the user has animations disabled at the OS
  /// level; consumers should fall back to opacity-only transitions and
  /// render final frames without positional/scale motion.
  static bool reduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Asserts (in debug) that the configured durations stay within
  /// the design bands. Property 9 — durations ∈ [100, 400] ms for
  /// micro, [200, 400] ms for page transitions.
  static void assertBands() {
    assert(
      micro.inMilliseconds >= 100 && micro.inMilliseconds <= 400,
      'AppMotion.micro must be in [100, 400] ms',
    );
    assert(
      page.inMilliseconds >= 200 && page.inMilliseconds <= 400,
      'AppMotion.page must be in [200, 400] ms',
    );
  }
}
