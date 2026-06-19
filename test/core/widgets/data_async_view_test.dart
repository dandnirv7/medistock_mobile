import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/utils/ui_state.dart';
import 'package:medistock_mobile/core/widgets/data_async_view.dart';
import 'package:medistock_mobile/core/widgets/empty_state.dart';
import 'package:medistock_mobile/core/widgets/error_view.dart';
import 'package:medistock_mobile/core/widgets/skeleton_loader.dart';

import '../../support/gen.dart';

class _IntItem {
  _IntItem(this.id);
  final int id;
}

void main() {
  group('Property 7 - DataAsyncView state exclusivity', () {
    Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('loading renders skeleton, no content/empty/error', (tester) async {
      final state = ViewState.loading.obs;
      final items = <_IntItem>[].obs;
      await tester.pumpWidget(host(DataAsyncView<_IntItem>(
        state: state,
        items: items,
        builder: (_, _) => const Text('content'),
      )));
      expect(find.byType(ListSkeleton), findsOneWidget);
      expect(find.text('content'), findsNothing);
      expect(find.byType(EmptyState), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('content renders builder; skeleton/empty/error hidden', (tester) async {
      final state = ViewState.content.obs;
      final items = <_IntItem>[_IntItem(1), _IntItem(2)].obs;
      await tester.pumpWidget(host(DataAsyncView<_IntItem>(
        state: state,
        items: items,
        builder: (_, list) => Text('count=${list.length}'),
      )));
      expect(find.text('count=2'), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.byType(EmptyState), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('empty renders EmptyState; skeleton/error hidden', (tester) async {
      final state = ViewState.empty.obs;
      final items = <_IntItem>[].obs;
      await tester.pumpWidget(host(DataAsyncView<_IntItem>(
        state: state,
        items: items,
        builder: (_, _) => const Text('content'),
        emptyTitle: 'No data',
      )));
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('error renders ErrorView; skeleton/empty hidden', (tester) async {
      final state = ViewState.error.obs;
      final items = <_IntItem>[].obs;
      var retries = 0;
      await tester.pumpWidget(host(DataAsyncView<_IntItem>(
        state: state,
        items: items,
        builder: (_, _) => const Text('content'),
        errorMessage: 'Gagal memuat'.obs,
        onRetry: () async => retries++,
      )));
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Gagal memuat'), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('content with empty items falls back to empty', (tester) async {
      final state = ViewState.content.obs;
      final items = <_IntItem>[].obs;
      await tester.pumpWidget(host(DataAsyncView<_IntItem>(
        state: state,
        items: items,
        builder: (_, _) => const Text('content'),
        emptyTitle: 'No data',
      )));
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('Property 7 - state exclusivity for every ViewState value',
        (tester) async {
      const iterations = 20;
      final r = rng(0xD07A);
      for (var i = 0; i < iterations; i++) {
        // Pick a random ViewState and a random item count.
        final s = ViewState.values[r.nextBoundedInt(0, ViewState.values.length - 1)];
        final n = r.nextBoundedInt(0, 3);
        final state = s.obs;
        final items = <_IntItem>[
          for (var k = 0; k < n; k++) _IntItem(k),
        ].obs;
        await tester.pumpWidget(host(DataAsyncView<_IntItem>(
          state: state,
          items: items,
          builder: (_, list) => Text('count=${list.length}'),
          emptyTitle: 'No data',
          errorMessage: 'fail'.obs,
        )));
        // Count how many distinct "view kinds" are present.
        final hasSkeleton = find.byType(ListSkeleton).evaluate().isNotEmpty;
        final hasContent = find.text('count=$n').evaluate().isNotEmpty;
        final hasEmpty = find.byType(EmptyState).evaluate().isNotEmpty;
        final hasError = find.byType(ErrorView).evaluate().isNotEmpty;
        // Exclusive: at most one is true.
        final count = [hasSkeleton, hasContent, hasEmpty, hasError]
            .where((e) => e)
            .length;
        expect(count, lessThanOrEqualTo(1),
            reason: 'iteration $i (state=$s n=$n): $count kinds present');
        // Skeleton never co-renders with empty/error.
        if (hasSkeleton) {
          expect(hasEmpty, isFalse);
          expect(hasError, isFalse);
        }
      }
    });
  });
}
