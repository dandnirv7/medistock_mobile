import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/medicine_form_controller.dart';

class MedicineFormView extends GetView<MedicineFormController> {
  const MedicineFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editing == null ? 'Tambah Obat' : 'Edit Obat',
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
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
              TextFormField(
                controller: controller.codeCtrl,
                decoration: const InputDecoration(labelText: 'Kode / SKU'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    controller.requiredText(v, 'Kode'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Obat'),
                validator: (v) =>
                    controller.requiredText(v, 'Nama obat'),
              ),
              const SizedBox(height: 12),
              _Dropdown<String>(
                label: 'Kategori',
                value: controller.categoryId.value,
                items: controller.categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.categoryId.value = v,
                hint: 'Pilih kategori',
                required: true,
              ),
              const SizedBox(height: 12),
              _Dropdown<String>(
                label: 'Supplier',
                value: controller.supplierId.value,
                items: controller.suppliers
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.supplierId.value = v,
                hint: 'Pilih supplier (opsional)',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.unitCtrl,
                decoration: const InputDecoration(
                  labelText: 'Satuan (Tablet, Botol, dll)',
                ),
                validator: (v) =>
                    controller.requiredText(v, 'Satuan'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.purchasePriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Harga Beli',
                      ),
                      validator: (v) => controller.numberText(
                        v,
                        'Harga beli',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: controller.sellingPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Harga Jual',
                      ),
                      validator: (v) => controller.numberText(
                        v,
                        'Harga jual',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.editing == null)
                TextFormField(
                  controller: controller.currentStockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok Awal',
                  ),
                  validator: (v) => controller.numberText(
                    v,
                    'Stok awal',
                    integer: true,
                  ),
                ),
              if (controller.editing == null) const SizedBox(height: 12),
              TextFormField(
                controller: controller.minimumStockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Minimum',
                ),
                validator: (v) => controller.numberText(
                  v,
                  'Stok minimum',
                  integer: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.expiredDateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Expired',
                  suffixIcon: IconButton(
                    onPressed: () => _pickDate(context),
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                ),
                maxLines: 3,
              ),
              if (controller.editing != null) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.isActive.value,
                  onChanged: (v) => controller.isActive.value = v,
                  title: const Text('Aktif'),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final ok = await controller.submit();
                  if (ok) Get.back();
                },
                child: Text(
                  controller.editing == null ? 'Simpan' : 'Perbarui',
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
      initialDate: controller.expiredDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.setExpiredDate(picked);
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.required = false,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
      ),
      hint: hint == null ? null : Text(hint!),
      validator: (v) {
        if (required && (v == null || (v is String && v.isEmpty))) {
          return '$label wajib dipilih';
        }
        return null;
      },
    );
  }
}
