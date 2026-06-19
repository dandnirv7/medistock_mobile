import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../medicines/controllers/medicine_list_controller.dart';
import '../../medicines/data/repositories/medicine_repository.dart' show MedicineExpiredFilter;
import '../../medicines/models/medicine_model.dart';
import '../../../core/theme/app_icons.dart';

class StockLevelView extends GetView<MedicineListController> {
  const StockLevelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: controller.setSearch,
              decoration: InputDecoration(
                hintText: 'Cari nama atau kode obat...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: Obx(
                  () => controller.search.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(AppIcons.close),
                          onPressed: () {
                            controller.search.value = '';
                            controller.fetch();
                          },
                        ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          _StockFilterRow(),
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: AppIcons.inventory2_outlined,
                  title: 'Belum ada data stok',
                  subtitle: 'Tambahkan obat terlebih dahulu untuk melihat stok.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.refresh(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = controller.items[i];
                    return _StockLevelCard(medicine: m);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMovementTypeSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(AppIcons.swap_vert),
        label: const Text('Mutasi'),
      ),
    );
  }

  void _showMovementTypeSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Pilih Jenis Mutasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _MovementTypeTile(
              icon: AppIcons.arrow_downward,
              color: AppColors.primary,
              title: 'Stok Masuk',
              subtitle: 'Catat pembelian / penambahan stok',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.stockIn);
              },
            ),
            const SizedBox(height: 10),
            _MovementTypeTile(
              icon: AppIcons.arrow_upward,
              color: AppColors.secondary,
              title: 'Stok Keluar',
              subtitle: 'Catat penjualan / pengeluaran stok',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.stockOut);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _StockFilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<MedicineListController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Stok Rendah',
                selected: c.lowStockOnly.value,
                onSelected: (v) {
                  c.lowStockOnly.value = v;
                  c.fetch();
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Aman',
                selected: c.expiredFilter.value ==
                    MedicineExpiredFilter.safe,
                onSelected: (v) {
                  c.expiredFilter.value = v
                      ? MedicineExpiredFilter.safe
                      : MedicineExpiredFilter.all;
                  c.fetch();
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Segera Expired',
                selected: c.expiredFilter.value ==
                    MedicineExpiredFilter.soon,
                onSelected: (v) {
                  c.expiredFilter.value = v
                      ? MedicineExpiredFilter.soon
                      : MedicineExpiredFilter.all;
                  c.fetch();
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Sudah Expired',
                selected: c.expiredFilter.value ==
                    MedicineExpiredFilter.expired,
                onSelected: (v) {
                  c.expiredFilter.value = v
                      ? MedicineExpiredFilter.expired
                      : MedicineExpiredFilter.all;
                  c.fetch();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class _StockLevelCard extends StatelessWidget {
  const _StockLevelCard({required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final isOut = medicine.currentStock <= 0;
    final isLow = !isOut && medicine.currentStock <= medicine.minimumStock;
    final status = isOut
        ? _StockChipData('Habis', AppColors.danger, AppColors.danger)
        : isLow
            ? _StockChipData(
                'Stok Rendah', AppColors.warning, AppColors.warning)
            : _StockChipData('Aman', AppColors.primary, AppColors.primary);
    final progress = medicine.minimumStock <= 0
        ? 1.0
        : (medicine.currentStock / (medicine.minimumStock * 2))
            .clamp(0.0, 1.0)
            .toDouble();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Get.toNamed(
        AppRoutes.medicineDetail,
        arguments: {'id': medicine.id},
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    AppIcons.medicationOutlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${medicine.code} • ${medicine.categoryName ?? '-'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(data: status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stok Saat Ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${medicine.currentStock} ${medicine.unit}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isOut
                              ? AppColors.danger
                              : isLow
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stok Minimum',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${medicine.minimumStock} ${medicine.unit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOut
                      ? AppColors.danger
                      : isLow
                          ? AppColors.warning
                          : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockChipData {
  const _StockChipData(this.label, this.color, this.borderColor);
  final String label;
  final Color color;
  final Color borderColor;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.data});
  final _StockChipData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.borderColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          color: data.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MovementTypeTile extends StatelessWidget {
  const _MovementTypeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
