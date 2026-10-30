part of '../graft_state.dart';

@pragma('vm:prefer-inline')
bool _tryFastSingleScalar(GraftState state) {
  final p = state._singleBaseline;
  if (!state._allScalarProps ||
      state._baseline != null ||
      identical(p, _undefined) ||
      Graft.observer != null) {
    return false;
  }
  state.props;
  final c = state._pendingSingle;
  if (p == c) return true;
  state._singleBaseline = c;
  state._version++;
  if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
  final g = state._graft;
  if (g != null) {
    if (GraftEngine.hasOnlyFastDirectReceiver(g)) {
      final fast = GraftEngine.getFastDirectReceiver(g)!;
      if (fast.mounted) {
        fast.markFastDirty(GraftMask.bit0);
        return true;
      }
      GraftEngine.setFastDirectReceiver(g, null);
    }
    if (GraftEngine.hasOnlySingleListener(g)) {
      GraftEngine.singleListener(g)!();
      return true;
    }
    if (!GraftEngine.hasAnyListeners(g)) return true;
    _stateNotifyGraft(state, g, GraftMask.bit0);
  }
  return true;
}

@pragma('vm:prefer-inline')
bool _tryFastMultiScalar5(GraftState state) {
  state.props;
  final c0 = state._s0, c1 = state._s1, c2 = state._s2;
  final c3 = state._s3, c4 = state._s4;
  final p0 = state._b0, p1 = state._b1, p2 = state._b2;
  final p3 = state._b3, p4 = state._b4;
  final g = state._graft;
  if (g != null &&
      (GraftEngine.hasOnlySingleListener(g) || !GraftEngine.hasAnyListeners(g))) {
    if (p0 == c0 && p1 == c1 && p2 == c2 && p3 == c3 && p4 == c4) return true;
    state._b0 = c0;
    state._b1 = c1;
    state._b2 = c2;
    state._b3 = c3;
    state._b4 = c4;
    state._version++;
    if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
    if (GraftEngine.hasOnlySingleListener(g)) {
      GraftEngine.singleListener(g)!();
    }
    return true;
  }
  int w = 0;
  if (p0 != c0) {
    state._b0 = c0;
    w |= 1;
  }
  if (p1 != c1) {
    state._b1 = c1;
    w |= 2;
  }
  if (p2 != c2) {
    state._b2 = c2;
    w |= 4;
  }
  if (p3 != c3) {
    state._b3 = c3;
    w |= 8;
  }
  if (p4 != c4) {
    state._b4 = c4;
    w |= 16;
  }
  if (w == 0) return true;
  state._version++;
  if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
  if (g != null) {
    if (!GraftEngine.hasAnyListeners(g)) return true;
    final mask =
        w == 31 ? GraftMask.allBitsUpTo(5) : GraftMask.fromWords(w, 0);
    _stateNotifyGraft(state, g, mask);
  }
  return true;
}

@pragma('vm:prefer-inline')
bool _tryFastMultiScalar2to4(GraftState state, int sc) {
  state.props;
  final c0 = state._s0, c1 = state._s1;
  final p0 = state._b0, p1 = state._b1;
  final g = state._graft;
  if (g != null &&
      (GraftEngine.hasOnlySingleListener(g) || !GraftEngine.hasAnyListeners(g))) {
    final d0 = p0 != c0;
    final d1 = p1 != c1;
    final d2 = (sc > 2) && (state._b2 != state._s2);
    final d3 = (sc > 3) && (state._b3 != state._s3);
    if (!(d0 | d1 | d2 | d3)) return true;
    state._b0 = c0;
    state._b1 = c1;
    if (sc > 2) state._b2 = state._s2;
    if (sc > 3) state._b3 = state._s3;
    state._version++;
    if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
    if (GraftEngine.hasOnlySingleListener(g)) {
      GraftEngine.singleListener(g)!();
    }
    return true;
  }
  int w = 0;
  if (p0 != c0) {
    state._b0 = c0;
    w |= 1;
  }
  if (p1 != c1) {
    state._b1 = c1;
    w |= 2;
  }
  if (sc > 2) {
    final c2 = state._s2, p2 = state._b2;
    if (p2 != c2) {
      state._b2 = c2;
      w |= 4;
    }
    if (sc > 3) {
      final c3 = state._s3, p3 = state._b3;
      if (p3 != c3) {
        state._b3 = c3;
        w |= 8;
      }
    }
  }
  if (w == 0) return true;
  state._version++;
  if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
  if (g != null) {
    if (!GraftEngine.hasAnyListeners(g)) return true;
    if (GraftEngine.hasOnlySingleListener(g)) {
      GraftEngine.singleListener(g)!();
      return true;
    }
    final mask =
        w == 15 ? GraftMask.allBitsUpTo(4) : GraftMask.fromWords(w, 0);
    _stateNotifyGraft(state, g, mask);
  }
  return true;
}

