part of '../child_slot_engine.dart';

/// Multi-child layout diffing engine that isolates each slot child into its own diffing element.
class GraftMultiChildDiffEngine<S extends GraftState> extends StatefulWidget
    implements GraftEquivalent {
  final Graft<S> graft;
  final dynamic layout;
  final List<Widget> Function(S state) slots;

  const GraftMultiChildDiffEngine({
    super.key,
    required this.graft,
    required this.layout,
    required this.slots,
  });

  /// Compares two widgets for content equivalence to prevent unnecessary slot rebuilds.
  static bool isWidgetEquivalent(
    Widget a,
    Widget b, [
    BuildContext? context,
    Set<Widget>? visited,
  ]) {
    if (identical(a, b)) return true;
    if (a.runtimeType != b.runtimeType) return false;
    if (a.key != b.key) return false;

    if (a is GraftEquivalent) {
      return (a as GraftEquivalent).isEquivalentTo(b);
    }
    if (a == b) return true;

    if (_diffMatchPrimitives(a, b, context, visited)) return true;
    if (_diffMatchContainers(a, b, context, visited)) return true;
    if (_diffMatchInteractive(a, b, context, visited)) return true;

    return false;
  }

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftMultiChildDiffEngine) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftMultiChildDiffEngine<S>> createState() =>
      _GraftMultiChildDiffEngineState<S>();
}

