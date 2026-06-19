import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../home/controllers/home_shell_controller.dart';
import '../../medicines/data/repositories/medicine_repository.dart'
    show MedicineExpiredFilter;
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_summary_model.dart';
import '../widgets/dashboard_stat_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthSession>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 72,
        title: Obx(() {
          final user = auth.userRx.value;
          final name = user?.name.isNotEmpty == true
              ? user!.name
              : (user?.username ?? 'Admin Apotek');
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.border(AppRadii.md),
                ),
                child: const Icon(
                  AppIcons.medicalServices,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, $name',
                      style: AppTextStyles.sectionHeader.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Selamat datang kembali!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Get.toNamed(AppRoutes.alerts),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(AppIcons.alerts),
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
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Obx(() {
          if (controller.isLoading.value && controller.summary.value == null) {
            return const _LoadingDashboard();
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
            return EmptyState(
              title: 'Tidak ada data',
              subtitle: 'Belum ada ringkasan yang dapat ditampilkan',
              icon: AppIcons.dashboard,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              const _SearchBar(),
              const SizedBox(height: AppSpacing.lg),
              _StatGrid(summary: summary),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Peringatan',
                action: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.alerts),
                  child: Text(
                    'Lihat semua',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _AlertCard(
                title: 'Stok Rendah',
                icon: AppIcons.lowStock,
                accent: AppColors.stockLow,
                count: summary.lowStockCount,
                subtitle: summary.lowStockCount == 0
                    ? 'Tidak ada obat dengan stok rendah'
                    : '${summary.lowStockCount} obat dengan stok di bawah minimum',
                onTap: () => Get.find<HomeShellController>()
                    .openMedicines(lowStockOnly: true),
              ),
              const SizedBox(height: AppSpacing.md),
              _AlertCard(
                title: 'Hampir Expired',
                icon: AppIcons.expiringSoon,
                accent: AppColors.expiredSoon,
                count: summary.expiredSoonCount,
                subtitle: summary.expiredSoonCount == 0
                    ? 'Tidak ada obat hampir expired'
                    : '${summary.expiredSoonCount} obat akan expired dalam 30 hari',
                onTap: () => Get.find<HomeShellController>()
                    .openMedicines(expired: MedicineExpiredFilter.soon),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _QuickActions(),
            ],
          );
        }),
      ),
    );
  }
}

class _LoadingDashboard extends StatelessWidget {
  const _LoadingDashboard();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        _SearchBar(),
        SizedBox(height: AppSpacing.lg),
        _StatGridLoading(),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _StatGridLoading extends StatelessWidget {
  const _StatGridLoading();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.05,
      children: const [
        _StatCardSkeletonBox(),
        _StatCardSkeletonBox(),
        _StatCardSkeletonBox(),
        _StatCardSkeletonBox(),
      ],
    );
  }
}

class _StatCardSkeletonBox extends StatelessWidget {
  const _StatCardSkeletonBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
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
        onTap: () => Get.find<HomeShellController>().openMedicines(),
        decoration: const InputDecoration(
          hintText: 'Cari obat, kode, atau supplier...',
          prefixIcon: Icon(AppIcons.search, color: AppColors.textSecondary),
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
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.05,
      children: [
        DashboardStatCard(
          label: 'Total Obat',
          value: summary.totalMedicines,
          icon: AppIcons.medicines,
          accent: AppColors.primary,
          unit: 'Jenis',
        ),
        DashboardStatCard(
          label: 'Stok Rendah',
          value: summary.lowStockCount,
          icon: AppIcons.lowStock,
          accent: AppColors.stockLow,
          unit: 'Obat',
        ),
        DashboardStatCard(
          label: 'Hampir Expired',
          value: summary.expiredSoonCount,
          icon: AppIcons.expiringSoon,
          accent: AppColors.expired,
          unit: 'Obat',
        ),
        DashboardStatCard(
          label: 'Supplier',
          value: summary.totalSuppliers,
          icon: AppIcons.suppliers,
          accent: AppColors.violet,
          unit: 'Supplier',
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.count,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final int count;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCount = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.border(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.border(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadii.border(AppRadii.md),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (hasCount)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.caption.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              AppIcons.chevronRight,
              color: hasCount ? AppColors.textSecondary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft tint backgrounds for the four quick-action buttons. The UI reference
/// uses a single calm green family for all four actions (medicine, stock-in,
/// stock-out, mutations), so the tiles share one light-green tint and a green
/// icon — only the glyph differs.
const List<Color> _quickActionTints = [
  AppColors.primaryLight,
  AppColors.primaryLight,
  AppColors.primaryLight,
  AppColors.primaryLight,
];

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aksi Cepat'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: AppIcons.medicines,
                label: 'Data Obat',
                tint: _quickActionTints[0],
                iconColor: AppColors.primary,
                onTap: () => Get.find<HomeShellController>().openMedicines(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickAction(
                icon: AppIcons.stockIn,
                label: 'Stok Masuk',
                tint: _quickActionTints[1],
                iconColor: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.stockIn),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickAction(
                icon: AppIcons.stockOut,
                label: 'Stok Keluar',
                tint: _quickActionTints[2],
                iconColor: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.stockOut),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickAction(
                icon: AppIcons.stockMovements,
                label: 'Mutasi',
                tint: _quickActionTints[3],
                iconColor: AppColors.primary,
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
    required this.tint,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.border(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: AppRadii.border(AppRadii.lg),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.border(AppRadii.md),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
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
    return ErrorView(message: message, onRetry: onRetry);
  }
}
