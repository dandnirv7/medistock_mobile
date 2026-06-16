import '../../features/categories/models/category_model.dart';

List<CategoryModel> buildCategorySeed() {
  return [
    CategoryModel(
      id: 'cat-1',
      name: 'Analgesik',
      description: 'Obat pereda nyeri dan penurun panas',
      isActive: true,
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 5),
    ),
    CategoryModel(
      id: 'cat-2',
      name: 'Antibiotik',
      description: 'Obat untuk melawan infeksi bakteri',
      isActive: true,
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 5),
    ),
    CategoryModel(
      id: 'cat-3',
      name: 'Vitamin & Suplemen',
      description: 'Vitamin dan suplemen kesehatan',
      isActive: true,
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 5),
    ),
    CategoryModel(
      id: 'cat-4',
      name: 'Antihistamin',
      description: 'Obat alergi dan antihistamin',
      isActive: true,
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 5),
    ),
    CategoryModel(
      id: 'cat-5',
      name: 'Antasida',
      description: 'Obat maag dan gangguan lambung',
      isActive: true,
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 5),
    ),
  ];
}
