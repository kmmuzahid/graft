part of '../graft_state.dart';

@pragma('vm:prefer-inline')
GraftMask _diffDualProps(
  GraftState state,
  List<Object?> prev,
  dynamic current,
) {
  final buf = state._propsBuffer;
  final c0 = buf != null ? buf[0] : current[0];
  final c1 = buf != null ? buf[1] : current[1];
  final p0 = prev[0];
  final p1 = prev[1];

  bool d0 = false;
  bool d1 = false;
  if (state._allScalarProps) {
    if (p0 != c0) {
      prev[0] = c0;
      d0 = true;
    }
    if (p1 != c1) {
      prev[1] = c1;
      d1 = true;
    }
  } else {
    d0 = _diffPropertyAtIndex(state, prev, 0, c0);
    d1 = _diffPropertyAtIndex(state, prev, 1, c1);
  }

  if (!d0 && !d1) {
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (d0 && !d1) {
    state._dirtyMask = GraftMask.bit0;
    return GraftMask.bit0;
  }
  if (!d0 && d1) {
    state._dirtyMask = GraftMask.bit1;
    return GraftMask.bit1;
  }
  final curMask = state._dirtyMask;
  if (!curMask.isAllDirty && curMask.matchesWords(3, 0)) {
    return curMask;
  }
  final mask = GraftMask.allBitsUpTo(2);
  state._dirtyMask = mask;
  return mask;
}
