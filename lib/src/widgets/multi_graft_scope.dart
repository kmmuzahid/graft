import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import 'child_slot_engine.dart';

/// Single leaf diff engine that combines multiple [Graft] controllers into a unified rebuild boundary.
///
/// Whenever *any* of the watched controllers update, [builder] is re-evaluated.
/// Content equivalence ([GraftMultiChildDiffEngine.isWidgetEquivalent]) guarantees that
/// if the rendered output is identical, **0 Element rebuilds** occur in the render pipeline.
class GraftMultiSlotScope extends StatefulWidget implements GraftEquivalent {
  /// The list of [Graft] controllers to watch.
  final List<Graft> grafts;

  /// The widget builder combining states from all watched grafts.
  final Widget Function() builder;

  /// Creates a [GraftMultiSlotScope].
  const GraftMultiSlotScope({
    super.key,
    required this.grafts,
    required this.builder,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftMultiSlotScope) return false;
    if (key != other.key || grafts.length != other.grafts.length) return false;
    for (int i = 0; i < grafts.length; i++) {
      if (!identical(grafts[i], other.grafts[i])) return false;
    }
    return true;
  }

  @override
  State<GraftMultiSlotScope> createState() => _GraftMultiSlotScopeState();
}

class _GraftMultiSlotScopeState extends State<GraftMultiSlotScope> {
  late final ValueNotifier<Widget> _slotNotifier;

  @override
  void initState() {
    super.initState();
    _slotNotifier = ValueNotifier<Widget>(widget.builder());
    for (final graft in widget.grafts) {
      graft.addListener(_onStateChanged);
    }
  }

  void _onStateChanged() {
    if (!mounted) return;
    final oldWidget = _slotNotifier.value;
    final newWidget = widget.builder();

    if (identical(oldWidget, newWidget)) return;
    if (GraftMultiChildDiffEngine.isWidgetEquivalent(
        oldWidget, newWidget, context)) {
      return;
    }

    _slotNotifier.value = newWidget;
  }

  @override
  void didUpdateWidget(covariant GraftMultiSlotScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool changed = false;
    if (widget.grafts.length != oldWidget.grafts.length) {
      changed = true;
    } else {
      for (int i = 0; i < widget.grafts.length; i++) {
        if (!identical(widget.grafts[i], oldWidget.grafts[i])) {
          changed = true;
          break;
        }
      }
    }

    if (changed) {
      for (final graft in oldWidget.grafts) {
        graft.removeListener(_onStateChanged);
      }
      for (final graft in widget.grafts) {
        graft.addListener(_onStateChanged);
      }
      _onStateChanged();
    }
  }

  @override
  void dispose() {
    for (final graft in widget.grafts) {
      graft.removeListener(_onStateChanged);
    }
    _slotNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Widget>(
      valueListenable: _slotNotifier,
      builder: (_, widget, __) => widget,
    );
  }
}
