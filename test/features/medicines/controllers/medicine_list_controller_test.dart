import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/models/paginated.dart';
import 'package:medistock_mobile/core/network/api_client.dart';
import 'package:medistock_mobile/core/storage/secure_storage_service.dart';
import 'package:medistock_mobile/features/medicines/controllers/medicine_list_controller.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/medicines/models/medicine_model.dart';

/// A repository that resolves a [Completer] per call so the test can hold
/// responses back and stage overlapping calls deterministically.
class _FakeRepo implements MedicineRepository {
  final List<Completer<Paginated<MedicineModel>>> pending = [];
  int callCount = 0;

  @override
  Future<Paginated<MedicineModel>> getAll({
    MedicineQuery? query,
    CancelToken? cancelToken,
  }) {
    callCount++;
    final completer = Completer<Paginated<MedicineModel>>();
    pending.add(completer);
    cancelToken?.whenCancel
        .then((_) => completer.completeError(DioException(
              requestOptions: RequestOptions(path: '/medicines'),
              type: DioExceptionType.cancel,
            )));
    return completer.future;
  }

  @override
  Future<MedicineModel> getById(String id) =>
      throw UnimplementedError();

  @override
  Future<MedicineModel> create({
    required String code,
    required String name,
    String? categoryId,
    String? supplierId,
    required String unit,
    required double purchasePrice,
    required double sellingPrice,
    int currentStock = 0,
    required int minimumStock,
    DateTime? expiredDate,
    String? description,
  }) =>
      throw UnimplementedError();

  @override
  Future<MedicineModel> update(
    String id, {
    String? code,
    String? name,
    String? categoryId,
    String? supplierId,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? minimumStock,
    DateTime? expiredDate,
    String? description,
    bool? isActive,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();
}

MedicineModel _med(String id, String name) => MedicineModel(
      id: id,
      code: 'C-$id',
      name: name,
      unit: 'pcs',
      purchasePrice: 1,
      sellingPrice: 1,
      currentStock: 5,
      minimumStock: 1,
    );

Paginated<MedicineModel> _page(List<MedicineModel> items) => Paginated(
      items: items,
      page: 1,
      limit: 20,
      total: items.length,
      totalPages: 1,
    );

void main() {
  group('MedicineListController race-safety', () {
    late _FakeRepo repo;
    late MedicineListController ctrl;

    setUp(() {
      repo = _FakeRepo();
      ctrl = MedicineListController(
        repo,
        apiClient: ApiClient(storage: SecureStorageService()),
      );
    });

    test('rapid filter swap keeps only the latest response', () async {
      // Fire two overlapping load() calls — second call simulates a
      // tab change that arrives before the first one resolves.
      final first = ctrl.load();
      // Yield so the first call registers a CancelToken before the second.
      await Future<void>.delayed(Duration.zero);
      final second = ctrl.load();

      expect(repo.callCount, 2);

      // Second call's token is active; the first should be cancelled.
      // Stage responses: second call's response arrives first, then the
      // (now-cancelled) first call would have arrived.
      repo.pending[1].complete(_page([_med('1', 'Amlodipine')]));
      await second;

      // Items reflect the second call only.
      expect(ctrl.items.length, 1);
      expect(ctrl.items.first.id, '1');

      // Now resolve the first call — it must be discarded, not overwrite.
      repo.pending[0].complete(_page([_med('2', 'B'), _med('3', 'C')]));
      await first;

      expect(ctrl.items.length, 1);
      expect(ctrl.items.first.id, '1');
    });

    test('onClose cancels the in-flight request', () async {
      final future = ctrl.load();
      expect(repo.callCount, 1);
      // Resolve only after onClose, simulating a slow network.
      ctrl.onClose();
      repo.pending.first.complete(_page([_med('1', 'A')]));
      // Should not throw, items stay empty (controller is closed).
      await future;
    });
  });
}
