part of '../graft_state.dart';

@pragma('vm:prefer-inline')
GraftMask _stateDiffChanges(GraftState state) {
  final p = state._singleBaseline;
  if (state._baseline == null && !identical(p, _undefined)) {
    if (state._allScalarProps) {
      state.props;
      final c = state._pendingSingle;
      if (p == c) {
        state._dirtyMask = GraftMask.empty;
        return GraftMask.empty;
      }
      state._singleBaseline = c;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    if (p is GraftState) {
      return _diffSingleNestedState(state, p);
    }
    state.props;
    final c = state._pendingSingle;
    return _diffSinglePropValue(state, p, c);
  }

  final current = state.props;
  final len = current.length;
  if (len == 0) {
    state._dirtyMask = GraftMask.allDirty;
    return GraftMask.allDirty;
  }

  if (len == 1) {
    final c = current is _GraftPropsSingle ? current.value : current[0];
    final p = state._singleBaseline;
    if (identical(p, _undefined)) {
      state._singleBaseline = _snapshotValue(c);
      state._prevListLength = c is List ? c.length : -1;
      state._singleNestedVersion = c is GraftState ? c._version : -1;
      state._dirtyMask = GraftMask.allDirty;
      return GraftMask.allDirty;
    }
    return _diffSinglePropValue(state, p, c);
  }

  final prev = state._baseline;
  if (prev == null || prev.length != len) {
    if (current is _GraftPropsListView) {
      final list = current._list;
      if (list.isNotEmpty && list[0] is GraftState) {
        state._baseline = List<Object?>.generate(
          len,
          (i) => _snapshotValue(current[i]),
          growable: false,
        );
      } else {
        state._baseline = List<Object?>.of(list, growable: false);
      }
    } else {
      state._baseline = List<Object?>.generate(
        len,
        (i) => _snapshotValue(current[i]),
        growable: false,
      );
    }
    state._dirtyMask = GraftMask.allDirty;
    return GraftMask.allDirty;
  }

  if (len == 2) {
    return _diffDualProps(state, prev, current);
  }
  if (len == 3) {
    return _diffTripleProps(state, prev, current);
  }
  if (len == 4) {
    return _diffQuadProps(state, prev, current);
  }
  if (len == 5) {
    return _diffPentaProps(state, prev, current);
  }
  return _diffGeneralProps(state, prev, current, len);
}
