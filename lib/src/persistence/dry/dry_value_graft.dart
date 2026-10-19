/// Frame-0 persistent single value state container.
library;

import '../../core/value_graft.dart';

/// Single-value state container supporting Frame-0 dry persistence.
final class DryGraftValue<T> extends GraftValue<T> {
  final String _key;

  DryGraftValue(super.value, {required String key}) : _key = key;

  @override
  String get dryKey => _key;

  @override
  void onHydrate() {
    value = read(value);
  }
}

/// Persistent [ValueGraft] that automatically hydrates on Frame 0.
class DryValueGraft<T> extends ValueGraft<T> {
  DryValueGraft(T initialValue, {required String key})
      : super.fromState(DryGraftValue<T>(initialValue, key: key));
}
