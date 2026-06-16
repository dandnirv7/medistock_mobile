import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../../stock_movements/models/stock_movement_model.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_summary_model.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Obx(() {
          if (controller.isLoading.value && controller.summary.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null &&
              controller.summary.value == null) {
            return _Error(
              message: controller.errorMessage.value!,
              onRetry: controller.refreshAll,
            );
          }
          final summary = controller.summary.value;
          if (summary == null) {
            return const Center(child: Text('Tidak ada data'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Greeting(),
              const SizedBox(height: 16),
              _SummaryGrid(summary: summary),
              const SizedBox(height: 24),
              _AlertSection(
                title: 'Stok Rendah',
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.stockLow,
                emptyText: 'Tidak ada obat dengan stok rendah',
                count: summary.lowStockCount,
                children: summary.lowStockMedicines
                    .map(
                      (m) => _AlertTile(
                        title: m.name,
                        subtitle: m.code,
                        trailing:
                            '${m.currentStock}/${m.minimumStock} ${m.unit}',
                      ),
                    )
                    .toList(),
                onSeeAll: () => Get.toNamed(
                  AppRoutes.medicines,
                  arguments: _MedicineFilterArg(lowStock: true),
                ),
              ),
              const SizedBox(height: 16),
              _AlertSection(
                title: 'Segera Expired',
                icon: Icons.schedule,
                iconColor: AppColors.expiredSoon,
                emptyText: 'Tidak ada obat yang akan segera expired',
                count: summary.expiredSoonCount,
                children: summary.expiredSoonMedicines
                    .map(
                      (m) => _AlertTile(
                        title: m.name,
                        subtitle: m.code,
                        trailing: m.expiredDate == null
                            ? '-'
                            : DateFormatter.toDisplay(m.expiredDate!),
                      ),
                    )
                    .toList(),
                onSeeAll: () => Get.toNamed(AppRoutes.alerts),
              ),
              const SizedBox(height: 16),
              _RecentMovements(
                items: controller.recentMovements.toList(),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: const _DashboardBottomNav(),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repo = Get.find<AuthRepository>();
    return FutureBuilder<UserModel?>(
      future: repo.currentUser(),
      builder: (context, snap) {
        final user = snap.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.name ?? "Admin"}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Berikut ringkasan stok apotek hari ini',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCard(
        label: 'Total Obat',
        value: summary.totalMedicines.toString(),
        icon: Icons.medication_outlined,
        color: AppColors.primary,
      ),
      _SummaryCard(
        label: 'Total Stok',
        value: summary.totalStock.toString(),
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
      ),
      _SummaryCard(
        label: 'Stok Rendah',
        value: summary.lowStockCount.toString(),
        icon: Icons.warning_amber_outlined,
        color: AppColors.stockLow,
        alert: summary.lowStockCount > 0,
      ),
      _SummaryCard(
        label: 'Expired',
        value: summary.expiredCount.toString(),
        icon: Icons.event_busy,
        color: AppColors.danger,
        alert: summary.expiredCount > 0,
      ),
      _SummaryCard(
        label: 'Segera Expired',
        value: summary.expiredSoonCount.toString(),
        icon: Icons.schedule,
        color: AppColors.expiredSoon,
        alert: summary.expiredSoonCount > 0,
      ),
      _SummaryCard(
        label: 'Nilai Stok',
        value: CurrencyFormatter.format(summary.totalValue),
        icon: Icons.payments_outlined,
        color: AppColors.success,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert ? color.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (alert)
                Icon(Icons.notifications_active, color: color, size: 18),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  const _AlertSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.emptyText,
    required this.count,
    required this.children,
    required this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String emptyText;
  final int count;
  final List<Widget> children;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: onSeeAll,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                emptyText,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...children
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: c,
                  ),
                ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RecentMovements extends StatelessWidget {
  const _RecentMovements({required this.items});

  final List<StockMovementModel> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.info, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mutasi Terbaru',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.stockMovements),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Belum ada mutasi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...items.take(5).map(
                  (m) => _MovementRow(movement: m),
                ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final StockMovementModel movement;

  @override
  Widget build(BuildContext context) {
    final isIn = movement.type == StockMovementType.stockIn;
    final color = isIn ? AppColors.success : AppColors.danger;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isIn ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        movement.medicineName ?? '-',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        movement.transactionDate == null
            ? '-'
            : DateFormatter.toDisplay(movement.transactionDate!),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '${isIn ? '+' : '-'}${movement.quantity}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DashboardBottomNav extends StatefulWidget {
  const _DashboardBottomNav();

  @override
  State<_DashboardBottomNav> createState() => _DashboardBottomNavState();
}

class _DashboardBottomNavState extends State<_DashboardBottomNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) {
        setState(() => _index = i);
        switch (i) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Get.toNamed(AppRoutes.medicines);
            break;
          case 2:
            Get.toNamed(AppRoutes.stockMovements);
            break;
          case 3:
            Get.toNamed(AppRoutes.alerts);
            break;
          case 4:
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.medication_outlined),
          selectedIcon: Icon(Icons.medication),
          label: 'Obat',
        ),
        NavigationDestination(
          icon: Icon(Icons.swap_vert_outlined),
          selectedIcon: Icon(Icons.swap_vert),
          label: 'Mutasi',
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Alert',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marker argument for routes that should open a list pre-filtered.
class _MedicineFilterArg {
  _MedicineFilterArg({this.lowStock = false});
  final bool lowStock;
}
