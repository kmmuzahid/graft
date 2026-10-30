import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_mask.dart';
import '../core/graft_scope_tracker.dart';
import 'child_slot_engine.dart';

/// An isolated rebuild boundary that automatically discovers all [Graft] instances
/// accessed inside it and adapts backward via self-optimizing field learning.
///
/// Features:
/// 1. Zero-boilerplate multi-Graft auto-discovery (no manual lists).
/// 2. Backward adaptive learning: diffs rendered output with [GraftMultiChildDiffEngine.isWidgetEquivalent]
///    to bypass unrelated property modifications without executing builder.
/// 3. Tree rebuild insulation: rebuilds are trapped inside this boundary.
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
  final Map<Graft, GraftMask> _ignoredMasks = {};
  final Map<Graft, void Function(GraftMask)> _listeners = {};

  @override
  void initState() {
    super.initState();
    final tracker = GraftScopeTracker();
    final initialWidget =
        GraftScopeTracker.run(tracker, () => widget.builder(context));
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
      _ignoredMasks.remove(graft);
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

    // Fast-path bypass: If this mutation is known to be ignored on the current output branch,
    // bypass completely in 1 CPU cycle!
    final ignored = _ignoredMasks[graft];
    if (ignored != null &&
        !dirtyMask.isAllDirty &&
        dirtyMask.isSubsetOf(ignored)) {
      return; // 0 builder execution, 0 widget allocations!
    }

    final tracker = GraftScopeTracker();
    final newWidget =
        GraftScopeTracker.run(tracker, () => widget.builder(context));
    _syncSubscriptions(tracker.accessedGrafts);

    final oldWidget = _slotNotifier.value;
    if (identical(oldWidget, newWidget)) return;

    // Content equivalence check
    if (GraftMultiChildDiffEngine.isWidgetEquivalent(
        oldWidget, newWidget, context)) {
      if (dirtyMask.isNotEmpty && !dirtyMask.isAllDirty) {
        final single = dirtyMask.singleBitIndex;
        if (single != null) {
          _ignoredMasks[graft] =
              (_ignoredMasks[graft] ?? GraftMask.empty).withBit(single);
        } else {
          _ignoredMasks[graft] =
              (_ignoredMasks[graft] ?? GraftMask.empty).union(dirtyMask);
        }
      }
      return; // Output identical: ignore this field on the current branch!
    }

    // Output changed! Clear ignored mask for this graft because the boundary
    // has transitioned to a new visual state or conditional branch.
    _ignoredMasks[graft] = GraftMask.empty;

    _slotNotifier.value = newWidget;
  }

  @override
  void didUpdateWidget(covariant GraftBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted) return;
    final tracker = GraftScopeTracker();
    final newWidget =
        GraftScopeTracker.run(tracker, () => widget.builder(context));
    _syncSubscriptions(tracker.accessedGrafts);
    _ignoredMasks.clear();
    _slotNotifier.value = newWidget;
  }

  @override
  void dispose() {
    for (final entry in _listeners.entries) {
      entry.key.removeMaskListener(entry.value);
    }
    _listeners.clear();
    _subscribedGrafts.clear();
    _ignoredMasks.clear();
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
