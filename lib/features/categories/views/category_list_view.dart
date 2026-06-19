import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/data_async_view.dart';
import '../controllers/category_list_controller.dart';
import '../models/category_model.dart';

class CategoryListView extends GetView<CategoryListController> {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
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
                hintText: 'Cari kategori',
                prefixIcon: Icon(AppIcons.search),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: DataAsyncView<CategoryModel>(
                state: controller.state,
                items: controller.items,
                errorMessage: controller.errorMessage,
                onRetry: controller.load,
                emptyTitle: 'Belum ada kategori',
                emptySubtitle: 'Tambahkan kategori untuk mengelompokkan obat',
                emptyIcon: AppIcons.categoryOutlined,
                emptyActionLabel: 'Tambah Kategori',
                onEmptyAction: () => Get.toNamed(AppRoutes.categoryForm),
                builder: (context, list) => _CategoryList(items: list),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Get.find<AuthSession>().userRx.value?.isAdmin == true
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.categoryForm),
                icon: const Icon(AppIcons.add),
                label: const Text('Tambah'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.items});
  final List<CategoryModel> items;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryListController>();
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
        final c = items[i];
        return _CategoryTile(
          category: c,
          onTap: () => Get.toNamed(
            AppRoutes.categoryForm,
            arguments: c,
          ),
          onDelete: () async {
            final ok = await ConfirmDialog.show(
              context,
              title: 'Hapus kategori?',
              message: '${c.name} akan dinonaktifkan.',
            );
            if (ok) await controller.delete(c);
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback onTap;
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
              AppIcons.categoryOutlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (category.description != null &&
                    category.description!.isNotEmpty)
                  Text(
                    category.description!,
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
          IconButton(
            tooltip: 'Hapus',
            onPressed: onDelete,
            icon: const Icon(AppIcons.delete, color: AppColors.danger),
          ),
          const Icon(AppIcons.chevronRight, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
