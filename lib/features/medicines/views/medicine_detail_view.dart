import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/medicine_detail_controller.dart';

class MedicineDetailView extends GetView<MedicineDetailController> {
  const MedicineDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Obat'),
        actions: [
          Obx(() {
            final m = controller.medicine.value;
            if (m == null) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Edit',
              onPressed: () => Get.toNamed(
                AppRoutes.medicineForm,
                arguments: m,
              ),
              icon: const Icon(Icons.edit_outlined),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.medicine.value == null) {
          return const LoadingOverlay();
        }
        final m = controller.medicine.value;
        if (m == null) {
          return const Center(child: Text('Obat tidak ditemukan'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medication_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m.code,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StockBadge(medicine: m),
                      ExpiredBadge(medicine: m),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Informasi',
              children: [
                _InfoRow(label: 'Kategori', value: m.categoryName ?? '-'),
                _InfoRow(label: 'Supplier', value: m.supplierName ?? '-'),
                _InfoRow(label: 'Satuan', value: m.unit),
                _InfoRow(
                  label: 'Expired',
                  value: m.expiredDate == null
                      ? '-'
                      : DateFormatter.toDisplay(m.expiredDate!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Stok & Harga',
              children: [
                _InfoRow(
                  label: 'Stok saat ini',
                  value: '${m.currentStock} ${m.unit}',
                ),
                _InfoRow(
                  label: 'Stok minimum',
                  value: '${m.minimumStock} ${m.unit}',
                ),
                _InfoRow(
                  label: 'Harga beli',
                  value: CurrencyFormatter.format(m.purchasePrice),
                ),
                _InfoRow(
                  label: 'Harga jual',
                  value: CurrencyFormatter.format(m.sellingPrice),
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
                    child: Text(m.description!),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.stockIn, arguments: m),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Stok Masuk'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.stockOut, arguments: m),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Stok Keluar'),
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
