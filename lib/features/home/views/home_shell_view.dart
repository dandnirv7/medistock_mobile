import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../controllers/home_shell_controller.dart';

class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;
      final tab = HomeShellController.tabs[index];
      return Scaffold(
        body: tab.route == AppRoutes.dashboard
            ? const _DashboardBody()
            : const _PlaceholderBody(title: 'Halaman dalam pengembangan'),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeTab,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          destinations: [
            for (final t in HomeShellController.tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
          ],
        ),
      );
    });
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediStock'),
        centerTitle: false,
      ),
      drawer: const _AppDrawer(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Dashboard lengkap akan digenerate pada milestone M2.\n'
            'Saat ini hanya shell (bottom nav + drawer) yang aktif.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const _AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title\n\n(Isi lengkap di milestone berikutnya)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AuthSession>();
    final authRepo = Get.find<AuthRepository>();
    final user = session.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(user: user, authRepo: authRepo),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: AppRoutes.dashboard,
                  ),
                  _DrawerItem(
                    icon: Icons.medication_outlined,
                    label: 'Data Obat',
                    route: AppRoutes.medicines,
                  ),
                  _DrawerItem(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    route: AppRoutes.categories,
                  ),
                  _DrawerItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Supplier',
                    route: AppRoutes.suppliers,
                  ),
                  _DrawerItem(
                    icon: Icons.arrow_downward,
                    label: 'Stok Masuk',
                    route: AppRoutes.stockIn,
                  ),
                  _DrawerItem(
                    icon: Icons.arrow_upward,
                    label: 'Stok Keluar',
                    route: AppRoutes.stockOut,
                  ),
                  _DrawerItem(
                    icon: Icons.swap_horiz,
                    label: 'Mutasi Stok',
                    route: AppRoutes.stockMovements,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await Get.toNamed<void>(AppRoutes.profile);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({this.user, required this.authRepo});

  final UserModel? user;
  final AuthRepository authRepo;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'MediStock';
    final role = user?.role ?? 'User';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_pharmacy,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'MediStock',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Text(
            'Inventory',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Get.toNamed<void>(route);
      },
    );
  }
}
