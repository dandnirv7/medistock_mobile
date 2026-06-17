import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../controllers/supplier_list_controller.dart';
import '../models/supplier_model.dart';

class SupplierListView extends GetView<SupplierListController> {
  const SupplierListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supplier')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: controller.setSearch,
              decoration: const InputDecoration(
                hintText: 'Cari supplier',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
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
                  icon: Icons.local_shipping_outlined,
                  title: 'Belum ada supplier',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final s = controller.items[i];
                    return _SupplierTile(
                      supplier: s,
                      onEdit: () => Get.toNamed(
                        AppRoutes.supplierForm,
                        arguments: s,
                      ),
                      onDelete: () => _confirmDelete(context, s),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.supplierForm),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SupplierModel s) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Hapus supplier?',
      message: '${s.name} akan dinonaktifkan.',
    );
    if (ok) await controller.delete(s);
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplierModel supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (supplier.phone != null || supplier.email != null)
                  Text(
                    [supplier.phone, supplier.email]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(' • '),
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
          Wrap(
            spacing: 4,
            children: [
              _CircleIconButton(
                icon: Icons.call_outlined,
                onTap: () {
                  if (supplier.phone != null && supplier.phone!.isNotEmpty) {
                    Get.snackbar(
                      'Telepon',
                      supplier.phone!,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              _CircleIconButton(
                icon: Icons.message_outlined,
                onTap: () {
                  if (supplier.phone != null && supplier.phone!.isNotEmpty) {
                    Get.snackbar(
                      'WhatsApp',
                      supplier.phone!,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
