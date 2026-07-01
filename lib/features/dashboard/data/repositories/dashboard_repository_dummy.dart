import '../../../../data/dummy/dummy_store.dart';
import '../../models/dashboard_summary_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryDummy implements DashboardRepository {
  DashboardRepositoryDummy() : _store = DummyStore.instance;

  final DummyStore _store;

  @override
  Future<DashboardSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final meds = _store.medicinesMutable.where((m) => m.isActive).toList();
    final lowStock = meds.where((m) => m.isLowStock).toList();
    final expiredSoon = meds.where((m) => m.isExpiredSoon).toList();
    final expired = meds.where((m) => m.isExpired).toList();
    final totalStock = meds.fold<int>(0, (sum, m) => sum + m.currentStock);
    final totalValue = meds.fold<double>(
      0,
      (sum, m) => sum + (m.purchasePrice * m.currentStock),
    );
    final totalAssetValue = meds.fold<double>(
      0,
      (sum, m) => sum + (m.purchasePrice * m.currentStock),
    );

    final lowSample = lowStock.take(3).toList();
    final soonSample = expiredSoon.take(3).toList();

    return DashboardSummary(
      totalMedicines: meds.length,
      totalCategories:
          _store.categoriesMutable.where((c) => c.isActive).length,
      totalSuppliers: _store.suppliersMutable.where((s) => s.isActive).length,
      totalStock: totalStock,
      totalValue: totalValue,
      totalAssetValue: totalAssetValue,
      lowStockCount: lowStock.length,
      expiredSoonCount: expiredSoon.length,
      expiredCount: expired.length,
      lowStockMedicines: lowSample,
      expiredSoonMedicines: soonSample,
      recentMovements: const [],
    );
  }
}
