import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../core/graft_state.dart';
import 'child_slot_engine.dart';

/// A lightweight rebuild firewall that isolates leaf updates at Depth $N$.
///
/// Wrapping a widget subtree with [GraftBoundary] ensures that updates to that subtree
/// rebuild **strictly within this boundary**, preventing ancestor containers
/// (such as outer `Container`, `Card`, `Padding`, or `Scaffold`) from re-evaluating.
///
/// ### Example 1: Zero-Boilerplate Fat-Arrow Closure
/// ```dart
/// Container(
///   padding: const EdgeInsets.all(16),
///   child: Container(
///     decoration: cardDecoration,
///     child: GraftBoundary(() => Text(state.name)), // 👈 Shield
///   ),
/// )
/// ```
///
/// ### Example 2: Static Child Constructor
/// ```dart
/// Container(
///   child: GraftBoundary.child(
///     child: const UserAvatarCard(),
///   ),
/// )
/// ```
class GraftBoundary<S extends GraftState> extends StatefulWidget {
  /// The builder closure returning the reactive child widget.
  final Widget Function() builder;

  /// Optional explicit [Graft] controller.
  /// If omitted, automatically resolves from the ambient [InheritedGraftScope] or tree.
  final Graft<S>? graft;

  /// Optional specific field index from `tracked` to watch.
  /// If provided, this boundary only rebuilds when that specific field bit is dirty.
  final int? field;

  /// Creates a [GraftBoundary] with a zero-boilerplate builder closure.
  const GraftBoundary(
    this.builder, {
    super.key,
    this.graft,
    this.field,
  });

  /// Creates a [GraftBoundary] wrapping an existing custom widget component.
  GraftBoundary.child({
    super.key,
    required Widget child,
    this.graft,
    this.field,
  }) : builder = (() => child);

  @override
  State<GraftBoundary<S>> createState() => _GraftBoundaryState<S>();
}

class _GraftBoundaryState<S extends GraftState> extends State<GraftBoundary<S>> {
  Graft<S>? _graft;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveGraft();
  }

  void _resolveGraft() {
    final resolvedGraft = widget.graft ??
        context.dependOnInheritedWidgetOfExactType<InheritedGraftScope>()?.graft as Graft<S>?;

    if (_graft != resolvedGraft) {
      _graft?.removeMaskListener(_onMaskDirty);
      _graft = resolvedGraft;
      _graft?.addMaskListener(_onMaskDirty);
    }
  }

  void _onMaskDirty(int dirtyMask) {
    if (!mounted) return;

    if (widget.field != null && dirtyMask != -1) {
      if ((dirtyMask & (1 << widget.field!)) == 0) {
        return; // Clean bit: skip!
      }
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant GraftBoundary<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graft != widget.graft || oldWidget.field != widget.field) {
      _resolveGraft();
    }
  }

  @override
  void dispose() {
    _graft?.removeMaskListener(_onMaskDirty);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}
