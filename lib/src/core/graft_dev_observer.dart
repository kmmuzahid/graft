part of 'graft_observer.dart';

/// Out-of-the-box development observer featuring high-visibility ANSI colorized terminal logs.
class GraftDevObserver extends GraftObserver {
  final bool logState;
  final bool? _logChanges;

  bool get logChanges => _logChanges ?? logState;
  final bool logDI;
  final bool logDry;
  final bool logBindings;
  final bool logRebuilds;
  final bool logErrors;
  final bool enableTimeline;
  final bool asyncLog;

  GraftDevObserver({
    this.logState = false,
    bool? logChanges,
    this.logDI = true,
    this.logDry = true,
    this.logBindings = false,
    this.logRebuilds = false,
    this.logErrors = true,
    this.enableTimeline = false,
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
  void onScopeCreated(Object scopeId, {bool preserved = false}) =>
      _logScopeCreated(this, scopeId, preserved: preserved);

  @override
  void onScopeDropped(
    Object scopeId, {
    List<Type> members = const [],
    List<Type> registeredTypes = const [],
  }) =>
      _logScopeDropped(this, scopeId,
          members: members, registeredTypes: registeredTypes);

  @override
  void onDependencyBound(
    Type type, {
    Object? scopeId,
    bool singleton = true,
    bool preserved = false,
    bool isAsync = false,
  }) =>
      _logDependencyBound(this, type,
          scopeId: scopeId,
          singleton: singleton,
          preserved: preserved,
          isAsync: isAsync);

  @override
  void onDryHydrated(
    GraftState state, {
    required String key,
    required bool fromCache,
  }) =>
      _logDryHydrated(this, state, key: key, fromCache: fromCache);

  @override
  void onDryInvalidated(
    Object target, {
    required String key,
    bool isScopePurge = false,
  }) =>
      _logDryInvalidated(this, target,
          key: key, isScopePurge: isScopePurge);

  @override
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) =>
      _logSlotRebuild(this, graft, slotIndex, widget);

  @override
  void onCreate(dynamic graft) => _logCreate(this, graft);

  @override
  void onChange(dynamic graft, GraftChange change) =>
      _logChange(this, graft, change);

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) =>
      _logError(this, graft, error, stackTrace);

  @override
  void onDispose(dynamic graft) => _logDispose(this, graft);
}

