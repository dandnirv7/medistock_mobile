import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/data_async_view.dart';
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              onChanged: controller.setSearch,
              decoration: const InputDecoration(
                hintText: 'Cari supplier',
                prefixIcon: Icon(AppIcons.search),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: DataAsyncView<SupplierModel>(
                state: controller.state,
                items: controller.items,
                errorMessage: controller.errorMessage,
                onRetry: controller.load,
                emptyTitle: 'Belum ada supplier',
                emptySubtitle: 'Tambahkan supplier untuk mulai mencatat pembelian',
                emptyIcon: AppIcons.localShipping,
                emptyActionLabel: 'Tambah Supplier',
                onEmptyAction: () => Get.toNamed(AppRoutes.supplierForm),
                builder: (context, list) => _SupplierList(items: list),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Get.find<AuthSession>().userRx.value?.isAdmin == true
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.supplierForm),
                icon: const Icon(AppIcons.add),
                label: const Text('Tambah'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _SupplierList extends StatelessWidget {
  const _SupplierList({required this.items});
  final List<SupplierModel> items;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupplierListController>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final s = items[i];
        return _SupplierTile(
          supplier: s,
          onEdit: () => Get.toNamed(AppRoutes.supplierForm, arguments: s),
          onDelete: () async {
            final ok = await ConfirmDialog.show(
              context,
              title: 'Hapus supplier?',
              message: '${s.name} akan dinonaktifkan.',
            );
            if (ok) await controller.delete(s);
          },
        );
      },
    );
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.border(AppRadii.md),
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
              borderRadius: AppRadii.border(AppRadii.sm),
            ),
            child: const Icon(
              AppIcons.localShipping,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (supplier.phone != null && supplier.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supplier.phone!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (supplier.address != null &&
                    supplier.address!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    supplier.address!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              _CircleIconButton(
                icon: AppIcons.call,
                onTap: () {
                  if (supplier.phone != null && supplier.phone!.isNotEmpty) {
                    SnackbarHelper.success('Telepon ${supplier.phone}');
                  } else {
                    SnackbarHelper.error('Nomor telepon tidak tersedia');
                  }
                },
              ),
              _CircleIconButton(
                icon: AppIcons.message,
                onTap: () {
                  if (supplier.phone != null && supplier.phone!.isNotEmpty) {
                    SnackbarHelper.success('WhatsApp ${supplier.phone}');
                  } else {
                    SnackbarHelper.error('Nomor WhatsApp tidak tersedia');
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
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
