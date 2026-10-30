import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft_async.dart';
import 'graft_change.dart';
import 'graft_mask.dart';
import 'graft_observer.dart';
import 'graft_scope_tracker.dart';
import 'graft_state.dart';
import '../persistence/ambient_locator.dart';
import '../persistence/dry/dry_state_hook.dart';
import '../persistence/state_config.dart';

part 'graft_receivers.dart';
part 'graft_dispatch.dart';
part 'graft_lifecycle.dart';
part 'graft_async_task.dart';

/// Base class for reactive state management with fine-grained slot isolation.
class Graft<S extends GraftState> extends ChangeNotifier {
  static GraftObserver? observer;

  static void init({GraftStateConfig? config, void Function()? setup}) {
    if (config != null) configurePersistence(config);
    setup?.call();
  }

  final S _state;
  void Function(GraftMask dirtyMask)? _singleMaskListener;
  List<void Function(GraftMask dirtyMask)>? _extraMaskListeners;
  bool _isDisposed = false;
  bool _pendingNotify = false;
  bool _isNotifying = false;
  ValueListenable<S>? _listenableCache;

  GraftFastReceiver? _fastDirectReceiver;
  GraftMask _fastDirectMask = GraftMask.empty;
  List<List<GraftItemReceiver?>?>? _receiverDirectory;

  VoidCallback? _singleListener;
  List<VoidCallback>? _extraListeners;
  bool _hasOnlySingle = false;
  bool _hasOnlySingleListener = false;
  bool _hasOnlyFastDirectReceiver = false;
  bool _hasAnyListeners = false;
  int _currentAsyncTaskId = 0;

  @nonVirtual
  void updateItem(int index, [void Function()? mutate]) {
    mutate?.call();
    state.update(itemIndex: index);
  }

  Graft(S initialState) : _state = initialState {
    _graftBindInitial(this, initialState);
  }

  Graft.dry(Function stateFactory, {String? key})
      : this._fromDryRecord(_initDryState<S>(stateFactory, key), key);
  Graft._fromDryRecord((S, String, bool) record, String? customKey)
      : _state = record.$1 {
    _graftBindDry(this, record.$2, record.$3, customKey);
  }

  @protected
  @mustCallSuper
  void onInit() {}
  @protected
  @mustCallSuper
  void onDispose() {}

  @nonVirtual
  @pragma('vm:prefer-inline')
  S get state {
    if (GraftScopeTracker.hasActiveScope) GraftScopeTracker.current?.record(this);
    return _state;
  }

  @nonVirtual
  ValueListenable<S> get listenable =>
      _listenableCache ??= _GraftListenable<S>(this);

  void _recomputeSingleListenerFlag() => _graftRecomputeSingleListenerFlag(this);

  @override
  @nonVirtual
  bool operator ==(Object other) => identical(this, other);

  @override
  @nonVirtual
  int get hashCode => identityHashCode(this);

  @override
  @nonVirtual
  bool get hasListeners =>
      _singleListener != null ||
      (_extraListeners != null && _extraListeners!.isNotEmpty) ||
      super.hasListeners;

  @nonVirtual
  bool get isDisposed => _isDisposed;

  @override
  @nonVirtual
  void addListener(VoidCallback listener) => _graftAddListener(this, listener);

  @override
  @nonVirtual
  void removeListener(VoidCallback listener) => _graftRemoveListener(this, listener);

  @nonVirtual
  void addMaskListener(void Function(GraftMask dirtyMask) listener) =>
      _graftAddMaskListener(this, listener);

  @nonVirtual
  void removeMaskListener(void Function(GraftMask dirtyMask) listener) =>
      _graftRemoveMaskListener(this, listener);

  @override
  @nonVirtual
  void notifyListeners() => _graftNotifyListeners(this);

  @pragma('vm:prefer-inline')
  void _notifyMask(GraftMask dirtyMask, {GraftChange<dynamic>? change}) =>
      _graftNotifyMask(this, dirtyMask, change: change);

  @nonVirtual
  void notify({GraftChange<dynamic>? change}) =>
      _graftNotify(this, change: change);

  @nonVirtual
  S mutate(void Function(S state) action) {
    action(_state);
    _state.update();
    return _state;
  }

  @nonVirtual
  void reset() => !_isDisposed ? _state.reset() : null;

  @protected
  @nonVirtual
  void addError(Object error, [StackTrace? stackTrace]) =>
      observer?.onError(this, error, stackTrace ?? StackTrace.current);

  @nonVirtual
  Future<T?> runAsync<T>({
    required Future<T> Function() task,
    required void Function(GraftAsync<T> result) onUpdate,
  }) =>
      _graftRunAsync<T>(this, task: task, onUpdate: onUpdate);

  @mustCallSuper
  @override
  void dispose() {
    _graftDispose(this);
    super.dispose();
  }
}
