import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/models/paginated.dart';
import '../../../app/routes/app_routes.dart';
import '../../medicines/data/repositories/medicine_repository.dart';
import '../../medicines/models/medicine_model.dart';
import '../controllers/category_list_controller.dart';
import '../models/category_model.dart';

class CategoryDetailView extends StatelessWidget {
  const CategoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final category = Get.arguments as CategoryModel;
    final ctrl = Get.find<CategoryListController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Detail Kategori'),
        actions: [
          Obx(
            () => Get.find<AuthSession>().isAdmin
                ? PopupMenuButton<String>(
                    icon: Icon(LucideIcons.moreVertical, color: AppColors.textPrimary),
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColors.border),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Get.toNamed(AppRoutes.categoryForm, arguments: category);
                      } else if (value == 'delete') {
                        _confirmDelete(context, category, ctrl);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(AppIcons.edit, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text('Edit', style: AppTextStyles.body),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(AppIcons.delete, size: 18, color: AppColors.danger),
                            const SizedBox(width: 10),
                            Text('Hapus', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(category: category),
          const SizedBox(height: 16),
          _DescriptionCard(category: category),
          const SizedBox(height: 16),
          _StatsCard(category: category),
          const SizedBox(height: 16),
          _MedicinesSection(categoryId: category.id),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryModel category,
    CategoryListController ctrl,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ctrl.delete(category);
      Get.back();
    }
  }
}

class _InfoCard extends StatelessWidget {
  final CategoryModel category;

  const _InfoCard({required this.category});

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
            child: Icon(LucideIcons.tags, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: AppTextStyles.screenTitle),
                const SizedBox(height: 2),
                Text(
                  '${category.medicineCount} obat',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: category.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.isActive ? 'Aktif' : 'Nonaktif',
              style: AppTextStyles.caption.copyWith(
                color: category.isActive ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final CategoryModel category;

  const _DescriptionCard({required this.category});

  @override
  Widget build(BuildContext context) {
    if (category.description == null || category.description!.isEmpty) {
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
          Text('Deskripsi', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 8),
          Text(
            category.description!,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final CategoryModel category;

  const _StatsCard({required this.category});

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
          _InfoRow(label: 'ID', value: category.id),
          const SizedBox(height: 8),
          _InfoRow(label: 'Total Obat', value: '${category.medicineCount}'),
          if (category.createdAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Dibuat',
              value: _formatDate(category.createdAt!),
            ),
          ],
          if (category.updatedAt != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Diperbarui',
              value: _formatDate(category.updatedAt!),
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

class _MedicinesSection extends StatefulWidget {
  final String categoryId;

  const _MedicinesSection({required this.categoryId});

  @override
  State<_MedicinesSection> createState() => _MedicinesSectionState();
}

class _MedicinesSectionState extends State<_MedicinesSection> {
  final MedicineRepository _repo = Get.find<MedicineRepository>();
  late Future<Paginated<MedicineModel>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _medicinesFuture = _repo.getAll(
      query: MedicineQuery(
        categoryId: widget.categoryId,
        limit: 50,
        sortBy: 'name',
        sortOrder: 'asc',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Paginated<MedicineModel>>(
      future: _medicinesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                'Gagal memuat daftar obat',
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
            ),
          );
        }
        final medicines = snapshot.data?.items ?? [];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Obat',
                    style: AppTextStyles.sectionHeader,
                  ),
                  Text(
                    '${medicines.length} item',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (medicines.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Belum ada obat dalam kategori ini',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...medicines.map((m) => _MedicineTile(medicine: m)),
            ],
          ),
        );
      },
    );
  }
}

class _MedicineTile extends StatelessWidget {
  final MedicineModel medicine;

  const _MedicineTile({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final isLowStock = medicine.currentStock <= medicine.minimumStock;
    final isExpired = medicine.expiredDate != null && medicine.expiredDate!.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isLowStock
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.medication,
              size: 18,
              color: isLowStock ? AppColors.warning : AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Stok: ${medicine.currentStock}',
                      style: AppTextStyles.caption.copyWith(
                        color: isLowStock ? AppColors.warning : AppColors.textSecondary,
                        fontWeight: isLowStock ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (isExpired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Kadaluarsa',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (medicine.expiredDate != null)
            Text(
              DateFormatter.toDisplay(medicine.expiredDate!),
              style: AppTextStyles.caption.copyWith(
                color: isExpired ? AppColors.danger : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
