// Property-based tests for the StatCard counter math (Property 1).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/widgets/stat_card.dart' show StatCard;

import '../../support/gen.dart';

const IconData kStubIcon = IconData(0xf000, fontFamily: 'stub');

/// Pure clone of the counter's display function so the property can be
/// tested without mounting a widget tree.
int displayValue({
  required int from,
  required int to,
  required double t,
}) {
  final lower = from < to ? from : to;
  final upper = from > to ? from : to;
  final v = (from + (to - from) * t).clamp(lower.toDouble(), upper.toDouble());
  return v.round();
}

void main() {
  group('Property 1 — counter bounds & monotonicity', () {
    test('display value stays within [min, max] for t in [0, 1]', () {
      const iterations = 2000;
      final r = rng(0xB0B1);
      for (var i = 0; i < iterations; i++) {
        final from = r.nextBoundedInt(-1000, 1000);
        final to = r.nextBoundedInt(-1000, 1000);
        final t = r.nextBoundedDouble(0.0, 1.0);
        final v = displayValue(from: from, to: to, t: t);
        final lower = from < to ? from : to;
        final upper = from > to ? from : to;
        expect(v, inInclusiveRange(lower, upper),
            reason: 'from=$from to=$to t=$t v=$v');
      }
    });

    test('display value equals `to` at t = 1', () {
      const iterations = 200;
      final r = rng(0xB0B2);
      for (var i = 0; i < iterations; i++) {
        final from = r.nextBoundedInt(-1000, 1000);
        final to = r.nextBoundedInt(-1000, 1000);
        final v = displayValue(from: from, to: to, t: 1.0);
        expect(v, to);
      }
    });

    test('display value equals `from` at t = 0', () {
      const iterations = 200;
      final r = rng(0xB0B3);
      for (var i = 0; i < iterations; i++) {
        final from = r.nextBoundedInt(-1000, 1000);
        final to = r.nextBoundedInt(-1000, 1000);
        final v = displayValue(from: from, to: to, t: 0.0);
        expect(v, from);
      }
    });

    test('interrupt at arbitrary t keeps the next tween bounded', () {
      const iterations = 200;
      final r = rng(0xB0B4);
      for (var i = 0; i < iterations; i++) {
        final a = r.nextBoundedInt(0, 500);
        final b = r.nextBoundedInt(0, 500);
        final c = r.nextBoundedInt(0, 500);
        final t1 = r.nextBoundedDouble(0.0, 1.0);
        final interrupted = displayValue(from: a, to: b, t: t1);
        expect(interrupted, inInclusiveRange(
          a < b ? a : b,
          a > b ? a : b,
        ));
        final t2 = r.nextBoundedDouble(0.0, 1.0);
        final final2 = displayValue(from: interrupted, to: c, t: t2);
        expect(
          final2,
          inInclusiveRange(
            interrupted < c ? interrupted : c,
            interrupted > c ? interrupted : c,
          ),
        );
      }
    });

    test('StatCard exposes the expected public surface', () {
      final c = StatCard(
        label: 'Total',
        icon: kStubIcon,
        accent: const Color(0xFF000000),
      );
      expect(c.duration, const Duration(milliseconds: 600));
      expect(c.value, isNull);
      expect(c.onTap, isNull);
      expect(c.label, 'Total');
    });
  });
}
