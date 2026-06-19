import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../medicines/controllers/medicine_list_controller.dart';
import '../../medicines/data/repositories/medicine_repository.dart';
import '../../medicines/models/medicine_model.dart';
import '../../../core/theme/app_icons.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({super.key});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final MedicineListController _ctrl;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _ctrl = Get.isRegistered<MedicineListController>()
        ? Get.find<MedicineListController>()
        : Get.put(
            MedicineListController(Get.find<MedicineRepository>()),
            permanent: true,
          );
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        _applyFilterForTab(_tab.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilterForTab(0);
    });
  }

  void _applyFilterForTab(int index) {
    switch (index) {
      case 0:
        _ctrl.setLowStockOnly(true);
        _ctrl.setExpiredFilter(MedicineExpiredFilter.all);
        break;
      case 1:
        _ctrl.setLowStockOnly(false);
        _ctrl.setExpiredFilter(MedicineExpiredFilter.expired);
        break;
      case 2:
        _ctrl.setLowStockOnly(false);
        _ctrl.setExpiredFilter(MedicineExpiredFilter.soon);
        break;
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Stok Rendah'),
            Tab(text: 'Expired'),
            Tab(text: 'Segera'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _AlertList(),
          _AlertList(),
          _AlertList(),
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MedicineListController>();
    return Obx(() {
      if (c.items.isEmpty) {
        return const EmptyState(
          icon: AppIcons.check_circle_outline,
          title: 'Tidak ada alert',
          subtitle: 'Semua obat dalam kondisi aman',
        );
      }
      return RefreshIndicator(
        onRefresh: c.refresh,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: c.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final m = c.items[i];
            return _AlertTile(
              medicine: m,
              onTap: () => Get.toNamed(
                AppRoutes.medicineDetail,
                parameters: {'id': m.id},
              ),
            );
          },
        ),
      );
    });
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.medicine, required this.onTap});
  final MedicineModel medicine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lowStock = medicine.isLowStock;
    final expired = medicine.isExpired;
    final color = expired
        ? AppColors.expired
        : lowStock
            ? AppColors.stockLow
            : AppColors.expiredSoon;
    final icon = expired
        ? AppIcons.event_busy
        : lowStock
            ? AppIcons.warning_amber_outlined
            : AppIcons.schedule;
    final label = expired
        ? 'Expired'
        : lowStock
            ? 'Stok ${medicine.currentStock}/${medicine.minimumStock}'
            : 'Expired ${DateFormatter.toDisplay(medicine.expiredDate!)}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
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
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
