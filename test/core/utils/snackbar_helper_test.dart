import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/utils/snackbar_helper.dart';

import '../../support/gen.dart';

void main() {
  group('SnackbarHelper.resolveMessage — Property 4: Message length bound', () {
    test('null and empty input produce the default message within bounds', () {
      final success = SnackbarHelper.resolveMessage(null, isError: false);
      final error = SnackbarHelper.resolveMessage(null, isError: true);
      expect(success.length, inInclusiveRange(1, 200));
      expect(error.length, inInclusiveRange(1, 200));
    });

    test('blank input is replaced with the default', () {
      expect(
        SnackbarHelper.resolveMessage('   ', isError: false),
        SnackbarHelper.resolveMessage(null, isError: false),
      );
    });

    test('normal strings pass through untouched', () {
      const m = 'Item saved successfully';
      expect(SnackbarHelper.resolveMessage(m, isError: false), m);
    });

    test('Property 4 — random strings always clamp into [1, 200]', () {
      const iterations = 2000;
      final r = rng(0xD1C0);
      for (var i = 0; i < iterations; i++) {
        // Sometimes null, sometimes empty, sometimes random.
        String? input;
        final mode = r.nextBoundedInt(0, 3);
        switch (mode) {
          case 0:
            input = null;
            break;
          case 1:
            input = '';
            break;
          case 2:
            input = '   ';
            break;
          default:
            input = r.nextString(minLength: 0, maxLength: 1024);
        }
        final success = SnackbarHelper.resolveMessage(input, isError: false);
        final error = SnackbarHelper.resolveMessage(input, isError: true);
        expect(success.length, inInclusiveRange(1, 200));
        expect(error.length, inInclusiveRange(1, 200));
      }
    });
  });
}
