import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/stock_report_model.dart';
import '../controllers/stock_report_controller.dart';

class StockReportView extends StatelessWidget {
  const StockReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StockReportController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Laporan Stok'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: ctrl.load,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(ctrl: ctrl),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (ctrl.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: ctrl.errorMessage.value,
                  onRetry: ctrl.load,
                );
              }
              if (ctrl.items.isEmpty) {
                return const _EmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: ctrl.items.length,
                itemBuilder: (context, index) =>
                    _StockReportCard(item: ctrl.items[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.ctrl});

  final StockReportController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        final activeStatus = ctrl.status.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusChip(
                label: 'Semua',
                isActive: activeStatus.isEmpty,
                color: AppColors.textSecondary,
                onTap: () => ctrl.setFilter(stockStatus: ''),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: 'Sehat',
                isActive: activeStatus == 'healthy',
                color: AppColors.success,
                onTap: () => ctrl.setFilter(stockStatus: 'healthy'),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: 'Stok Rendah',
                isActive: activeStatus == 'low',
                color: AppColors.warning,
                onTap: () => ctrl.setFilter(stockStatus: 'low'),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: 'Kedaluwarsa',
                isActive: activeStatus == 'expired',
                color: AppColors.danger,
                onTap: () => ctrl.setFilter(stockStatus: 'expired'),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? color : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stock report card
// ---------------------------------------------------------------------------

class _StockReportCard extends StatelessWidget {
  const _StockReportCard({required this.item});

  final StockReportItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _statusColor(item.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    LucideIcons.pill,
                    size: 20,
                    color: _statusColor(item.status),
                  ),
                ),
                const SizedBox(width: 10),
                // Name & code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        item.code,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _StatusBadge(status: item.status),
              ],
            ),
          ),

          // Stock info row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                _InfoChip(
                  icon: LucideIcons.packageOpen,
                  label: 'Stok saat ini',
                  value: '${item.currentStock} ${item.unit}',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: LucideIcons.alertTriangle,
                  label: 'Stok minimum',
                  value: '${item.minimumStock} ${item.unit}',
                ),
              ],
            ),
          ),

          // Category / supplier row
          if (item.categoryName != null || item.supplierName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  if (item.categoryName != null) ...[
                    Icon(LucideIcons.tag,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      item.categoryName!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (item.supplierName != null) ...[
                    Icon(LucideIcons.building2,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.supplierName!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Batches
          if (item.batches.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Batch (${item.batches.length})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...item.batches.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(LucideIcons.boxes,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            b.batchNumber,
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            'Exp: ${b.expiredDate}',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${b.quantity} ${item.unit}',
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'low':
        return AppColors.warning;
      case 'expired':
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status) {
      case 'low':
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.onWarning;
        label = 'Stok Rendah';
        break;
      case 'expired':
        bg = AppColors.danger.withValues(alpha: 0.12);
        fg = AppColors.onDanger;
        label = 'Kedaluwarsa';
        break;
      default:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.onSuccess;
        label = 'Sehat';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
            Text(
              value,
              style: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clipboardList,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data stok',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
