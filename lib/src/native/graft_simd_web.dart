import 'dart:typed_data';
import '../core/graft_mask.dart';

/// Web & WASM fallback implementation of [GraftSimd].
///
/// On Web and non-FFI platforms, transparently utilizes Graft's high-speed
/// 64-bit pure Dart bitmask diffing engine with 0 behavioral divergence.
abstract final class GraftSimd {
  /// Always null on Web platforms.
  static Object? get dylib => null;

  /// Always false on Web platforms (uses pure Dart 64-bit engine).
  static bool get isAvailable => false;

  /// Always -1 on Web platforms.
  static int get version => -1;

  /// No-op on Web platforms.
  static bool loadFrom(String dylibPath) => false;

  /// Compares two 64-bit integer property buffers using pure Dart 64-bit word diffing.
  ///
  /// Returns a [GraftMask] bitset where dirty indices are set to 1.
  static GraftMask diffInt64(Int64List oldProps, Int64List newProps) {
    final count = oldProps.length < newProps.length ? oldProps.length : newProps.length;
    if (count <= 0) return GraftMask.empty;

    final numWords = (count + 63) >> 6;
    final words = List<int>.filled(numWords, 0);
    bool hasDiff = false;

    for (int i = 0; i < count; i++) {
      if (oldProps[i] != newProps[i]) {
        words[i >> 6] |= (1 << (i & 63));
        hasDiff = true;
      }
    }

    if (!hasDiff) return GraftMask.empty;

    final w0 = words[0] & 0xFFFFFFFF;
    final w1 = (words[0] >> 32) & 0xFFFFFFFF;
    List<int>? extra;
    if (words.length > 1) {
      extra = <int>[];
      for (int i = 1; i < words.length; i++) {
        extra.add(words[i] & 0xFFFFFFFF);
        extra.add((words[i] >> 32) & 0xFFFFFFFF);
      }
    }
    return GraftMask.fromWords(w0, w1, extra);
  }
}
