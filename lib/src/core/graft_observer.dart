import 'package:flutter/foundation.dart';
import 'graft.dart';
import 'graft_change.dart';

/// Global observer interface for monitoring the lifecycle, transitions, and errors
/// across all [Graft] instances.
///
/// ### Why implement GraftObserver?
/// - **Centralized Observability:** Track every controller's birth, transition, error, and disposal in one place.
/// - **Production Diagnostics:** Send errors to Sentry, Crashlytics, or Datadog without littering UI code with try/catches.
/// - **Developer Experience:** Use prebuilt [GraftDevObserver] during development for ANSI colorized console logs.
///
/// ### Setup:
/// Attach your observer at app startup in `main()`:
/// ```dart
/// void main() {
///   Graft.observer = GraftDevObserver(); // or your custom AppObserver()
///   runApp(const MyApp());
/// }
/// ```
abstract class GraftObserver {
  /// Called immediately when any [Graft] instance is created.
  ///
  /// Useful for performance profiling, dependency auditing, or logging initialization.
  ///
  /// ### Example:
  /// ```dart
  /// @override
  /// void onCreate(dynamic graft) {
  ///   print('Created: ${graft.runtimeType}');
  /// }
  /// ```
  void onCreate(dynamic graft) {}

  /// Called whenever a [Graft] transitions state or calls `state..update()`.
  ///
  /// Contains the [change] with both the previous and next states.
  ///
  /// ### Example:
  /// ```dart
  /// @override
  /// void onChange(dynamic graft, GraftChange change) {
  ///   print('${graft.runtimeType} changed to ${change.nextState}');
  /// }
  /// ```
  void onChange(dynamic graft, GraftChange change) {}

  /// Called whenever an unhandled error is dispatched through [Graft.addError].
  ///
  /// Connect this method to error reporting services (Firebase Crashlytics, Sentry, Datadog).
  ///
  /// ### Example:
  /// ```dart
  /// @override
  /// void onError(dynamic graft, Object error, StackTrace stackTrace) {
  ///   FirebaseCrashlytics.instance.recordError(error, stackTrace);
  /// }
  /// ```
  void onError(dynamic graft, Object error, StackTrace stackTrace) {}

  /// Called immediately before any [Graft] instance is disposed.
  ///
  /// Useful for verifying that route-scoped instances are properly freed and
  /// detecting potential memory leaks.
  ///
  /// ### Example:
  /// ```dart
  /// @override
  /// void onDispose(dynamic graft) {
  ///   print('Disposed: ${graft.runtimeType}');
  /// }
  /// ```
  void onDispose(dynamic graft) {}
}

/// Out-of-the-box development observer featuring high-visibility ANSI colorized terminal logs.
///
/// ### Why use GraftDevObserver?
/// - Formats lifecycle events with distinctive emoji badges and terminal colors.
/// - Clearly prints current vs next state differences on every transition.
/// - Formats stack traces when [Graft.addError] is caught.
/// - Automatically disables output outside of `kDebugMode` (0 overhead in release builds).
///
/// ### Example:
/// ```dart
/// void main() {
///   if (kDebugMode) {
///     Graft.observer = GraftDevObserver();
///   }
///   runApp(const MyApp());
/// }
/// ```
class GraftDevObserver extends GraftObserver {
  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _green = '\x1B[32m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _magenta = '\x1B[35m';

  @override
  void onCreate(dynamic graft) {
    if (kDebugMode) {
      debugPrint(
        '$_bold$_green[🌱 GRAFT CREATED]$_reset | $_cyan${graft.runtimeType}$_reset',
      );
    }
  }

  @override
  void onChange(dynamic graft, GraftChange change) {
    if (kDebugMode) {
      debugPrint(
        '$_bold$_yellow[⚡ GRAFT CHANGE]$_reset | '
        '$_cyan${graft.runtimeType}$_reset\n'
        '  $_magenta${change.currentState}$_reset\n'
        '  ➡️ $_green${change.nextState}$_reset',
      );
    }
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint(
        '$_bold$_red[💥 GRAFT ERROR]$_reset | '
        '$_cyan${graft.runtimeType}$_reset: $error\n$stackTrace',
      );
    }
  }

  @override
  void onDispose(dynamic graft) {
    if (kDebugMode) {
      debugPrint(
        '$_bold$_red[🗑️ GRAFT DISPOSED]$_reset | $_cyan${graft.runtimeType}$_reset',
      );
    }
  }
}

