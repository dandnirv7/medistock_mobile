import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/models/user_model.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _Body(controller: controller),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Obx(() {
          final user = session.userRx.value;
          return _UserHeader(user: user);
        }),
        const SizedBox(height: 16),
        _MenuTile(
          icon: Icons.medication_outlined,
          title: 'Kelola Obat',
          onTap: () => _safeNavigate(AppRoutes.medicines),
        ),
        _MenuTile(
          icon: Icons.category_outlined,
          title: 'Kelola Kategori',
          onTap: () => _safeNavigate(AppRoutes.categories),
        ),
        _MenuTile(
          icon: Icons.local_shipping_outlined,
          title: 'Kelola Supplier',
          onTap: () => _safeNavigate(AppRoutes.suppliers),
        ),
        _MenuTile(
          icon: Icons.history,
          title: 'Riwayat Mutasi',
          onTap: () => _safeNavigate(AppRoutes.stockMovements),
        ),
        _MenuTile(
          icon: Icons.notifications_outlined,
          title: 'Alert',
          onTap: () => _safeNavigate(AppRoutes.alerts),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
          ),
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  void _safeNavigate(String route) {
    try {
      Get.toNamed(route);
    } catch (e) {
      // Surface as a snackbar so the user gets feedback instead of a silent crash.
      Get.snackbar(
        'Navigasi gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    try {
      final ok = await ConfirmDialog.show(
        context,
        title: 'Keluar?',
        message: 'Anda akan keluar dari sesi ini.',
        confirmLabel: 'Keluar',
        destructive: true,
      );
      if (ok) await controller.logout();
    } catch (e) {
      Get.snackbar(
        'Logout gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final initial = (user?.name.isNotEmpty == true
            ? user!.name[0]
            : 'A')
        .toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user?.username ?? "-"}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
