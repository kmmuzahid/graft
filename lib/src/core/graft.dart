import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft_mask.dart';
import 'graft_observer.dart';
import 'graft_scope_tracker.dart';
import 'graft_state.dart';
import '../persistence/ambient_locator.dart';
import '../persistence/dry/dry_state_hook.dart';
import '../persistence/dry_config.dart';

part 'graft_receivers.dart';
part 'graft_dispatch.dart';
part 'graft_lifecycle.dart';

/// Base class for reactive state management with fine-grained slot isolation.
class Graft<S extends GraftState> implements Listenable {
  static GraftObserver? _observer;

  /// Active observer for monitoring lifecycles, state diffs, and errors.
  ///
  /// To configure an observer in application code, use [Graft.config].
  @internal
  static GraftObserver? get observer => _observer;

  @internal
  static set observer(GraftObserver? value) => _observer = value;

  /// Centralized optional configuration for Graft persistence, diagnostics, and DI.
  ///
  /// Calling [Graft.config] is completely optional—Graft works out of the box with zero setup.
  /// When called, it configures global persistence, attaches observers (automatically enabling
  /// console logs in [kDebugMode]), and executes dependency setup in [di].
  ///
  /// ### Parameters:
  /// - [dryConfig]: Storage coordinator contract for Frame-0 disk persistence ([GraftDryConfig]).
  /// - [observer]: Custom telemetry, crash reporting, or analytics observer (e.g. Firebase Crashlytics).
  /// - [debugLogging]: Master switch for console logging. Defaults to `true` in [kDebugMode]. Set `false` to silence logs.
  /// - [logRebuilds]: Whether to log isolated slot widget rebuilds in the console. Defaults to `false`.
  /// - [logState]: Whether to print full state instances on mutations. Defaults to `false`.
  /// - [logChanges]: Whether to print transition diff snapshots. Defaults to `false`.
  /// - [logDI]: Whether to log DI scope creation and member teardown. Defaults to `true`.
  /// - [logDry]: Whether to log Frame-0 dry persistence hydration and invalidation. Defaults to `true`.
  /// - [logBindings]: Whether to log individual dependency bindings. Defaults to `false`.
  /// - [logErrors]: Whether to log unhandled errors dispatched to [Graft.addError]. Defaults to `true`.
  /// - [enableTimeline]: Whether to emit synchronous timeline trace events to Flutter DevTools Performance view. Defaults to `false`.
  /// - [di]: Optional setup block for registering app-level dependencies via `bind<T>()`.
  static void config({
    GraftDryConfig? dryConfig,
    GraftObserver? observer,
    bool debugLogging = kDebugMode,
    bool logChanges = false,
    bool logRebuilds = false,
    bool logState = false,
    bool logDI = true,
    bool logDry = true,
    bool logBindings = false,
    bool logErrors = true,
    bool enableTimeline = false,
    void Function()? di,
  }) {
    if (dryConfig != null) configurePersistence(dryConfig);

    final customFlagSpecified = logRebuilds ||
        logState ||
        logChanges ||
        !logDI ||
        !logDry ||
        logBindings ||
        !logErrors ||
        enableTimeline;

    final shouldLog = debugLogging || customFlagSpecified;
    final debugObserver = shouldLog
        ? GraftDebugObserver(
            logRebuilds: logRebuilds,
            logState: logState,
            logChanges: logChanges,
            logDI: logDI,
            logDry: logDry,
            logBindings: logBindings,
            logErrors: logErrors,
            enableTimeline: enableTimeline,
          )
        : null;

    if (observer != null && debugObserver != null) {
      _observer = CompositeGraftObserver(observer, debugObserver);
    } else if (observer != null) {
      _observer = observer;
    } else if (debugObserver != null) {
      _observer = debugObserver;
    }

    di?.call();
  }

  final S _state;
  void Function(GraftMask dirtyMask)? _singleMaskListener;
  List<void Function(GraftMask dirtyMask)>? _extraMaskListeners;
  bool _isDisposed = false;
  bool _pendingNotify = false;
  bool _isNotifying = false;

  GraftFastReceiver? _fastDirectReceiver;
  GraftMask _fastDirectMask = GraftMask.empty;
  List<List<GraftItemReceiver?>?>? _receiverDirectory;

  VoidCallback? _singleListener;
  List<VoidCallback>? _extraListeners;
  bool _hasOnlySingle = false;
  bool _hasOnlySingleListener = false;
  bool _hasOnlyFastDirectReceiver = false;
  bool _hasAnyListeners = false;

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
    if (GraftScopeTracker.hasActiveScope) {
      GraftScopeTracker.current?.record(this);
    }
    return _state;
  }

  void _recomputeSingleListenerFlag() =>
      _graftRecomputeSingleListenerFlag(this);

  @override
  @nonVirtual
  bool operator ==(Object other) => identical(this, other);

  @override
  @nonVirtual
  int get hashCode => identityHashCode(this);

  @nonVirtual
  bool get hasListeners =>
      _singleListener != null ||
      (_extraListeners != null && _extraListeners!.isNotEmpty);

  @nonVirtual
  bool get isDisposed => _isDisposed;

  @override
  @nonVirtual
  void addListener(VoidCallback listener) => _graftAddListener(this, listener);

  @override
  @nonVirtual
  void removeListener(VoidCallback listener) =>
      _graftRemoveListener(this, listener);

  @internal
  @nonVirtual
  void addMaskListener(void Function(GraftMask dirtyMask) listener) =>
      _graftAddMaskListener(this, listener);

  @internal
  @nonVirtual
  void removeMaskListener(void Function(GraftMask dirtyMask) listener) =>
      _graftRemoveMaskListener(this, listener);

  @nonVirtual
  void notifyListeners() => _graftNotifyListeners(this);

  @pragma('vm:prefer-inline')
  void _notifyMask(GraftMask dirtyMask, {GraftChange<dynamic>? change}) =>
      _graftNotifyMask(this, dirtyMask, change: change);

  @internal
  @nonVirtual
  void notify({GraftChange<dynamic>? change}) =>
      _graftNotify(this, change: change);

  /// Purges this controller's persisted Frame-0 dry state from L1 RAM and disk.
  @nonVirtual
  void invalidateDry() => state.invalidateDry();

  @protected
  @nonVirtual
  void addError(Object error, [StackTrace? stackTrace]) =>
      observer?.onError(this, error, stackTrace ?? StackTrace.current);

  @mustCallSuper
  void dispose() {
    _graftDispose(this);
  }
}
