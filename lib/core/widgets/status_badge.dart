import 'package:flutter/material.dart';

import '../../features/medicines/models/medicine_model.dart';
import '../theme/app_colors.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.medicine});

  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final color = medicine.isLowStock ? AppColors.stockLow : AppColors.stockSafe;
    final label = medicine.isLowStock ? 'Stok Rendah' : 'Stok Aman';
    return _Badge(label: label, color: color, icon: Icons.inventory_2_outlined);
  }
}

class ExpiredBadge extends StatelessWidget {
  const ExpiredBadge({super.key, required this.medicine});

  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    if (medicine.isExpired) {
      return const _Badge(
        label: 'Expired',
        color: AppColors.expired,
        icon: Icons.event_busy,
      );
    }
    if (medicine.isExpiredSoon) {
      return const _Badge(
        label: 'Segera Expired',
        color: AppColors.expiredSoon,
        icon: Icons.schedule,
      );
    }
    if (medicine.expiredDate == null) {
      return const _Badge(
        label: 'Tidak ada tanggal',
        color: AppColors.textSecondary,
        icon: Icons.help_outline,
      );
    }
    return const _Badge(
      label: 'Aman',
      color: AppColors.expiredSafe,
      icon: Icons.verified_outlined,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
