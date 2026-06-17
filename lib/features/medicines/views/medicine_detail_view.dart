import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../controllers/medicine_detail_controller.dart';
import '../models/medicine_model.dart';

class MedicineDetailView extends GetView<MedicineDetailController> {
  const MedicineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Obat')),
      body: Obx(() {
        if (controller.isLoading.value && controller.medicine.value == null) {
          return const LoadingOverlay();
        }
        final m = controller.medicine.value;
        if (m == null) {
          return const Center(child: Text('Obat tidak ditemukan'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _Header(medicine: m),
            const SizedBox(height: 16),
            _Section(
              title: 'Informasi',
              children: [
                _Row(label: 'Kategori', value: m.categoryName ?? '-'),
                _Row(label: 'Supplier', value: m.supplierName ?? '-'),
                _Row(
                  label: 'Harga Beli',
                  value: CurrencyFormatter.format(m.purchasePrice),
                ),
                _Row(
                  label: 'Harga Jual',
                  value: CurrencyFormatter.format(m.sellingPrice),
                ),
                _Row(
                  label: 'Stok Saat Ini',
                  value: '${m.currentStock} ${m.unit}',
                  highlight: true,
                ),
                _Row(
                  label: 'Stok Minimum',
                  value: '${m.minimumStock} ${m.unit}',
                ),
                _Row(
                  label: 'Tanggal Expired',
                  value: m.expiredDate == null
                      ? '-'
                      : DateFormatter.toDisplay(m.expiredDate!),
                  danger: m.expiredStatus == ExpiredStatus.expired,
                ),
              ],
            ),
            if (m.description != null && m.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _Section(
                title: 'Deskripsi',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      m.description!,
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Get.toNamed(
                      AppRoutes.medicineForm,
                      arguments: m,
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Get.snackbar(
                      'Segera Hadir',
                      'Hapus obat akan tersedia di rilis berikutnya.',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final isTablet = medicine.unit.toLowerCase().contains('tablet') ||
        medicine.unit.toLowerCase().contains('kaplet');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              isTablet ? Icons.medication : Icons.medical_services,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medicine.code,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    medicine.unit.isEmpty ? 'Obat' : medicine.unit,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.highlight = false,
    this.danger = false,
  });
  final String label;
  final String value;
  final bool highlight;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final valueColor = danger
        ? AppColors.danger
        : (highlight ? AppColors.primary : AppColors.textPrimary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
