import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart' show AppRadii;
import 'app_text_styles.dart';

/// Light-mode theme for MediStock (req 1.1, 1.2, 1.5, 3.5).
///
/// Dark mode is intentionally not supported (DEC-2 in the requirements).
class AppTheme {
  AppTheme._();

  /// Resolve the [TextStyle] for a given [AppTextStyles] role while
  /// applying the [Plus Jakarta Sans] font family, with a safe fallback
  /// when the font cannot be loaded.
  static TextStyle _roleStyle(TextStyle base) {
    try {
      return GoogleFonts.plusJakartaSans(textStyle: base);
    } catch (_) {
      return base;
    }
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    final textTheme = AppTextStyles.buildTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _roleStyle(
          AppTextStyles.cardTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.border(AppRadii.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.border(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.border(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.border(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.border(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.border(AppRadii.md),
          ),
          textStyle: _roleStyle(
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.border(AppRadii.md),
          ),
          textStyle: _roleStyle(
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _roleStyle(
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
      dividerColor: AppColors.border,
      chipTheme: const ChipThemeData(
        side: BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
