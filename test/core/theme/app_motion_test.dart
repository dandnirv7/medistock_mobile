import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_motion.dart';

void main() {
  group('Property 9 - duration clamp', () {
    test('micro duration is in [100, 400] ms', () {
      expect(AppMotion.micro.inMilliseconds, inInclusiveRange(100, 400));
    });

    test('page transition duration is in [200, 400] ms', () {
      expect(AppMotion.page.inMilliseconds, inInclusiveRange(200, 400));
    });

    test('all configured durations satisfy their bands', () {
      final micros = <Duration>[AppMotion.micro, AppMotion.press];
      for (final d in micros) {
        expect(d.inMilliseconds, inInclusiveRange(100, 400),
            reason: '$d not in micro band');
      }
      final pages = <Duration>[AppMotion.page];
      for (final d in pages) {
        expect(d.inMilliseconds, inInclusiveRange(200, 400),
            reason: '$d not in page band');
      }
      // Skimmer cycle is allowed to live outside the micro band; the
      // band requirement applies to discrete transitions, not the
      // looping cadence. Still assert it is positive.
      expect(AppMotion.shimmer.inMilliseconds, greaterThan(0));
    });

    test('assertBands() does not throw', () {
      AppMotion.assertBands();
    });
  });
}
