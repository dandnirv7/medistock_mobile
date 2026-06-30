import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_async_view.dart';
import '../controllers/supplier_list_controller.dart';
import '../models/supplier_model.dart';

class SupplierListView extends GetView<SupplierListController> {
  const SupplierListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Supplier'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Obx(() => _SearchBar(
              query: controller.search.value,
              onChanged: controller.setSearch,
              onSort: () => _showSortSheet(context),
              sortBy: controller.sortBy.value,
              sortOrder: controller.sortOrder.value,
            )),
          ),
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

  void _showSortSheet(BuildContext context) {
    final ctrl = controller;
    final currentField = ctrl.sortBy.value;
    final currentOrder = ctrl.sortOrder.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Urutkan', style: AppTextStyles.sectionHeader),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(AppIcons.close, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SortOption(
              icon: LucideIcons.arrowUpWideNarrow,
              label: 'Nama (A-Z)',
              isSelected: currentField == 'name' && currentOrder == 'asc',
              onTap: () { ctrl.setSort('name', 'asc'); Get.back(); },
            ),
            _SortOption(
              icon: LucideIcons.arrowDownWideNarrow,
              label: 'Nama (Z-A)',
              isSelected: currentField == 'name' && currentOrder == 'desc',
              onTap: () { ctrl.setSort('name', 'desc'); Get.back(); },
            ),
            _SortOption(
              icon: LucideIcons.clock,
              label: 'Terbaru',
              isSelected: currentField == 'createdAt' && currentOrder == 'desc',
              onTap: () { ctrl.setSort('createdAt', 'desc'); Get.back(); },
            ),
            _SortOption(
              icon: LucideIcons.history,
              label: 'Terlama',
              isSelected: currentField == 'createdAt' && currentOrder == 'asc',
              onTap: () { ctrl.setSort('createdAt', 'asc'); Get.back(); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onSort;
  final String sortBy;
  final String sortOrder;

  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.onSort,
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(AppIcons.search, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Cari supplier...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: () => onChanged(''),
                    child: Icon(AppIcons.close, color: AppColors.textSecondary, size: 18),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSort,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              sortOrder == 'desc' ? LucideIcons.arrowDownWideNarrow : LucideIcons.arrowUpWideNarrow,
              size: 20,
              color: sortBy != 'name' || sortOrder != 'asc'
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(AppIcons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SupplierList extends StatelessWidget {
  const _SupplierList({required this.items});
  final List<SupplierModel> items;

  @override
  Widget build(BuildContext context) {
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
          onTap: () => Get.toNamed(AppRoutes.supplierDetail, arguments: s),
        );
      },
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({
    required this.supplier,
    required this.onTap,
  });

  final SupplierModel supplier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
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
                borderRadius: BorderRadius.circular(AppSpacing.sm),
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
                    style: AppTextStyles.cardTitle,
                  ),
                  if (supplier.phone != null && supplier.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      supplier.phone!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (supplier.address != null &&
                      supplier.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      supplier.address!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
