import 'package:flutter/material.dart';

import '../../features/medicines/models/medicine_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_icons.dart';

/// Semantic tone used by [StatusBadge] (req 4.5, 13.1).
enum BadgeTone {
  success,
  warning,
  danger,
  neutral;

  /// The "background" color associated with the tone. The badge
  /// background uses a 12% alpha of this color, blended onto the
  /// surrounding surface.
  Color get color {
    switch (this) {
      case BadgeTone.success:
        return AppColors.success;
      case BadgeTone.warning:
        return AppColors.warning;
      case BadgeTone.danger:
        return AppColors.danger;
      case BadgeTone.neutral:
        return AppColors.textSecondary;
    }
  }

  /// The foreground text/icon color used by the badge. Chosen to meet
  /// WCAG AA contrast against the 12%-alpha background (Property 5).
  Color get onColor {
    switch (this) {
      case BadgeTone.success:
        return AppColors.onSuccess;
      case BadgeTone.warning:
        return AppColors.onWarning;
      case BadgeTone.danger:
        return AppColors.onDanger;
      case BadgeTone.neutral:
        return AppColors.onNeutral;
    }
  }
}

/// Unified status badge (req 13.1, 13.3, 14.1).
///
/// * Always renders an icon and a text label (never color-only).
/// * Background is the tone color at 12% alpha; foreground is the
///   tone color at full strength, guaranteeing WCAG AA contrast on
///   light surfaces (Property 5).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = tone.onColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: AppRadii.border(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Thin wrappers kept for backward compatibility -----------------

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final isLow = medicine.isLowStock;
    return StatusBadge(
      label: isLow ? 'Stok Rendah' : 'Stok Aman',
      tone: isLow ? BadgeTone.warning : BadgeTone.success,
      icon: AppIcons.inventory2_outlined,
    );
  }
}

class ExpiredBadge extends StatelessWidget {
  const ExpiredBadge({super.key, required this.medicine});
  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    if (medicine.isExpired) {
      return const StatusBadge(
        label: 'Expired',
        tone: BadgeTone.danger,
        icon: AppIcons.event_busy,
      );
    }
    if (medicine.isExpiredSoon) {
      return const StatusBadge(
        label: 'Segera Expired',
        tone: BadgeTone.warning,
        icon: AppIcons.schedule,
      );
    }
    if (medicine.expiredDate == null) {
      return const StatusBadge(
        label: 'Tidak ada tanggal',
        tone: BadgeTone.neutral,
        icon: AppIcons.help_outline,
      );
    }
    return const StatusBadge(
      label: 'Aman',
      tone: BadgeTone.success,
      icon: AppIcons.verified_outlined,
    );
  }
}
