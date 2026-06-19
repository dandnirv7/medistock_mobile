import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/widgets/empty_state.dart';
import 'package:medistock_mobile/core/widgets/error_view.dart';

void main() {
  group('EmptyState / ErrorView interactions', () {
    testWidgets('EmptyState shows the primary action when provided',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Belum ada obat',
              subtitle: 'Tambahkan obat pertama Anda',
              primaryActionLabel: 'Tambah Obat',
              onPrimaryAction: () => taps++,
            ),
          ),
        ),
      );
      expect(find.text('Belum ada obat'), findsOneWidget);
      expect(find.text('Tambah Obat'), findsOneWidget);
      await tester.tap(find.text('Tambah Obat'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('EmptyState without action hides the action button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(title: 'Empty'),
          ),
        ),
      );
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('ErrorView retry button is disabled while isRetrying',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Gagal memuat data',
              onRetry: () => taps++,
              isRetrying: true,
            ),
          ),
        ),
      );
      expect(find.text('Gagal memuat data'), findsOneWidget);
      // The retry button is in a loading state: the label is replaced
      // by a spinner, and the underlying AppButton has its onPressed
      // set to null. We can still try to tap the AppButton, but it
      // should be a no-op.
      final btnFinder = find.byType(InkWell).first;
      await tester.tap(btnFinder, warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('ErrorView retry fires once isRetrying clears', (tester) async {
      var isRetrying = true;
      var taps = 0;
      late StateSetter outerSet;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                outerSet = setState;
                return ErrorView(
                  message: 'Gagal',
                  onRetry: () => taps++,
                  isRetrying: isRetrying,
                );
              },
            ),
          ),
        ),
      );
      outerSet(() => isRetrying = false);
      await tester.pump();
      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      expect(taps, 1);
    });
  });
}
