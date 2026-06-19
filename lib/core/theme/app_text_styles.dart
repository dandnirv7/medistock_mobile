import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Named typographic roles for the MediStock app (req 1.1, 1.3, 1.4).
///
/// All screens must consume one of these roles via [AppTextStyles.of]
/// or [AppTextStyles.textTheme] — never hand-roll a [TextStyle] in a view.
class AppTextStyles {
  AppTextStyles._();

  /// Family used across every role. Set once here.
  static const String _family = 'Plus Jakarta Sans';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.1,
  );

  /// Numeric metric (e.g. dashboard stat number).
  /// `fontFeatures: [tabular]` keeps digits monospaced for animated counters.
  static const TextStyle numericMetric = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// All known roles. Default for unknown names is [body].
  static const Map<String, TextStyle> _roles = <String, TextStyle>{
    'screenTitle': screenTitle,
    'sectionHeader': sectionHeader,
    'cardTitle': cardTitle,
    'body': body,
    'caption': caption,
    'numericMetric': numericMetric,
  };

  /// Resolve a role by name. Falls back to [body] for unknown input.
  static TextStyle of(String? role) => _roles[role] ?? body;

  /// Build the [TextTheme] from the resolved font family, applied
  /// against the app's text color.
  ///
  /// `google_fonts` may fail to load over the network in offline mode.
  /// We fall back to the platform default sans-serif instead of throwing,
  /// so the app always launches.
  static TextTheme buildTextTheme(TextTheme base) {
    try {
      return GoogleFonts.plusJakartaSansTextTheme(base).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
    } catch (_) {
      return base.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
    }
  }

  /// All known role names.
  static Iterable<String> get roles => _roles.keys;
}
