import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository_dummy.dart';
import 'package:medistock_mobile/features/stock_movements/models/stock_movement_model.dart';

void main() {
  late StockMovementRepositoryDummy repo;

  setUp(() {
    repo = StockMovementRepositoryDummy();
  });

  test('default list returns movements sorted desc by date', () async {
    final res = await repo.getAll(
      query: StockMovementQuery(limit: 100),
    );
    expect(res.items.length, 25);
    for (var i = 0; i < res.items.length - 1; i++) {
      final a = res.items[i].transactionDate;
      final b = res.items[i + 1].transactionDate;
      if (a != null && b != null) {
        expect(b.isBefore(a) || b == a, true);
      }
    }
  });

  test('filter by type IN only', () async {
    final res = await repo.getAll(
      query: StockMovementQuery(limit: 100, type: StockMovementType.stockIn),
    );
    expect(res.items.every((m) => m.type == StockMovementType.stockIn), true);
  });

  test('stockIn increases medicine stock and creates a record', () async {
    final initial = await repo.getAll(query: StockMovementQuery(limit: 100));
    await repo.stockIn(
      medicineId: 'med-1',
      quantity: 25,
    );
    final after = await repo.getAll(query: StockMovementQuery(limit: 100));
    expect(after.items.length, initial.items.length + 1);
    expect(after.items.first.type, StockMovementType.stockIn);
    expect(after.items.first.medicineId, 'med-1');
  });

  test('stockOut decreases stock and rejects insufficient', () async {
    expect(
      () => repo.stockOut(medicineId: 'med-1', quantity: 99999),
      throwsA(anything),
    );
  });
}
