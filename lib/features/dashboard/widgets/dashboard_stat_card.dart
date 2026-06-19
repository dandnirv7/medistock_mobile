import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';

/// Dashboard-specific thin wrapper around [StatCard] that keeps the
/// old call sites stable while routing all styling through tokens.
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.unit,
    this.onTap,
  });

  final String label;
  final int? value;
  final IconData icon;
  final Color accent;
  final String? unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      label: label,
      value: value,
      icon: icon,
      accent: accent,
      unit: unit,
      onTap: onTap,
    );
  }
}

/// Solid-tint background colors used by the dashboard for icon
/// containers. They stay within the existing brand palette.
Color dashboardAccentBg(Color accent) => tintedAccent(accent);

/// Returns a soft 12% tint of [accent] blended onto white. The
/// [primary] token has a curated matching color ([primaryLight]) so
/// it is preferred for brand consistency; every other accent falls
/// through to the blend.
Color tintedAccent(Color accent) {
  if (accent == AppColors.primary) return AppColors.primaryLight;
  return _blend(accent, 0.12);
}

Color _blend(Color fg, double alpha) {
  final r = ((fg.r * 255).round() * alpha + 255 * (1 - alpha)).round();
  final g = ((fg.g * 255).round() * alpha + 255 * (1 - alpha)).round();
  final b = ((fg.b * 255).round() * alpha + 255 * (1 - alpha)).round();
  return Color.fromARGB(255, r, g, b);
}
