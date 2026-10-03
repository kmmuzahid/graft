import 'dart:async';
import 'package:flutter/foundation.dart';
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
/// - **Fluent Mutation:** Update state via `state..field = value..update();`.
/// - **0-Rebuild Slot Diffing:** In `graft.column(...)`, only slots with changed data rebuild.
/// - **Automatic Route Disposal:** Disposed when the screen that created it pops.
///
/// ### Example:
/// ```dart
/// class UserState extends GraftState {
///   String name = '';
///   int age = 0;
/// }
///
/// class UserGraft extends Graft<UserState> {
///   UserGraft() : super(UserState());
///
///   void updateProfile(String name, int age) {
///     state
///       ..name = name
///       ..age = age
///       ..update(); // Batched diffing: fires 1 frame update!
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
  S get state => _state;

  /// Directly assigns a new state instance and notifies listeners.
  ///
  /// ```dart
  /// state = nextState;
  /// ```
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
  ValueListenable<S> get listenable => _notifier;

  /// Whether this [Graft] has been disposed.
  ///
  /// Once disposed, all listeners are released and emissions are ignored.
  bool get isDisposed => _isDisposed;

  /// Adds a [listener] callback to be notified whenever [state] updates.
  ///
  /// Remember to remove the listener using [removeListener] when no longer needed.
  void addListener(VoidCallback listener) {
    if (!_isDisposed) {
      _notifier.addListener(listener);
    }
  }

  /// Removes a previously registered [listener].
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      _notifier.removeListener(listener);
    }
  }

  /// Notifies all listeners and triggers fine-grained slot diffing for [state].
  ///
  /// Typically called automatically by `state..update()` when using [GraftState].
  /// Can also be called directly to force a slot-diff pass.
  void notify() {
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
            notify();
          }
        });
      }
      return;
    }

    _isNotifying = true;
    try {
      final change = GraftChange<S>(
        currentState: _state,
        nextState: _state,
      );

      observer?.onChange(this, change);
      _notifier.forceNotify();
    } finally {
      _isNotifying = false;
    }
  }

  /// Updates the state to [newState] and notifies all listeners.
  ///
  /// - If [newState] is equal to current [state] (via `operator ==`), this is a no-op.
  /// - If this [Graft] is disposed, this operation is ignored.
  @protected
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
    );

    observer?.onChange(this, change);
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
  void addError(Object error, [StackTrace? stackTrace]) {
    observer?.onError(this, error, stackTrace ?? StackTrace.current);
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
    _notifier.dispose();
  }
}
