part of '../graft_state.dart';

@pragma('vm:prefer-inline')
GraftMask _diffSinglePropValue(GraftState state, Object? p, Object? c) {
  if (c is num || c is String || c is bool || c is Enum) {
    if (p == c) {
      state._dirtyMask = GraftMask.empty;
      return GraftMask.empty;
    }
    state._singleBaseline = c;
    state._dirtyMask = GraftMask.bit0;
    return GraftMask.bit0;
  }
  if (c is GraftState) {
    if (!identical(p, c)) {
      state._singleBaseline = c;
      state._singleNestedVersion = c._version;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    final cv = c._version;
    final capturedV = state._singleNestedVersion;
    if (capturedV >= 0 && cv == capturedV) {
      state._dirtyMask = GraftMask.empty;
      return GraftMask.empty;
    }
    if (c._diffChanges().isNotEmpty) {
      state._singleNestedVersion = cv;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._singleNestedVersion = cv;
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (identical(p, c)) {
    if (c is List) {
      if (state._prevListLength != c.length) {
        state._prevListLength = c.length;
        state._dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    } else if (c is Iterable || c is Map) {
      if (!_deepEquals(p, c)) {
        state._singleBaseline = _snapshotValue(c);
        state._dirtyMask = GraftMask.bit0;
        return GraftMask.bit0;
      }
    }
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (p is List && c is List) {
    final clen = c.length;
    if (state._prevListLength != clen) {
      state._prevListLength = clen;
      state._baselineNeedsSync = true;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    if (state._baselineNeedsSync) {
      state._singleBaseline = List<Object?>.of(c, growable: false);
      state._baselineNeedsSync = false;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    if (_diffListAndUpdate(p, c)) {
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (p is Map && c is Map) {
    if (_diffMapAndUpdate(p, c)) {
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  if (_isPropertyDirty(p, c)) {
    state._singleBaseline = _updateSnapshot(p, c);
    state._dirtyMask = GraftMask.bit0;
    return GraftMask.bit0;
  } else {
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
}

@pragma('vm:prefer-inline')
GraftMask _diffSingleNestedState(GraftState state, GraftState p) {
  final cv = p._version;
  final capturedV = state._singleNestedVersion;
  if (capturedV >= 0 && cv == capturedV) {
    state.props;
    final c = state._pendingSingle;
    if (!identical(p, c)) {
      state._singleBaseline = c;
      state._singleNestedVersion = c is GraftState ? c._version : -1;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  final leaf = state._leafState;
  if (leaf != null) {
    if (leaf._diffChanges().isNotEmpty) {
      state._singleNestedVersion = p._version;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._singleNestedVersion = p._version;
    state.props;
    final c = state._pendingSingle;
    if (!identical(p, c)) {
      state._singleBaseline = c;
      state._singleNestedVersion = c is GraftState ? c._version : -1;
      state._dirtyMask = GraftMask.bit0;
      return GraftMask.bit0;
    }
    state._dirtyMask = GraftMask.empty;
    return GraftMask.empty;
  }
  GraftState cur = p;
  while (cur._baseline == null) {
    final next = cur._singleBaseline;
    if (next is GraftState) {
      cur = next;
    } else {
      break;
    }
  }
  if (cur._diffChanges().isNotEmpty) {
    state._singleNestedVersion = p._version;
    state._dirtyMask = GraftMask.bit0;
    return GraftMask.bit0;
  }
  state._singleNestedVersion = p._version;
  state.props;
  final c = state._pendingSingle;
  if (!identical(p, c)) {
    state._singleBaseline = c;
    state._singleNestedVersion = c is GraftState ? c._version : -1;
    state._dirtyMask = GraftMask.bit0;
    return GraftMask.bit0;
  }
  state._dirtyMask = GraftMask.empty;
  return GraftMask.empty;
}

