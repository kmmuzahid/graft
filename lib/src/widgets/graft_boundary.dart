import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_mask.dart';
import '../core/graft_scope_tracker.dart';
import 'child_slot_engine.dart';

/// An isolated rebuild boundary that automatically discovers all [Graft] instances
/// accessed inside it and adapts backward via self-optimizing field learning.
///
/// ### Why use GraftBoundary?
/// 1. **Zero-Boilerplate Multi-Graft Discovery:** Simply read whatever `.state` you need.
///    Any [Graft] accessed during `builder` is auto-discovered and subscribed with **0 manual lists**:
///    ```dart
///    GraftBoundary(
///      builder: (context) {
///        return Row(
///          children: [
///            Text(userGraft.state.name),
///            const SizedBox(width: 8),
///            Text(themeGraft.state.accent),
///          ],
///        );
///      },
///    )
///    ```
/// 2. **Backward Adaptive Learning:** By diffing rendered output with [GraftMultiChildDiffEngine.isWidgetEquivalent],
///    the boundary learns which properties across all watched Grafts actually affect the UI.
///    Unrelated property modifications are **bypassed in 1 CPU cycle** without executing `builder`
///    or allocating any widgets.
/// 3. **Tree Rebuild Insulation:** Rebuilds are trapped inside this boundary; outside parent and
///    sibling widgets experience **0 element rebuilds**.
class GraftBoundary extends StatefulWidget implements GraftEquivalent {
  /// The reactive widget builder.
  final Widget Function(BuildContext context) builder;

  /// Creates an isolated [GraftBoundary].
  const GraftBoundary({
    super.key,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftBoundary) return false;
    return key == other.key;
  }

  @override
  State<GraftBoundary> createState() => _GraftBoundaryState();
}

class _GraftBoundaryState extends State<GraftBoundary> {
  late final ValueNotifier<Widget> _slotNotifier;
  final Set<Graft> _subscribedGrafts = {};
  final Map<Graft, GraftMask> _learnedDependencies = {};
  final Map<Graft, void Function(GraftMask)> _listeners = {};

  @override
  void initState() {
    super.initState();
    final tracker = GraftScopeTracker();
    final initialWidget = GraftScopeTracker.run(tracker, () => widget.builder(context));
    _slotNotifier = ValueNotifier<Widget>(initialWidget);
    _syncSubscriptions(tracker.accessedGrafts);
  }

  void _syncSubscriptions(Set<Graft> currentGrafts) {
    // Unsubscribe removed grafts
    final removed = _subscribedGrafts.difference(currentGrafts);
    for (final graft in removed) {
      final listener = _listeners.remove(graft);
      if (listener != null) {
        graft.removeMaskListener(listener);
      }
      _learnedDependencies.remove(graft);
      _subscribedGrafts.remove(graft);
    }

    // Subscribe new grafts
    final added = currentGrafts.difference(_subscribedGrafts);
    for (final graft in added) {
      void listener(GraftMask mask) => _onGraftDirty(graft, mask);
      _listeners[graft] = listener;
      graft.addMaskListener(listener);
      _subscribedGrafts.add(graft);
    }
  }

  void _onGraftDirty(Graft graft, GraftMask dirtyMask) {
    if (!mounted) return;

    // Fast-path bypass: If dependencies for this graft are already learned
    // and none of the changed fields intersect, bypass completely in 1 CPU cycle!
    final learned = _learnedDependencies[graft];
    if (learned != null && !dirtyMask.isAllDirty && !dirtyMask.intersects(learned)) {
      return; // 0 builder execution, 0 widget allocations!
    }

    final tracker = GraftScopeTracker();
    final newWidget = GraftScopeTracker.run(tracker, () => widget.builder(context));
    _syncSubscriptions(tracker.accessedGrafts);

    final oldWidget = _slotNotifier.value;
    if (identical(oldWidget, newWidget)) return;

    // Content equivalence check
    if (GraftMultiChildDiffEngine.isWidgetEquivalent(oldWidget, newWidget, context)) {
      return; // Output identical: do NOT learn this field as a dependency!
    }

    // Output changed! Accumulate active fields into learned bitmask
    if (!dirtyMask.isEmpty && !dirtyMask.isAllDirty) {
      final single = dirtyMask.singleBitIndex;
      if (single != null) {
        _learnedDependencies[graft] =
            (_learnedDependencies[graft] ?? GraftMask.empty).withBit(single);
      } else if (_learnedDependencies[graft] == null || _learnedDependencies[graft]!.isEmpty) {
        _learnedDependencies[graft] = dirtyMask;
      } else {
        _learnedDependencies[graft] = _learnedDependencies[graft]!.union(dirtyMask);
      }
    }

    _slotNotifier.value = newWidget;
  }

  @override
  void didUpdateWidget(covariant GraftBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted) return;
    final tracker = GraftScopeTracker();
    final newWidget = GraftScopeTracker.run(tracker, () => widget.builder(context));
    _syncSubscriptions(tracker.accessedGrafts);
    _slotNotifier.value = newWidget;
  }

  @override
  void dispose() {
    for (final entry in _listeners.entries) {
      entry.key.removeMaskListener(entry.value);
    }
    _listeners.clear();
    _subscribedGrafts.clear();
    _learnedDependencies.clear();
    _slotNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Widget>(
      valueListenable: _slotNotifier,
      builder: (_, content, __) => content,
    );
  }
}
