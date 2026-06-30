import 'package:get/get.dart';

import '../../features/alerts/bindings/alerts_binding.dart';
import '../../features/alerts/views/alerts_view.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/categories/bindings/category_binding.dart';
import '../../features/categories/views/category_form_view.dart';
import '../../features/categories/views/category_detail_view.dart';
import '../../features/categories/views/category_list_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/home/bindings/home_shell_binding.dart';
import '../../features/home/views/home_shell_view.dart';
import '../../features/medicines/bindings/medicine_binding.dart';
import '../../features/medicines/views/medicine_detail_view.dart';
import '../../features/medicines/views/medicine_form_view.dart';
import '../../features/medicines/views/medicine_list_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/stock_movements/bindings/stock_movement_binding.dart';
import '../../features/stock_movements/views/stock_in_view.dart';
import '../../features/stock_movements/views/stock_movement_list_view.dart';
import '../../features/stock_movements/views/stock_level_view.dart';
import '../../features/stock_movements/views/stock_out_view.dart';
import '../../features/suppliers/bindings/supplier_binding.dart';
import '../../features/suppliers/views/supplier_form_view.dart';
import '../../features/suppliers/views/supplier_detail_view.dart';
import '../../features/suppliers/views/supplier_list_view.dart';
import '../bindings/auth_middleware.dart';
import '../bindings/role_guard.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeShellView(),
      binding: HomeShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.medicines,
      page: () => const MedicineListView(),
      binding: MedicineBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.medicineForm,
      page: () => const MedicineFormView(),
      binding: MedicineBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.medicineDetail,
      page: () => const MedicineDetailView(),
      binding: MedicineBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoryListView(),
      binding: CategoryBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.categoryForm,
      page: () => const CategoryFormView(),
      binding: CategoryBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.categoryDetail,
      page: () => const CategoryDetailView(),
      binding: CategoryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.suppliers,
      page: () => const SupplierListView(),
      binding: SupplierBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.supplierForm,
      page: () => const SupplierFormView(),
      binding: SupplierBinding(),
      middlewares: [AuthMiddleware(), RoleGuard.requireAdmin],
    ),
    GetPage(
      name: AppRoutes.supplierDetail,
      page: () => const SupplierDetailView(),
      binding: SupplierBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.stockIn,
      page: () => const StockInView(),
      binding: StockMovementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.stockOut,
      page: () => const StockOutView(),
      binding: StockMovementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.stockMovements,
      page: () => const StockMovementListView(),
      binding: StockMovementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.stockLevels,
      page: () => const StockLevelView(),
      binding: MedicineBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.alerts,
      page: () => const AlertsView(),
      binding: AlertsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
