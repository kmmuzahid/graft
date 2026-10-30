part of '../child_slot_engine.dart';

/// A reactive item slot for lazy virtualized collections ([ListView.builder], [GridView.builder], etc.).
class GraftItemSlot<S extends GraftState, T> extends StatefulWidget
    implements GraftEquivalent {
  final Graft<S> graft;
  final int? index;
  final T Function(S state) selector;
  final Widget Function(BuildContext context, T item)? builder;
  final Widget Function(T item)? valueBuilder;

  const GraftItemSlot({
    super.key,
    required this.graft,
    required this.selector,
    this.builder,
    this.valueBuilder,
    this.index,
  }) : assert(builder != null || valueBuilder != null,
            'Either builder or valueBuilder must be provided');

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftItemSlot) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  State<GraftItemSlot<S, T>> createState() => _GraftItemSlotState<S, T>();
}

class _GraftItemSlotState<S extends GraftState, T>
    extends State<GraftItemSlot<S, T>> implements GraftItemReceiver {
  Element? _element;
  T? _item;
  Widget? _cachedWidget;
  bool _hasInitialItem = false;
  late Graft<S> _graft;
  late T Function(S state) _selector;
  Widget Function(BuildContext context, T item)? _builder;
  Widget Function(T item)? _valueBuilder;

  @override
  void initState() {
    super.initState();
    _graft = widget.graft;
    _selector = widget.selector;
    _builder = widget.builder;
    _valueBuilder = widget.valueBuilder;
    _element = context as Element;
    _resolveInitialItem();
    _graft.addMaskListener(_onMaskChange);
    if (widget.index != null) {
      GraftEngine.registerItemReceiver(_graft, widget.index!, this);
    }
  }

  void _resolveInitialItem() {
    try {
      _item = _selector(_graft.state);
      _hasInitialItem = true;
    } catch (_) {
      _hasInitialItem = false;
    }
  }

  void _updateItemIfChanged() {
    if (!mounted) return;
    final T nextItem;
    try {
      nextItem = _selector(_graft.state);
    } catch (_) {
      return;
    }
    if (identical(_item, nextItem)) return;
    if (_hasInitialItem && _item == nextItem) return;

    _item = nextItem;
    _hasInitialItem = true;
    _cachedWidget = null;
    (_element ?? (context as Element)).markNeedsBuild();
  }

  @override
  @pragma('vm:prefer-inline')
  void markItemDirty() => _updateItemIfChanged();

  void _onMaskChange(GraftMask mask) => _updateItemIfChanged();

  @override
  void reassemble() {
    super.reassemble();
    _resolveInitialItem();
    _cachedWidget = null;
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant GraftItemSlot<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selector = widget.selector;
    _builder = widget.builder;
    _valueBuilder = widget.valueBuilder;
    if (oldWidget.index != widget.index || oldWidget.graft != widget.graft) {
      if (oldWidget.index != null) {
        GraftEngine.unregisterItemReceiver(
            oldWidget.graft, oldWidget.index!, this);
      }
      if (widget.index != null) {
        GraftEngine.registerItemReceiver(widget.graft, widget.index!, this);
      }
    }
    if (oldWidget.graft != widget.graft) {
      oldWidget.graft.removeMaskListener(_onMaskChange);
      _graft = widget.graft;
      _resolveInitialItem();
      _graft.addMaskListener(_onMaskChange);
      _cachedWidget = null;
    } else {
      _cachedWidget = null;
    }
  }

  @override
  void dispose() {
    _graft.removeMaskListener(_onMaskChange);
    if (widget.index != null) {
      GraftEngine.unregisterItemReceiver(_graft, widget.index!, this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cached = _cachedWidget;
    if (cached != null) return cached;
    if (!_hasInitialItem) {
      _resolveInitialItem();
      if (!_hasInitialItem) return const SizedBox.shrink();
    }
    final itm = _item as T;
    final child =
        _valueBuilder != null ? _valueBuilder!(itm) : _builder!(context, itm);
    _cachedWidget = child;
    if (Graft.observer != null) {
      Graft.observer!.onSlotRebuild(_graft, -1, child);
    }
    return child;
  }
}

