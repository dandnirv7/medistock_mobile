import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Semantic color tokens for the MediStock app.
///
/// Stock/expiry status colors are aliases of the semantic
/// `success`/`warning`/`danger` tokens so they stay in lockstep.
class AppColors {
  AppColors._();

  // -- Brand --
  static const Color primary = Color(0xFF2E7D6B); // teal-green apotek
  static const Color primaryDark = Color(0xFF1F5C4F);
  static const Color primaryLight = Color(0xFFE3F2EE);

  static const Color secondary = Color(0xFFFF8A3D); // accent orange
  static const Color secondaryLight = Color(0xFFFFE7D4);

  // -- Surface / text --
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1B1F23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // -- Semantic status (source of truth) --
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color violet = Color(0xFF7C3AED); // supplier accent (mockup)

  // -- Stock status aliases (req 2.4, 3.2) --
  static const Color stockSafe = success; // safe stock
  static const Color stockLow = warning; // low stock
  static const Color stockOut = danger; // out of stock

  // -- Expiry status aliases (req 2.4, 3.2) --
  static const Color expiredSafe = success;
  static const Color expiredSoon = warning;
  static const Color expired = danger;

  /// Neutral fallback for unresolved color tokens.
  static const Color neutralFallback = textSecondary;

  // -- Badge text (700-800 weight) — meet WCAG AA on 12% alpha of the
  //    tone color blended onto the app surface.
  static const Color onSuccess = Color(0xFF166534);
  static const Color onWarning = Color(0xFF92400E);
  static const Color onDanger = Color(0xFF991B1B);
  static const Color onInfo = Color(0xFF1E40AF);
  static const Color onNeutral = Color(0xFF374151);

  // -- Lookup table for [resolve] --
  static const Map<String, Color> _palette = <String, Color>{
    'primary': primary,
    'primaryDark': primaryDark,
    'primaryLight': primaryLight,
    'secondary': secondary,
    'secondaryLight': secondaryLight,
    'background': background,
    'surface': surface,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
    'border': border,
    'success': success,
    'warning': warning,
    'danger': danger,
    'info': info,
    'stockSafe': stockSafe,
    'stockLow': stockLow,
    'stockOut': stockOut,
    'expiredSafe': expiredSafe,
    'expiredSoon': expiredSoon,
    'expired': expired,
  };

  /// Resolve a color token by name. Returns [neutralFallback] for
  /// null/unknown keys and never throws.
  static Color resolve(String? key) {
    if (key == null || key.isEmpty) {
      _logFallback(key);
      return neutralFallback;
    }
    final color = _palette[key];
    if (color == null) {
      _logFallback(key);
      return neutralFallback;
    }
    return color;
  }

  /// All known palette keys. Useful for tests/asserts.
  static Iterable<String> get knownKeys => _palette.keys;

  static void _logFallback(String? key) {
    if (kDebugMode) {
      debugPrint('[AppColors] missing token "$key" — using neutralFallback');
    }
  }
}
