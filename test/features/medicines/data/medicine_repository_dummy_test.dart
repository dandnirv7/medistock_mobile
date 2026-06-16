import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository_dummy.dart';

void main() {
  late MedicineRepositoryDummy repo;

  setUp(() {
    repo = MedicineRepositoryDummy();
  });

  test('default list returns paginated items with defaults', () async {
    final res = await repo.getAll(query: MedicineQuery(limit: 100));
    expect(res.items, isNotEmpty);
    expect(res.total, greaterThan(0));
    expect(res.page, 1);
  });

  test('search filter narrows the list', () async {
    final all = await repo.getAll(query: MedicineQuery(limit: 100));
    final narrowed = await repo.getAll(
      query: MedicineQuery(search: 'Paracetamol', limit: 100),
    );
    expect(narrowed.total, lessThan(all.total));
    expect(
      narrowed.items.every((m) => m.name.toLowerCase().contains('paracetamol')),
      true,
    );
  });

  test('lowStockOnly flag returns only low-stock medicines', () async {
    final res = await repo.getAll(
      query: MedicineQuery(lowStockOnly: true, limit: 100),
    );
    expect(res.items.every((m) => m.isLowStock), true);
  });

  test('expired filter returns only expired', () async {
    final res = await repo.getAll(
      query: MedicineQuery(
        expiredFilter: MedicineExpiredFilter.expired,
        limit: 100,
      ),
    );
    expect(res.items.every((m) => m.isExpired), true);
  });

  test('pagination splits results across pages', () async {
    final page1 = await repo.getAll(
      query: MedicineQuery(page: 1, limit: 5),
    );
    final page2 = await repo.getAll(
      query: MedicineQuery(page: 2, limit: 5),
    );
    expect(page1.items.length, lessThanOrEqualTo(5));
    final ids1 = page1.items.map((m) => m.id).toSet();
    final ids2 = page2.items.map((m) => m.id).toSet();
    expect(ids1.intersection(ids2), isEmpty);
  });

  test('create + delete', () async {
    final created = await repo.create(
      code: 'TEST-001',
      name: 'Test Medicine',
      categoryId: 'cat-1',
      supplierId: 'sup-1',
      unit: 'Tablet',
      purchasePrice: 100,
      sellingPrice: 200,
      currentStock: 10,
      minimumStock: 5,
    );
    expect(created.code, 'TEST-001');
    final list = await repo.getAll(
      query: MedicineQuery(search: 'TEST-001', limit: 100),
    );
    expect(list.items, isNotEmpty);
    await repo.delete(created.id);
    final after = await repo.getAll(
      query: MedicineQuery(search: 'TEST-001', limit: 100),
    );
    expect(after.items, isEmpty);
  });
}
