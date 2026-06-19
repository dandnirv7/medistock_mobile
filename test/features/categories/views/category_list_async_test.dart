// End-to-end widget tests for the CategoryList view (Task 12.5).
//
// Verifies the four state transitions (loading -> content, loading ->
// empty, loading -> error + retry, pull-to-refresh) using a fake
// repository injected through the GetX binding.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/models/paginated.dart';
import 'package:medistock_mobile/core/widgets/skeleton_loader.dart';
import 'package:medistock_mobile/core/utils/ui_state.dart';
import 'package:medistock_mobile/features/categories/controllers/category_list_controller.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository.dart';
import 'package:medistock_mobile/features/categories/models/category_model.dart';
import 'package:medistock_mobile/features/categories/views/category_list_view.dart';

import '../../../test_helpers.dart';

class _FakeRepo implements CategoryRepository {
  _FakeRepo(this._initial);
  List<CategoryModel> _initial;
  int getAllCalls = 0;
  int refreshCalls = 0;
  bool throwOnGetAll = false;
  Duration getAllDelay = Duration.zero;

  @override
  Future<Paginated<CategoryModel>> getAll({
    CategoryQuery? query,
  }) async {
    getAllCalls++;
    if (getAllDelay > Duration.zero) {
      await Future<void>.delayed(getAllDelay);
    }
    if (throwOnGetAll) {
      throw StateError('boom');
    }
    return Paginated<CategoryModel>(
      items: _initial,
      total: _initial.length,
      page: 1,
      limit: 20,
      totalPages: 1,
    );
  }

  @override
  Future<CategoryModel> getById(String id) async {
    return _initial.firstWhere((c) => c.id == id);
  }

  @override
  Future<CategoryModel> create({required String name, String? description}) async {
    final c = CategoryModel(
      id: 'new-${_initial.length + 1}',
      name: name,
      description: description,
    );
    _initial = [..._initial, c];
    return c;
  }

  @override
  Future<void> delete(String id) async {
    _initial = _initial.where((c) => c.id != id).toList();
  }

  @override
  Future<CategoryModel> update(
    String id, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    return _initial.firstWhere((c) => c.id == id);
  }
}

Future<void> _setUpController(CategoryRepository repo) async {
  await registerTestServices();
  if (Get.isRegistered<CategoryRepository>()) {
    await Get.delete<CategoryRepository>(force: true);
  }
  Get.put<CategoryRepository>(repo, permanent: true);
  Get.put<CategoryListController>(
    CategoryListController(Get.find<CategoryRepository>()),
    permanent: true,
  );
}

void main() {
  group('CategoryListView - data states', () {
    tearDown(() async {
      await Get.deleteAll(force: true);
    });

    testWidgets('skeleton -> content', (tester) async {
      final repo = _FakeRepo([
        CategoryModel(id: '1', name: 'Analgesik'),
        CategoryModel(id: '2', name: 'Antibiotik'),
      ]);
      await _setUpController(repo);
      repo.getAllDelay = const Duration(milliseconds: 50);

      await tester.pumpWidget(
        const MaterialApp(home: CategoryListView()),
      );
      // Loading state: skeleton visible.
      await tester.pump();
      expect(find.byType(ListSkeleton), findsOneWidget);

      // After the fetch resolves: content is shown.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Analgesik'), findsOneWidget);
      expect(find.text('Antibiotik'), findsOneWidget);
      expect(find.byType(ListSkeleton), findsNothing);
    });

    testWidgets('skeleton -> empty (with action)', (tester) async {
      final repo = _FakeRepo(const <CategoryModel>[]);
      await _setUpController(repo);

      await tester.pumpWidget(
        const MaterialApp(home: CategoryListView()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Belum ada kategori'), findsOneWidget);
      expect(find.text('Tambah Kategori'), findsOneWidget);
    });

    testWidgets('skeleton -> error + retry recovers', (tester) async {
      final repo = _FakeRepo(const <CategoryModel>[]);
      await _setUpController(repo);

      await tester.pumpWidget(
        const MaterialApp(home: CategoryListView()),
      );
      await tester.pump();

      // Trigger error and let the controller settle.
      repo.throwOnGetAll = true;
      await Get.find<CategoryListController>().load();
      // Wait for the error message to populate. The data load is async,
      // so we pump until the controller reports an error or time out.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        if (Get.find<CategoryListController>().state.value == ViewState.error) {
          break;
        }
      }
      expect(Get.find<CategoryListController>().state.value, ViewState.error);
      // The error view's message is the controller's errorMessage.
      final msg = Get.find<CategoryListController>().errorMessage.value;
      expect(find.text(msg), findsOneWidget);

      // Recover.
      repo.throwOnGetAll = false;
      repo._initial = [CategoryModel(id: '1', name: 'Recovered')];
      await tester.tap(find.text('Coba lagi'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Recovered'), findsOneWidget);
    });

    testWidgets('pull-to-refresh triggers refresh() once and is in-flight guarded',
        (tester) async {
      final repo = _FakeRepo([
        CategoryModel(id: '1', name: 'A'),
      ]);
      await _setUpController(repo);
      repo.getAllDelay = const Duration(milliseconds: 100);

      await tester.pumpWidget(
        const MaterialApp(home: CategoryListView()),
      );
      await tester.pump(const Duration(milliseconds: 150));

      // Wait for the initial load to complete.
      await tester.pump(const Duration(milliseconds: 200));
      final controller = Get.find<CategoryListController>();
      final initialCalls = repo.getAllCalls;

      // Fire two refreshes back-to-back. The first one increments the
      // call counter; the second is a no-op while the first is in
      // flight (the AsyncListState guard rejects concurrent calls).
      // We don't await the futures directly because the in-test
      // FakeAsync clock needs explicit pumps for the delay to elapse.
      final f1 = controller.refresh();
      await tester.pump(const Duration(milliseconds: 20));
      final f2 = controller.refresh();
      // Now advance enough time for the first refresh to complete.
      await tester.pump(const Duration(milliseconds: 200));
      await f1;
      await f2;
      // Exactly one extra underlying call from the refresh; the
      // second was a no-op while the first was in flight.
      expect(repo.getAllCalls - initialCalls, 1);
    });
  });

  test('AsyncListState mixin exposes the expected shape', () {
    // Sanity: confirm the controller carries the ViewState contract.
    final c = CategoryListController(_FakeRepo(const <CategoryModel>[]));
    expect(c.state, isA<Rx<ViewState>>());
    expect(c.items, isA<RxList<CategoryModel>>());
    expect(c.errorMessage, isA<RxString>());
    expect(c.isRefreshing, isA<RxBool>());
  });
}
