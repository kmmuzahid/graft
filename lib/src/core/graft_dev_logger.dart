part of 'graft_observer.dart';

void _logScopeCreated(GraftDevObserver observer, Object scopeId, {bool preserved = false}) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft DI: Scope Created [$scopeId]',
      arguments: <String, dynamic>{
        'scopeId': '$scopeId',
        'preserved': preserved,
      },
    );
  }
  if (kDebugMode && observer.logDI) {
    final mode = preserved ? 'preserved' : 'transient';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._blue}[📦 GRAFT DI SCOPE CREATED]${GraftDevObserver._reset} | '
      '${GraftDevObserver._cyan}$scopeId${GraftDevObserver._reset} '
      '(${GraftDevObserver._yellow}$mode${GraftDevObserver._reset})',
    );
  }
}

void _logScopeDropped(
  GraftDevObserver observer,
  Object scopeId, {
  List<Type> members = const [],
  List<Type> registeredTypes = const [],
}) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft DI: Scope Dropped [$scopeId]',
      arguments: <String, dynamic>{
        'scopeId': '$scopeId',
        'membersCount': members.length,
      },
    );
  }
  if (kDebugMode && observer.logDI) {
    final buffer = StringBuffer();
    buffer.write(
      '${GraftDevObserver._bold}${GraftDevObserver._magenta}[💥 GRAFT DI SCOPE DESTROYED]${GraftDevObserver._reset} | '
      '${GraftDevObserver._cyan}$scopeId${GraftDevObserver._reset}\n',
    );
    if (members.isNotEmpty) {
      buffer.write(
        '  ${GraftDevObserver._bold} Disposed Members (${members.length}):${GraftDevObserver._reset}\n',
      );
      for (final m in members) {
        buffer.write('  • ${GraftDevObserver._yellow}$m${GraftDevObserver._reset}\n');
      }
    } else if (registeredTypes.isNotEmpty) {
      buffer.write(
        '  ${GraftDevObserver._bold} Registered Bindings Cleared (${registeredTypes.length}):${GraftDevObserver._reset}\n',
      );
      for (final t in registeredTypes) {
        buffer.write('  • ${GraftDevObserver._yellow}$t${GraftDevObserver._reset}\n');
      }
    } else {
      buffer.write('  (no members active)\n');
    }
    observer._output(buffer.toString().trimRight());
  }
}

void _logDependencyBound(
  GraftDevObserver observer,
  Type type, {
  Object? scopeId,
  bool singleton = true,
  bool preserved = false,
  bool isAsync = false,
}) {
  if (kDebugMode && observer.logBindings) {
    final scopeName = scopeId ?? 'root';
    final asyncFlag = isAsync ? ' async' : '';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._blue}[🔗 GRAFT DI BIND]${GraftDevObserver._reset} | '
      '${GraftDevObserver._cyan}$type${GraftDevObserver._reset} in ${GraftDevObserver._yellow}$scopeName${GraftDevObserver._reset}$asyncFlag',
    );
  }
}

void _logDryHydrated(
  GraftDevObserver observer,
  GraftState state, {
  required String key,
  required bool fromCache,
}) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft Dry: ${state.runtimeType} hydrated',
      arguments: <String, dynamic>{
        'state': '${state.runtimeType}',
        'key': key,
        'fromCache': fromCache,
      },
    );
  }
  if (kDebugMode && observer.logDry) {
    final source = fromCache
        ? '${GraftDevObserver._green} restored from L1 RAM in <50ns${GraftDevObserver._reset}'
        : '${GraftDevObserver._yellow} initial defaults loaded${GraftDevObserver._reset}';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._cyan}[❄️ GRAFT DRY HYDRATED]${GraftDevObserver._reset} | '
      '${GraftDevObserver._magenta}${state.runtimeType}${GraftDevObserver._reset} '
      '💾 [key: ${GraftDevObserver._yellow}$key${GraftDevObserver._reset}] | $source',
    );
  }
}

void _logDryInvalidated(
  GraftDevObserver observer,
  Object target, {
  required String key,
  bool isScopePurge = false,
}) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft Dry: Invalidated [$key]',
      arguments: <String, dynamic>{
        'key': key,
        'isScopePurge': isScopePurge,
      },
    );
  }
  if (kDebugMode && observer.logDry) {
    if (isScopePurge) {
      observer._output(
        '${GraftDevObserver._bold}${GraftDevObserver._red}[🧹 GRAFT DRY SCOPE PURGED]${GraftDevObserver._reset} | '
        '${GraftDevObserver._cyan}$target${GraftDevObserver._reset} '
        '💾 [prefix: ${GraftDevObserver._yellow}$key${GraftDevObserver._reset}] | L1 RAM & disk cache cleared',
      );
    } else {
      final typeName = target is GraftState ? target.runtimeType : target;
      observer._output(
        '${GraftDevObserver._bold}${GraftDevObserver._red}[🧹 GRAFT DRY INVALIDATED]${GraftDevObserver._reset} | '
        '${GraftDevObserver._magenta}$typeName${GraftDevObserver._reset} '
        '💾 [key: ${GraftDevObserver._yellow}$key${GraftDevObserver._reset}] | persistence cleared for session',
      );
    }
  }
}

