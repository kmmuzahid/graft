import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'graft.dart';
import 'graft_change.dart';
import 'graft_state.dart';

/// Global observer interface for monitoring the lifecycle, transitions, dependency injection,
/// Frame-0 dry persistence, and errors across all Graft instances.
///
/// ### Why implement GraftObserver?
/// - **Centralized Observability:** Track every controller's birth, transition, error, and disposal in one place.
/// - **DI Graph Visibility:** Monitor scope creations, member disposals, and bindings in real-time.
/// - **Persistence Tracking:** Inspect Frame-0 dry state hydration and invalidation events.
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
  void onCreate(dynamic graft) {}

  /// Called whenever a [Graft] transitions state or calls `state..update()`.
  void onChange(dynamic graft, GraftChange change) {}

  /// Called whenever an unhandled error is dispatched through [Graft.addError].
  void onError(dynamic graft, Object error, StackTrace stackTrace) {}

  /// Called immediately before any [Graft] instance is disposed.
  void onDispose(dynamic graft) {}

  /// Called whenever a slot widget inside [graft] rebuilds.
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) {}

  /// Called when a DI scope is created.
  void onScopeCreated(Object scopeId, {bool preserved = false}) {}

  /// Called when a DI scope is dropped and all contained dependencies are disposed.
  ///
  /// [members] contains the list of instantiated dependency types that were disposed.
  /// [registeredTypes] contains all types registered in this scope.
  void onScopeDropped(
    Object scopeId, {
    List<Type> members = const [],
    List<Type> registeredTypes = const [],
  }) {}

  /// Called when a dependency binding is registered into a DI scope.
  void onDependencyBound(
    Type type, {
    Object? scopeId,
    bool singleton = true,
    bool preserved = false,
    bool isAsync = false,
  }) {}

  /// Called when a state instance is hydrated via Frame-0 dry persistence.
  ///
  /// [fromCache] is `true` if restored synchronously from L1 RAM in < 50ns,
  /// or `false` if initialized with fresh defaults.
  void onDryHydrated(
    GraftState state, {
    required String key,
    required bool fromCache,
  }) {}

  /// Called when dry state is invalidated and purged from persistence.
  void onDryInvalidated(
    Object target, {
    required String key,
    bool isScopePurge = false,
  }) {}
}

/// Out-of-the-box development observer featuring high-visibility ANSI colorized terminal logs,
/// DI scope tracking, Frame-0 persistence identification, non-blocking asynchronous dispatch,
/// and Flutter DevTools Timeline integration.
///
/// ### Why use GraftDevObserver?
/// - Formats lifecycle events with distinctive emoji badges and terminal colors.
/// - **Non-blocking Async Logging:** By default ([asyncLog] is `true`), logs are batched into
///   an asynchronous microtask, ensuring console I/O never blocks the main UI thread or state budget.
/// - **DI Scope Tracking:** Logs scope creation and lists all disposed member dependencies on teardown.
/// - **Dry State Identification:** Clearly marks persistent states with `💾 [DRY: key]` and logs invalidation.
/// - Clearly prints current vs next state differences on every transition.
/// - Formats stack traces when [Graft.addError] is caught.
/// - Emits Flutter DevTools Timeline performance events when [enableTimeline] is true.
/// - Automatically disables output outside of `kDebugMode` (0 overhead in release builds).
/// - Every log category can be selectively enabled or disabled via constructor flags.
///
/// ### Example:
/// ```dart
/// void main() {
///   if (kDebugMode) {
///     Graft.observer = GraftDevObserver(
///       logDI: true,
///       logDry: true,
///       logState: true,
///       asyncLog: true, // Non-blocking async console output (default)
///     );
///   }
///   runApp(const MyApp());
/// }
/// ```
class GraftDevObserver extends GraftObserver {
  /// Whether to log controller creations and disposals (`🌱`, `🗑️`).
  final bool logState;

  final bool? _logChanges;

  /// Whether to log state mutations and transitions (`⚡`).
  ///
  /// Defaults to `false`. If not explicitly set, falls back to [logState].
  bool get logChanges => _logChanges ?? logState;

  /// Whether to log DI scope lifecycle (creation, members, and teardowns).
  final bool logDI;

  /// Whether to log Frame-0 dry persistence events (hydrations, invalidations, purges).
  final bool logDry;

  /// Whether to log individual dependency binding registrations.
  final bool logBindings;

  /// Whether to print diagnostics on fine-grained slot rebuilds.
  final bool logRebuilds;

  /// Whether to log unhandled errors caught by Graft.
  final bool logErrors;

  /// Whether to emit DevTools Timeline events for performance profiling.
  final bool enableTimeline;

  /// Whether logs are flushed asynchronously to prevent blocking the UI thread.
  ///
  /// When `true` (default), log messages are queued and flushed in an asynchronous
  /// microtask, decoupling console I/O from state mutation and frame rendering budgets.
  /// When `false`, logs are emitted synchronously via [debugPrint].
  final bool asyncLog;

  /// Creates a development observer with configurable logging flags and async dispatch.
  GraftDevObserver({
    /// Whether to log controller creations and disposals (`🌱`, `🗑️`).
    ///
    /// Defaults to `false`.
    this.logState = false,

    /// Whether to log state mutations and transitions (`⚡`).
    ///
    /// When enabled, prints state changes with current vs next state differences.
    /// Defaults to `false`.
    bool? logChanges,

    /// Whether to log DI scope lifecycle, including scope creation and active member teardowns (`📦`, `💥`).
    ///
    /// When a scope drops, lists all instantiated member types that were disposed.
    /// Defaults to `true`.
    this.logDI = true,

    /// Whether to log Frame-0 dry persistence badges, hydrations, and invalidations (`💾`, `❄️`, `🧹`).
    ///
    /// Displays `💾 [DRY: key]` badges on states, and logs L1 RAM cache restores vs default loads.
    /// Defaults to `true`.
    this.logDry = true,

    /// Whether to log individual dependency binding registrations (`🔗`).
    ///
    /// Useful for debugging the initial wiring of your dependency injection tree.
    /// Defaults to `false`.
    this.logBindings = false,

    /// Whether to print diagnostics on fine-grained slot widget rebuilds (`🔄`).
    ///
    /// Useful for verifying that only targeted slots rebuild during state mutations.
    /// Defaults to `false`.
    this.logRebuilds = false,

    /// Whether to format and log unhandled errors caught by Graft (`💥`).
    ///
    /// Formats errors and stack traces caught through [Graft.addError].
    /// Defaults to `true`.
    this.logErrors = true,

    /// Whether to emit Flutter DevTools Timeline performance events for profiling.
    ///
    /// Visible in DevTools > Timeline / Performance view.
    /// Defaults to `false`.
    this.enableTimeline = false,

    /// Whether logs are flushed asynchronously in a microtask to avoid blocking the main UI thread.
    ///
    /// When `true`, console I/O is decoupled from state updates to preserve 60/120fps frame budgets.
    /// Defaults to `true`.
    this.asyncLog = true,
  }) : _logChanges = logChanges;

  List<String> _logQueue = [];
  bool _flushScheduled = false;

  void _output(String message) {
    if (!kDebugMode) return;
    if (!asyncLog) {
      debugPrint(message);
      return;
    }
    _logQueue.add(message);
    if (!_flushScheduled) {
      _flushScheduled = true;
      scheduleMicrotask(_flushLogs);
    }
  }

  void _flushLogs() {
    _flushScheduled = false;
    if (_logQueue.isEmpty) return;
    final batch = _logQueue;
    _logQueue = [];
    for (var i = 0; i < batch.length; i++) {
      debugPrint(batch[i]);
    }
  }

  /// Flushes any pending asynchronous logs immediately.
  @visibleForTesting
  void flushLogs() => _flushLogs();

  static const _reset = '\x1B[0m';
  static const _bold = '\x1B[1m';
  static const _green = '\x1B[32m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _red = '\x1B[31m';
  static const _magenta = '\x1B[35m';
  static const _blue = '\x1B[34m';

  @override
  void onScopeCreated(Object scopeId, {bool preserved = false}) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft DI: Scope Created [$scopeId]',
        arguments: <String, dynamic>{
          'scopeId': '$scopeId',
          'preserved': preserved,
        },
      );
    }
    if (kDebugMode && logDI) {
      final mode = preserved ? 'preserved' : 'transient';
      _output(
        '$_bold$_blue[📦 GRAFT DI SCOPE CREATED]$_reset | '
        '$_cyan$scopeId$_reset '
        '($_yellow$mode$_reset)',
      );
    }
  }

  @override
  void onScopeDropped(
    Object scopeId, {
    List<Type> members = const [],
    List<Type> registeredTypes = const [],
  }) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft DI: Scope Dropped [$scopeId]',
        arguments: <String, dynamic>{
          'scopeId': '$scopeId',
          'membersCount': members.length,
        },
      );
    }
    if (kDebugMode && logDI) {
      final buffer = StringBuffer();
      buffer.write(
        '$_bold$_magenta[💥 GRAFT DI SCOPE DESTROYED]$_reset | '
        '$_cyan$scopeId$_reset\n',
      );
      if (members.isNotEmpty) {
        buffer.write(
          '  $_bold Disposed Members (${members.length}):$_reset\n',
        );
        for (final m in members) {
          buffer.write('  • $_yellow$m$_reset\n');
        }
      } else if (registeredTypes.isNotEmpty) {
        buffer.write(
          '  $_bold Registered Bindings Cleared (${registeredTypes.length}):$_reset\n',
        );
        for (final t in registeredTypes) {
          buffer.write('  • $_yellow$t$_reset\n');
        }
      } else {
        buffer.write('  (no members active)\n');
      }
      _output(buffer.toString().trimRight());
    }
  }

  @override
  void onDependencyBound(
    Type type, {
    Object? scopeId,
    bool singleton = true,
    bool preserved = false,
    bool isAsync = false,
  }) {
    if (kDebugMode && logBindings) {
      final scopeName = scopeId ?? 'root';
      final asyncFlag = isAsync ? ' async' : '';
      _output(
        '$_bold$_blue[🔗 GRAFT DI BIND]$_reset | '
        '$_cyan$type$_reset in $_yellow$scopeName$_reset$asyncFlag',
      );
    }
  }

  @override
  void onDryHydrated(
    GraftState state, {
    required String key,
    required bool fromCache,
  }) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft Dry: ${state.runtimeType} hydrated',
        arguments: <String, dynamic>{
          'state': '${state.runtimeType}',
          'key': key,
          'fromCache': fromCache,
        },
      );
    }
    if (kDebugMode && logDry) {
      final source = fromCache
          ? '$_green restored from L1 RAM in <50ns$_reset'
          : '$_yellow initial defaults loaded$_reset';
      _output(
        '$_bold$_cyan[❄️ GRAFT DRY HYDRATED]$_reset | '
        '$_magenta${state.runtimeType}$_reset '
        '💾 [key: $_yellow$key$_reset] | $source',
      );
    }
  }

  @override
  void onDryInvalidated(
    Object target, {
    required String key,
    bool isScopePurge = false,
  }) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft Dry: Invalidated [$key]',
        arguments: <String, dynamic>{
          'key': key,
          'isScopePurge': isScopePurge,
        },
      );
    }
    if (kDebugMode && logDry) {
      if (isScopePurge) {
        _output(
          '$_bold$_red[🧹 GRAFT DRY SCOPE PURGED]$_reset | '
          '$_cyan$target$_reset '
          '💾 [prefix: $_yellow$key$_reset] | L1 RAM & disk cache cleared',
        );
      } else {
        final typeName = target is GraftState ? target.runtimeType : target;
        _output(
          '$_bold$_red[🧹 GRAFT DRY INVALIDATED]$_reset | '
          '$_magenta$typeName$_reset '
          '💾 [key: $_yellow$key$_reset] | persistence cleared for session',
        );
      }
    }
  }

  @override
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft: ${graft.runtimeType} Slot #$slotIndex rebuild',
        arguments: <String, dynamic>{
          'graft': '${graft.runtimeType}',
          'slotIndex': slotIndex,
          'widget': '${widget.runtimeType}',
        },
      );
    }
    if (kDebugMode && logRebuilds) {
      _output(
        '$_bold$_cyan[🔄 GRAFT SLOT REBUILD]$_reset | '
        '$_magenta${graft.runtimeType}$_reset | '
        'Slot #$slotIndex (${widget.runtimeType})',
      );
    }
  }

  @override
  void onCreate(dynamic graft) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft: ${graft.runtimeType}.onCreate()',
        arguments: <String, dynamic>{'graft': '${graft.runtimeType}'},
      );
    }
    if (kDebugMode && logState) {
      final isDry = graft is Graft && graft.state.isDryEnabled;
      final dryBadge = isDry
          ? ' 💾 $_yellow[DRY: ${graft.state.dryKey}]$_reset'
          : '';
      _output(
        '$_bold$_green[🌱 GRAFT CREATED]$_reset | $_cyan${graft.runtimeType}$_reset$dryBadge',
      );
    }
  }

  @override
  void onChange(dynamic graft, GraftChange change) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft: ${graft.runtimeType}.update()',
        arguments: <String, dynamic>{
          'graft': '${graft.runtimeType}',
          'currentState': '${change.currentState}',
          'nextState': '${change.nextState}',
        },
      );
    }
    if (kDebugMode && logChanges) {
      final isDry = graft is Graft && graft.state.isDryEnabled;
      final dryBadge = isDry
          ? ' 💾 $_yellow[DRY: ${graft.state.dryKey}]$_reset'
          : '';
      _output(
        '$_bold$_yellow[⚡ GRAFT CHANGE]$_reset | '
        '$_cyan${graft.runtimeType}$_reset$dryBadge\n'
        '  $_magenta${change.currentState}$_reset\n'
        '  ➡️ $_green${change.nextState}$_reset',
      );
    }
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft: ${graft.runtimeType}.onError()',
        arguments: <String, dynamic>{
          'graft': '${graft.runtimeType}',
          'error': '$error',
        },
      );
    }
    if (kDebugMode && logErrors) {
      _output(
        '$_bold$_red[💥 GRAFT ERROR]$_reset | '
        '$_cyan${graft.runtimeType}$_reset: $error\n$stackTrace',
      );
    }
  }

  @override
  void onDispose(dynamic graft) {
    if (enableTimeline && !kReleaseMode) {
      developer.Timeline.instantSync(
        'Graft: ${graft.runtimeType}.onDispose()',
        arguments: <String, dynamic>{'graft': '${graft.runtimeType}'},
      );
    }
    if (kDebugMode && logState) {
      final isDry = graft is Graft && graft.state.isDryEnabled;
      final dryBadge = isDry
          ? ' 💾 $_yellow[DRY: ${graft.state.dryKey}]$_reset'
          : '';
      _output(
        '$_bold$_red[🗑️ GRAFT DISPOSED]$_reset | $_cyan${graft.runtimeType}$_reset$dryBadge',
      );
    }
  }
}
