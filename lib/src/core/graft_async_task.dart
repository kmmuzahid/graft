part of 'graft.dart';

Future<T?> _graftRunAsync<T>(
  Graft graft, {
  required Future<T> Function() task,
  required void Function(GraftAsync<T> result) onUpdate,
}) async {
  if (graft._isDisposed) return null;
  final taskId = ++graft._currentAsyncTaskId;
  var notified = false;
  void trackingListener() => notified = true;
  graft.addListener(trackingListener);

  try {
    onUpdate(const GraftAsync.loading());
    if (!notified) graft.notify();
    notified = false;

    final result = await task();
    if (!graft._isDisposed && taskId == graft._currentAsyncTaskId) {
      onUpdate(GraftAsync.data(result));
      if (!notified) graft.notify();
      return result;
    }
    return null;
  } catch (e, st) {
    if (!graft._isDisposed && taskId == graft._currentAsyncTaskId) {
      onUpdate(GraftAsync.error(e, st));
      if (!notified) graft.notify();
      graft.addError(e, st);
    }
    return null;
  } finally {
    graft.removeListener(trackingListener);
  }
}

(S, String, bool) _initDryState<S extends GraftState>(
    Function stateFactory, String? key) {
  final dryKey = key ?? (Function.apply(stateFactory, const []) as S).dryKey;
  final (state, fromCache) =
      DryStateHook.hydrateFactoryWithStatus<S>(stateFactory, dryKey);
  return (state, dryKey, fromCache);
}

void _graftBindInitial(Graft graft, GraftState initialState) {
  GraftStateEngine.bind(initialState, graft);
  graft.onInit();
  Graft.observer?.onCreate(graft);
}

void _graftBindDry(Graft graft, String dryKey, bool fromCache, String? customKey) {
  GraftStateEngine.setCustomDryKey(graft._state, customKey);
  GraftStateEngine.bind(graft._state, graft);
  DryStateHook.enableDryForState(graft._state, dryKey);
  Graft.observer?.onDryHydrated(graft._state, key: dryKey, fromCache: fromCache);
  graft.onInit();
  Graft.observer?.onCreate(graft);
}
