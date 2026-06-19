// Lightweight deterministic test-data helpers for property-based tests.
//
// We can't add a PBT dependency, so each helper exposes:
//   - a fixed seed (for reproducible failure logs)
//   - a [generate] function that returns the next pseudo-random value
//   - bounded [int] / [double] helpers
//
// The implementations are intentionally tiny (a linear congruential
// generator) — enough to spread inputs across the space without
// distributing the work to an extra package.
import 'dart:math' as math;

class SeededRng {
  SeededRng([int? seed]) : _state = seed ?? 0xC0FFEE;

  int _state;
  static const int _multiplier = 0x5DEECE66D;
  static const int _addend = 0xB;
  static const int _mask = (1 << 48) - 1;

  /// Returns the next pseudo-random non-negative integer.
  int nextInt() {
    _state = (_state * _multiplier + _addend) & _mask;
    return _state >> 17;
  }

  /// Returns an int in `[min, max]`.
  int nextBoundedInt(int min, int max) {
    assert(min <= max);
    final span = max - min + 1;
    return min + (nextInt() % span);
  }

  /// Returns a double in `[0.0, 1.0)`.
  double nextDouble() => nextInt() / 0x7FFFFFFF;

  /// Returns a double in `[min, max)`.
  double nextBoundedDouble(double min, double max) {
    assert(min <= max);
    return min + nextDouble() * (max - min);
  }

  /// Returns a random printable ASCII string of [length] characters drawn
  /// from letters + digits + punctuation.
  String nextString({int minLength = 0, int maxLength = 32}) {
    const pool =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_- .!?';
    final length = nextBoundedInt(minLength, maxLength);
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(pool[nextInt() % pool.length]);
    }
    return buffer.toString();
  }
}

/// Convenience entry point used by tests for default seeded runs.
SeededRng rng([int? seed]) => SeededRng(seed);

/// Quick non-empty ASCII random string of bounded length.
String randomString(SeededRng r, {int maxLength = 64}) =>
    r.nextString(minLength: 1, maxLength: maxLength);

/// Shorthand for `math.min` (kept for symmetry with the design doc).
int imin(int a, int b) => math.min(a, b);
int imax(int a, int b) => math.max(a, b);
double dmin(double a, double b) => math.min(a, b);
double dmax(double a, double b) => math.max(a, b);
