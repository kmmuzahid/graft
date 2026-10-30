part of 'graft_observer.dart';

void _logSlotRebuild(GraftDevObserver observer, dynamic graft, int slotIndex, Widget widget) {
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
      '${GraftDevObserver._bold}${GraftDevObserver._cyan}[🔄 GRAFT SLOT REBUILD]${GraftDevObserver._reset} | '
      '${GraftDevObserver._magenta}${graft.runtimeType}${GraftDevObserver._reset} | '
      'Slot #$slotIndex (${widget.runtimeType})',
    );
  }
}

void _logCreate(GraftDevObserver observer, dynamic graft) {
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
        isDry ? ' 💾 ${GraftDevObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDevObserver._reset}' : '';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._green}[🌱 GRAFT CREATED]${GraftDevObserver._reset} | ${GraftDevObserver._cyan}${graft.runtimeType}${GraftDevObserver._reset}$dryBadge',
    );
  }
}

void _logChange(GraftDevObserver observer, dynamic graft, GraftChange change) {
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
        isDry ? ' 💾 ${GraftDevObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDevObserver._reset}' : '';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._yellow}[⚡ GRAFT CHANGE]${GraftDevObserver._reset} | '
      '${GraftDevObserver._cyan}${graft.runtimeType}${GraftDevObserver._reset}$dryBadge\n'
      '  ${GraftDevObserver._magenta}${change.currentState}${GraftDevObserver._reset}\n'
      '  ➡️ ${GraftDevObserver._green}${change.nextState}${GraftDevObserver._reset}',
    );
  }
}

void _logError(GraftDevObserver observer, dynamic graft, Object error, StackTrace stackTrace) {
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
      '${GraftDevObserver._bold}${GraftDevObserver._red}[💥 GRAFT ERROR]${GraftDevObserver._reset} | '
      '${GraftDevObserver._cyan}${graft.runtimeType}${GraftDevObserver._reset}: $error\n$stackTrace',
    );
  }
}

void _logDispose(GraftDevObserver observer, dynamic graft) {
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
        isDry ? ' 💾 ${GraftDevObserver._yellow}[DRY: ${graft.state.dryKey}]${GraftDevObserver._reset}' : '';
    observer._output(
      '${GraftDevObserver._bold}${GraftDevObserver._red}[🗑️ GRAFT DISPOSED]${GraftDevObserver._reset} | ${GraftDevObserver._cyan}${graft.runtimeType}${GraftDevObserver._reset}$dryBadge',
    );
  }
}

