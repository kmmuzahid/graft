part of '../child_slot_engine.dart';

/// An isolated single-element slot scope that directly rebuilds only its own leaf element when notified.
class _ChildSlotScope extends Widget {
  final SlotMetadata slot;

  const _ChildSlotScope({
    super.key,
    required this.slot,
  });

  @override
  Element createElement() => _ChildSlotElement(this);
}

class _ChildSlotElement extends ComponentElement implements GraftFastReceiver {
  _ChildSlotElement(_ChildSlotScope super.widget);

  @override
  _ChildSlotScope get widget => super.widget as _ChildSlotScope;

  late SlotMetadata _slot;
  bool _isDirty = false;

  @pragma('vm:prefer-inline')
  void updateSlotWidget(Widget newWidget) {
    _slot.currentWidget = newWidget;
    _slot.notifier.value = newWidget;
    final dynamic g = _slot.graft;
    if (g is Graft) {
      Graft.observer?.onSlotRebuild(g, _slot.slotIndex, newWidget);
    }
    markNeedsBuild();
  }

  @pragma('vm:prefer-inline')
  void markSlotDirty() {
    _isDirty = true;
    markNeedsBuild();
  }

  @override
  void markFastDirty() => markSlotDirty();

  @override
  void mount(Element? parent, Object? newSlot) {
    _slot = widget.slot;
    super.mount(parent, newSlot);
    _slot.element = this;
    _slot.notifier.attachElement();
  }

  @override
  void update(covariant _ChildSlotScope newWidget) {
    final oldSlot = _slot;
    super.update(newWidget);
    _slot = newWidget.slot;
    if (oldSlot != _slot) {
      oldSlot.notifier.detachElement();
      _slot.notifier.attachElement();
      final dynamic oldG = oldSlot.graft;
      if (oldG is Graft &&
          identical(GraftEngine.getFastDirectReceiver(oldG), this)) {
        GraftEngine.setFastDirectReceiver(oldG, null);
        GraftEngine.setFastDirectMask(oldG, GraftMask.empty);
      }
    }
    _slot.element = this;
    _isDirty = false;
    rebuild(force: true);
  }

  @override
  void unmount() {
    _slot.notifier.detachElement();
    if (identical(_slot.element, this)) {
      _slot.element = null;
    }
    final dynamic g = _slot.graft;
    if (g is Graft && identical(GraftEngine.getFastDirectReceiver(g), this)) {
      GraftEngine.setFastDirectReceiver(g, null);
      GraftEngine.setFastDirectMask(g, GraftMask.empty);
    }
    super.unmount();
  }

  @override
  Widget build() {
    if (_isDirty) {
      _isDirty = false;
      final w = _slot.evaluate != null
          ? _slot.evaluate!()
          : (_slot.evaluator != null && _slot.graft is Graft
              ? _slot.evaluator!((_slot.graft as Graft).state)
              : _slot.currentWidget);
      _slot.currentWidget = w;
      final g = _slot.graft;
      if (g is Graft) {
        Graft.observer?.onSlotRebuild(g, _slot.slotIndex, w);
      }
      return w;
    }
    return _slot.currentWidget;
  }
}

