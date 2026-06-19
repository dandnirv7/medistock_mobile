import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Shared error-state widget (req 10.1, 10.2, 10.4, 10.7).
///
/// Renders an error icon, the [message], and a retry button that
/// disables itself while a retry is in flight.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isRetrying = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              AppIcons.errorIcon,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.sectionHeader.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Coba lagi',
                icon: AppIcons.retry,
                onPressed: onRetry,
                isLoading: isRetrying,
                variant: AppButtonVariant.outline,
                expanded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
