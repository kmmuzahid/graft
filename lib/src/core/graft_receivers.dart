part of 'graft.dart';

/// Internal interface for zero-overhead direct element notification.
@internal
abstract interface class GraftFastReceiver {
  bool get mounted;
  void markFastDirty([GraftMask? mask]);
}

/// Internal interface for zero-overhead index-addressed item slot notification.
@internal
abstract interface class GraftItemReceiver {
  bool get mounted;
  void markItemDirty();
}

void _graftRegisterItemReceiver(Graft graft, int index, GraftItemReceiver receiver) {
  final chunkIdx = index >> 6;
  final offset = index & 63;
  final dir = graft._receiverDirectory ??= <List<GraftItemReceiver?>?>[];
  while (dir.length <= chunkIdx) {
    dir.add(null);
  }
  final chunk = dir[chunkIdx] ??= List<GraftItemReceiver?>.filled(64, null);
  chunk[offset] = receiver;
}

void _graftUnregisterItemReceiver(Graft graft, int index, GraftItemReceiver receiver) {
  final chunkIdx = index >> 6;
  final dir = graft._receiverDirectory;
  if (dir != null && chunkIdx < dir.length) {
    final chunk = dir[chunkIdx];
    if (chunk != null && identical(chunk[index & 63], receiver)) {
      chunk[index & 63] = null;
    }
  }
}

@pragma('vm:prefer-inline')
bool _graftHasItemReceiver(Graft graft, int index) {
  final chunkIdx = index >> 6;
  final dir = graft._receiverDirectory;
  if (dir != null && chunkIdx < dir.length) {
    final chunk = dir[chunkIdx];
    if (chunk != null) return chunk[index & 63] != null;
  }
  return false;
}

@pragma('vm:prefer-inline')
void _graftNotifyItem(Graft graft, int index) {
  if (graft._isDisposed) return;
  final chunkIdx = index >> 6;
  final dir = graft._receiverDirectory;
  if (dir != null && chunkIdx < dir.length) {
    final chunk = dir[chunkIdx];
    if (chunk != null) {
      final r = chunk[index & 63];
      if (r != null && r.mounted) {
        r.markItemDirty();
        final single = graft._singleListener;
        if (single != null) {
          single();
          final extra = graft._extraListeners;
          if (extra != null && extra.isNotEmpty) {
            final eLen = extra.length;
            for (int i = 0; i < eLen; i++) {
              extra[i]();
            }
          }
        }
        return;
      }
    }
  }
  graft._notifyMask(GraftMask.bit0);
}

/// Internal engine accessor for [Graft]. Never exported in public API.
@internal
abstract final class GraftEngine {
  static GraftFastReceiver? getFastDirectReceiver(Graft graft) =>
      graft._fastDirectReceiver;

  @pragma('vm:prefer-inline')
  static bool canActivateFastReceiver(Graft graft) =>
      graft._singleListener == null &&
      (graft._extraListeners == null || graft._extraListeners!.isEmpty) &&
      (graft._extraMaskListeners == null || graft._extraMaskListeners!.isEmpty) &&
      graft._fastDirectReceiver == null &&
      Graft.observer == null;

  static void setFastDirectReceiver(Graft graft, GraftFastReceiver? r) {
    if (r != null && !canActivateFastReceiver(graft)) {
      graft._fastDirectReceiver = null;
      GraftStateEngine.setFastReceiver(graft._state, null);
      graft._recomputeSingleListenerFlag();
      return;
    }
    graft._fastDirectReceiver = r;
    GraftStateEngine.setFastReceiver(graft._state, r);
    graft._recomputeSingleListenerFlag();
  }

  static GraftMask getFastDirectMask(Graft graft) => graft._fastDirectMask;

  static void setFastDirectMask(Graft graft, GraftMask mask) =>
      graft._fastDirectMask = mask;

  static void registerItemReceiver(
          Graft graft, int index, GraftItemReceiver receiver) =>
      _graftRegisterItemReceiver(graft, index, receiver);

  static void unregisterItemReceiver(
          Graft graft, int index, GraftItemReceiver receiver) =>
      _graftUnregisterItemReceiver(graft, index, receiver);

  static bool hasItemReceiver(Graft graft, int index) =>
      _graftHasItemReceiver(graft, index);

  static void notifyItem(Graft graft, int index) =>
      _graftNotifyItem(graft, index);

  static void notifyMask(Graft graft, GraftMask mask,
          {GraftChange<dynamic>? change}) =>
      graft._notifyMask(mask, change: change);

  @pragma('vm:prefer-inline')
  static bool hasAnyListeners(Graft graft) => graft._hasAnyListeners;

  @pragma('vm:prefer-inline')
  static VoidCallback? singleListener(Graft graft) => graft._singleListener;

  @pragma('vm:prefer-inline')
  static bool hasOnlySingleListener(Graft graft) =>
      graft._hasOnlySingleListener;

  @pragma('vm:prefer-inline')
  static bool hasOnlyFastDirectReceiver(Graft graft) =>
      graft._hasOnlyFastDirectReceiver;

  @pragma('vm:prefer-inline')
  static S getState<S extends GraftState>(Graft<S> graft) => graft._state;

  @pragma('vm:prefer-inline')
  static int getScalarCount(Graft graft) =>
      GraftStateEngine.scalarCount(graft._state);
}

