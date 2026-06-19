import 'package:flutter/widgets.dart';

/// Spacing scale (req 3.3, 3.4, 5.1, 5.2, 5.4).
///
/// The whole app must use these constants; no other spacing values are
/// permitted in polished widgets (Property 2).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// The closed set of allowed spacing values (Property 2).
  ///
  /// Implemented as a const list + lookup rather than a `Set<double>`
  /// because `double` is not hashable in a const context.
  static const List<double> _allowed = <double>[xs, sm, md, lg, xl];

  /// Returns `true` if [value] is a member of the spacing scale.
  static bool contains(double value) {
    for (final v in _allowed) {
      if (v == value) return true;
    }
    return false;
  }

  /// The allowed spacing values.
  static List<double> get allowed => List<double>.unmodifiable(_allowed);
}

/// Border-radius tokens (req 3.5).
class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double pill = 999;

  /// Resolve a numeric radius into a [Radius], defaulting to [md].
  static Radius radius([double? value]) =>
      Radius.circular(value ?? md);

  /// Resolve a numeric radius into a [BorderRadius], defaulting to [md].
  static BorderRadius border([double? value]) =>
      BorderRadius.circular(value ?? md);
}
