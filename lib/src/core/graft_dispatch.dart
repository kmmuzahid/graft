part of 'graft.dart';

void _graftRecomputeSingleListenerFlag(Graft graft) {
  graft._hasOnlySingle = graft._singleListener != null &&
      (graft._extraListeners == null || graft._extraListeners!.isEmpty) &&
      graft._singleMaskListener == null;
  graft._hasOnlySingleListener =
      graft._hasOnlySingle && graft._fastDirectReceiver == null && Graft.observer == null;
  graft._hasOnlyFastDirectReceiver = graft._fastDirectReceiver != null &&
      (graft._extraMaskListeners == null || graft._extraMaskListeners!.isEmpty) &&
      graft._singleListener == null &&
      Graft.observer == null;
  graft._hasAnyListeners = graft._singleListener != null ||
      graft._singleMaskListener != null ||
      graft._fastDirectReceiver != null ||
      (graft._extraListeners != null && graft._extraListeners!.isNotEmpty) ||
      (graft._extraMaskListeners != null && graft._extraMaskListeners!.isNotEmpty);
}

@pragma('vm:prefer-inline')
void _graftNotifyMask(Graft graft, GraftMask dirtyMask, {GraftChange<dynamic>? change}) {
  if (graft._isDisposed) return;

  if (graft._singleListener == null &&
      graft._singleMaskListener == null &&
      graft._fastDirectReceiver == null &&
      Graft.observer == null) {
    return;
  }

  final single = graft._singleListener;
  if (single != null &&
      Graft.observer == null &&
      graft._extraListeners == null &&
      graft._singleMaskListener == null &&
      graft._fastDirectReceiver == null) {
    single();
    return;
  }

  if (graft._hasOnlyFastDirectReceiver) {
    final fe = graft._fastDirectReceiver!;
    if (fe.mounted) {
      fe.markFastDirty();
      return;
    }
    graft._fastDirectReceiver = null;
    GraftStateEngine.setFastReceiver(graft._state, null);
    graft._fastDirectMask = GraftMask.empty;
  }

  if (single != null &&
      graft._fastDirectReceiver == null &&
      Graft.observer == null &&
      graft._singleMaskListener == null) {
    single();
    final extra = graft._extraListeners;
    if (extra != null && extra.isNotEmpty) {
      final len = extra.length;
      for (int i = 0; i < len; i++) {
        extra[i]();
      }
    }
    return;
  }

  final sml = graft._singleMaskListener;
  if (sml != null) {
    sml(dirtyMask);
    final eml = graft._extraMaskListeners;
    if (eml != null && eml.isNotEmpty) {
      final mLen = eml.length;
      for (int i = 0; i < mLen; i++) {
        eml[i](dirtyMask);
      }
    }
  }
  final fallbackSingle = graft._singleListener;
  if (fallbackSingle != null) {
    fallbackSingle();
    final extra = graft._extraListeners;
    if (extra != null && extra.isNotEmpty) {
      final eLen = extra.length;
      for (int i = 0; i < eLen; i++) {
        extra[i]();
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
          dirtyMask: dirtyMask,
        );
    Graft.observer?.onChange(graft, effectiveChange);
  }
}

class _GraftListenable<S extends GraftState> implements ValueListenable<S> {
  final Graft<S> _graft;
  const _GraftListenable(this._graft);

  @override
  S get value => _graft.state;

  @override
  void addListener(VoidCallback listener) => _graft.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _graft.removeListener(listener);
}

/// Persistence extensions on [Graft].
extension GraftPersistenceX<S extends GraftState> on Graft<S> {
  /// Permanently deactivates and invalidates dry state persistence for this session.
  void invalidateDry() => state.invalidateDry();
}
