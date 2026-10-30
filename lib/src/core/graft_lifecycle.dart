part of 'graft.dart';

void _graftAddListener(Graft graft, VoidCallback listener) {
  if (!graft._isDisposed) {
    graft._fastDirectReceiver = null;
    GraftStateEngine.setFastReceiver(graft._state, null);
    graft._fastDirectMask = GraftMask.empty;
    if (graft._singleListener == null) {
      graft._singleListener = listener;
      graft._recomputeSingleListenerFlag();
      return;
    }
    (graft._extraListeners ??= []).add(listener);
    graft._hasOnlySingle = false;
    graft._recomputeSingleListenerFlag();
  }
}

void _graftRemoveListener(Graft graft, VoidCallback listener) {
  if (!graft._isDisposed) {
    if (identical(graft._singleListener, listener)) {
      graft._singleListener = null;
      if (graft._extraListeners != null && graft._extraListeners!.isNotEmpty) {
        graft._singleListener = graft._extraListeners!.removeLast();
      }
      graft._recomputeSingleListenerFlag();
      return;
    }
    graft._extraListeners?.remove(listener);
    graft._recomputeSingleListenerFlag();
  }
}

void _graftAddMaskListener(Graft graft, void Function(GraftMask dirtyMask) listener) {
  if (!graft._isDisposed) {
    if (graft._singleMaskListener == null) {
      graft._singleMaskListener = listener;
      graft._recomputeSingleListenerFlag();
      return;
    }
    (graft._extraMaskListeners ??= []).add(listener);
    graft._fastDirectReceiver = null;
    GraftStateEngine.setFastReceiver(graft._state, null);
    graft._fastDirectMask = GraftMask.empty;
    graft._recomputeSingleListenerFlag();
  }
}

void _graftRemoveMaskListener(Graft graft, void Function(GraftMask dirtyMask) listener) {
  if (!graft._isDisposed) {
    graft._fastDirectReceiver = null;
    GraftStateEngine.setFastReceiver(graft._state, null);
    graft._fastDirectMask = GraftMask.empty;
    if (identical(graft._singleMaskListener, listener)) {
      graft._singleMaskListener = null;
      if (graft._extraMaskListeners != null && graft._extraMaskListeners!.isNotEmpty) {
        graft._singleMaskListener = graft._extraMaskListeners!.removeLast();
      }
      graft._recomputeSingleListenerFlag();
      return;
    }
    graft._extraMaskListeners?.remove(listener);
    graft._recomputeSingleListenerFlag();
  }
}

void _graftNotifyListeners(Graft graft) {
  if (graft._isDisposed) return;
  final single = graft._singleListener;
  if (single != null) {
    single();
    final extra = graft._extraListeners;
    if (extra != null && extra.isNotEmpty) {
      final len = extra.length;
      for (int i = 0; i < len; i++) {
        extra[i]();
      }
    }
  }
}

void _graftNotify(Graft graft, {GraftChange<dynamic>? change}) {
  if (graft._isDisposed) {
    if (kDebugMode) {
      debugPrint('Warning: Cannot notify on a disposed Graft (${graft.runtimeType}).');
    }
    return;
  }

  if (graft._isNotifying) {
    if (!graft._pendingNotify) {
      graft._pendingNotify = true;
      scheduleMicrotask(() {
        graft._pendingNotify = false;
        if (!graft._isDisposed) {
          graft.notify(change: change);
        }
      });
    }
    return;
  }

  graft._isNotifying = true;
  try {
    final sml = graft._singleMaskListener;
    if (sml != null) {
      sml(GraftMask.allDirty);
      final eml = graft._extraMaskListeners;
      if (eml != null && eml.isNotEmpty) {
        final len = eml.length;
        for (int i = 0; i < len; i++) {
          eml[i](GraftMask.allDirty);
        }
      }
    }
    if (Graft.observer != null) {
      final effectiveChange = change ??
          GraftChange(
            currentState: graft._state,
            nextState: graft._state,
            previousProps: GraftStateEngine.baselineSnapshot(graft._state),
            nextProps: List<Object?>.of(
              GraftStateEngine.props(graft._state),
              growable: false,
            ),
            dirtyMask: graft._state.dirtyMask,
          );
      Graft.observer?.onChange(graft, effectiveChange);
    }
    if (graft.hasListeners) {
      graft.notifyListeners();
    }
  } finally {
    graft._isNotifying = false;
  }
}

void _graftDispose(Graft graft) {
  if (graft._isDisposed) return;
  graft.onDispose();
  graft._isDisposed = true;
  graft._singleListener = null;
  graft._extraListeners?.clear();
  graft._hasOnlySingle = false;
  graft._singleMaskListener = null;
  graft._extraMaskListeners?.clear();
  graft._fastDirectReceiver = null;
  GraftStateEngine.setFastReceiver(graft._state, null);
  graft._fastDirectMask = GraftMask.empty;
  graft._receiverDirectory = null;
  Graft.observer?.onDispose(graft);
}
