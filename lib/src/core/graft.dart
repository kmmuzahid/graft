import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft_async.dart';
import 'graft_change.dart';
import 'graft_mask.dart';
import 'graft_observer.dart';
import 'graft_scope_tracker.dart';
import 'graft_state.dart';

/// Internal notifier that allows forcing notifications even when mutating state in-place.
class _GraftNotifier<T> extends ValueNotifier<T> {
  _GraftNotifier(super.value);

  void forceNotify() {
    notifyListeners();
  }
}

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
///   List<Object?> get props => [name, age];
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
abstract class Graft<S extends GraftState> {
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

  late S _state;
  late final _GraftNotifier<S> _notifier;
  final List<void Function(GraftMask dirtyMask)> _maskListeners = [];
  bool _isDisposed = false;
  bool _pendingNotify = false;
  bool _isNotifying = false;

  /// Creates a new [Graft] with the given [initialState].
  ///
  /// Automatically binds [initialState] to this controller and notifies [observer].
  Graft(S initialState) {
    _state = initialState;
    _notifier = _GraftNotifier<S>(initialState);
    initialState.bindGraft(this);
    observer?.onCreate(this);
  }

  /// The current state snapshot of this [Graft].
  ///
  /// Automatically records dependency when accessed inside a `GraftBoundary.builder`.
  /// Read properties directly or chain mutations using cascade:
  /// ```dart
  /// state..name = 'Alice'..update();
  /// ```
  @nonVirtual
  S get state {
    GraftScopeTracker.current?.record(this);
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
  ValueListenable<S> get listenable => _notifier;

  /// Whether this [Graft] has been disposed.
  ///
  /// Once disposed, all listeners are released and emissions are ignored.
  @nonVirtual
  bool get isDisposed => _isDisposed;

  /// Adds a [listener] callback to be notified whenever [state] updates.
  ///
  /// Remember to remove the listener using [removeListener] when no longer needed.
  @nonVirtual
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      _notifier.addListener(listener);
    }
  }

  /// Removes a previously registered [listener].
  @nonVirtual
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      _notifier.removeListener(listener);
    }
  }

  /// Adds a listener to be notified with an unbounded [GraftMask] whenever tracked fields update.
  @nonVirtual
  void addMaskListener(void Function(GraftMask dirtyMask) listener) {
    if (!_isDisposed) {
      _maskListeners.add(listener);
    }
  }

  /// Removes a previously registered mask [listener].
  @nonVirtual
  void removeMaskListener(void Function(GraftMask dirtyMask) listener) {
    if (!_isDisposed) {
      _maskListeners.remove(listener);
    }
  }

  /// Dispatches [dirtyMask] to all mask listeners, then triggers notification.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  @pragma('vm:prefer-inline')
  void notifyMask(GraftMask dirtyMask, {GraftChange<dynamic>? change}) {
    if (_isDisposed) return;
    if (_maskListeners.isNotEmpty) {
      final len = _maskListeners.length;
      for (int i = 0; i < len; i++) {
        if (i < _maskListeners.length) {
          _maskListeners[i](dirtyMask);
        }
      }
    }
    if (observer != null) {
      final effectiveChange = change ??
          GraftChange<S>(
            currentState: _state,
            nextState: _state,
            previousProps: _state.baselineSnapshot,
            nextProps: List<Object?>.of(_state.props, growable: false),
            dirtyMask: dirtyMask,
          );
      observer?.onChange(this, effectiveChange);
    }
    if (_notifier.hasListeners) {
      _notifier.forceNotify();
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
      if (_maskListeners.isNotEmpty) {
        final len = _maskListeners.length;
        for (int i = 0; i < len; i++) {
          if (i < _maskListeners.length) {
            _maskListeners[i](GraftMask.allDirty);
          }
        }
      }
      if (observer != null) {
        final effectiveChange = change ??
            GraftChange<S>(
              currentState: _state,
              nextState: _state,
              previousProps: _state.baselineSnapshot,
              nextProps: List<Object?>.of(_state.props, growable: false),
              dirtyMask: _state.dirtyMask,
            );
        observer?.onChange(this, effectiveChange);
      }
      if (_notifier.hasListeners) {
        _notifier.forceNotify();
      }
    } finally {
      _isNotifying = false;
    }
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

  /// Executes an asynchronous [task], managing loading and error state transitions via [onUpdate].
  ///
  /// ### Example:
  /// ```dart
  /// await runAsync<User>(
  ///   task: () => api.fetchUser(),
  ///   onUpdate: (asyncState) => state..user = asyncState..update(),
  /// );
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
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _maskListeners.clear();
    _notifier.dispose();
    observer?.onDispose(this);
  }
}
