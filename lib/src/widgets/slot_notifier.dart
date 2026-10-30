part of 'slot_metadata.dart';

/// Ultra-lightweight [ValueNotifier] that tracks element attachment with zero listener overhead.
class SlotNotifier extends ValueNotifier<Widget> {
  SlotNotifier(super.value);
  bool _elementAttached = false;
  Widget? _latestValue;

  /// Attaches the slot's leaf element.
  void attachElement() => _elementAttached = true;

  /// Detaches the slot's leaf element.
  void detachElement() => _elementAttached = false;

  @override
  bool get hasListeners => _elementAttached || super.hasListeners;

  @override
  Widget get value => _latestValue ?? super.value;

  @override
  set value(Widget newValue) {
    if (identical(value, newValue)) return;
    _latestValue = newValue;
    if (super.hasListeners) {
      super.value = newValue;
    }
  }

  /// Whether external listeners are registered on this notifier.
  bool get hasExternalListeners => super.hasListeners;
}

