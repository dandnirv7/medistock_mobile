import '../../features/suppliers/models/supplier_model.dart';

List<SupplierModel> buildSupplierSeed() {
  return [
    SupplierModel(
      id: 'sup-1',
      name: 'PT Kimia Farma Tbk',
      phone: '021-5551234',
      email: 'order@kimiafarma.co.id',
      address: 'Jl. Veteran No. 1, Jakarta Pusat',
      notes: 'Supplier utama untuk analgesik & antibiotik',
      isActive: true,
      createdAt: DateTime(2025, 1, 10),
      updatedAt: DateTime(2025, 1, 10),
    ),
    SupplierModel(
      id: 'sup-2',
      name: 'PT Kalbe Farma',
      phone: '021-5559876',
      email: 'sales@kalbefarma.com',
      address: 'Jl. Letjend Suprapto Kav 4, Jakarta',
      notes: 'Pemasok vitamin dan suplemen',
      isActive: true,
      createdAt: DateTime(2025, 1, 12),
      updatedAt: DateTime(2025, 1, 12),
    ),
    SupplierModel(
      id: 'sup-3',
      name: 'PT Sanofi Indonesia',
      phone: '021-5554321',
      email: 'info@sanofi.id',
      address: 'Jl. Jend. Sudirman Kav 45, Jakarta',
      notes: 'Supplier antihistamin dan antasida',
      isActive: true,
      createdAt: DateTime(2025, 2, 1),
      updatedAt: DateTime(2025, 2, 1),
    ),
    SupplierModel(
      id: 'sup-4',
      name: 'PT Dexa Medica',
      phone: '021-5551122',
      email: 'order@dexa-medica.com',
      address: 'Jl. Bintaro Raya, Tangerang Selatan',
      notes: 'Supplier generik',
      isActive: true,
      createdAt: DateTime(2025, 2, 15),
      updatedAt: DateTime(2025, 2, 15),
    ),
  ];
}
