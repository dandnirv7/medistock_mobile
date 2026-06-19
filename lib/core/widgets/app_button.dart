import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Visual variants of [AppButton] (req 13.1).
enum AppButtonVariant { primary, secondary, outline, text }

/// Reusable button used across the app (req 13.1, 13.2, 13.4, 14.2).
///
/// * Minimum height of 48 dp to meet the WCAG touch-target size
///   (req 14.2).
/// * [isLoading] renders a [CircularProgressIndicator] in place of the
///   label and silently ignores additional taps until cleared
///   (req 13.4).
/// * Token-only colors and spacing; never hand-roll styles in views.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final content = isLoading
        ? _buildLoading()
        : Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: TextStyle(
                  color: _foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          );

    switch (variant) {
      case AppButtonVariant.primary:
        return _frame(
          background: AppColors.primary,
          foreground: _foreground,
          child: content,
          onPressed: effectiveOnPressed,
        );
      case AppButtonVariant.secondary:
        return _frame(
          background: AppColors.secondary,
          foreground: _foreground,
          child: content,
          onPressed: effectiveOnPressed,
        );
      case AppButtonVariant.outline:
        return _frame(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: Border.all(color: AppColors.primary),
          child: content,
          onPressed: effectiveOnPressed,
        );
      case AppButtonVariant.text:
        return SizedBox(
          height: 48,
          child: TextButton(
            onPressed: effectiveOnPressed,
            child: content,
          ),
        );
    }
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_foreground),
      ),
    );
  }

  Widget _frame({
    required Color background,
    required Color foreground,
    required Widget child,
    required VoidCallback? onPressed,
    Border? border,
  }) {
    final btn = Material(
      color: background,
      borderRadius: AppRadii.border(AppRadii.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.border(AppRadii.md),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadii.border(AppRadii.md),
            border: border,
          ),
          child: child,
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  Color get _foreground =>
      variant == AppButtonVariant.outline || variant == AppButtonVariant.text
          ? AppColors.primary
          : Colors.white;
}
