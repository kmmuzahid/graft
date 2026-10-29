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

/// Base class for reactive state management with fine-grained slot isolation.
///
/// A [Graft] manages domain state of type [S], which must extend [GraftState].
/// It connects business logic to Flutter UI with automatic 0-rebuild slot diffing.
///
/// ### Why use Graft?
/// - **Zero Boilerplate:** No `copyWith()`, no `Equatable`, no `build_runner`.
/// - **Fluent Mutation:** Update state via `state..field = value..update();`.
/// - **0-Rebuild Slot Diffing:** In `graft.slots(...)`, only slots with changed data rebuild.
/// - **Automatic Route Disposal:** Disposed when the screen that created it pops.
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = '';
///   int age = 0;
///
///   @override
///   GraftProps get props => propsOf(name, age);
/// }
///
/// class UserGraft extends Graft<UserState> {
///   UserGraft() : super(UserState());
///
///   void updateProfile(String name, int age) {
///     state
///       ..name = name
///       ..age = age
///       ..update();
///   }
/// }
/// ```
class Graft<S extends GraftState> extends ChangeNotifier {
  /// Global observer for monitoring lifecycle transitions and errors across all [Graft] instances.
  ///
  /// Set this in `main()` to log transitions or report errors to analytics:
  /// ```dart
  /// void main() {
  ///   Graft.observer = GraftDevObserver(); // Colorized terminal logs
  ///   runApp(const MyApp());
  /// }
  /// ```
  static GraftObserver? observer;

  /// Optional application entry point in main():
  /// Only needed if you want custom [config] or custom [setup].
  /// If omitted, Graft automatically boots with default file storage lazily on first access.
  /// 100% synchronous (0-await!) — background storage I/O is handled self-healingly by the engine.
  static void init({
    GraftStateConfig? config,
    void Function()? setup,
  }) {
    if (config != null) {
      configurePersistence(config);
    }
    setup?.call();
  }

  late S _state;
  void Function(GraftMask dirtyMask)? _singleMaskListener;
  List<void Function(GraftMask dirtyMask)>? _extraMaskListeners;
  bool _isDisposed = false;
  bool _pendingNotify = false;
  bool _isNotifying = false;
  ValueListenable<S>? _listenableCache;

  GraftFastReceiver? _fastDirectReceiver;
  GraftMask _fastDirectMask = GraftMask.empty;
  Map<int, GraftItemReceiver>? _indexedItemReceivers;

  void _registerItemReceiver(int index, GraftItemReceiver receiver) {
    _indexedItemReceivers ??= <int, GraftItemReceiver>{};
    _indexedItemReceivers![index] = receiver;
  }

  void _unregisterItemReceiver(int index, GraftItemReceiver receiver) {
    final map = _indexedItemReceivers;
    if (map != null) {
      if (identical(map[index], receiver)) {
        map.remove(index);
      }
    }
  }

  @pragma('vm:prefer-inline')
  bool _hasItemReceiver(int index) =>
      _indexedItemReceivers?.containsKey(index) ?? false;

  @pragma('vm:prefer-inline')
  void _notifyItem(int index) {
    if (_isDisposed) return;
    final r = _indexedItemReceivers?[index];
    if (r != null && r.mounted) {
      r.markItemDirty();
      final single = _singleListener;
      if (single != null) {
        single();
        final extra = _extraListeners;
        if (extra != null && extra.isNotEmpty) {
          final eLen = extra.length;
          for (int i = 0; i < eLen; i++) {
            extra[i]();
          }
        }
      }
      return;
    }
    _notifyMask(GraftMask.bit0);
  }

  /// Mutates state and notifies the item receiver at [index] directly in O(1) time.
  @nonVirtual
  void updateItem(int index, [void Function()? mutate]) {
    mutate?.call();
    state.update(itemIndex: index);
  }

  /// Creates a new [Graft] with the given [initialState].
  ///
  /// Automatically binds [initialState] to this controller, restores Frame-0
  /// dry state if enabled, invokes [onInit], and notifies [observer].
  Graft(S initialState) {
    _state = initialState;
    GraftStateEngine.bind(initialState, this);
    onInit();
    observer?.onCreate(this);
  }

  /// Creates a new [Graft] with Frame-0 dry state hydration using constructor tear-off [stateFactory].
  ///
  /// Restores persisted properties from L1 RAM in < 50ns directly into constructor arguments.
  /// Eliminates all [GraftState.onHydrate], `read()`, and magic strings completely!
  ///
  /// ### Example:
  /// ```dart
  /// class CheckoutGraft extends Graft<CheckoutState> {
  ///   CheckoutGraft() : super.dry(CheckoutState.new);
  /// }
  /// ```
  Graft.dry(
    Function stateFactory, {
    String? key,
  }) {
    final dryKey = key ?? (Function.apply(stateFactory, const []) as S).dryKey;
    final (state, fromCache) =
        DryStateHook.hydrateFactoryWithStatus<S>(stateFactory, dryKey);
    _state = state;
    GraftStateEngine.setCustomDryKey(_state, key);
    GraftStateEngine.bind(_state, this);
    DryStateHook.enableDryForState(_state, dryKey);
    observer?.onDryHydrated(_state, key: dryKey, fromCache: fromCache);
    onInit();
    observer?.onCreate(this);
  }

  /// Called immediately after state binding and Frame-0 dry hydration.
  ///
  /// Override this to initialize controllers from hydrated state or setup listeners:
  /// ```dart
  /// @override
  /// void onInit() {
  ///   super.onInit();
  ///   nameController.text = state.customerName; // Restored on Frame 0!
  /// }
  /// ```
  @protected
  @mustCallSuper
  void onInit() {}

  /// Called when this [Graft] instance is being disposed.
  ///
  /// Override this to dispose text editing controllers or cancel timers:
  /// ```dart
  /// @override
  /// void onDispose() {
  ///   nameController.dispose();
  ///   super.onDispose();
  /// }
  /// ```
  @protected
  @mustCallSuper
  void onDispose() {}

  /// The current state snapshot of this [Graft].
  ///
  /// Automatically records dependency when accessed inside a `GraftBoundary.builder`.
  /// Read properties directly or chain mutations using cascade:
  /// ```dart
  /// state..name = 'Alice'..update();
  /// ```
  @nonVirtual
  @pragma('vm:prefer-inline')
  S get state {
    if (GraftScopeTracker.hasActiveScope) {
      GraftScopeTracker.current?.record(this);
    }
    return _state;
  }

  /// A [ValueListenable] representation of this [Graft]'s state.
  ///
  /// Useful for interop with Flutter's standard `ValueListenableBuilder`:
  /// ```dart
  /// ValueListenableBuilder(
  ///   valueListenable: graft.listenable,
  ///   builder: (context, state, _) => Text(state.name),
  /// )
  /// ```
  @nonVirtual
  ValueListenable<S> get listenable =>
      _listenableCache ??= _GraftListenable<S>(this);

  VoidCallback? _singleListener;
  List<VoidCallback>? _extraListeners;
  bool _hasOnlySingle = false;
  bool _hasOnlySingleListener = false;
  bool _hasOnlyFastDirectReceiver = false;

  void _recomputeSingleListenerFlag() {
    _hasOnlySingle = _singleListener != null &&
        (_extraListeners == null || _extraListeners!.isEmpty) &&
        _singleMaskListener == null;
    _hasOnlySingleListener =
        _hasOnlySingle && _fastDirectReceiver == null && observer == null;
    _hasOnlyFastDirectReceiver = _fastDirectReceiver != null &&
        (_extraMaskListeners == null || _extraMaskListeners!.isEmpty) &&
        _singleListener == null &&
        observer == null;
  }

  @override
  @nonVirtual
  bool operator ==(Object other) => identical(this, other);

  @override
  @nonVirtual
  int get hashCode => identityHashCode(this);

  /// Whether this [Graft] has any registered listeners.
  @override
  @nonVirtual
  bool get hasListeners =>
      _singleListener != null ||
      (_extraListeners != null && _extraListeners!.isNotEmpty) ||
      super.hasListeners;

  bool get _hasAnyListeners =>
      _singleListener != null ||
      _singleMaskListener != null ||
      (_extraListeners != null && _extraListeners!.isNotEmpty) ||
      (_extraMaskListeners != null && _extraMaskListeners!.isNotEmpty) ||
      super.hasListeners;

  /// Whether this [Graft] has been disposed.
  ///
  /// Once disposed, all listeners are released and emissions are ignored.
  @nonVirtual
  bool get isDisposed => _isDisposed;

  /// Adds a [listener] callback to be notified whenever [state] updates.
  ///
  /// Remember to remove the listener using [removeListener] when no longer needed.
  @override
  @nonVirtual
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      if (_singleListener == null) {
        _singleListener = listener;
        _recomputeSingleListenerFlag();
        return;
      }
      (_extraListeners ??= []).add(listener);
      _hasOnlySingle = false;
      _recomputeSingleListenerFlag();
    }
  }

  /// Removes a previously registered [listener].
  @override
  @nonVirtual
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      if (identical(_singleListener, listener)) {
        _singleListener = null;
        if (_extraListeners != null && _extraListeners!.isNotEmpty) {
          _singleListener = _extraListeners!.removeLast();
        }
        _recomputeSingleListenerFlag();
        return;
      }
      _extraListeners?.remove(listener);
      _recomputeSingleListenerFlag();
    }
  }

  /// Adds a listener to be notified with an unbounded [GraftMask] whenever tracked fields update.
  @nonVirtual
  void addMaskListener(void Function(GraftMask dirtyMask) listener) {
    if (!_isDisposed) {
      if (_singleMaskListener == null) {
        _singleMaskListener = listener;
        _recomputeSingleListenerFlag();
        return;
      }
      (_extraMaskListeners ??= []).add(listener);
      _fastDirectReceiver = null;
      _fastDirectMask = GraftMask.empty;
      _recomputeSingleListenerFlag();
    }
  }

  /// Removes a previously registered mask [listener].
  @nonVirtual
  void removeMaskListener(void Function(GraftMask dirtyMask) listener) {
    if (!_isDisposed) {
      if (identical(_singleMaskListener, listener)) {
        _singleMaskListener = null;
        if (_extraMaskListeners != null && _extraMaskListeners!.isNotEmpty) {
          _singleMaskListener = _extraMaskListeners!.removeLast();
        }
        _recomputeSingleListenerFlag();
        return;
      }
      _extraMaskListeners?.remove(listener);
      _recomputeSingleListenerFlag();
    }
  }

  @override
  @nonVirtual
  void notifyListeners() {
    if (_isDisposed) return;
    final single = _singleListener;
    if (single != null) {
      single();
      final extra = _extraListeners;
      if (extra != null && extra.isNotEmpty) {
        final len = extra.length;
        for (int i = 0; i < len; i++) {
          extra[i]();
        }
      }
    }
  }

  @pragma('vm:prefer-inline')
  void _notifyMask(GraftMask dirtyMask, {GraftChange<dynamic>? change}) {
    if (_isDisposed) return;

    // ⚡ 0-cycle fast return if no listeners whatsoever (Scenario D1, D2, C3)
    if (_singleListener == null &&
        _singleMaskListener == null &&
        _fastDirectReceiver == null &&
        observer == null) {
      return;
    }

    // ⚡ Fast direct single VoidCallback listener (Scenario A1, A2, A3, A4, B)
    final single = _singleListener;
    if (single != null &&
        observer == null &&
        _extraListeners == null &&
        _singleMaskListener == null &&
        _fastDirectReceiver == null) {
      single();
      return;
    }

    // ⚡ Ultra-fast direct element path (Scenario B1, B2, A1 with leaf slots).
    if (_hasOnlyFastDirectReceiver) {
      final fe = _fastDirectReceiver!;
      if (fe.mounted) {
        fe.markFastDirty();
        return;
      }
      _fastDirectReceiver = null;
      _fastDirectMask = GraftMask.empty;
    }

    if (single != null &&
        _fastDirectReceiver == null &&
        observer == null &&
        _singleMaskListener == null) {
      single();
      final extra = _extraListeners;
      if (extra != null && extra.isNotEmpty) {
        final len = extra.length;
        for (int i = 0; i < len; i++) {
          extra[i]();
        }
      }
      return;
    }

    final sml = _singleMaskListener;
    if (sml != null) {
      sml(dirtyMask);
      final eml = _extraMaskListeners;
      if (eml != null && eml.isNotEmpty) {
        final mLen = eml.length;
        for (int i = 0; i < mLen; i++) {
          eml[i](dirtyMask);
        }
      }
    }
    final fallbackSingle = _singleListener;
    if (fallbackSingle != null) {
      fallbackSingle();
      final extra = _extraListeners;
      if (extra != null && extra.isNotEmpty) {
        final eLen = extra.length;
        for (int i = 0; i < eLen; i++) {
          extra[i]();
        }
      }
    }
    if (observer != null) {
      final effectiveChange = change ??
          GraftChange<S>(
            currentState: _state,
            nextState: _state,
            previousProps: GraftStateEngine.baselineSnapshot(_state),
            nextProps: List<Object?>.of(_state.props, growable: false),
            dirtyMask: dirtyMask,
          );
      observer?.onChange(this, effectiveChange);
    }
  }

  /// Notifies all listeners and triggers fine-grained slot diffing for [state].
  ///
  /// Typically called automatically by `state..update()` when using [GraftState].
  /// Can also be called directly to force a slot-diff pass.
  @nonVirtual
  void notify({GraftChange<dynamic>? change}) {
    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Cannot notify on a disposed Graft ($runtimeType).',
        );
      }
      return;
    }

    if (_isNotifying) {
      if (!_pendingNotify) {
        _pendingNotify = true;
        scheduleMicrotask(() {
          _pendingNotify = false;
          if (!_isDisposed) {
            notify(change: change);
          }
        });
      }
      return;
    }

    _isNotifying = true;
    try {
      final sml = _singleMaskListener;
      if (sml != null) {
        sml(GraftMask.allDirty);
        final eml = _extraMaskListeners;
        if (eml != null && eml.isNotEmpty) {
          final len = eml.length;
          for (int i = 0; i < len; i++) {
            eml[i](GraftMask.allDirty);
          }
        }
      }
      if (observer != null) {
        final effectiveChange = change ??
            GraftChange<S>(
              currentState: _state,
              nextState: _state,
              previousProps: GraftStateEngine.baselineSnapshot(_state),
              nextProps: List<Object?>.of(_state.props, growable: false),
              dirtyMask: _state.dirtyMask,
            );
        observer?.onChange(this, effectiveChange);
      }
      if (hasListeners) {
        notifyListeners();
      }
    } finally {
      _isNotifying = false;
    }
  }

  /// Mutates [state] in-place via [action] and automatically triggers diffing and UI notification.
  ///
  /// This is an optional alternative to native Dart cascades (`state..field = val..update()`).
  ///
  /// ```dart
  /// graft.mutate((s) {
  ///   s.name = 'Alice';
  ///   s.score += 10;
  /// });
  /// ```
  @nonVirtual
  S mutate(void Function(S state) action) {
    action(_state);
    _state.update();
    return _state;
  }

  /// Resets this Graft's state and notifies all listeners synchronously.
  @nonVirtual
  void reset() {
    if (_isDisposed) return;
    _state.reset();
  }

  /// Reports an unhandled error to the global [observer].
  ///
  /// Useful in `try/catch` blocks:
  /// ```dart
  /// try {
  ///   await api.fetch();
  /// } catch (e, st) {
  ///   addError(e, st);
  /// }
  /// ```
  @protected
  @nonVirtual
  void addError(Object error, [StackTrace? stackTrace]) {
    observer?.onError(this, error, stackTrace ?? StackTrace.current);
  }

  int _currentAsyncTaskId = 0;

  /// Executes an asynchronous [task], managing loading and error state transitions via [onUpdate].
  ///
  /// Transparently discards stale in-flight responses if a newer task is started before this one completes,
  /// preventing out-of-order state overwrites during rapid user interactions.
  ///
  /// ### Example:
  /// ```dart
  /// await runAsync<User>(
  ///   task: () => api.fetchUser(),
  ///   onUpdate: (asyncState) => state..user = asyncState..update(),
  /// );
  /// ```
  @nonVirtual
  Future<T?> runAsync<T>({
    required Future<T> Function() task,
    required void Function(GraftAsync<T> result) onUpdate,
  }) async {
    if (_isDisposed) return null;
    final taskId = ++_currentAsyncTaskId;
    var notified = false;
    void trackingListener() => notified = true;
    addListener(trackingListener);

    try {
      onUpdate(const GraftAsync.loading());
      if (!notified) notify();
      notified = false;

      final result = await task();
      // 🛡️ RACE CONDITION GUARD: Discard stale response if a newer task was launched
      if (!_isDisposed && taskId == _currentAsyncTaskId) {
        onUpdate(GraftAsync.data(result));
        if (!notified) notify();
        return result;
      }
      return null;
    } catch (e, st) {
      if (!_isDisposed && taskId == _currentAsyncTaskId) {
        onUpdate(GraftAsync.error(e, st));
        if (!notified) notify();
        addError(e, st);
      }
      return null;
    } finally {
      removeListener(trackingListener);
    }
  }

  /// Disposes this [Graft], releasing all listeners and notifying [observer].
  ///
  /// Subclasses should override this method to close streams, timers, or controllers:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _timer.cancel();
  ///   super.dispose();
  /// }
  /// ```
  @mustCallSuper
  @override
  void dispose() {
    if (_isDisposed) return;
    onDispose();
    _isDisposed = true;
    _singleListener = null;
    _extraListeners?.clear();
    _hasOnlySingle = false;
    _singleMaskListener = null;
    _extraMaskListeners?.clear();
    _fastDirectReceiver = null;
    _fastDirectMask = GraftMask.empty;
    super.dispose();
    observer?.onDispose(this);
  }
}

/// Persistence extensions on [Graft].
extension GraftPersistenceX<S extends GraftState> on Graft<S> {
  /// Permanently deactivates and invalidates dry state persistence for this session.
  void invalidateDry() => state.invalidateDry();
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

/// Internal interface for zero-overhead direct element notification.
///
/// Implemented by slot elements to allow [GraftEngine.notifyMask] to directly mark
/// the element dirty in Flutter's pipeline without invoking closure listener chains.
@internal
abstract interface class GraftFastReceiver {
  /// Whether the receiver element is currently mounted in the widget tree.
  bool get mounted;

  /// Directly marks the element dirty for rebuilding in Flutter's build pass.
  void markFastDirty();
}

/// Internal interface for zero-overhead index-addressed item slot notification.
@internal
abstract interface class GraftItemReceiver {
  /// Whether the receiver element is currently mounted in the widget tree.
  bool get mounted;

  /// Directly marks the item slot dirty for rebuilding in Flutter's build pass.
  void markItemDirty();
}

/// Internal engine accessor for [Graft].
/// Internal to package:graft; never exported in public API.
@internal
abstract final class GraftEngine {
  /// Gets the registered fast direct receiver for [graft].
  static GraftFastReceiver? getFastDirectReceiver(Graft graft) =>
      graft._fastDirectReceiver;

  /// Sets the fast direct receiver for [graft].
  static void setFastDirectReceiver(Graft graft, GraftFastReceiver? r) =>
      graft._fastDirectReceiver = r;

  /// Gets the dirty mask under which fast direct receiver applies.
  static GraftMask getFastDirectMask(Graft graft) => graft._fastDirectMask;

  /// Sets the dirty mask under which fast direct receiver applies.
  static void setFastDirectMask(Graft graft, GraftMask mask) =>
      graft._fastDirectMask = mask;

  /// Registers an index-addressed item receiver.
  static void registerItemReceiver(
          Graft graft, int index, GraftItemReceiver receiver) =>
      graft._registerItemReceiver(index, receiver);

  /// Unregisters an index-addressed item receiver.
  static void unregisterItemReceiver(
          Graft graft, int index, GraftItemReceiver receiver) =>
      graft._unregisterItemReceiver(index, receiver);

  /// Checks if an item receiver is registered at [index].
  static bool hasItemReceiver(Graft graft, int index) =>
      graft._hasItemReceiver(index);

  /// Dispatches an update directly to the item slot at [index].
  static void notifyItem(Graft graft, int index) => graft._notifyItem(index);

  /// Dispatches [mask] to all mask listeners on [graft].
  static void notifyMask(Graft graft, GraftMask mask,
          {GraftChange<dynamic>? change}) =>
      graft._notifyMask(mask, change: change);

  /// Whether any listeners exist on [graft].
  static bool hasAnyListeners(Graft graft) => graft._hasAnyListeners;

  /// The single listener callback on [graft].
  static VoidCallback? singleListener(Graft graft) => graft._singleListener;

  /// Whether [graft] has only a single VoidCallback listener.
  static bool hasOnlySingleListener(Graft graft) =>
      graft._hasOnlySingleListener;

  /// Whether [graft] has only a fast direct receiver.
  static bool hasOnlyFastDirectReceiver(Graft graft) =>
      graft._hasOnlyFastDirectReceiver;
}
