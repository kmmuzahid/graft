part of 'graft_widgets.dart';

/// Extension on [ValueGraft<T>] providing clean, single-value reactive widget builders.
extension ValueGraftWidgetsX<T> on ValueGraft<T> {
  /// A reactive slot that diffs and rebuilds only when [value] changes.
  ///
  /// ### Examples:
  /// ```dart
  /// // 1. Standalone Counter:
  /// counterGraft.slot(
  ///   builder: (count) => Text('Count: $count'),
  /// )
  /// ```
  Widget slot({
    required Widget Function(T value) builder,
    Key? key,
  }) {
    GraftScopeGuard.verifyNotActive(this, 'graft.slot');
    return GraftSingleSlotScope<GraftValue<T>>(
      key: key,
      graft: this,
      builder: (s) => builder(s.value),
    );
  }
}

