import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository_dummy.dart';

void main() {
  late CategoryRepositoryDummy repo;

  setUp(() {
    repo = CategoryRepositoryDummy();
  });

  test('default list returns active categories', () async {
    final res = await repo.getAll();
    expect(res.items, isNotEmpty);
    expect(res.items.every((c) => c.isActive), true);
  });

  test('search narrows the list', () async {
    final all = await repo.getAll();
    final narrowed = await repo.getAll(
      query: CategoryQuery(search: 'anal'),
    );
    expect(narrowed.total, lessThan(all.total));
  });

  test('create + delete is a soft delete', () async {
    final created = await repo.create(
      name: 'Kategori Test',
      description: 'desc',
    );
    expect(created.isActive, true);
    await repo.delete(created.id);
    final res = await repo.getAll(
      query: CategoryQuery(search: 'Kategori Test'),
    );
    expect(res.items, isEmpty);
  });
}
