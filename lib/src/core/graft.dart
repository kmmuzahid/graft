import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft_async.dart';
import 'graft_change.dart';
import 'graft_mask.dart';
import 'graft_observer.dart';
import 'graft_scope_tracker.dart';
import 'graft_state.dart';


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

  late S _state;
  void Function(GraftMask dirtyMask)? _singleMaskListener;
  List<void Function(GraftMask dirtyMask)>? _extraMaskListeners;
  bool _isDisposed = false;
  bool _pendingNotify = false;
  bool _isNotifying = false;
  ValueListenable<S>? _listenableCache;

  /// Creates a new [Graft] with the given [initialState].
  ///
  /// Automatically binds [initialState] to this controller and notifies [observer].
  Graft(S initialState) {
    _state = initialState;
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

  /// Whether this [Graft] has any registered listeners.
  @override
  bool get hasListeners =>
      _singleListener != null ||
      (_extraListeners != null && _extraListeners!.isNotEmpty) ||
      super.hasListeners;

  /// Internal engine check: whether any standard, mask, or ChangeNotifier listeners exist.
  @internal
  bool get hasAnyListeners =>
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
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      if (_singleListener == null) {
        _singleListener = listener;
        return;
      }
      (_extraListeners ??= []).add(listener);
    }
  }

  /// Removes a previously registered [listener].
  @override
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      if (identical(_singleListener, listener)) {
        _singleListener = null;
        if (_extraListeners != null && _extraListeners!.isNotEmpty) {
          _singleListener = _extraListeners!.removeLast();
        }
        return;
      }
      _extraListeners?.remove(listener);
    }
  }

  /// Adds a listener to be notified with an unbounded [GraftMask] whenever tracked fields update.
  @nonVirtual
  void addMaskListener(void Function(GraftMask dirtyMask) listener) {
    if (!_isDisposed) {
      if (_singleMaskListener == null) {
        _singleMaskListener = listener;
        return;
      }
      (_extraMaskListeners ??= []).add(listener);
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
        return;
      }
      _extraMaskListeners?.remove(listener);
    }
  }

  @override
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

  /// Dispatches [dirtyMask] to all mask listeners, then triggers notification.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  @pragma('vm:prefer-inline')
  void notifyMask(GraftMask dirtyMask, {GraftChange<dynamic>? change}) {
    if (_isDisposed) return;
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
              previousProps: _state.baselineSnapshot,
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
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _singleListener = null;
    _extraListeners?.clear();
    _singleMaskListener = null;
    _extraMaskListeners?.clear();
    super.dispose();
    observer?.onDispose(this);
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

