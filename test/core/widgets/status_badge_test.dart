// Property 5 — every (tone, background) pair must meet WCAG AA contrast
// (>= 4.5:1) for the badge label.
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/widgets/status_badge.dart';

import '../../support/gen.dart';

void main() {
  group('Property 5 - StatusBadge contrast invariant', () {
    test('every tone meets WCAG AA on a light surface background', () {
      const surface = 0xFFFFFFFF;
      for (final tone in BadgeTone.values) {
        // The badge text uses onColor (a darker shade of the tone) so
        // it stays legible on the 12%-alpha background.
        final fg = tone.onColor;
        final bg = blendArgb(tone.color, surface, 0.12);
        final ratio = contrastRatio(fg, bg);
        expect(ratio, greaterThanOrEqualTo(4.5),
            reason: '$tone contrast=$ratio is below WCAG AA');
      }
    });

    test('Property 5 - randomized surfaces still pass WCAG AA for the four tones', () {
      const iterations = 100;
      final r = rng(0xC0DE);
      for (var i = 0; i < iterations; i++) {
        final r0 = r.nextBoundedInt(0xEE, 0xFF);
        final g0 = r.nextBoundedInt(0xEE, 0xFF);
        final b0 = r.nextBoundedInt(0xEE, 0xFF);
        final surface = (0xFF << 24) | (r0 << 16) | (g0 << 8) | b0;
        for (final tone in BadgeTone.values) {
          final fg = tone.onColor;
          final bg = blendArgb(tone.color, surface, 0.12);
          final ratio = contrastRatio(fg, bg);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason:
                  'iteration $i, $tone: contrast=$ratio (surface=0x${surface.toRadixString(16)})');
        }
      }
    });
  });
}

/// Alpha blend a [Color] over a packed [background] ARGB int.
int blendArgb(Color fg, int bgInt, double alpha) {
  final a = (alpha * 255).round();
  final aComp = 255 - a;
  final fr = (fg.r * 255).round();
  final fg2 = (fg.g * 255).round();
  final fb = (fg.b * 255).round();
  final br = (bgInt >> 16) & 0xFF;
  final bg2 = (bgInt >> 8) & 0xFF;
  final bb = bgInt & 0xFF;
  final r = (fr * a + br * aComp) ~/ 255;
  final g = (fg2 * a + bg2 * aComp) ~/ 255;
  final b = (fb * a + bb * aComp) ~/ 255;
  return (0xFF << 24) | (r << 16) | (g << 8) | b;
}

/// WCAG 2.x relative luminance for an ARGB int.
double relativeLuminance(int argb) {
  double channel(int c) {
    final v = c / 255.0;
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }
  final r = channel((argb >> 16) & 0xFF);
  final g = channel((argb >> 8) & 0xFF);
  final b = channel(argb & 0xFF);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG contrast ratio between two ARGB ints.
double contrastRatioInt(int a, int b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final l1 = la > lb ? la : lb;
  final l2 = la > lb ? lb : la;
  return (l1 + 0.05) / (l2 + 0.05);
}

/// Convenience: ratio between a [Color] foreground and a packed ARGB bg.
double contrastRatio(Color fg, int bg) {
  final fgArgb =
      ((fg.a * 255).round() << 24) |
      ((fg.r * 255).round() << 16) |
      ((fg.g * 255).round() << 8) |
      (fg.b * 255).round();
  return contrastRatioInt(fgArgb, bg);
}
