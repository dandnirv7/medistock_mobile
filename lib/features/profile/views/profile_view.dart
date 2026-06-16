import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = controller.session;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () {
              // Trigger rebuild on session change by reading user.
              session.user;
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
                        (session.user?.name.isNotEmpty == true
                                ? session.user!.name[0]
                                : 'A')
                            .toUpperCase(),
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
                            session.user?.name ?? 'Admin',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${session.user?.username ?? "-"}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (session.user?.email != null)
                            Text(
                              session.user!.email!,
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
            },
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.medication_outlined,
            title: 'Kelola Obat',
            onTap: () => Get.toNamed(AppRoutes.medicines),
          ),
          _MenuTile(
            icon: Icons.category_outlined,
            title: 'Kelola Kategori',
            onTap: () => Get.toNamed(AppRoutes.categories),
          ),
          _MenuTile(
            icon: Icons.local_shipping_outlined,
            title: 'Kelola Supplier',
            onTap: () => Get.toNamed(AppRoutes.suppliers),
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'Riwayat Mutasi',
            onTap: () => Get.toNamed(AppRoutes.stockMovements),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Alert',
            onTap: () => Get.toNamed(AppRoutes.alerts),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Keluar?',
                message: 'Anda akan keluar dari sesi ini.',
                confirmLabel: 'Keluar',
                destructive: true,
              );
              if (ok) await controller.logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
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
