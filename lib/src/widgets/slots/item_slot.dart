part of '../child_slot_engine.dart';

/// A reactive item slot for lazy virtualized collections ([ListView.builder], [GridView.builder], etc.).
class GraftItemSlot<S extends GraftState, T> extends Widget
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
  }) : assert(builder != null || valueBuilder != null);

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! GraftItemSlot) return false;
    return graft == other.graft && key == other.key;
  }

  @override
  Element createElement() => _GraftItemSlotElement<S, T>(this);
}

class _GraftItemSlotElement<S extends GraftState, T> extends ComponentElement
    implements GraftItemReceiver {
  _GraftItemSlotElement(GraftItemSlot<S, T> super.widget);

  @override
  GraftItemSlot<S, T> get widget => super.widget as GraftItemSlot<S, T>;

  T? _item;
  Widget? _cachedWidget;
  bool _hasInitialItem = false;
  late Graft<S> _graft;
  late T Function(S state) _selector;
  Widget Function(BuildContext context, T item)? _builder;
  Widget Function(T item)? _valueBuilder;
  int? _index;

  @override
  void mount(Element? parent, Object? newSlot) {
    final w = widget;
    _graft = w.graft;
    _selector = w.selector;
    _builder = w.builder;
    _valueBuilder = w.valueBuilder;
    _index = w.index;
    _resolveInitialItem();
    super.mount(parent, newSlot);
    _graft.addMaskListener(_onMaskChange);
    if (_index != null) GraftEngine.registerItemReceiver(_graft, _index!, this);
  }

  void _resolveInitialItem() {
    try {
      _item = _selector(GraftEngine.getState(_graft));
      _hasInitialItem = true;
    } catch (_) {
      _hasInitialItem = false;
    }
  }

  @override
  @pragma('vm:prefer-inline')
  void markItemDirty() {
    if (!mounted) return;
    final T next;
    try {
      next = _selector(GraftEngine.getState(_graft));
    } catch (_) {
      return;
    }
    if (identical(_item, next) || (_hasInitialItem && _item == next)) return;
    _item = next;
    _hasInitialItem = true;
    _cachedWidget = null;
    markNeedsBuild();
  }

  void _onMaskChange(GraftMask mask) => markItemDirty();

  @override
  void reassemble() {
    super.reassemble();
    _resolveInitialItem();
    _cachedWidget = null;
    if (mounted) markNeedsBuild();
  }

  @override
  void update(covariant GraftItemSlot<S, T> newWidget) {
    final oldGraft = _graft;
    final oldIndex = _index;
    super.update(newWidget);
    _selector = newWidget.selector;
    _builder = newWidget.builder;
    _valueBuilder = newWidget.valueBuilder;
    _index = newWidget.index;
    if (oldIndex != _index || oldGraft != newWidget.graft) {
      if (oldIndex != null) GraftEngine.unregisterItemReceiver(oldGraft, oldIndex, this);
      if (_index != null) GraftEngine.registerItemReceiver(newWidget.graft, _index!, this);
    }
    if (oldGraft != newWidget.graft) {
      oldGraft.removeMaskListener(_onMaskChange);
      _graft = newWidget.graft;
      _resolveInitialItem();
      _graft.addMaskListener(_onMaskChange);
    }
    _cachedWidget = null;
    rebuild(force: true);
  }

  @override
  void unmount() {
    _graft.removeMaskListener(_onMaskChange);
    if (_index != null) GraftEngine.unregisterItemReceiver(_graft, _index!, this);
    super.unmount();
  }

  @override
  Widget build() {
    final cached = _cachedWidget;
    if (cached != null) return cached;
    if (!_hasInitialItem) {
      _resolveInitialItem();
      if (!_hasInitialItem) return const SizedBox.shrink();
    }
    final itm = _item as T;
    final child = _valueBuilder != null ? _valueBuilder!(itm) : _builder!(this, itm);
    _cachedWidget = child;
    Graft.observer?.onSlotRebuild(_graft, -1, child);
    return child;
  }
}
