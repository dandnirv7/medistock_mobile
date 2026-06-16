import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/categories/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('fromJson parses api response', () {
      final c = CategoryModel.fromJson({
        'id': 'cat-1',
        'name': 'Analgesik',
        'description': 'Pereda nyeri',
        'isActive': true,
        'medicineCount': 5,
        'createdAt': '2025-01-05T00:00:00.000Z',
        'updatedAt': '2025-01-05T00:00:00.000Z',
      });
      expect(c.id, 'cat-1');
      expect(c.name, 'Analgesik');
      expect(c.description, 'Pereda nyeri');
      expect(c.isActive, true);
      expect(c.medicineCount, 5);
      expect(c.createdAt, isNotNull);
    });

    test('toJson round-trips', () {
      final c = CategoryModel(
        id: 'cat-1',
        name: 'Analgesik',
        description: 'Pereda nyeri',
        isActive: true,
      );
      final c2 = CategoryModel.fromJson(c.toJson());
      expect(c2.id, c.id);
      expect(c2.name, c.name);
      expect(c2.isActive, c.isActive);
    });
  });
}
