import 'package:get/get.dart';

import '../../features/categories/models/category_model.dart';
import '../../features/medicines/models/medicine_model.dart';
import '../../features/stock_movements/models/stock_movement_model.dart';
import '../../features/suppliers/models/supplier_model.dart';
import 'dummy_categories.dart';
import 'dummy_medicines.dart';
import 'dummy_stock_movements.dart';
import 'dummy_suppliers.dart';

/// In-memory store that backs all *RepositoryDummy implementations.
class DummyStore {
  /// Returns the registered store, or creates + registers a default one.
  static DummyStore get instance {
    if (Get.isRegistered<DummyStore>()) {
      return Get.find<DummyStore>();
    }
    final created = DummyStore();
    Get.put<DummyStore>(created, permanent: true);
    return created;
  }

  late final List<CategoryModel> _categories;
  late final List<SupplierModel> _suppliers;
  late final List<MedicineModel> _medicines;
  late final List<StockMovementModel> _movements;

  DummyStore() {
    _categories = buildCategorySeed();
    _suppliers = buildSupplierSeed();
    _medicines = buildMedicineSeed(_categories, _suppliers);
    _movements = buildStockMovementSeed(_medicines, _suppliers);
  }

  // ---- Public read/write ----
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get categoriesMutable => _categories;

  List<SupplierModel> get suppliers => List.unmodifiable(_suppliers);
  List<SupplierModel> get suppliersMutable => _suppliers;

  List<MedicineModel> get medicines => List.unmodifiable(_medicines);
  List<MedicineModel> get medicinesMutable => _medicines;

  List<StockMovementModel> get movements => List.unmodifiable(_movements);
  List<StockMovementModel> get movementsMutable => _movements;
}
