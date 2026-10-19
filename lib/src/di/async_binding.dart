/// Automated non-blocking execution gate for asynchronous dependencies.
library;

import 'dart:async';

/// Automated non-blocking execution gate for asynchronous dependencies.
///
/// Transparently buffers callers on Frame 0 before background initialization
/// completes, and returns cached instances instantly (0ns) once ready.
/// Developers write 100% standard Dart methods with zero manual guard() wrappers.
final class AsyncBinding<T> {
  /// The asynchronous factory used to instantiate [T].
  final Future<T> Function() factory;

  /// Whether this instance is cached as a singleton in its owning scope.
  final bool singleton;

  /// Whether this dependency is preserved across screen route pops.
  final bool preserved;

  Future<T>? _future;
  T? _resolvedInstance;
  bool _isCompleted = false;

  /// Creates a new [AsyncBinding] wrapper for [factory].
  AsyncBinding(
    this.factory, {
    this.singleton = true,
    this.preserved = false,
  });

  /// Starts or returns the background initialization Future.
  Future<T> resolve() {
    if (_isCompleted) return Future<T>.value(_resolvedInstance as T);
    if (_future != null) return _future!;

    final completer = Completer<T>();
    _future = completer.future;

    factory().then((instance) {
      if (singleton) {
        _resolvedInstance = instance;
        _isCompleted = true;
      }
      completer.complete(instance);
    }).catchError((Object err, StackTrace stack) {
      _future = null;
      completer.completeError(err, stack);
    });

    return _future!;
  }

  /// Synchronously returns the resolved instance if already completed.
  T? get resolvedInstance => _isCompleted ? _resolvedInstance : null;

  /// Whether the background asynchronous factory has completed.
  bool get isCompleted => _isCompleted;

  /// Resets state when scope is dropped.
  void reset() {
    _future = null;
    _resolvedInstance = null;
    _isCompleted = false;
  }
}
