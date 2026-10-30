part of '../child_slot_engine.dart';

/// A layout-agnostic, 100% lazy virtualized collection engine with per-item slot diffing.
class GraftBuilderDiffEngine<S extends GraftState, T> extends StatefulWidget
    implements GraftEquivalent {
  final Graft<S> graft;
  final Widget Function(int itemCount, NullableIndexedWidgetBuilder itemBuilder)
      layout;
  final int Function(S state) itemCount;
  final T Function(S state, int index) item;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Key Function(T item)? itemKey;

  const GraftBuilderDiffEngine({
    super.key,
    required this.graft,
    required this.layout,
    required this.itemCount,
    required this.item,
    required this.itemBuilder,
    this.itemKey,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftBuilderDiffEngine) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftBuilderDiffEngine<S, T>> createState() =>
      _GraftBuilderDiffEngineState<S, T>();
}

class _GraftBuilderDiffEngineState<S extends GraftState, T>
    extends State<GraftBuilderDiffEngine<S, T>> {
  late int _count;
  bool _contractVerified = false;

  @override
  void initState() {
    super.initState();
    _count = widget.itemCount(widget.graft.state);
    widget.graft.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (!mounted) return;
    final nextCount = widget.itemCount(widget.graft.state);
    if (_count != nextCount) {
      setState(() {
        _count = nextCount;
      });
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _count = widget.itemCount(widget.graft.state);
    _contractVerified = false;
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant GraftBuilderDiffEngine<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _contractVerified = false;
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeListener(_onStateChange);
      _count = widget.itemCount(widget.graft.state);
      widget.graft.addListener(_onStateChange);
    } else {
      _onStateChange();
    }
  }

  @override
  void dispose() {
    widget.graft.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? engineItemBuilder(BuildContext context, int index) {
      if (index < 0 || index >= _count) return null;
      return GraftItemSlot<S, T>(
        key: widget.itemKey != null
            ? widget.itemKey!(widget.item(widget.graft.state, index))
            : ValueKey(index),
        index: index,
        graft: widget.graft,
        selector: (s) {
          final count = widget.itemCount(s);
          if (index < 0 || index >= count) {
            throw RangeError.index(index, count);
          }
          return widget.item(s, index);
        },
        builder: (ctx, item) => widget.itemBuilder(ctx, item, index),
      );
    }

    final layoutWidget = widget.layout(_count, engineItemBuilder);

    assert(() {
      if (!_contractVerified) {
        _verifyBuilderContract(layoutWidget, _count, engineItemBuilder);
        _contractVerified = true;
      }
      return true;
    }());

    return layoutWidget;
  }
}

