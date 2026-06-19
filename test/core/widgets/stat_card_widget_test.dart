import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_colors.dart';
import 'package:medistock_mobile/core/theme/app_icons.dart';
import 'package:medistock_mobile/core/widgets/stat_card.dart';

void main() {
  group('StatCard — widget tests', () {
    testWidgets('renders the label and a numeric value when value is set',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Total Obat',
              value: 42,
              icon: AppIcons.medicines,
              accent: AppColors.primary,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Total Obat'), findsOneWidget);
      // Initial value should be the target.
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows a — placeholder when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Stok Rendah',
              icon: AppIcons.lowStock,
              accent: AppColors.warning,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Stok Rendah'), findsOneWidget);
    });

    testWidgets('counter animates and reaches the target within 600 ms',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Mutasi Hari Ini',
              value: 10,
              icon: AppIcons.stockMovements,
              accent: AppColors.info,
            ),
          ),
        ),
      );
      // Pump the full animation duration plus a frame to settle.
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('counter updates when value changes', (tester) async {
      var value = 1;
      late StateSetter outerSet;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                outerSet = setState;
                return StatCard(
                  label: 'Counter',
                  value: value,
                  icon: AppIcons.dashboard,
                  accent: AppColors.primary,
                );
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('1'), findsOneWidget);
      outerSet(() => value = 25);
      // Pump one frame so the new TweenAnimationBuilder is built, then
      // advance the full animation duration.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('tappable StatCard exposes a Material InkWell', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Tappable',
              value: 3,
              icon: AppIcons.dashboard,
              accent: AppColors.primary,
              onTap: () => taps++,
            ),
          ),
        ),
      );
      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(StatCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('non-tappable StatCard does not render an InkWell',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Read-only',
              value: 7,
              icon: AppIcons.dashboard,
              accent: AppColors.primary,
            ),
          ),
        ),
      );
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
