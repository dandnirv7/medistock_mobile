import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_colors.dart';
import 'package:medistock_mobile/core/theme/app_icons.dart';
import 'package:medistock_mobile/core/widgets/stat_card.dart';

void main() {
  group('StatCard — unit subtitle', () {
    testWidgets('renders the unit string below the numeric value',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Total Obat',
              value: 1248,
              icon: AppIcons.medicines,
              accent: AppColors.primary,
              unit: 'Jenis',
              duration: Duration.zero,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1248'), findsOneWidget);
      expect(find.text('Jenis'), findsOneWidget);
      expect(find.text('Total Obat'), findsOneWidget);
    });

    testWidgets('omits the unit row when unit is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Stok Rendah',
              value: 5,
              icon: AppIcons.lowStock,
              accent: AppColors.warning,
              duration: Duration.zero,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
      // No unit should be rendered — there is no way for the empty/null
      // value to render as anything other than the value itself.
      expect(find.text('Jenis'), findsNothing);
      expect(find.text('Obat'), findsNothing);
    });

    testWidgets('omits the unit row when unit is an empty string',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Supplier',
              value: 3,
              icon: AppIcons.suppliers,
              accent: AppColors.info,
              unit: '',
              duration: Duration.zero,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    });
  });
}
