import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../medicines/models/medicine_model.dart';
import '../controllers/stock_in_controller.dart';

class StockInView extends GetView<StockInController> {
  const StockInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Masuk')),
      body: Obx(() {
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (controller.errorMessage.value != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              DropdownButtonFormField<String>(
                initialValue: controller.medicineId.value,
                items: controller.medicines
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.code} - ${m.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: controller.setMedicine,
                decoration: const InputDecoration(
                  labelText: 'Pilih Obat *',
                ),
                validator: (v) =>
                    v == null ? 'Pilih obat terlebih dahulu' : null,
              ),
              if (controller.selectedMedicine != null) ...[
                const SizedBox(height: 8),
                _CurrentStockTile(medicine: controller.selectedMedicine!),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                validator: controller.positiveInt,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: controller.supplierId.value,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tanpa supplier'),
                  ),
                  ...controller.suppliers.map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ),
                  ),
                ],
                onChanged: controller.setSupplier,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.dateCtrl,
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.notesCtrl,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final ok = await controller.submit();
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              'Berhasil',
                              'Stok masuk berhasil disimpan',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                            );
                          }
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    controller.isLoading.value ? 'Menyimpan…' : 'Simpan',
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.setDate(picked);
  }
}

class _CurrentStockTile extends StatelessWidget {
  const _CurrentStockTile({required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Stok saat ini: ${medicine.currentStock} ${medicine.unit}',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
