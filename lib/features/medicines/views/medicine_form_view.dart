import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/app_date_picker.dart';
import '../controllers/medicine_form_controller.dart';
import '../models/medicine_model.dart';
import 'scan_view.dart';

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
                controller: controller.nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Obat *',
                  hintText: 'Masukkan nama obat',
                ),
                validator: (v) =>
                    controller.requiredText(v, 'Nama obat'),
              ),
              const SizedBox(height: 12),
              // Kode Obat + Scan button row (Req 5.1).
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kode Obat *',
                        hintText: 'Mis. PAR-500',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          controller.requiredText(v, 'Kode'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _ScanButton(
                      onScanned: (medicine) {
                        controller.autoFillFromMedicine(medicine);
                        SnackbarHelper.success(
                          'Form diisi dari barcode: ${medicine.name}',
                        );
                      },
                    ),
                  ),
                ],
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
              _Dropdown<String>(
                label: 'Satuan',
                value: controller.unit.value,
                items: controller.unitOptions
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.unit.value = v;
                },
                hint: 'Pilih satuan',
                required: true,
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Harga beli wajib diisi',
                        ),
                        FormBuilderValidators.numeric(
                          errorText: 'Nilai harus angka positif',
                        ),
                        FormBuilderValidators.min(
                          1,
                          errorText: 'Nilai harus angka positif',
                        ),
                      ]),
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
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Harga jual wajib diisi',
                        ),
                        FormBuilderValidators.numeric(
                          errorText: 'Nilai harus angka positif',
                        ),
                        FormBuilderValidators.min(
                          1,
                          errorText: 'Nilai harus angka positif',
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.editing == null) ...[
                    Expanded(
                      child: TextFormField(
                        controller: controller.currentStockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok Saat Ini',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Stok saat ini wajib diisi',
                          ),
                          FormBuilderValidators.integer(
                            errorText: 'Nilai harus angka positif atau nol',
                          ),
                          FormBuilderValidators.min(
                            0,
                            errorText: 'Nilai harus angka positif atau nol',
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: controller.minimumStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok Minimum',
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: 'Stok minimum wajib diisi',
                        ),
                        FormBuilderValidators.integer(
                          errorText: 'Nilai harus angka positif atau nol',
                        ),
                        FormBuilderValidators.min(
                          0,
                          errorText: 'Nilai harus angka positif atau nol',
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.expiredDateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Expired *',
                  suffixIcon: IconButton(
                    onPressed: () => _pickDate(context),
                    icon: const Icon(AppIcons.calendar_today_outlined),
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
    final picked = await AppDatePicker.show(
      context,
      initialDate: controller.expiredDate ?? DateTime.now(),
      title: 'Tanggal Expired',
    );
    if (picked != null) controller.setExpiredDate(picked);
  }
}

/// Compact icon button that opens [ScanView] and calls [onScanned] on success.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onScanned});

  final void Function(MedicineModel medicine) onScanned;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Scan barcode',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Get.to<void>(
            () => ScanView(onBarcodeScanned: onScanned),
            transition: Transition.downToUp,
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary),
          ),
          child: const Icon(AppIcons.barcode, color: AppColors.primary, size: 22),
        ),
      ),
    );
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
