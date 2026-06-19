import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/models/user_model.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme/app_icons.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Obx(() => _ProfileHeader(user: session.userRx.value)),
        const SizedBox(height: 24),
        Obx(() => _AccountInfoCard(user: session.userRx.value)),
        const SizedBox(height: 16),
        _SectionTile(
          icon: AppIcons.settings_outlined,
          title: 'Pengaturan Aplikasi',
          subtitle: 'Tema, notifikasi, dan preferensi lainnya',
          onTap: () {
            SnackbarHelper.info('Pengaturan aplikasi akan tersedia di rilis berikutnya.');
          },
        ),
        _SectionTile(
          icon: AppIcons.shield_outlined,
          title: 'Keamanan',
          subtitle: 'Ubah password dan keamanan akun',
          onTap: () {
            SnackbarHelper.info('Pengaturan keamanan akan tersedia di rilis berikutnya.');
          },
        ),
        _SectionTile(
          icon: AppIcons.info_outline,
          title: 'Tentang Aplikasi',
          subtitle: 'Versi 1.0.0',
          onTap: () {
            SnackbarHelper.info('MediStock Inventory v1.0.0\nKelola Stok Obat dengan Mudah, Aman, dan Terpercaya.');
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => _confirmLogout(context),
          icon: const Icon(AppIcons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
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
SnackbarHelper.error('Logout gagal: ${e.toString()}');
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final initial = (user?.name.isNotEmpty == true
            ? user!.name[0]
            : 'A')
        .toUpperCase();
    final role = user?.userRole.label ?? 'User';
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? 'Admin Apotek',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (user?.email != null) ...[
          const SizedBox(height: 2),
          Text(
            user!.email!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            role,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Text(
              'Informasi Akun',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _InfoRow(
            icon: AppIcons.person_outline,
            label: 'Nama',
            value: user?.name.isNotEmpty == true ? user!.name : '-',
          ),
          _InfoRow(
            icon: AppIcons.accountCircleOutlined,
            label: 'Username',
            value: user?.username.isNotEmpty == true ? user!.username : '-',
          ),
          _InfoRow(
            icon: AppIcons.email,
            label: 'Email',
            value: user?.email?.isNotEmpty == true ? user!.email! : '-',
          ),
          _InfoRow(
            icon: AppIcons.verified_outlined,
            label: 'Peran',
            value: user?.userRole.label ?? '-',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          AppIcons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
