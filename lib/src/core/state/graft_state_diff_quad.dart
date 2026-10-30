part of '../graft_state.dart';

@pragma('vm:prefer-inline')
GraftMask _diffQuadProps(
  GraftState state,
  List<Object?> prev,
  dynamic current,
) {
  final buf = state._propsBuffer;
  final c0 = buf != null ? buf[0] : current[0];
  final c1 = buf != null ? buf[1] : current[1];
  final c2 = buf != null ? buf[2] : current[2];
  final c3 = buf != null ? buf[3] : current[3];
  final p0 = prev[0];
  final p1 = prev[1];
  final p2 = prev[2];
  final p3 = prev[3];

  int w = 0;
  if (state._allScalarProps) {
    if (p0 != c0) {
      prev[0] = c0;
      w |= 1;
    }
    if (p1 != c1) {
      prev[1] = c1;
      w |= 2;
    }
    if (p2 != c2) {
      prev[2] = c2;
      w |= 4;
    }
    if (p3 != c3) {
      prev[3] = c3;
      w |= 8;
    }
  } else {
    if (_diffPropertyAtIndex(state, prev, 0, c0)) w |= 1;
    if (_diffPropertyAtIndex(state, prev, 1, c1)) w |= 2;
    if (_diffPropertyAtIndex(state, prev, 2, c2)) w |= 4;
    if (_diffPropertyAtIndex(state, prev, 3, c3)) w |= 8;
  }

  if (w == 0) {
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (w == 15) {
    final mask = GraftMask.allBitsUpTo(4);
    state._dirtyMask = mask;
    return mask;
  }
  if ((w & (w - 1)) == 0) {
    final mask = GraftMask.bit(w.bitLength - 1);
    state._dirtyMask = mask;
    return mask;
  }
  final curMask = state._dirtyMask;
  if (!curMask.isAllDirty && curMask.matchesWords(w, 0)) {
    return curMask;
  }
  final mask = GraftMask.fromWords(w, 0);
  state._dirtyMask = mask;
  return mask;
}

