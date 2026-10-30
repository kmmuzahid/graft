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

  int i = 0;
  while (i + 7 < len) {
    final c0 = buf != null ? buf[i] : current[i];
    final c1 = buf != null ? buf[i + 1] : current[i + 1];
    final c2 = buf != null ? buf[i + 2] : current[i + 2];
    final c3 = buf != null ? buf[i + 3] : current[i + 3];
    final c4 = buf != null ? buf[i + 4] : current[i + 4];
    final c5 = buf != null ? buf[i + 5] : current[i + 5];
    final c6 = buf != null ? buf[i + 6] : current[i + 6];
    final c7 = buf != null ? buf[i + 7] : current[i + 7];

    final p0 = prev[i];
    final p1 = prev[i + 1];
    final p2 = prev[i + 2];
    final p3 = prev[i + 3];
    final p4 = prev[i + 4];
    final p5 = prev[i + 5];
    final p6 = prev[i + 6];
    final p7 = prev[i + 7];

    if (state._allScalarProps &&
        identical(p0, c0) &&
        identical(p1, c1) &&
        identical(p2, c2) &&
        identical(p3, c3) &&
        identical(p4, c4) &&
        identical(p5, c5) &&
        identical(p6, c6) &&
        identical(p7, c7)) {
      i += 8;
      continue;
    }

    for (int k = 0; k < 8; k++) {
      final idx = i + k;
      final c = buf != null ? buf[idx] : current[idx];
      if (_diffPropertyAtIndex(state, prev, idx, c)) {
        dirtyCount++;
        if (dirtyCount == 1) singleDirtyIndex = idx;
        if (idx < 32) {
          w0 |= (1 << idx);
        } else if (idx < 64) {
          w1 |= (1 << (idx - 32));
        } else {
          final wordIdx = (idx >> 5) - 2;
          extra ??= <int>[];
          while (extra.length <= wordIdx) {
            extra.add(0);
          }
          extra[wordIdx] |= (1 << (idx & 31));
        }
      }
    }
    i += 8;
  }

  for (; i < len; i++) {
    final c = buf != null ? buf[i] : current[i];
    if (_diffPropertyAtIndex(state, prev, i, c)) {
      dirtyCount++;
      if (dirtyCount == 1) singleDirtyIndex = i;
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
