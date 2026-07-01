import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/data_async_view.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_icons.dart';
import '../controllers/category_list_controller.dart';
import '../models/category_model.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CategoryListController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Kategori'),
      ),
      floatingActionButton: Obx(
        () => Get.find<AuthSession>().isAdmin
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => _openForm(context),
                child: const Icon(LucideIcons.plus),
              )
            : const SizedBox.shrink(),
      ),
      body: DataAsyncView<CategoryModel>(
        state: ctrl.state,
        items: ctrl.items,
        onRetry: ctrl.load,
        errorMessage: ctrl.errorMessage,
        emptyTitle: 'Belum ada kategori',
        emptyActionLabel: 'Tambah Kategori',
        onEmptyAction: () => _openForm(context),
        builder: (context, items) => _CategoryBody(
          items: items,
          ctrl: ctrl,
          onCreate: () => _openForm(context),
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Get.toNamed('/categories/form');
  }
}

class _CategoryBody extends StatelessWidget {
  final List<CategoryModel> items;
  final CategoryListController ctrl;
  final VoidCallback onCreate;

  const _CategoryBody({
    required this.items,
    required this.ctrl,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              Obx(() => _SearchBar(
                query: ctrl.search.value,
                onChanged: ctrl.setSearch,
                onSort: () => _showSortSheet(context, ctrl),
                sortBy: ctrl.sortBy.value,
                sortOrder: ctrl.sortOrder.value,
              )),
              const SizedBox(height: 16),
              if (items.isEmpty)
                _EmptyState()
              else
                ...items.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryTile(category: cat),
                )),
              const SizedBox(height: 16),
              Obx(
                () => Get.find<AuthSession>().isAdmin
                    ? _BottomAddCard(onTap: onCreate)
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _showSortSheet(BuildContext context, CategoryListController ctrl) {
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
            _SortOption(
              icon: LucideIcons.pill,
              label: 'Obat Terbanyak',
              isSelected: currentField == 'medicineCount' && currentOrder == 'desc',
              onTap: () { ctrl.setSort('medicineCount', 'desc'); Get.back(); },
            ),
            _SortOption(
              icon: LucideIcons.pill,
              label: 'Obat Tersedikit',
              isSelected: currentField == 'medicineCount' && currentOrder == 'asc',
              onTap: () { ctrl.setSort('medicineCount', 'asc'); Get.back(); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
                      hintText: 'Cari kategori...',
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

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/categories/detail', arguments: category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(_iconFor(category), color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.medicineCount} obat',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(CategoryModel cat) {
    final name = cat.name.toLowerCase();
    if (name.contains('tablet') || name.contains('kaplet')) return LucideIcons.pill;
    if (name.contains('sirup') || name.contains('syrup')) return LucideIcons.flaskRound;
    if (name.contains('salep') || name.contains('cream') || name.contains('ointment')) return LucideIcons.beaker;
    if (name.contains('tetes') || name.contains('drop')) return LucideIcons.droplet;
    if (name.contains('injeksi') || name.contains('suntik')) return AppIcons.syringe;
    return AppIcons.categories;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(LucideIcons.folderOpen, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Belum ada kategori',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAddCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomAddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(AppIcons.add, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Kategori Baru',
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buat kategori untuk pengelompokan obat',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
