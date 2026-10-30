part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _tryFastLeaf(GraftState state) {
  final leaf = state._leafState;
  if (leaf != null && Graft.observer == null) {
    state._version++;
    if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
    leaf.update();
    return true;
  }
  return false;
}

@pragma('vm:prefer-inline')
bool _tryFastSingleBaseline(GraftState state, Object? p) {
  if (state._baseline != null ||
      identical(p, _undefined) ||
      Graft.observer != null) {
    return false;
  }

  if (p is List) {
    state.props;
    final c = state._pendingSingle;
    if (c is List) {
      final clen = c.length;
      if (state._prevListLength != clen) {
        state._prevListLength = clen;
        state._baselineNeedsSync = true;
        state._version++;
        state._dirtyMask = GraftMask.bit0;
        _stateDispatchNotification(state, GraftMask.bit0);
        return true;
      }
      if (state._baselineNeedsSync) {
        state._singleBaseline = List<Object?>.of(c, growable: false);
        state._baselineNeedsSync = false;
        state._version++;
        state._dirtyMask = GraftMask.bit0;
        _stateDispatchNotification(state, GraftMask.bit0);
        return true;
      }
      if (_diffListAndUpdate(p, c)) {
        state._version++;
        state._dirtyMask = GraftMask.bit0;
        _stateDispatchNotification(state, GraftMask.bit0);
        return true;
      }
    }
  } else if (p is GraftState) {
    final cur = state._leafState ?? p;
    final leafP = cur._singleBaseline;
    if (cur._baseline == null &&
        (cur._allScalarProps ||
            leafP is num ||
            leafP is String ||
            leafP is bool ||
            leafP is Enum)) {
      cur.props;
      final c = cur._pendingSingle;
      if (leafP == c) return true;
      state._version++;
      cur._version++;
      cur._singleBaseline = c;
      state._singleNestedVersion = p._version;
      state._dirtyMask = GraftMask.bit0;
      final g = state._graft;
      if (g != null) GraftEngine.notifyMask(g, GraftMask.bit0);
      return true;
    }
    if (cur._diffChanges().isNotEmpty) {
      state._version++;
      cur._version++;
      state._singleNestedVersion = p._version;
      state._dirtyMask = GraftMask.bit0;
      final g = state._graft;
      if (g != null) GraftEngine.notifyMask(g, GraftMask.bit0);
      return true;
    }
  }
  return false;
}

