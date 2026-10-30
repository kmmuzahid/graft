import 'package:flutter/foundation.dart';

part 'mask_ops.dart';
part 'mask_inspection.dart';

/// An unconstrained, high-performance bitset for fine-grained slot and state diffing.
@immutable
class GraftMask {
  final bool _allDirty;
  final int _w0;
  final int _w1;
  final List<int>? _extraWords;

  static final List<GraftMask> _singleBitCache = List<GraftMask>.generate(
    64,
    (i) => i < 32 ? GraftMask._(w0: 1 << i) : GraftMask._(w1: 1 << (i - 32)),
    growable: false,
  );

  static final List<GraftMask> _allBitsUpToCache = List<GraftMask>.generate(
    33,
    (n) => n == 0
        ? const GraftMask._()
        : (n == 32
            ? const GraftMask._(w0: 0xFFFFFFFF)
            : GraftMask._(w0: (1 << n) - 1)),
    growable: false,
  );

  @pragma('vm:prefer-inline')
  static GraftMask allBitsUpTo(int count) {
    if (count >= 0 && count <= 32) return _allBitsUpToCache[count];
    return allDirty;
  }

  static final GraftMask bit0 = _singleBitCache[0];
  static final GraftMask bit1 = _singleBitCache[1];
  static const GraftMask allDirty = GraftMask._(allDirty: true);
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

  @pragma('vm:prefer-inline')
  static GraftMask bit(int index) {
    if (index >= 0 && index < 64) return _singleBitCache[index];
    return GraftMask.fromIndex(index);
  }

  @pragma('vm:prefer-inline')
  bool matchesWords(int w0, int w1, [List<int>? extra]) {
    if (_allDirty) return false;
    if (_w0 != w0 || _w1 != w1) return false;
    if (_extraWords == null && extra == null) return true;
    if (_extraWords == null || extra == null) return false;
    if (_extraWords!.length != extra.length) return false;
    for (int i = 0; i < extra.length; i++) {
      if (_extraWords![i] != extra[i]) return false;
    }
    return true;
  }

  factory GraftMask.fromIndex(int index) {
    if (index < 0) return empty;
    if (index < 64) return _singleBitCache[index];
    final word = index >> 5;
    final bit = 1 << (index & 31);
    final extra = List<int>.filled(word - 1, 0);
    extra[word - 2] = bit;
    return GraftMask._(extraWords: extra);
  }

  @internal
  factory GraftMask.fromWords(int w0, int w1, [List<int>? extraWords]) {
    if (w0 == 0 && w1 == 0 && (extraWords == null || _isAllZero(extraWords))) {
      return empty;
    }
    if (w1 == 0 && (extraWords == null || extraWords.isEmpty)) {
      if ((w0 & (w0 - 1)) == 0) {
        final idx = (w0 & 0xFFFFFFFF).bitLength - 1;
        if (idx >= 0 && idx < 32) return _singleBitCache[idx];
      }
      if (((w0 + 1) & w0) == 0) {
        final count = (w0 & 0xFFFFFFFF).bitLength;
        if (count >= 0 && count <= 32) return _allBitsUpToCache[count];
      }
    }
    if (w0 == 0 &&
        (extraWords == null || extraWords.isEmpty) &&
        (w1 & (w1 - 1)) == 0) {
      final idx = (w1 & 0xFFFFFFFF).bitLength - 1;
      if (idx >= 0 && idx < 32) return _singleBitCache[idx + 32];
    }
    return GraftMask._(w0: w0, w1: w1, extraWords: extraWords);
  }

  bool get isAllDirty => _allDirty;

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

  bool get isNotEmpty => !isEmpty;

  @pragma('vm:prefer-inline')
  bool isBitSet(int index) => _maskIsBitSet(this, index);

  @pragma('vm:prefer-inline')
  GraftMask withBit(int index) => _maskWithBit(this, index);

  @pragma('vm:prefer-inline')
  bool intersects(GraftMask other) => _maskIntersects(this, other);

  @pragma('vm:prefer-inline')
  bool isSubsetOf(GraftMask other) => _maskIsSubsetOf(this, other);

  @pragma('vm:prefer-inline')
  GraftMask union(GraftMask other) => _maskUnion(this, other);

  @pragma('vm:prefer-inline')
  int? get singleBitIndex => _maskSingleBitIndex(this);

  @override
  bool operator ==(Object other) => _maskEquals(this, other);

  @override
  int get hashCode => _maskHashCode(this);

  @override
  String toString() => _maskToString(this);
}
