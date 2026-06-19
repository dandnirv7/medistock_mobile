import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Shared empty-state widget (req 9.1, 9.2, 9.3, 13.5).
///
/// Renders exactly an icon + message + an optional primary action.
/// All colors and spacing come from the design tokens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? AppIcons.empty, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: primaryActionLabel!,
                onPressed: onPrimaryAction!,
                icon: AppIcons.add,
                expanded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
