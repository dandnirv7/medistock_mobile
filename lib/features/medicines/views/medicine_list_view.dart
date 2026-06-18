import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../controllers/medicine_list_controller.dart';
import '../data/repositories/medicine_repository.dart' show MedicineExpiredFilter;
import '../models/medicine_model.dart';

class MedicineListView extends GetView<MedicineListController> {
  const MedicineListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obat'),
        actions: [
          IconButton(
            tooltip: 'Cari',
            onPressed: () => _openSearch(context),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Filter',
            onPressed: () => _openCategoryFilter(context),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChipRow(),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const LoadingOverlay();
              }
              if (controller.errorMessage.value != null &&
                  controller.items.isEmpty) {
                return ErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.fetch,
                );
              }
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.medication_outlined,
                  title: 'Belum ada obat',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetch,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          Obx(
                            () => Text(
                              'Total ${controller.total.value} obat',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Urutkan',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                        itemCount: controller.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _MedicineCard(
                          medicine: controller.items[i],
                          onTap: () => Get.toNamed(
                            AppRoutes.medicineDetail,
                            parameters: {'id': controller.items[i].id},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Get.find<AuthSession>().userRx.value?.isAdmin == true
            ? FloatingActionButton(
                heroTag: 'fab-medicine',
                onPressed: () => Get.toNamed(AppRoutes.medicineForm),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cari obat'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nama atau kode obat',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) {
              controller.search.value = v;
              controller.fetch();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _openCategoryFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Semua Kategori'),
                onTap: () {
                  controller.categoryFilter.value = null;
                  controller.fetch();
                  Navigator.of(context).pop();
                },
              ),
              const Divider(height: 1),
              // Categories are not loaded here; we expose only the
              // "clear" affordance for now. Full category dropdown
              // wiring happens in the form view.
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  MedicineListController get controller => Get.find<MedicineListController>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          scrollDirection: Axis.horizontal,
          children: [
            _FilterChip(
              label: 'Semua',
              selected: !controller.lowStockOnly.value &&
                  controller.expiredFilter.value ==
                      MedicineExpiredFilter.all,
              onTap: () {
                controller.lowStockOnly.value = false;
                controller.setExpiredFilter(MedicineExpiredFilter.all);
              },
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'Hampir Expired',
              selected:
                  controller.expiredFilter.value == MedicineExpiredFilter.soon,
              onTap: () => controller
                  .setExpiredFilter(MedicineExpiredFilter.soon),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: 'Stok Rendah',
              selected: controller.lowStockOnly.value,
              onTap: () {
                controller.lowStockOnly.value = !controller.lowStockOnly.value;
                controller.fetch();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine, required this.onTap});

  final MedicineModel medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stock = medicine.stockStatus;
    final expired = medicine.expiredStatus;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MedIcon(unit: medicine.unit),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine.code,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _StatusPill(
                        label: medicine.unit.isEmpty ? 'Obat' : medicine.unit,
                        color: AppColors.primary,
                        bg: AppColors.primaryLight,
                      ),
                      if (stock != StockStatus.safe)
                        _StatusPill(
                          label: stock.label,
                          color: stock == StockStatus.out
                              ? AppColors.danger
                              : AppColors.warning,
                          bg: stock == StockStatus.out
                              ? const Color(0xFFFFE7E7)
                              : const Color(0xFFFFF4E5),
                        ),
                      if (expired == ExpiredStatus.expired ||
                          expired == ExpiredStatus.soon)
                        _StatusPill(
                          label: 'Exp: ${_formatExpiry(medicine.expiredDate)}',
                          color: expired == ExpiredStatus.expired
                              ? AppColors.danger
                              : AppColors.warning,
                          bg: expired == ExpiredStatus.expired
                              ? const Color(0xFFFFE7E7)
                              : const Color(0xFFFFF4E5),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${medicine.currentStock}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Stok',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiry(DateTime? d) {
    if (d == null) return '-';
    return DateFormatter.toDisplayShort(d);
  }
}

class _MedIcon extends StatelessWidget {
  const _MedIcon({required this.unit});

  final String unit;

  @override
  Widget build(BuildContext context) {
    final isTablet = unit.toLowerCase().contains('tablet') ||
        unit.toLowerCase().contains('kaplet');
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isTablet ? Icons.medication : Icons.medical_services,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
