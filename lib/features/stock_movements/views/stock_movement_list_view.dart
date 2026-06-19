import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/data_async_view.dart';
import '../controllers/stock_movement_list_controller.dart';
import '../models/stock_movement_model.dart';
import '../widgets/stock_movement_filter_sheet.dart';

class StockMovementListView extends GetView<StockMovementListController> {
  const StockMovementListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutasi Stok'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Filter',
              onPressed: () => _openFilterSheet(context),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(AppIcons.filter),
                  if (controller.hasActiveFilters)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              decoration: InputDecoration(
                hintText: 'Cari obat, supplier, atau catatan...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: Obx(
                  () => controller.search.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(AppIcons.close),
                          onPressed: () {
                            controller.search.value = '';
                            controller.load();
                          },
                        ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: DataAsyncView<StockMovementModel>(
                state: controller.state,
                items: controller.items,
                errorMessage: controller.errorMessage,
                onRetry: controller.load,
                emptyTitle: 'Belum ada mutasi',
                emptySubtitle:
                    'Mutasi stok akan muncul di sini setelah ada stok masuk atau keluar',
                emptyIcon: AppIcons.swapVert,
                builder: (context, list) => _MovementList(items: list),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab-in',
            onPressed: () => Get.toNamed(AppRoutes.stockIn),
            backgroundColor: AppColors.success,
            child: const Icon(AppIcons.stockIn, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.small(
            heroTag: 'fab-out',
            onPressed: () => Get.toNamed(AppRoutes.stockOut),
            backgroundColor: AppColors.danger,
            child: const Icon(AppIcons.stockOut, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StockMovementFilterSheet(),
    );
  }
}

class _MovementList extends StatelessWidget {
  const _MovementList({required this.items});
  final List<StockMovementModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final m = items[i];
        return _MovementCard(
          movement: m,
          onTapMedicine: () => Get.toNamed(
            AppRoutes.medicineDetail,
            parameters: {'id': m.medicineId},
          ),
        );
      },
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({
    required this.movement,
    required this.onTapMedicine,
  });

  final StockMovementModel movement;
  final VoidCallback onTapMedicine;

  @override
  Widget build(BuildContext context) {
    final isIn = movement.type == StockMovementType.stockIn;
    final accent = isIn ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.border(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isIn ? 'IN' : 'OUT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: GestureDetector(
                  onTap: onTapMedicine,
                  child: Text(
                    movement.medicineName ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            children: [
              _Cell(label: 'Qty', value: '${isIn ? '+' : '-'}${movement.quantity}'),
              const SizedBox(width: AppSpacing.lg),
              _Cell(label: 'Sebelum', value: '${movement.stockBefore}'),
              const SizedBox(width: AppSpacing.lg),
              _Cell(label: 'Sesudah', value: '${movement.stockAfter}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  movement.transactionDate == null
                      ? '-'
                      : DateFormatter.toDisplayWithTime(
                          movement.transactionDate!,
                        ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                movement.reason.label,
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}
