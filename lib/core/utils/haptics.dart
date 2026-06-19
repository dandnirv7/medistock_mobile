import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptic feedback helper (req 15.1–15.5).
///
/// On Android, `lightSuccess()` triggers exactly one `HapticFeedback.lightImpact`
/// pulse. On any other platform, every call is a no-op and never throws.
class Haptics {
  Haptics._();

  /// Test seam: tests can replace [_platform] to verify the platform guard.
  @visibleForTesting
  static TargetPlatform platform = defaultTargetPlatform;

  /// Test seam: tests can replace [_lightImpactCalls] to count invocations.
  @visibleForTesting
  static int lightImpactCalls = 0;

  /// Reset all test seams. Call between test cases.
  @visibleForTesting
  static void resetForTest() {
    platform = defaultTargetPlatform;
    lightImpactCalls = 0;
  }

  /// Trigger exactly one light haptic pulse on Android only.
  ///
  /// Safe to call from any platform — non-Android platforms are no-ops.
  static Future<void> lightSuccess() async {
    if (platform != TargetPlatform.android) {
      return;
    }
    lightImpactCalls += 1;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics must never propagate an error to the caller.
    }
  }
}
