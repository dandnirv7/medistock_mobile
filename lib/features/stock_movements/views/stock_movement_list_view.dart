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

class StockMovementListView extends GetView<StockMovementListController> {
  const StockMovementListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Mutasi'),
        actions: [
          PopupMenuButton<StockMovementType?>(
            tooltip: 'Filter tipe',
            icon: const Icon(Icons.filter_list),
            onSelected: controller.setType,
            itemBuilder: (_) => [
              const PopupMenuItem<StockMovementType?>(
                value: null,
                child: Text('Semua'),
              ),
              const PopupMenuItem<StockMovementType?>(
                value: StockMovementType.stockIn,
                child: Text('Stok Masuk'),
              ),
              const PopupMenuItem<StockMovementType?>(
                value: StockMovementType.stockOut,
                child: Text('Stok Keluar'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
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
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) => _MovementTile(
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
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.movement,
    required this.onTapMedicine,
  });

  final StockMovementModel movement;
  final VoidCallback onTapMedicine;

  @override
  Widget build(BuildContext context) {
    final isIn = movement.type == StockMovementType.stockIn;
    final color = isIn ? AppColors.success : AppColors.danger;
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.medicineName ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${movement.medicineCode ?? '-'} • ${movement.reason.label}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movement.transactionDate == null
                      ? '-'
                      : DateFormatter.toDisplayWithTime(
                          movement.transactionDate!,
                        ),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (movement.notes != null && movement.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      movement.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIn ? '+' : '-'}${movement.quantity}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '→ ${movement.stockAfter}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
