import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_icons.dart';

import '../../support/gen.dart';

void main() {
  group('AppIcons.byName — Property 6 (icon half)', () {
    test('returns the fallback for null/empty input without throwing', () {
      expect(AppIcons.byName(null), AppIcons.fallback);
      expect(AppIcons.byName(''), AppIcons.fallback);
    });

    test('returns a real IconData for known keys', () {
      for (final key in const [
        'dashboard',
        'medicines',
        'categories',
        'suppliers',
        'stockIn',
        'stockOut',
        'lowStock',
        'expired',
        'empty',
        'error',
        'retry',
        'add',
        'search',
        'edit',
        'delete',
        'close',
        'check',
        'chevronRight',
      ]) {
        expect(AppIcons.byName(key), isA<IconData>());
        expect(AppIcons.byName(key).codePoint, greaterThan(0));
      }
    });

    test('returns the fallback for unknown keys without throwing', () {
      expect(AppIcons.byName('not-a-real-icon'), AppIcons.fallback);
      expect(AppIcons.byName('??'), AppIcons.fallback);
      expect(AppIcons.byName(' '), AppIcons.fallback);
    });

    test('Property 6 — randomized inputs never throw and stay valid', () {
      // Generative loop over 1000 random strings + edge cases.
      const iterations = 1000;
      final r = rng(0xA1C0);
      for (var i = 0; i < iterations; i++) {
        final s = r.nextString(minLength: 0, maxLength: 64);
        final IconData icon;
        try {
          icon = AppIcons.byName(s);
        } catch (e) {
          fail('AppIcons.byName threw for input "$s": $e');
        }
        expect(icon, isA<IconData>());
        expect(icon.codePoint, greaterThan(0));
      }
    });
  });
}
