part of 'graft.dart';

/// Internal interface for zero-overhead direct element notification.
@internal
abstract interface class GraftFastReceiver {
  bool get mounted;
  void markFastDirty();
}

/// Internal interface for zero-overhead index-addressed item slot notification.
@internal
abstract interface class GraftItemReceiver {
  bool get mounted;
  void markItemDirty();
}

void _graftRegisterItemReceiver(Graft graft, int index, GraftItemReceiver receiver) {
  if (graft._sparseReceivers == null && graft._denseReceivers.every((r) => r == null)) {
    graft._denseWindowStart = (index ~/ 64) * 64;
  }
  final offset = index - graft._denseWindowStart;
  if (offset >= 0 && offset < 64) {
    graft._denseReceivers[offset] = receiver;
  } else {
    (graft._sparseReceivers ??= <int, GraftItemReceiver>{})[index] = receiver;
  }
}

void _graftUnregisterItemReceiver(Graft graft, int index, GraftItemReceiver receiver) {
  final offset = index - graft._denseWindowStart;
  if (offset >= 0 && offset < 64) {
    if (identical(graft._denseReceivers[offset], receiver)) {
      graft._denseReceivers[offset] = null;
    }
  } else {
    final map = graft._sparseReceivers;
    if (map != null && identical(map[index], receiver)) {
      map.remove(index);
    }
  }
}

@pragma('vm:prefer-inline')
bool _graftHasItemReceiver(Graft graft, int index) {
  final offset = index - graft._denseWindowStart;
  if (offset >= 0 && offset < 64) {
    return graft._denseReceivers[offset] != null;
  }
  return graft._sparseReceivers?.containsKey(index) ?? false;
}

@pragma('vm:prefer-inline')
void _graftNotifyItem(Graft graft, int index) {
  if (graft._isDisposed) return;
  GraftItemReceiver? r;
  final offset = index - graft._denseWindowStart;
  if (offset >= 0 && offset < 64) {
    r = graft._denseReceivers[offset];
  } else {
    r = graft._sparseReceivers?[index];
  }
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
  graft._notifyMask(GraftMask.bit0);
}

/// Internal engine accessor for [Graft]. Never exported in public API.
@internal
abstract final class GraftEngine {
  static GraftFastReceiver? getFastDirectReceiver(Graft graft) =>
      graft._fastDirectReceiver;

  static void setFastDirectReceiver(Graft graft, GraftFastReceiver? r) =>
      graft._fastDirectReceiver = r;

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

  static bool hasAnyListeners(Graft graft) => graft._hasAnyListeners;

  static VoidCallback? singleListener(Graft graft) => graft._singleListener;

  static bool hasOnlySingleListener(Graft graft) =>
      graft._hasOnlySingleListener;

  static bool hasOnlyFastDirectReceiver(Graft graft) =>
      graft._hasOnlyFastDirectReceiver;
}

