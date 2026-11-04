part of 'graft_observer.dart';

void _logSlotRebuild(GraftDebugObserver observer, dynamic graft, int slotIndex, Widget widget) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft: ${graft.runtimeType} Slot #$slotIndex rebuild',
      arguments: <String, dynamic>{
        'graft': '${graft.runtimeType}',
        'slotIndex': slotIndex,
        'widget': '${widget.runtimeType}',
      },
    );
  }
  if (kDebugMode && observer.logRebuilds) {
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._cyan}[🔄 GRAFT SLOT REBUILD]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._magenta}${graft.runtimeType}${GraftDebugObserver._reset} | '
      'Slot #$slotIndex (${widget.runtimeType})',
    );
  }
}

void _logCreate(GraftDebugObserver observer, dynamic graft) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft: ${graft.runtimeType}.onCreate()',
      arguments: <String, dynamic>{'graft': '${graft.runtimeType}'},
    );
  }
  if (kDebugMode && observer.logState) {
    final isDry =
        graft is Graft && GraftStateEngine.isDryEnabled(graft.state);
    final dryBadge =
        isDry ? ' 💾 ${GraftDebugObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDebugObserver._reset}' : '';
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._green}[🌱 GRAFT CREATED]${GraftDebugObserver._reset} | ${GraftDebugObserver._cyan}${graft.runtimeType}${GraftDebugObserver._reset}$dryBadge',
    );
  }
}

void _logChange(GraftDebugObserver observer, dynamic graft, GraftChange change) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft: ${graft.runtimeType}.update()',
      arguments: <String, dynamic>{
        'graft': '${graft.runtimeType}',
        'currentState': '${change.currentState}',
        'nextState': '${change.nextState}',
      },
    );
  }
  if (kDebugMode && observer.logChanges) {
    final isDry =
        graft is Graft && GraftStateEngine.isDryEnabled(graft.state);
    final dryBadge =
        isDry ? ' 💾 ${GraftDebugObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDebugObserver._reset}' : '';
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._yellow}[⚡ GRAFT CHANGE]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._cyan}${graft.runtimeType}${GraftDebugObserver._reset}$dryBadge\n'
      '  ${GraftDebugObserver._magenta}${change.currentState}${GraftDebugObserver._reset}\n'
      '  ➡️ ${GraftDebugObserver._green}${change.nextState}${GraftDebugObserver._reset}',
    );
  }
}

void _logError(GraftDebugObserver observer, dynamic graft, Object error, StackTrace stackTrace) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft: ${graft.runtimeType}.onError()',
      arguments: <String, dynamic>{
        'graft': '${graft.runtimeType}',
        'error': '$error',
      },
    );
  }
  if (kDebugMode && observer.logErrors) {
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._red}[💥 GRAFT ERROR]${GraftDebugObserver._reset} | '
      '${GraftDebugObserver._cyan}${graft.runtimeType}${GraftDebugObserver._reset}: $error\n$stackTrace',
    );
  }
}

void _logDispose(GraftDebugObserver observer, dynamic graft) {
  if (observer.enableTimeline && !kReleaseMode) {
    developer.Timeline.instantSync(
      'Graft: ${graft.runtimeType}.onDispose()',
      arguments: <String, dynamic>{'graft': '${graft.runtimeType}'},
    );
  }
  if (kDebugMode && observer.logState) {
    final isDry =
        graft is Graft && GraftStateEngine.isDryEnabled(graft.state);
    final dryBadge =
        isDry ? ' 💾 ${GraftDebugObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDebugObserver._reset}' : '';
    observer._output(
      '${GraftDebugObserver._bold}${GraftDebugObserver._red}[🗑️ GRAFT DISPOSED]${GraftDebugObserver._reset} | ${GraftDebugObserver._cyan}${graft.runtimeType}${GraftDebugObserver._reset}$dryBadge',
    );
  }
}

