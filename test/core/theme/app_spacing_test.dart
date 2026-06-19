import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_spacing.dart';

import '../../support/gen.dart';

void main() {
  group('AppSpacing — Property 2: spacing closure', () {
    test('constants are members of {4, 8, 12, 16, 24}', () {
      for (final v in [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ]) {
        expect(AppSpacing.contains(v), isTrue,
            reason: '$v is not in the allowed set');
      }
    });

    test('the allowed set has exactly five values: 4, 8, 12, 16, 24', () {
      expect(AppSpacing.allowed.toList(), <double>{4, 8, 12, 16, 24});
      expect(AppSpacing.allowed.length, 5);
    });

    test('Property 2 — random non-token values are NOT in allowed set', () {
      const iterations = 200;
      final r = rng(0xC1C0);
      for (var i = 0; i < iterations; i++) {
        final v = r.nextBoundedDouble(0, 100);
        // Random floats are almost certainly not in the set; the
        // generator never picks the exact tokens in the same range.
        if (AppSpacing.contains(v)) {
          // Acceptable only if the random draw happened to land on a token.
          expect(v, anyOf(4, 8, 12, 16, 24));
        } else {
          // Not in the set — this is the common case.
          expect(v, isNot(anyOf(4, 8, 12, 16, 24)));
        }
      }
    });
  });

  group('AppRadii', () {
    test('exposes the expected numeric tokens', () {
      expect(AppRadii.sm, 8);
      expect(AppRadii.md, 10);
      expect(AppRadii.lg, 12);
      expect(AppRadii.pill, 999);
    });

    test('radius() and border() default to md when no value given', () {
      expect(AppRadii.radius().x, AppRadii.md);
      expect(AppRadii.border().topLeft.x, AppRadii.md);
    });
  });
}
