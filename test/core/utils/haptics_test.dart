import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/utils/haptics.dart';

import '../../support/gen.dart';

void main() {
  group('Haptics — Property 10: Platform guard', () {
    setUp(Haptics.resetForTest);
    tearDown(Haptics.resetForTest);

    test('on Android: lightSuccess triggers exactly one haptic call', () async {
      Haptics.platform = TargetPlatform.android;
      Haptics.lightImpactCalls = 0;
      await Haptics.lightSuccess();
      expect(Haptics.lightImpactCalls, 1);
    });

    test('on iOS: lightSuccess triggers zero haptic calls', () async {
      Haptics.platform = TargetPlatform.iOS;
      Haptics.lightImpactCalls = 0;
      await Haptics.lightSuccess();
      expect(Haptics.lightImpactCalls, 0);
    });

    test('on Linux: lightSuccess is a no-op (no error)', () async {
      Haptics.platform = TargetPlatform.linux;
      Haptics.lightImpactCalls = 0;
      await Haptics.lightSuccess();
      expect(Haptics.lightImpactCalls, 0);
    });

    test('on Windows: lightSuccess is a no-op (no error)', () async {
      Haptics.platform = TargetPlatform.windows;
      Haptics.lightImpactCalls = 0;
      await Haptics.lightSuccess();
      expect(Haptics.lightImpactCalls, 0);
    });

    test('on macOS: lightSuccess is a no-op (no error)', () async {
      Haptics.platform = TargetPlatform.macOS;
      Haptics.lightImpactCalls = 0;
      await Haptics.lightSuccess();
      expect(Haptics.lightImpactCalls, 0);
    });

    test('Property 10 — randomized platforms always match the contract', () {
      const iterations = 200;
      final r = rng(0xF1C0);
      final allPlatforms = <TargetPlatform>[
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.fuchsia,
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ];

      for (var i = 0; i < iterations; i++) {
        Haptics.platform =
            allPlatforms[r.nextBoundedInt(0, allPlatforms.length - 1)];
        Haptics.lightImpactCalls = 0;
        // No await — invocation itself is the contract.
        Haptics.lightSuccess();
        if (Haptics.platform == TargetPlatform.android) {
          expect(Haptics.lightImpactCalls, 1,
              reason: 'android should always trigger one pulse');
        } else {
          expect(Haptics.lightImpactCalls, 0,
              reason: '${Haptics.platform} should never trigger a pulse');
        }
      }
    });
  });
}
