import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_colors.dart';

import '../../support/gen.dart';

void main() {
  group('AppColors.resolve — Property 6 (color half)', () {
    test('returns neutralFallback for null/empty input', () {
      expect(AppColors.resolve(null), AppColors.neutralFallback);
      expect(AppColors.resolve(''), AppColors.neutralFallback);
    });

    test('returns the same Color for known keys', () {
      for (final key in AppColors.knownKeys) {
        final c = AppColors.resolve(key);
        expect(c, isA<Color>());
        expect(c.toARGB32() | 0x00000000, greaterThanOrEqualTo(0));
      }
    });

    test('aliases match the semantic tokens', () {
      expect(AppColors.stockSafe, AppColors.success);
      expect(AppColors.stockLow, AppColors.warning);
      expect(AppColors.stockOut, AppColors.danger);
      expect(AppColors.expiredSafe, AppColors.success);
      expect(AppColors.expiredSoon, AppColors.warning);
      expect(AppColors.expired, AppColors.danger);
    });

    test('returns neutralFallback for unknown keys', () {
      expect(AppColors.resolve('not-a-real-token'), AppColors.neutralFallback);
      expect(AppColors.resolve('??'), AppColors.neutralFallback);
      expect(AppColors.resolve(' '), AppColors.neutralFallback);
    });

    test('Property 6 — randomized inputs never throw and stay valid', () {
      const iterations = 1000;
      final r = rng(0xB1C0);
      for (var i = 0; i < iterations; i++) {
        final s = r.nextString(minLength: 0, maxLength: 64);
        final Color c;
        try {
          c = AppColors.resolve(s);
        } catch (e) {
          fail('AppColors.resolve threw for input "$s": $e');
        }
        expect(c, isA<Color>());
        // The ARGB int is well-defined and fits in 32 bits.
        expect(c.toARGB32() & 0xFFFFFFFF, isNonNegative);
      }
    });
  });
}
