import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_overlay.dart';
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
                  const Icon(Icons.tune),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: controller.setSearch,
              decoration: InputDecoration(
                hintText: 'Cari obat, supplier, atau catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.search.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.search.value = '';
                            controller.fetch();
                          },
                        ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
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
                  icon: Icons.swap_vert_outlined,
                  title: 'Belum ada mutasi',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => _MovementCard(
                    movement: controller.items[i],
                    onTapMedicine: () {
                      Get.toNamed(
                        AppRoutes.medicineDetail,
                        parameters: {'id': controller.items[i].medicineId},
                      );
                    },
                  ),
                ),
              );
            }),
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
            child: const Icon(Icons.arrow_downward, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'fab-out',
            onPressed: () => Get.toNamed(AppRoutes.stockOut),
            backgroundColor: AppColors.danger,
            child: const Icon(Icons.arrow_upward, color: Colors.white),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              const SizedBox(width: 10),
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
          const SizedBox(height: 10),
          Row(
            children: [
              _Cell(label: 'Qty', value: '${isIn ? '+' : '-'}${movement.quantity}'),
              const SizedBox(width: 16),
              _Cell(label: 'Sebelum', value: '${movement.stockBefore}'),
              const SizedBox(width: 16),
              _Cell(label: 'Sesudah', value: '${movement.stockAfter}'),
            ],
          ),
          const SizedBox(height: 8),
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
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
