import 'package:get/get.dart';

import '../../core/config/dummy_flag.dart';
import '../../core/network/api_client.dart';
import '../../features/categories/data/repositories/category_repository.dart';
import '../../features/categories/data/repositories/category_repository_api.dart';
import '../../features/categories/data/repositories/category_repository_dummy.dart';
import '../../features/medicines/data/repositories/medicine_repository.dart';
import '../../features/medicines/data/repositories/medicine_repository_api.dart';
import '../../features/medicines/data/repositories/medicine_repository_dummy.dart';
import '../../features/stock_movements/data/repositories/stock_movement_repository.dart';
import '../../features/stock_movements/data/repositories/stock_movement_repository_api.dart';
import '../../features/stock_movements/data/repositories/stock_movement_repository_dummy.dart';
import '../../features/suppliers/data/repositories/supplier_repository.dart';
import '../../features/suppliers/data/repositories/supplier_repository_api.dart';
import '../../features/suppliers/data/repositories/supplier_repository_dummy.dart';

/// Persistent services (storage, api client, dummy store, auth session) are
/// registered eagerly in `main()` so the initial route decision can read
/// hydrated state synchronously.
///
/// Repositories, on the other hand, are registered here so they are available
/// app-wide regardless of which feature binding has fired. Several screens read
/// from repositories they do not "own" — e.g. the medicine list's category
/// filter sheet needs [CategoryRepository], and the stock-in form needs both
/// [MedicineRepository] and [SupplierRepository]. Registering them globally
/// (lazily, with `fenix`) means `Get.isRegistered<T>()` is always true and
/// those cross-feature lookups never silently return empty.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(
      () => kUseDummyData
          ? CategoryRepositoryDummy()
          : CategoryRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<SupplierRepository>(
      () => kUseDummyData
          ? SupplierRepositoryDummy()
          : SupplierRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<MedicineRepository>(
      () => kUseDummyData
          ? MedicineRepositoryDummy()
          : MedicineRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<StockMovementRepository>(
      () => kUseDummyData
          ? StockMovementRepositoryDummy()
          : StockMovementRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
  }
}
