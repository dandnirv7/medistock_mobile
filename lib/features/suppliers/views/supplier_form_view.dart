import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/supplier_form_controller.dart';

class SupplierFormView extends GetView<SupplierFormController> {
  const SupplierFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.editing == null
                  ? 'Tambah Supplier'
                  : 'Edit Supplier',
            )),
      ),
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
              TextFormField(
                controller: controller.nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Supplier'),
                validator: (v) =>
                    controller.requiredText(v, 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: controller.emailValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.addressCtrl,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.notesCtrl,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 2,
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
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final ok = await controller.submit();
                          if (ok) Get.back();
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          controller.editing == null ? 'Simpan' : 'Perbarui',
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
