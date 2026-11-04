part of 'graft_observer.dart';

void _logScopeCreated(GraftDebugObserver observer, Object scopeId, {bool preserved = false}) {
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
      '${GraftDebugObserver._bold}${GraftDebugObserver._blue}[📦 GRAFT DI SCOPE CREATED]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._cyan}$scopeId${GraftDebugObserver._reset} '
      '(${GraftDebugObserver._yellow}$mode${GraftDebugObserver._reset})',
    );
  }
}

void _logScopeDropped(
  GraftDebugObserver observer,
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
      '${GraftDebugObserver._bold}${GraftDebugObserver._magenta}[💥 GRAFT DI SCOPE DESTROYED]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._cyan}$scopeId${GraftDebugObserver._reset}\n',
    );
    if (members.isNotEmpty) {
      buffer.write(
        '  ${GraftDebugObserver._bold} Disposed Members (${members.length}):${GraftDebugObserver._reset}\n',
      );
      for (final m in members) {
        buffer.write('  • ${GraftDebugObserver._yellow}$m${GraftDebugObserver._reset}\n');
      }
    } else if (registeredTypes.isNotEmpty) {
      buffer.write(
        '  ${GraftDebugObserver._bold} Registered Bindings Cleared (${registeredTypes.length}):${GraftDebugObserver._reset}\n',
      );
      for (final t in registeredTypes) {
        buffer.write('  • ${GraftDebugObserver._yellow}$t${GraftDebugObserver._reset}\n');
      }
    } else {
      buffer.write('  (no members active)\n');
    }
    observer._output(buffer.toString().trimRight());
  }
}

void _logDependencyBound(
  GraftDebugObserver observer,
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
      '${GraftDebugObserver._bold}${GraftDebugObserver._blue}[🔗 GRAFT DI BIND]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._cyan}$type${GraftDebugObserver._reset} in ${GraftDebugObserver._yellow}$scopeName${GraftDebugObserver._reset}$asyncFlag',
    );
  }
}

void _logDryHydrated(
  GraftDebugObserver observer,
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
        ? '${GraftDebugObserver._green} restored from L1 RAM in <50ns${GraftDebugObserver._reset}'
        : '${GraftDebugObserver._yellow} initial defaults loaded${GraftDebugObserver._reset}';
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._cyan}[❄️ GRAFT DRY HYDRATED]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._magenta}${state.runtimeType}${GraftDebugObserver._reset} '
      '💾 [key: ${GraftDebugObserver._yellow}$key${GraftDebugObserver._reset}] | $source',
    );
  }
}

void _logDryInvalidated(
  GraftDebugObserver observer,
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
        '${GraftDebugObserver._bold}${GraftDebugObserver._red}[🧹 GRAFT DRY SCOPE PURGED]${GraftDebugObserver._reset} | '
        '${GraftDebugObserver._cyan}$target${GraftDebugObserver._reset} '
        '💾 [prefix: ${GraftDebugObserver._yellow}$key${GraftDebugObserver._reset}] | L1 RAM & disk cache cleared',
      );
    } else {
      final typeName = target is GraftState ? target.runtimeType : target;
      observer._output(
        '${GraftDebugObserver._bold}${GraftDebugObserver._red}[🧹 GRAFT DRY INVALIDATED]${GraftDebugObserver._reset} | '
        '${GraftDebugObserver._magenta}$typeName${GraftDebugObserver._reset} '
        '💾 [key: ${GraftDebugObserver._yellow}$key${GraftDebugObserver._reset}] | persistence cleared for session',
      );
    }
  }
}

