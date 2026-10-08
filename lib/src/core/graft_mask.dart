import 'package:flutter/foundation.dart';

/// An unconstrained, high-performance bitset for fine-grained slot and state diffing.
///
/// ### Architecture:
/// - **Zero-Allocation Fast Path:** Inlines words 0 and 1 (`_w0` and `_w1`) to handle
///   states with up to 64 fields directly in CPU registers without allocating heap lists.
/// - **Unbounded Dynamic Words:** Dynamically allocates `_extraWords` for large state models
///   with 100, 500, or 1000+ fields.
/// - **Cross-Platform Safe:** Uses 32-bit chunking (`index >> 5` and `1 << (index & 31)`)
///   so bitwise operations are 100% mathematically identical on 64-bit Dart VM and 32-bit Dart Web (JS).
@immutable
class GraftMask {
  final bool _allDirty;
  final int _w0;
  final int _w1;
  final List<int>? _extraWords;

  /// Pre-allocated flyweight cache for all 64 single-bit masks across word 0 and word 1.
  /// Eliminates 100% of heap allocations for single-property mutations.
  static final List<GraftMask> _singleBitCache = List<GraftMask>.generate(
    64,
    (i) => i < 32
        ? GraftMask._(w0: 1 << i)
        : GraftMask._(w1: 1 << (i - 32)),
    growable: false,
  );

  /// Sentinel constant representing an all-dirty state mask (e.g. initial build, full reset).
  static const GraftMask allDirty = GraftMask._(allDirty: true);

  /// Empty bitmask representing zero modified fields.
  static const GraftMask empty = GraftMask._();

  const GraftMask._({
    bool allDirty = false,
    int w0 = 0,
    int w1 = 0,
    List<int>? extraWords,
  })  : _allDirty = allDirty,
        _w0 = w0,
        _w1 = w1,
        _extraWords = extraWords;

  /// Creates a mask with a single bit set at [index].
  factory GraftMask.fromIndex(int index) {
    if (index < 0) return empty;
    if (index < 64) return _singleBitCache[index];
    final word = index >> 5;
    final bit = 1 << (index & 31);

    final extra = List<int>.filled(word - 1, 0);
    extra[word - 2] = bit;
    return GraftMask._(extraWords: extra);
  }

  /// Creates a [GraftMask] directly from raw CPU word registers with zero intermediate allocations.
  @internal
  factory GraftMask.fromWords(int w0, int w1, [List<int>? extraWords]) {
    if (w0 == 0 && w1 == 0 && (extraWords == null || _isAllZero(extraWords))) {
      return empty;
    }
    // Fast-path single bit in word 0
    if (w1 == 0 && (extraWords == null || extraWords.isEmpty) && (w0 & (w0 - 1)) == 0) {
      final idx = (w0 & 0xFFFFFFFF).bitLength - 1;
      if (idx >= 0 && idx < 32) return _singleBitCache[idx];
    }
    // Fast-path single bit in word 1
    if (w0 == 0 && (extraWords == null || extraWords.isEmpty) && (w1 & (w1 - 1)) == 0) {
      final idx = (w1 & 0xFFFFFFFF).bitLength - 1;
      if (idx >= 0 && idx < 32) return _singleBitCache[idx + 32];
    }
    return GraftMask._(w0: w0, w1: w1, extraWords: extraWords);
  }

  static bool _isAllZero(List<int> words) {
    for (int i = 0; i < words.length; i++) {
      if (words[i] != 0) return false;
    }
    return true;
  }

  /// Whether this mask represents an all-dirty state.
  bool get isAllDirty => _allDirty;

  /// Whether no bits are set in this mask.
  bool get isEmpty {
    if (_allDirty) return false;
    if (_w0 != 0 || _w1 != 0) return false;
    final extra = _extraWords;
    if (extra != null) {
      for (int i = 0; i < extra.length; i++) {
        if (extra[i] != 0) return false;
      }
    }
    return true;
  }

  /// Whether at least one bit is set in this mask.
  bool get isNotEmpty => !isEmpty;

  /// Checks if the bit at [index] is set.
  bool isBitSet(int index) {
    if (_allDirty) return true;
    if (index < 0) return false;
    final word = index >> 5;
    final bit = 1 << (index & 31);

    if (word == 0) return (_w0 & bit) != 0;
    if (word == 1) return (_w1 & bit) != 0;

    final extraIdx = word - 2;
    final extra = _extraWords;
    if (extra == null || extraIdx >= extra.length) return false;
    return (extra[extraIdx] & bit) != 0;
  }

  /// Returns a new [GraftMask] with the bit at [index] set to 1.
  GraftMask withBit(int index) {
    if (_allDirty || index < 0) return this;
    if (isEmpty && index < 64) return _singleBitCache[index];
    final word = index >> 5;
    final bit = 1 << (index & 31);

    if (word == 0) {
      return GraftMask._(
        w0: _w0 | bit,
        w1: _w1,
        extraWords: _extraWords,
      );
    }
    if (word == 1) {
      return GraftMask._(
        w0: _w0,
        w1: _w1 | bit,
        extraWords: _extraWords,
      );
    }

    final extraIdx = word - 2;
    final currentExtra = _extraWords;
    final currentLen = currentExtra?.length ?? 0;
    final newLen = extraIdx >= currentLen ? extraIdx + 1 : currentLen;
    final nextExtra = List<int>.filled(newLen, 0);
    if (currentExtra != null) {
      for (int i = 0; i < currentExtra.length; i++) {
        nextExtra[i] = currentExtra[i];
      }
    }
    nextExtra[extraIdx] |= bit;
    return GraftMask._(w0: _w0, w1: _w1, extraWords: nextExtra);
  }

  /// Fast evaluation of whether this mask and [other] have any overlapping dirty bits.
  @pragma('vm:prefer-inline')
  bool intersects(GraftMask other) {
    if (_allDirty || other._allDirty) return true;

    // Word 0 check (1 CPU instruction)
    if ((_w0 & other._w0) != 0) return true;

    // Word 1 check
    if ((_w1 & other._w1) != 0) return true;

    // Extra words check if either mask has fields beyond bit 63
    final aExtra = _extraWords;
    final bExtra = other._extraWords;
    if (aExtra != null && bExtra != null) {
      final minLen = aExtra.length < bExtra.length ? aExtra.length : bExtra.length;
      for (int i = 0; i < minLen; i++) {
        if ((aExtra[i] & bExtra[i]) != 0) return true;
      }
    }
    return false;
  }

  /// Whether this mask is a subset of [other] (all bits in this mask are also set in [other]).
  @pragma('vm:prefer-inline')
  bool isSubsetOf(GraftMask other) {
    if (other._allDirty) return true;
    if (_allDirty) return false;
    if ((_w0 & ~other._w0) != 0) return false;
    if ((_w1 & ~other._w1) != 0) return false;
    final aExtra = _extraWords;
    final bExtra = other._extraWords;
    if (aExtra != null) {
      final bLen = bExtra?.length ?? 0;
      for (int i = 0; i < aExtra.length; i++) {
        final bVal = (i < bLen) ? bExtra![i] : 0;
        if ((aExtra[i] & ~bVal) != 0) return false;
      }
    }
    return true;
  }

  /// Computes the bitwise union (`this | other`).
  GraftMask union(GraftMask other) {
    if (_allDirty || other._allDirty) return allDirty;
    if (isEmpty) return other;
    if (other.isEmpty) return this;

    final nextW0 = _w0 | other._w0;
    final nextW1 = _w1 | other._w1;

    final aExtra = _extraWords;
    final bExtra = other._extraWords;
    if (aExtra == null && bExtra == null) {
      return GraftMask._(w0: nextW0, w1: nextW1);
    }

    final aLen = aExtra?.length ?? 0;
    final bLen = bExtra?.length ?? 0;
    final maxLen = aLen > bLen ? aLen : bLen;
    final nextExtra = List<int>.filled(maxLen, 0);

    for (int i = 0; i < maxLen; i++) {
      final aVal = (aExtra != null && i < aLen) ? aExtra[i] : 0;
      final bVal = (bExtra != null && i < bLen) ? bExtra[i] : 0;
      nextExtra[i] = aVal | bVal;
    }

    return GraftMask._(w0: nextW0, w1: nextW1, extraWords: nextExtra);
  }

  /// Returns the field index if exactly one bit is set in this mask, or `null` otherwise.
  /// Useful for adaptive single-field dependency learning.
  int? get singleBitIndex {
    if (_allDirty || isEmpty) return null;

    int setBitsCount = 0;
    int foundIndex = -1;

    void checkWord(int wordVal, int wordOffset) {
      int val = wordVal;
      while (val != 0) {
        if ((val & 1) != 0) {
          setBitsCount++;
          if (setBitsCount > 1) return;
        }
        val >>>= 1;
      }
      if (setBitsCount == 1 && foundIndex == -1) {
        for (int b = 0; b < 32; b++) {
          if ((wordVal & (1 << b)) != 0) {
            foundIndex = (wordOffset << 5) + b;
            break;
          }
        }
      }
    }

    if (_w0 != 0) checkWord(_w0, 0);
    if (setBitsCount > 1) return null;

    if (_w1 != 0) checkWord(_w1, 1);
    if (setBitsCount > 1) return null;

    final extra = _extraWords;
    if (extra != null) {
      for (int i = 0; i < extra.length; i++) {
        if (extra[i] != 0) {
          checkWord(extra[i], i + 2);
          if (setBitsCount > 1) return null;
        }
      }
    }

    return setBitsCount == 1 ? foundIndex : null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GraftMask) return false;
    if (_allDirty != other._allDirty) return false;
    if (_allDirty) return true;
    if (_w0 != other._w0 || _w1 != other._w1) return false;

    final aExtra = _extraWords;
    final bExtra = other._extraWords;
    final aLen = aExtra?.length ?? 0;
    final bLen = bExtra?.length ?? 0;
    final maxLen = aLen > bLen ? aLen : bLen;

    for (int i = 0; i < maxLen; i++) {
      final aVal = (aExtra != null && i < aLen) ? aExtra[i] : 0;
      final bVal = (bExtra != null && i < bLen) ? bExtra[i] : 0;
      if (aVal != bVal) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(_allDirty, _w0, _w1, _extraWords?.length ?? 0);

  @override
  String toString() {
    if (_allDirty) return 'GraftMask(allDirty)';
    if (isEmpty) return 'GraftMask(empty)';
    final buffer = StringBuffer('GraftMask(');
    buffer.write('0x${_w0.toRadixString(16)}');
    final extra = _extraWords;
    if (_w1 != 0 || (extra != null && extra.any((w) => w != 0))) {
      buffer.write(', 0x${_w1.toRadixString(16)}');
    }
    if (extra != null) {
      for (final w in extra) {
        if (w != 0) buffer.write(', 0x${w.toRadixString(16)}');
      }
    }
    buffer.write(')');
    return buffer.toString();
  }
}
