part of '../graft_state.dart';

@pragma('vm:prefer-inline')
GraftMask _diffGeneralProps(
  GraftState state,
  List<Object?> prev,
  dynamic current,
  int len,
) {
  final buf = state._propsBuffer;
  int singleDirtyIndex = -1;
  int dirtyCount = 0;
  int w0 = 0;
  int w1 = 0;
  List<int>? extra;

  for (int i = 0; i < len; i++) {
    final c = buf != null ? buf[i] : current[i];
    final dirty = _diffPropertyAtIndex(state, prev, i, c);
    if (!dirty) continue;

    dirtyCount++;
    if (dirtyCount == 1) {
      singleDirtyIndex = i;
    }
    if (i < 32) {
      w0 |= (1 << i);
    } else if (i < 64) {
      w1 |= (1 << (i - 32));
    } else {
      final wordIdx = (i >> 5) - 2;
      extra ??= <int>[];
      while (extra.length <= wordIdx) {
        extra.add(0);
      }
      extra[wordIdx] |= (1 << (i & 31));
    }
  }

  if (dirtyCount == 0) {
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (dirtyCount == 1 && singleDirtyIndex < 64) {
    final mask = GraftMask.bit(singleDirtyIndex);
    state._dirtyMask = mask;
    return mask;
  }
  final curMask = state._dirtyMask;
  if (!curMask.isAllDirty && curMask.matchesWords(w0, w1, extra)) {
    return curMask;
  }
  final mask = GraftMask.fromWords(w0, w1, extra);
  state._dirtyMask = mask;
  return mask;
}

