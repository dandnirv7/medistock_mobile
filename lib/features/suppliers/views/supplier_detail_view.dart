import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../controllers/supplier_list_controller.dart';
import '../models/supplier_model.dart';

class SupplierDetailView extends GetView<SupplierListController> {
  const SupplierDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final supplier = Get.arguments as SupplierModel;
    final isAdmin = Get.find<AuthSession>().userRx.value?.isAdmin == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Detail Supplier'),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              icon: Icon(LucideIcons.moreVertical, color: AppColors.textPrimary),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.border),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  Get.toNamed(AppRoutes.supplierForm, arguments: supplier);
                } else if (value == 'delete') {
                  _confirmDelete(supplier);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: 18, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: 18, color: AppColors.danger),
                      SizedBox(width: 10),
                      Text('Hapus', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(supplier: supplier),
          const SizedBox(height: 16),
          _ContactCard(supplier: supplier),
          const SizedBox(height: 16),
          _AddressCard(supplier: supplier),
          const SizedBox(height: 16),
          _StatsCard(supplier: supplier),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(SupplierModel supplier) async {
    final ok = await ConfirmDialog.show(
      Get.context!,
      title: 'Hapus supplier?',
      message: '${supplier.name} akan dinonaktifkan.',
    );
    if (ok == true) {
      await controller.delete(supplier);
      Get.back();
      SnackbarHelper.success('${supplier.name} dinonaktifkan');
    }
  }
}

class _InfoCard extends StatelessWidget {
  final SupplierModel supplier;

  const _InfoCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(AppIcons.localShipping, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name, style: AppTextStyles.screenTitle),
                const SizedBox(height: 2),
                Text(
                  '${supplier.medicineCount} obat',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SupplierModel supplier;

  const _ContactCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kontak', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telepon', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text(
                      supplier.phone ?? '-',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
              if (supplier.phone != null)
                GestureDetector(
                  onTap: () => SnackbarHelper.success('Telepon ${supplier.phone}'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.phoneCall, size: 18, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.mail, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    Text(
                      supplier.email ?? '-',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final SupplierModel supplier;

  const _AddressCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    if (supplier.address == null && supplier.notes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (supplier.address != null) ...[
            Text('Alamat', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            Text(
              supplier.address!,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (supplier.notes != null) ...[
            if (supplier.address != null) const SizedBox(height: 12),
            Text('Catatan', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            Text(
              supplier.notes!,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final SupplierModel supplier;

  const _StatsCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),
          _InfoRow(label: 'ID', value: supplier.id),
          const SizedBox(height: 8),
          _InfoRow(label: 'Total Obat', value: '${supplier.medicineCount}'),
          if (supplier.createdAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Dibuat',
              value: _formatDate(supplier.createdAt!),
            ),
          ],
          if (supplier.updatedAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Diperbarui',
              value: _formatDate(supplier.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => DateFormatter.toDisplay(d);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.body),
        ),
      ],
    );
  }
}
