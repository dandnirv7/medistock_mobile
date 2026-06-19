import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Centralized snackbar notifier (req 12.1–12.6).
///
/// Guarantees:
/// * Single visible snackbar at a time (Property 3).
/// * Message length is clamped to `[1, 200]` characters (Property 4).
/// * Default fallback message is used when the input is null/empty.
/// * 3 second auto-dismiss (req 12.3).
/// * Background/foreground colors derive from the palette
///   (req 12.1, 12.2) and stay consistent across the app.
class SnackbarHelper {
  SnackbarHelper._();

  static const String _defaultSuccessMessage = 'Berhasil';
  static const String _defaultErrorMessage = 'Terjadi kesalahan. Coba lagi.';
  static const String _defaultInfoMessage = 'Informasi';
  static const int _maxMessageLength = 200;

  // Holds the most recent visible snackbar so we can dismiss it before
  // showing a new one (Property 3).
  static String? _lastTitle;
  static String? _lastMessage;

  /// Show a success snackbar.
  static void success(String? message) =>
      _show(SnackbarTone.success, message, _defaultSuccessMessage);

  /// Show an error snackbar.
  static void error(String? message) =>
      _show(SnackbarTone.error, message, _defaultErrorMessage);

  /// Show an informational snackbar (neutral tone).
  static void info(String? message) =>
      _show(SnackbarTone.info, message, _defaultInfoMessage);

  /// Build the message that would be shown for [message] without
  /// actually presenting a snackbar. Exposed for tests / Property 4.
  ///
  /// Prefer the named-parameter form (). The legacy boolean
  /// overload is kept for compatibility with older tests.
  static String resolveMessage(String? message, {SnackbarTone? tone, bool? isError}) {
    final SnackbarTone effectiveTone;
    if (tone != null) {
      effectiveTone = tone;
    } else if (isError == true) {
      effectiveTone = SnackbarTone.error;
    } else {
      effectiveTone = SnackbarTone.success;
    }
    final String fallback;
    switch (effectiveTone) {
      case SnackbarTone.success:
        fallback = _defaultSuccessMessage;
        break;
      case SnackbarTone.error:
        fallback = _defaultErrorMessage;
        break;
      case SnackbarTone.info:
        fallback = _defaultInfoMessage;
        break;
    }
    final raw = (message == null || message.trim().isEmpty) ? fallback : message;
    return _clamp(raw);
  }

  /// Visible snackbar debug info, used by the widget test for Property 3.
  static String? get debugLastTitle => _lastTitle;
  static String? get debugLastMessage => _lastMessage;

  static String _clamp(String value) {
    if (value.length <= _maxMessageLength) return value;
    return value.substring(0, _maxMessageLength);
  }

  static void _show(SnackbarTone tone, String? message, String fallback) {
    final resolved = resolveMessage(message, tone: tone);
    final (bg, fg) = _paletteFor(tone);

    // Single-visible invariant: dismiss any open snackbar first.
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    _lastTitle = tone == SnackbarTone.error ? 'Error' : tone == SnackbarTone.info ? 'Info' : 'Sukses';
    _lastMessage = resolved;
    Get.snackbar(
      _lastTitle!,
      resolved,
      backgroundColor: bg,
      colorText: fg,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      shouldIconPulse: false,
      icon: Icon(
        tone == SnackbarTone.error
            ? AppIcons.error_outline
            : tone == SnackbarTone.info
                ? AppIcons.info_outline
                : AppIcons.check_circle_outline,
        color: fg,
      ),
    );
  }

  static (Color, Color) _paletteFor(SnackbarTone tone) {
    switch (tone) {
      case SnackbarTone.success:
        return (AppColors.success, Colors.white);
      case SnackbarTone.error:
        return (AppColors.danger, Colors.white);
      case SnackbarTone.info:
        return (AppColors.info, Colors.white);
    }
  }
}

enum SnackbarTone { success, error, info }
