part of '../graft_state.dart';

@pragma('vm:prefer-inline')
void _stateNotifyGraft(GraftState state, Graft g, GraftMask mask) {
  if (!GraftEngine.hasAnyListeners(g) && Graft.observer == null) {
    return;
  }
  if (GraftEngine.hasOnlyFastDirectReceiver(g)) {
    final fast = GraftEngine.getFastDirectReceiver(g)!;
    if (fast.mounted) {
      fast.markFastDirty(mask);
      return;
    }
    GraftEngine.setFastDirectReceiver(g, null);
  }
  if (GraftEngine.hasOnlySingleListener(g)) {
    GraftEngine.singleListener(g)!();
    return;
  }
  state._dirtyMask = mask;
  GraftEngine.notifyMask(g, mask);
}

@pragma('vm:prefer-inline')
void _stateDispatchNotification(GraftState state, GraftMask mask) {
  if (state._isDryEnabled) {
    DryStateHook.onStateUpdated(state);
  }
  final g = state._graft;
  if (g != null) {
    _stateNotifyGraft(state, g, mask);
  }
}

@pragma('vm:prefer-inline')
void _stateUpdate(GraftState state, {int? itemIndex}) {
  if (itemIndex != null) {
    state._version++;
    if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
    state._dirtyMask = GraftMask.bit0;
    final g = state._graft;
    if (g != null) {
      GraftEngine.notifyItem(g, itemIndex);
      return;
    }
  }

  if (_tryFastSingleScalar(state)) return;

  final sc = state._scalarCount;
  if (sc == 5 && Graft.observer == null) {
    if (_tryFastMultiScalar5(state)) return;
  } else if (sc >= 2 && sc < 5 && Graft.observer == null) {
    if (_tryFastMultiScalar2to4(state, sc)) return;
  }

  if (_tryFastLeaf(state)) return;

  final p = state._singleBaseline;
  if (_tryFastSingleBaseline(state, p)) return;

  state._version++;

  final prev = state._baseline;
  if (prev != null && state._allScalarProps && Graft.observer == null) {
    if (_tryFastBufferScalar(state, prev, prev.length)) return;
  }

  final hasObserver = Graft.observer != null;
  List<Object?>? prevSnapshot;
  if (hasObserver) {
    prevSnapshot = state._baselineSnapshot;
  }

  final mask = _stateDiffChanges(state);
  if (mask.isNotEmpty) {
    if (state._isDryEnabled) DryStateHook.onStateUpdated(state);
    final g = state._graft;
    if (hasObserver) {
      if (g != null) {
        GraftEngine.notifyMask(
          g,
          mask,
          change: GraftChange<dynamic>(
            currentState: state,
            nextState: state,
            previousProps: prevSnapshot ?? const [],
            nextProps: List<Object?>.of(state.props, growable: false),
            dirtyMask: mask,
          ),
        );
      }
    } else {
      if (g != null) {
        GraftEngine.notifyMask(g, mask);
      }
    }
  }
}

