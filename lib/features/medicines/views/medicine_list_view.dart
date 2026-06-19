import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_async_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/storage/auth_session.dart';
import '../../categories/data/repositories/category_repository.dart';
import '../../categories/models/category_model.dart';
import '../controllers/medicine_list_controller.dart';
import '../data/repositories/medicine_repository.dart' show MedicineExpiredFilter;
import '../models/medicine_model.dart';

class MedicineListView extends GetView<MedicineListController> {
  const MedicineListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Obat'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: () => _openCategoryFilter(context),
            icon: const Icon(AppIcons.filter),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: _InlineSearchField(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _FilterChipRow(),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: DataAsyncView<MedicineModel>(
                state: controller.state,
                items: controller.items,
                errorMessage: controller.errorMessage,
                onRetry: controller.load,
                emptyTitle: 'Belum ada obat',
                emptySubtitle: 'Tambahkan obat pertama untuk mulai mengelola inventaris',
                emptyIcon: AppIcons.medicines,
                emptyActionLabel: 'Tambah Obat',
                onEmptyAction: () => Get.toNamed(AppRoutes.medicineForm),
                builder: (context, list) => _MedicineList(items: list),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => Get.find<AuthSession>().userRx.value?.isAdmin == true
            ? FloatingActionButton(
                heroTag: 'fab-medicine',
                onPressed: () => Get.toNamed(AppRoutes.medicineForm),
                backgroundColor: AppColors.primary,
                child: const Icon(AppIcons.add, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _openCategoryFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CategoryFilterSheet(),
    );
  }
}

/// Inline search field placed directly under the AppBar. Stays in sync
/// with [MedicineListController.search] so that switching filters from
/// elsewhere (e.g. the filter sheet) still updates the displayed text,
/// and vice-versa. A short debounce keeps the request rate sensible
/// while the user is typing.
class _InlineSearchField extends StatefulWidget {
  @override
  State<_InlineSearchField> createState() => _InlineSearchFieldState();
}

class _InlineSearchFieldState extends State<_InlineSearchField> {
  late final TextEditingController _textCtrl;
  late final MedicineListController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MedicineListController>();
    _textCtrl = TextEditingController(text: _ctrl.search.value);
    // Pick up programmatic changes to the controller's search term
    // (e.g. from a future "clear filters" button) so the field stays
    // accurate.
    ever(_ctrl.search, (String value) {
      if (_textCtrl.text != value) {
        _textCtrl.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _textCtrl,
        onChanged: (v) => _ctrl.setSearch(v),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Cari obat, kode, atau supplier...',
          prefixIcon: Icon(AppIcons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// Bottom sheet content for choosing a medicine category (or "All").
///
/// Loads the full list of categories once when the sheet opens, then
/// filters locally as the user types in the search field at the top.
/// Tapping any row (or the "Semua Kategori" row) closes the sheet and
/// pushes the new filter into [MedicineListController].
class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet();

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late final MedicineListController _ctrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  Future<List<CategoryModel>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MedicineListController>();
    _categoriesFuture = _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<CategoryModel>> _fetch() async {
    if (!Get.isRegistered<CategoryRepository>()) return const [];
    final repo = Get.find<CategoryRepository>();
    final page = await repo.getAll(query: CategoryQuery(limit: 100));
    return page.items;
  }

  List<CategoryModel> _applyFilter(List<CategoryModel> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.toLowerCase();
    return source
        .where((c) => c.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _select(String? id) {
    _ctrl.categoryFilter.value = id;
    _ctrl.load();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Pilih Kategori',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Cari kategori...',
                    prefixIcon: Icon(AppIcons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: FutureBuilder<List<CategoryModel>>(
                  future: _categoriesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Gagal memuat kategori',
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final all = snap.data ?? const <CategoryModel>[];
                    final filtered = _applyFilter(all);
                    return ListView(
                      shrinkWrap: true,
                      children: [
                        _CategoryTile(
                          label: 'Semua Kategori',
                          trailing: _ctrl.categoryFilter.value == null
                              ? const Icon(AppIcons.check,
                                  color: AppColors.primary)
                              : null,
                          onTap: () => _select(null),
                        ),
                        const Divider(height: 1),
                        if (filtered.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'Tidak ada kategori yang cocok',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          for (final c in filtered) ...[
                            _CategoryTile(
                              label: c.name,
                              trailing: _ctrl.categoryFilter.value == c.id
                                  ? const Icon(AppIcons.check,
                                      color: AppColors.primary)
                                  : null,
                              onTap: () => _select(c.id),
                            ),
                            const Divider(height: 1),
                          ],
                        const SizedBox(height: AppSpacing.md),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label),
      trailing: trailing,
    );
  }
}

class _MedicineList extends StatelessWidget {
  const _MedicineList({required this.items});
  final List<MedicineModel> items;

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
      itemBuilder: (context, i) => _MedicineCard(
        medicine: items[i],
        onTap: () => Get.toNamed(
          AppRoutes.medicineDetail,
          parameters: {'id': items[i].id},
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow();
  MedicineListController get controller => Get.find<MedicineListController>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          scrollDirection: Axis.horizontal,
          children: [
            _FilterChip(
              label: 'Semua',
              selected: !controller.lowStockOnly.value &&
                  controller.expiredFilter.value ==
                      MedicineExpiredFilter.all,
              onTap: () {
                controller.lowStockOnly.value = false;
                controller.setExpiredFilter(MedicineExpiredFilter.all);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Hampir Expired',
              selected:
                  controller.expiredFilter.value == MedicineExpiredFilter.soon,
              onTap: () => controller
                  .setExpiredFilter(MedicineExpiredFilter.soon),
            ),
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: 'Stok Rendah',
              selected: controller.lowStockOnly.value,
              onTap: () {
                controller.lowStockOnly.value = !controller.lowStockOnly.value;
                controller.load();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine, required this.onTap});

  final MedicineModel medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stock = medicine.stockStatus;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.border(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.border(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MedIcon(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine.code,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusBadge(
                        label: medicine.unit.isEmpty ? 'Obat' : medicine.unit,
                        tone: BadgeTone.neutral,
                      ),
                      if (stock != StockStatus.safe)
                        StockBadge(medicine: medicine),
                      if (medicine.isExpired || medicine.isExpiredSoon)
                        ExpiredBadge(medicine: medicine),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${medicine.currentStock}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Stok',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MedIcon extends StatelessWidget {
  const _MedIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadii.border(AppRadii.md),
      ),
      child: const Icon(
        AppIcons.medicines,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
