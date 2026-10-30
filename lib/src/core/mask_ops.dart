part of 'graft_mask.dart';

@pragma('vm:prefer-inline')
bool _maskIsBitSet(GraftMask mask, int index) {
  if (mask._allDirty) return true;
  if (index < 0) return false;
  final word = index >> 5;
  final bit = 1 << (index & 31);

  if (word == 0) return (mask._w0 & bit) != 0;
  if (word == 1) return (mask._w1 & bit) != 0;

  final extraIdx = word - 2;
  final extra = mask._extraWords;
  if (extra == null || extraIdx >= extra.length) return false;
  return (extra[extraIdx] & bit) != 0;
}

@pragma('vm:prefer-inline')
GraftMask _maskWithBit(GraftMask mask, int index) {
  if (mask._allDirty || index < 0) return mask;
  if (mask.isEmpty && index < 64) return GraftMask._singleBitCache[index];
  final word = index >> 5;
  final bit = 1 << (index & 31);

  if (word == 0) {
    return GraftMask._(
      w0: mask._w0 | bit,
      w1: mask._w1,
      extraWords: mask._extraWords,
    );
  }
  if (word == 1) {
    return GraftMask._(
      w0: mask._w0,
      w1: mask._w1 | bit,
      extraWords: mask._extraWords,
    );
  }

  final extraIdx = word - 2;
  final currentExtra = mask._extraWords;
  final currentLen = currentExtra?.length ?? 0;
  final newLen = extraIdx >= currentLen ? extraIdx + 1 : currentLen;
  final nextExtra = List<int>.filled(newLen, 0);
  if (currentExtra != null) {
    for (int i = 0; i < currentExtra.length; i++) {
      nextExtra[i] = currentExtra[i];
    }
  }
  nextExtra[extraIdx] |= bit;
  return GraftMask._(w0: mask._w0, w1: mask._w1, extraWords: nextExtra);
}

@pragma('vm:prefer-inline')
bool _maskIntersects(GraftMask a, GraftMask b) {
  if (a._allDirty || b._allDirty) return true;
  if ((a._w0 & b._w0) != 0) return true;
  if ((a._w1 & b._w1) != 0) return true;

  final aExtra = a._extraWords;
  final bExtra = b._extraWords;
  if (aExtra != null && bExtra != null) {
    final minLen = aExtra.length < bExtra.length ? aExtra.length : bExtra.length;
    for (int i = 0; i < minLen; i++) {
      if ((aExtra[i] & bExtra[i]) != 0) return true;
    }
  }
  return false;
}

@pragma('vm:prefer-inline')
bool _maskIsSubsetOf(GraftMask a, GraftMask b) {
  if (b._allDirty) return true;
  if (a._allDirty) return false;
  if ((a._w0 & ~b._w0) != 0) return false;
  if ((a._w1 & ~b._w1) != 0) return false;

  final aExtra = a._extraWords;
  final bExtra = b._extraWords;
  if (aExtra != null) {
    final bLen = bExtra?.length ?? 0;
    for (int i = 0; i < aExtra.length; i++) {
      final bVal = (i < bLen) ? bExtra![i] : 0;
      if ((aExtra[i] & ~bVal) != 0) return false;
    }
  }
  return true;
}

@pragma('vm:prefer-inline')
GraftMask _maskUnion(GraftMask a, GraftMask b) {
  if (a._allDirty || b._allDirty) return GraftMask.allDirty;
  if (a.isEmpty) return b;
  if (b.isEmpty) return a;

  final nextW0 = a._w0 | b._w0;
  final nextW1 = a._w1 | b._w1;

  final aExtra = a._extraWords;
  final bExtra = b._extraWords;
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
