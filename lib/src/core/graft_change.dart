import 'graft_mask.dart';

/// Represents a state transition in a [Graft].
///
/// ### Why use GraftChange?
/// Whenever a [Graft] state transitions or updates, a [GraftChange] is dispatched
/// to [GraftObserver.onChange]. It captures a point-in-time snapshot of the transition,
/// containing the previous [currentState], updated [nextState], automated property-level
/// snapshots ([previousProps] and [nextProps]), and the [dirtyMask] ([GraftMask]).
///
/// Use this in:
/// - Custom logging and telemetry pipelines
/// - Time-travel debugging or state history tracking
/// - Remote analytics and crash diagnostic breadcrumbs
class GraftChange<S> {
  /// The state before the transition.
  final S currentState;

  /// The state after the transition.
  final S nextState;

  /// Automated snapshot of [GraftState.props] immediately before mutation.
  final List<Object?> previousProps;

  /// Automated snapshot of [GraftState.props] immediately after mutation.
  final List<Object?> nextProps;

  /// The unbounded [GraftMask] bitset indicating which property indices were modified.
  final GraftMask dirtyMask;

  /// Creates a [GraftChange] describing a transition from [currentState] to [nextState].
  const GraftChange({
    required this.currentState,
    required this.nextState,
    this.previousProps = const [],
    this.nextProps = const [],
    this.dirtyMask = GraftMask.allDirty,
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
      'GraftChange(current: $currentState, next: $nextState, previousProps: $previousProps, nextProps: $nextProps, dirtyMask: $dirtyMask)';
}
