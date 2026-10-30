part of 'graft_mask.dart';

@pragma('vm:prefer-inline')
int? _maskSingleBitIndex(GraftMask mask) {
  if (mask._allDirty) return null;
  final w0 = mask._w0;
  final w1 = mask._w1;
  final extra = mask._extraWords;

  if (w1 == 0 && (extra == null || _isAllZero(extra))) {
    if (w0 != 0 && (w0 & (w0 - 1)) == 0) {
      return (w0 & 0xFFFFFFFF).bitLength - 1;
    }
    return null;
  }
  if (w0 == 0 && (extra == null || _isAllZero(extra))) {
    if (w1 != 0 && (w1 & (w1 - 1)) == 0) {
      return ((w1 & 0xFFFFFFFF).bitLength - 1) + 32;
    }
    return null;
  }
  if (extra != null && w0 == 0 && w1 == 0) {
    int? found;
    for (int i = 0; i < extra.length; i++) {
      final w = extra[i];
      if (w == 0) continue;
      if ((w & (w - 1)) != 0 || found != null) return null;
      found = ((w & 0xFFFFFFFF).bitLength - 1) + ((i + 2) << 5);
    }
    return found;
  }
  return null;
}

@pragma('vm:prefer-inline')
bool _maskEquals(GraftMask a, Object other) {
  if (identical(a, other)) return true;
  if (other is! GraftMask) return false;
  if (a._allDirty != other._allDirty) return false;
  if (a._allDirty) return true;
  if (a._w0 != other._w0 || a._w1 != other._w1) return false;

  final aExtra = a._extraWords;
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

@pragma('vm:prefer-inline')
int _maskHashCode(GraftMask mask) =>
    Object.hash(mask._allDirty, mask._w0, mask._w1, mask._extraWords?.length ?? 0);

String _maskToString(GraftMask mask) {
  if (mask._allDirty) return 'GraftMask(allDirty)';
  if (mask.isEmpty) return 'GraftMask(empty)';
  final buffer = StringBuffer('GraftMask(');
  buffer.write('0x${mask._w0.toRadixString(16)}');
  final extra = mask._extraWords;
  if (mask._w1 != 0 || (extra != null && extra.any((w) => w != 0))) {
    buffer.write(', 0x${mask._w1.toRadixString(16)}');
  }
  if (extra != null) {
    for (final w in extra) {
      if (w != 0) buffer.write(', 0x${w.toRadixString(16)}');
    }
  }
  buffer.write(')');
  return buffer.toString();
}

@pragma('vm:prefer-inline')
bool _isAllZero(List<int> words) {
  for (int i = 0; i < words.length; i++) {
    if (words[i] != 0) return false;
  }
  return true;
}

