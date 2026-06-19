import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/widgets/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Simpan',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('shows a spinner and ignores taps while loading', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Kirim',
              isLoading: true,
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label is replaced by the spinner.
      expect(find.text('Kirim'), findsNothing);

      // Tapping the button should be a no-op while loading.
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('taps register again once loading is cleared', (tester) async {
      var taps = 0;
      var loading = true;
      late StateSetter outerSet;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                outerSet = setState;
                return AppButton(
                  label: 'Kirim',
                  isLoading: loading,
                  onPressed: () => taps++,
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(taps, 0);

      outerSet(() => loading = false);
      await tester.pump();
      // Now the button is interactive again.
      expect(find.text('Kirim'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('each variant renders without throwing', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: variant.name,
                variant: variant,
                onPressed: () {},
              ),
            ),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });
  });
}
