import '../core/graft_mask.dart';

/// Web & WASM fallback implementation of [GraftSimd].
///
/// On Web and non-FFI platforms, transparently utilizes Graft's high-speed
/// 32-bit chunked pure Dart bitmask diffing engine with 0 behavioral divergence.
abstract final class GraftSimd {
  /// Always null on Web platforms.
  static Object? get dylib => null;

  /// Always false on Web platforms (uses pure Dart bitmask engine).
  static bool get isAvailable => false;

  /// Always -1 on Web platforms.
  static int get version => -1;

  /// No-op on Web platforms.
  static bool loadFrom(String dylibPath) => false;

  /// Compares two integer property buffers using pure Dart 32-bit chunked diffing (100% web-safe).
  ///
  /// Returns a [GraftMask] bitset where dirty indices are set to 1.
  static GraftMask diffInt64(List<int> oldProps, List<int> newProps) {
    final count =
        oldProps.length < newProps.length ? oldProps.length : newProps.length;
    if (count <= 0) return GraftMask.empty;

    final numWords = (count + 31) >> 5;
    final words = List<int>.filled(numWords, 0);
    bool hasDiff = false;

    for (int i = 0; i < count; i++) {
      if (oldProps[i] != newProps[i]) {
        words[i >> 5] |= (1 << (i & 31));
        hasDiff = true;
      }
    }

    if (!hasDiff) return GraftMask.empty;

    final w0 = words[0];
    final w1 = numWords > 1 ? words[1] : 0;
    final extra = numWords > 2 ? words.sublist(2) : null;
    return GraftMask.fromWords(w0, w1, extra);
  }
}
