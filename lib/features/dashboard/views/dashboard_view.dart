import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../../medicines/models/medicine_model.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_summary_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const _Greeting(),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Get.toNamed(AppRoutes.alerts),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Obx(() {
          if (controller.isLoading.value && controller.summary.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null &&
              controller.summary.value == null) {
            return _Error(
              message: controller.errorMessage.value!,
              onRetry: controller.refreshAll,
            );
          }
          final summary = controller.summary.value;
          if (summary == null) {
            return const Center(child: Text('Tidak ada data'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _SearchBar(),
              const SizedBox(height: 20),
              _StatGrid(summary: summary),
              const SizedBox(height: 24),
              _AlertSection(
                title: 'Stok Rendah',
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.stockLow,
                count: summary.lowStockCount,
                subtitle:
                    '${summary.lowStockCount} obat dengan stok di bawah minimum',
                emptyText: 'Tidak ada obat dengan stok rendah',
                children: summary.lowStockMedicines
                    .map(
                      (m) => _AlertTile(
                        title: m.name,
                        subtitle: m.code,
                        trailing: '${m.currentStock} ${m.unit}',
                      ),
                    )
                    .toList(),
                onSeeAll: () => Get.toNamed(AppRoutes.medicines),
              ),
              const SizedBox(height: 12),
              _AlertSection(
                title: 'Hampir Expired',
                icon: Icons.calendar_today,
                iconColor: AppColors.expiredSoon,
                count: summary.expiredSoonCount,
                subtitle:
                    '${summary.expiredSoonCount} obat akan expired dalam 30 hari',
                emptyText: 'Tidak ada obat hampir expired',
                children: summary.expiredSoonMedicines
                    .map(
                      (m) => _AlertTile(
                        title: m.name,
                        subtitle: m.code,
                        trailing: m.expiredStatus.label,
                      ),
                    )
                    .toList(),
                onSeeAll: () => Get.toNamed(AppRoutes.alerts),
              ),
              const SizedBox(height: 24),
              const _QuickActions(),
            ],
          );
        }),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<AuthRepository>();
    return FutureBuilder<UserModel?>(
      future: repo.currentUser(),
      builder: (context, snap) {
        final name = snap.data?.name ?? 'Admin Apotek';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Halo, $name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Selamat datang kembali!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        readOnly: true,
        onTap: () => Get.toNamed(AppRoutes.medicines),
        decoration: const InputDecoration(
          hintText: 'Cari obat, kode, atau supplier...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          label: 'Total Obat',
          value: '${summary.totalMedicines}',
          sub: 'Jenis',
          icon: Icons.medication,
          color: AppColors.primary,
          bg: AppColors.primaryLight,
        ),
        _StatCard(
          label: 'Stok Rendah',
          value: '${summary.lowStockCount}',
          sub: 'Obat',
          icon: Icons.warning_amber,
          color: AppColors.stockLow,
          bg: const Color(0xFFFFF4E5),
        ),
        _StatCard(
          label: 'Hampir Expired',
          value: '${summary.expiredSoonCount}',
          sub: 'Obat',
          icon: Icons.calendar_today,
          color: AppColors.expiredSoon,
          bg: const Color(0xFFFFE7E7),
        ),
        _StatCard(
          label: 'Supplier',
          value: '${summary.totalSuppliers}',
          sub: 'Supplier',
          icon: Icons.local_shipping,
          color: AppColors.info,
          bg: const Color(0xFFE0EBFF),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  sub,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  const _AlertSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.subtitle,
    required this.emptyText,
    required this.children,
    required this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  final String subtitle;
  final String emptyText;
  final List<Widget> children;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Peringatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AlertCard(
          title: title,
          icon: icon,
          iconColor: iconColor,
          subtitle: subtitle,
          onTap: onSeeAll,
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        trailing,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.medication,
                label: 'Data Obat',
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.medicines),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.arrow_downward,
                label: 'Stok Masuk',
                color: AppColors.success,
                onTap: () => Get.toNamed(AppRoutes.stockIn),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.arrow_upward,
                label: 'Stok Keluar',
                color: AppColors.danger,
                onTap: () => Get.toNamed(AppRoutes.stockOut),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.swap_horiz,
                label: 'Mutasi',
                color: AppColors.info,
                onTap: () => Get.toNamed(AppRoutes.stockMovements),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
