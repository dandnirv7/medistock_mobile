import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/medicine_list_controller.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineListView extends GetView<MedicineListController> {
  const MedicineListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Obat'),
        actions: [
          IconButton(
            tooltip: 'Kategori',
            onPressed: () => Get.toNamed(AppRoutes.categories),
            icon: const Icon(Icons.category_outlined),
          ),
          IconButton(
            tooltip: 'Supplier',
            onPressed: () => Get.toNamed(AppRoutes.suppliers),
            icon: const Icon(Icons.local_shipping_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) {
                if (controller.search.value == v) return;
                controller.search.value = v;
                controller.fetch();
              },
              decoration: InputDecoration(
                hintText: 'Cari nama / kode obat',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.search.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => controller.setSearch(''),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
          ),
          _FilterChips(),
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
                  onRetry: controller.refresh,
                );
              }
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.medication_outlined,
                  title: 'Belum ada obat',
                  subtitle: 'Tambahkan obat dengan tombol + di bawah',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = controller.items[i];
                    return _MedicineTile(
                      medicine: m,
                      onTap: () => Get.toNamed(
                        AppRoutes.medicineDetail,
                        parameters: {'id': m.id},
                      ),
                      onEdit: () => Get.toNamed(
                        AppRoutes.medicineForm,
                        arguments: m,
                      ),
                      onDelete: () => _confirmDelete(context, m),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.medicineForm),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Obat'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MedicineModel m) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Hapus obat?',
      message: '${m.name} akan dihapus dari daftar.',
    );
    if (ok) {
      await controller.delete(m);
    }
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<MedicineListController>();
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const SizedBox(width: 4),
            _Chip(
              label: 'Semua',
              selected: c.expiredFilter.value == MedicineExpiredFilter.all &&
                  !c.lowStockOnly.value,
              onTap: () {
                c.setExpiredFilter(MedicineExpiredFilter.all);
                c.setLowStockOnly(false);
              },
            ),
            _Chip(
              label: 'Stok Rendah',
              selected: c.lowStockOnly.value,
              onTap: () => c.setLowStockOnly(!c.lowStockOnly.value),
            ),
            _Chip(
              label: 'Expired',
              selected: c.expiredFilter.value == MedicineExpiredFilter.expired,
              onTap: () => c
                  .setExpiredFilter(MedicineExpiredFilter.expired),
            ),
            _Chip(
              label: 'Segera Expired',
              selected: c.expiredFilter.value == MedicineExpiredFilter.soon,
              onTap: () => c.setExpiredFilter(MedicineExpiredFilter.soon),
            ),
            _Chip(
              label: 'Aman',
              selected: c.expiredFilter.value == MedicineExpiredFilter.safe,
              onTap: () => c.setExpiredFilter(MedicineExpiredFilter.safe),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.medicine,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicineModel medicine;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
          '${medicine.code} • ${medicine.categoryName ?? "Tanpa kategori"}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StockBadge(medicine: medicine),
                  const SizedBox(width: 8),
                  ExpiredBadge(medicine: medicine),
                  const Spacer(),
                  Text(
                    'Stok: ${medicine.currentStock} ${medicine.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payments_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(medicine.sellingPrice),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    medicine.expiredDate == null
                        ? 'Tidak ada tanggal'
                        : DateFormatter.toDisplay(medicine.expiredDate!),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
