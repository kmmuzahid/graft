/// Represents a state transition in a [Graft].
///
/// ### Why use GraftChange?
/// Whenever a [Graft] state transitions or updates, a [GraftChange] is dispatched
/// to [GraftObserver.onChange]. It captures a point-in-time snapshot of the transition,
/// containing both the previous [currentState] and the updated [nextState].
///
/// Use this in:
/// - Custom logging and telemetry pipelines
/// - Time-travel debugging or state history tracking
/// - Remote analytics and crash diagnostic breadcrumbs
///
/// ### Example:
/// ```dart
/// class MyObserver extends GraftObserver {
///   @override
///   void onChange(dynamic graft, GraftChange change) {
///     print('${graft.runtimeType} changed:');
///     print('  From: ${change.currentState}');
///     print('  To:   ${change.nextState}');
///   }
/// }
/// ```
class GraftChange<S> {
  /// The state before the transition.
  final S currentState;

  /// The state after the transition.
  final S nextState;

  /// Creates a [GraftChange] describing a transition from [currentState] to [nextState].
  const GraftChange({
    required this.currentState,
    required this.nextState,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraftChange<S> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() => 'GraftChange(current: $currentState, next: $nextState)';
}

