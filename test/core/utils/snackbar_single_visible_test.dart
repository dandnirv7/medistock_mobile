import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/utils/snackbar_helper.dart';

import '../../support/gen.dart';

void main() {
  group('SnackbarHelper — Property 3: Single-visible invariant', () {
    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
    }

    Future<void> flush(WidgetTester tester) async {
      // Wait long enough for any in-flight GetX snackbar animation to
      // finalize, but cap the duration so the test doesn't hang.
      await tester.pumpAndSettle(const Duration(seconds: 4));
    }

    testWidgets('last call wins; only one snackbar visible at a time',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      final sequence = <(bool isError, String msg)>[
        (false, 'Saved draft'),
        (true, 'Network error'),
        (false, 'Saved again'),
        (true, 'Permission denied'),
      ];

      for (final (isError, msg) in sequence) {
        if (isError) {
          SnackbarHelper.error(msg);
        } else {
          SnackbarHelper.success(msg);
        }
        await settle(tester);
      }

      // The most recent call's message is the visible one.
      expect(SnackbarHelper.debugLastMessage, sequence.last.$2);
      expect(SnackbarHelper.debugLastTitle, 'Error');

      // At most one snackbar is in the overlay at a time.
      final snackbarsVisible = find.byType(SnackBar);
      expect(snackbarsVisible.evaluate().length, lessThanOrEqualTo(1));

      await flush(tester);
    });

    testWidgets('Property 3 — random call sequences keep single-visible',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      const iterations = 10;
      final r = rng(0xE1C0);

      for (var i = 0; i < iterations; i++) {
        final isError = r.nextBoundedInt(0, 1) == 1;
        final msg = r.nextString(minLength: 1, maxLength: 64);
        if (isError) {
          SnackbarHelper.error(msg);
        } else {
          SnackbarHelper.success(msg);
        }
        await settle(tester);
        // Single-visible invariant.
        final count = find.byType(SnackBar).evaluate().length;
        expect(count, lessThanOrEqualTo(1),
            reason: 'iteration $i: $count snackbars visible');
        // The most recent message is reflected in the helper.
        expect(SnackbarHelper.debugLastMessage, msg);
        // Let the previous snackbar fully dismiss before the next one.
        await flush(tester);
      }
    });
  });
}
