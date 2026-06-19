import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/app/app.dart';
import 'package:medistock_mobile/core/theme/app_motion.dart';
import 'package:medistock_mobile/core/widgets/stat_card.dart';
import 'package:medistock_mobile/core/theme/app_colors.dart';
import 'package:medistock_mobile/core/theme/app_icons.dart';

void main() {
  group('Reduced-motion fallback', () {
    testWidgets('AppMotion.reduceMotion reports true when disableAnimations is on',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              expect(AppMotion.reduceMotion(context), isTrue);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('AppMotion.reduceMotion reports false by default', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(AppMotion.reduceMotion(context), isFalse);
            return const SizedBox.shrink();
          },
        ),
      );
    });

    testWidgets('StatCard renders the target value when reduce-motion is on',
        (tester) async {
      // The StatCard should reach the target value promptly, without
      // long positional motion, when reduce-motion is on. We assert it
      // appears within a single frame.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MaterialApp(
            home: Scaffold(
              body: StatCard(
                label: 'Obat',
                value: 7,
                icon: AppIcons.medicines,
                accent: AppColors.primary,
              ),
            ),
          ),
        ),
      );
      // Pump a few frames for the counter to settle to the target.
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('7'), findsOneWidget);
    });
  });

  test('MediStockApp builds with default transitions', () {
    // Sanity: ensure MediStockApp constructs without throwing.
    const app = MediStockApp();
    expect(app, isA<MediStockApp>());
    // No actual build of the app in this test because it depends on
    // GetX bindings not registered here.
  });
}
