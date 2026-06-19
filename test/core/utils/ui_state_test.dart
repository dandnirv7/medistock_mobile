import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/utils/ui_state.dart';

import '../../support/gen.dart';

class _Item {
  _Item(this.id);
  final int id;
  @override
  bool operator ==(Object other) => other is _Item && other.id == id;
  @override
  int get hashCode => id;
}

class _Holder extends GetxController with AsyncListState<_Item> {
  List<_Item>? initial;
  List<_Item>? refreshed;
  bool throwOnRefresh = false;
  Duration refreshLatency = Duration.zero;

  @override
  Future<void> load() async {
    await runLoad(() async => initial ?? <_Item>[]);
  }

  @override
  Future<void> refresh() async {
    await runRefresh(() async {
      if (refreshLatency > Duration.zero) {
        await Future<void>.delayed(refreshLatency);
      }
      if (throwOnRefresh) {
        throw StateError('refresh-failed');
      }
      return refreshed ?? <_Item>[];
    });
  }
}

class _ShortTimeoutHolder extends GetxController with AsyncListState<_Item> {
  List<_Item>? initial;
  List<_Item>? refreshed;
  bool throwOnRefresh = false;
  Duration refreshLatency = Duration.zero;

  @override
  Duration get refreshTimeout => const Duration(milliseconds: 50);

  @override
  Future<void> load() async {
    await runLoad(() async => initial ?? <_Item>[]);
  }

  @override
  Future<void> refresh() async {
    await runRefresh(() async {
      if (refreshLatency > Duration.zero) {
        await Future<void>.delayed(refreshLatency);
      }
      if (throwOnRefresh) {
        throw StateError('refresh-failed');
      }
      return refreshed ?? <_Item>[];
    });
  }
}

void main() {
  group('AsyncListState — Property 8: Refresh data retention', () {
    test('failed refresh keeps the prior items', () async {
      final h = _Holder();
      h.initial = <_Item>[_Item(1), _Item(2), _Item(3)];
      await h.load();
      expect(h.items.map((e) => e.id), [1, 2, 3]);

      // Now make refresh fail.
      h.throwOnRefresh = true;
      final before = List<_Item>.of(h.items);
      await h.refresh();
      // Items should be unchanged after a failed refresh.
      expect(h.items, equals(before));
    });

    test('timed-out refresh keeps the prior items', () async {
      final h = _ShortTimeoutHolder();
      h.initial = <_Item>[_Item(10), _Item(20)];
      h.refreshed = <_Item>[_Item(99)];
      await h.load();
      final before = List<_Item>.of(h.items);
      h.refreshLatency = const Duration(milliseconds: 200);
      await h.refresh();
      // Timed out — items remain the original list.
      expect(h.items, equals(before));
      // isRefreshing is reset
      expect(h.isRefreshing.value, isFalse);
    });

    test('successful refresh replaces items', () async {
      final h = _Holder();
      h.initial = <_Item>[_Item(1)];
      h.refreshed = <_Item>[_Item(2), _Item(3)];
      await h.load();
      expect(h.items.map((e) => e.id), [1]);
      h.refreshed = <_Item>[_Item(2), _Item(3)];
      await h.refresh();
      expect(h.items.map((e) => e.id), [2, 3]);
    });

    test('isRefreshing guard rejects concurrent calls', () async {
      final h = _Holder();
      h.initial = <_Item>[_Item(1)];
      await h.load();
      h.refreshLatency = const Duration(milliseconds: 30);
      h.refreshed = <_Item>[_Item(2)];
      // Fire two refreshes back-to-back. The first one increments the
      // counter; the second should be a no-op.
      final f1 = h.refresh();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final f2 = h.refresh();
      await Future.wait([f1, f2]);
      // Exactly one round of updates was applied.
      expect(h.items.map((e) => e.id), [2]);
      expect(h.isRefreshing.value, isFalse);
    });

    test('Property 8 — randomized failed/timed-out refreshes retain items',
        () async {
      const iterations = 50;
      final r = rng(0xA17B);

      for (var i = 0; i < iterations; i++) {
        final n = r.nextBoundedInt(0, 5);
        final initial = <_Item>[
          for (var j = 0; j < n; j++) _Item(j),
        ];
        // Use a holder with a short timeout to keep the test fast.
        final h = _ShortTimeoutHolder();
        h.initial = initial;
        await h.load();
        final before = List<_Item>.of(h.items);
        // Half the time, throw; the other half, time out.
        if (r.nextBoundedInt(0, 1) == 0) {
          h.throwOnRefresh = true;
        } else {
          h.refreshLatency = const Duration(milliseconds: 500);
        }
        await h.refresh();
        // Items must be identical pre/post.
        expect(h.items, equals(before),
            reason: 'iteration $i: items changed on failed/timeout refresh');
      }
    });
  });
}
