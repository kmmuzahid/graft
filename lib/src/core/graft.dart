import 'dart:async';
import 'package:flutter/foundation.dart';
import 'graft_async.dart';
import 'graft_change.dart';
import 'graft_observer.dart';
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
/// - **Fluent Mutation:** Update state via `state..field = value..update();` or `mutate((s) => s..field = value);`.
/// - **0-Rebuild Slot Diffing:** In `graft.column(...)`, only slots with changed data rebuild.
/// - **Automatic Route Disposal:** Disposed when the screen that created it pops.
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = '';
///   int age = 0;
///
///   @override
///   List<Object?> get tracked => [name, age];
/// }
///
/// class UserGraft extends Graft<UserState> {
///   UserGraft() : super(UserState());
///
///   void updateProfile(String name, int age) {
///     mutate((s) => s
///       ..name = name
///       ..age = age);
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
  final List<void Function(int dirtyMask)> _maskListeners = [];
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
  /// Read properties directly or chain mutations using cascade:
  /// ```dart
  /// state..name = 'Alice'..update();
  /// ```
  @nonVirtual
  S get state => _state;

  /// Directly assigns a new state instance and notifies listeners.
  ///
  /// ```dart
  /// state = nextState;
  /// ```
  @nonVirtual
  set state(S newState) => emit(newState);

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

  /// Adds a listener to be notified with a 64-bit integer [dirtyMask] whenever tracked fields update.
  @nonVirtual
  void addMaskListener(void Function(int dirtyMask) listener) {
    if (!_isDisposed) {
      _maskListeners.add(listener);
    }
  }

  /// Removes a previously registered mask [listener].
  @nonVirtual
  void removeMaskListener(void Function(int dirtyMask) listener) {
    if (!_isDisposed) {
      _maskListeners.remove(listener);
    }
  }

  /// Dispatches [dirtyMask] to all mask listeners, then triggers notification.
  /// Internal engine method: must not be called or overridden by user code.
  @internal
  @nonVirtual
  void notifyMask(int dirtyMask, {GraftChange<S>? change}) {
    if (_isDisposed) return;
    final listeners = List<void Function(int dirtyMask)>.from(_maskListeners);
    for (final listener in listeners) {
      listener(dirtyMask);
    }
    notify(change: change);
  }

  /// Notifies all listeners and triggers fine-grained slot diffing for [state].
  ///
  /// Typically called automatically by `state..update()` when using [GraftState].
  /// Can also be called directly to force a slot-diff pass.
  @nonVirtual
  void notify({GraftChange<S>? change}) {
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
      final effectiveChange = change ??
          GraftChange<S>(
            currentState: _state,
            nextState: _state,
            previousTracked: _state.baselineSnapshot,
            nextTracked: List<Object?>.of(_state.tracked, growable: false),
            dirtyMask: _state.dirtyMask,
          );

      observer?.onChange(this, effectiveChange);
      _notifier.forceNotify();
    } finally {
      _isNotifying = false;
    }
  }

  /// Atomically mutates state using [recipe] and triggers fine-grained slot diffing.
  ///
  /// Combines the zero-boilerplate fluency of cascade syntax (`mutate((s) => s..name = 'Bob');`)
  /// with automated state snapshots for [GraftObserver], audit trails, and time-travel testing.
  @nonVirtual
  void mutate(void Function(S state) recipe) => produce(recipe);

  /// Applies [recipe] mutations to produce a new state snapshot.
  ///
  /// Combines the zero-boilerplate fluency of cascade syntax (`produce((s) => s..name = 'Bob');`)
  /// with automated state snapshots for [GraftObserver], audit trails, and time-travel testing.
  @nonVirtual
  void produce(void Function(S draft) recipe) {
    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Cannot call produce on a disposed Graft ($runtimeType).',
        );
      }
      return;
    }

    final previousTracked = List<Object?>.of(_state.tracked, growable: false);
    final previousState = _state.copy() as S;
    recipe(_state);

    final mask = _state.diffChanges();
    if (mask != 0) {
      final change = GraftChange<S>(
        currentState: previousState,
        nextState: _state,
        previousTracked: previousTracked,
        nextTracked: List<Object?>.of(_state.tracked, growable: false),
        dirtyMask: mask,
      );

      notifyMask(mask, change: change);
    }
  }

  /// Updates the state to [newState] and notifies all listeners.
  ///
  /// - If [newState] is equal to current [state] (via `operator ==`), this is a no-op.
  /// - If this [Graft] is disposed, this operation is ignored.
  @protected
  @nonVirtual
  void emit(S newState) {
    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint(
          'Warning: Cannot emit new state ($newState) on a disposed Graft ($runtimeType).',
        );
      }
      return;
    }

    if (_state == newState) {
      return;
    }

    final previousState = _state;
    _state = newState;
    newState.bindGraft(this);

    final change = GraftChange<S>(
      currentState: previousState,
      nextState: newState,
      previousTracked: List<Object?>.of(previousState.tracked, growable: false),
      nextTracked: List<Object?>.of(newState.tracked, growable: false),
      dirtyMask: -1,
    );

    observer?.onChange(this, change);
    final maskCopy = List<void Function(int)>.from(_maskListeners);
    for (final listener in maskCopy) {
      listener(-1);
    }
    _notifier.value = newState;
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
  ///   onUpdate: (asyncState) => produce((s) => s.user = asyncState),
  /// );
  /// ```
  @nonVirtual
  Future<T?> runAsync<T>({
    required Future<T> Function() task,
    required void Function(GraftAsync<T> result) onUpdate,
  }) async {
    if (_isDisposed) return null;
    onUpdate(const GraftAsync.loading());
    notify();

    try {
      final result = await task();
      if (!_isDisposed) {
        onUpdate(GraftAsync.data(result));
        notify();
      }
      return result;
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        onUpdate(GraftAsync.error(error, stackTrace));
        addError(error, stackTrace);
        notify();
      }
      return null;
    }
  }

  /// Disposes this [Graft], releasing all listeners and internal resources.
  ///
  /// In typical usage, you do not need to call this manually—Graft automatically
  /// disposes route-scoped instances when their owner route is popped.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;

    observer?.onDispose(this);
    _isDisposed = true;
    _maskListeners.clear();
    _notifier.dispose();
  }
}
