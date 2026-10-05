/// Represents a state transition in a [Graft].
///
/// ### Why use GraftChange?
/// Whenever a [Graft] state transitions or updates, a [GraftChange] is dispatched
/// to [GraftObserver.onChange]. It captures a point-in-time snapshot of the transition,
/// containing the previous [currentState], updated [nextState], automated field-level
/// snapshots ([previousTracked] and [nextTracked]), and the 64-bit integer [dirtyMask].
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
///     print('  Before: ${change.previousTracked}');
///     print('  After:  ${change.nextTracked}');
///     print('  Dirty mask: 0x${change.dirtyMask.toRadixString(16)}');
///   }
/// }
/// ```
class GraftChange<S> {
  /// The state before the transition.
  final S currentState;

  /// The state after the transition.
  final S nextState;

  /// Automated snapshot of [GraftState.tracked] fields immediately before mutation.
  final List<Object?> previousTracked;

  /// Automated snapshot of [GraftState.tracked] fields immediately after mutation.
  final List<Object?> nextTracked;

  /// The 64-bit integer dirty bitmask indicating which field indices were modified.
  final int dirtyMask;

  /// Creates a [GraftChange] describing a transition from [currentState] to [nextState].
  const GraftChange({
    required this.currentState,
    required this.nextState,
    this.previousTracked = const [],
    this.nextTracked = const [],
    this.dirtyMask = -1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraftChange<S> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState &&
          dirtyMask == other.dirtyMask;

  @override
  int get hashCode =>
      currentState.hashCode ^ nextState.hashCode ^ dirtyMask.hashCode;

  @override
  String toString() =>
      'GraftChange(current: $currentState, next: $nextState, previousTracked: $previousTracked, nextTracked: $nextTracked, dirtyMask: 0x${dirtyMask.toRadixString(16)})';
}
