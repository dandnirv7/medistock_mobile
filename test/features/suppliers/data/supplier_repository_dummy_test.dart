import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/suppliers/data/repositories/supplier_repository.dart';
import 'package:medistock_mobile/features/suppliers/data/repositories/supplier_repository_dummy.dart';

void main() {
  late SupplierRepositoryDummy repo;

  setUp(() {
    repo = SupplierRepositoryDummy();
  });

  test('list returns active suppliers', () async {
    final res = await repo.getAll();
    expect(res.items, isNotEmpty);
  });

  test('search by name', () async {
    final res = await repo.getAll(
      query: SupplierQuery(search: 'Kalbe'),
    );
    expect(res.items.length, 1);
    expect(res.items.first.name, contains('Kalbe'));
  });

  test('create + soft delete', () async {
    final created = await repo.create(
      name: 'Supplier Test',
      phone: '08123',
    );
    await repo.delete(created.id);
    final res = await repo.getAll(
      query: SupplierQuery(search: 'Supplier Test'),
    );
    expect(res.items, isEmpty);
  });
}
