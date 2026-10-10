import 'graft.dart';

/// Ambient tracker that automatically records all [Graft] instances accessed
/// via `.state` during the execution of a `GraftBoundary.builder`.
///
/// Enables 100% zero-boilerplate multi-graft discovery without passing manual arrays.
class GraftScopeTracker {
  /// The currently active tracker on the execution callstack.
  static GraftScopeTracker? current;

  /// Fast boolean flag to avoid static property reads when no tracking scope is active.
  static bool hasActiveScope = false;

  /// All [Graft] instances recorded during the current tracking frame.
  final Set<Graft> accessedGrafts = {};

  /// Records access to [graft].
  void record(Graft graft) {
    accessedGrafts.add(graft);
  }

  /// Runs [action] within this tracking scope.
  static T run<T>(GraftScopeTracker tracker, T Function() action) {
    final previous = current;
    current = tracker;
    hasActiveScope = true;
    try {
      return action();
    } finally {
      current = previous;
      hasActiveScope = previous != null;
    }
  }
}
