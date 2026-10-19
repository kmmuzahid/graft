/// Cascaded mutable domain model contract for nested state properties.
library;

import '../../core/graft_state.dart';

/// Base class for domain sub-models supporting automatic serialization and bitmask diffing.
///
/// Models extending [GraftModel] can be placed directly inside a [GraftState]
/// and tracked in [GraftState.props] without custom serializers or copyWith boilerplate:
///
/// ```dart
/// class AddressModel extends GraftModel {
///   String street = '';
///   String city = '';
///
///   @override
///   GraftProps get props => propsOf(street, city);
/// }
/// ```
abstract class GraftModel {
  /// Defines domain properties for serialization and diffing.
  GraftProps get props;

  /// Optional reset callback to restore baseline values.
  void onReset() {}

  List<Object?>? _hydrationBuffer;
  int _hydrationReadIndex = 0;
  List<Object?>? _probeProps;

  /// Hook called during Frame-0 dry hydration to map restored values.
  void onDry() => onHydrate();

  /// Legacy hydration hook. Prefer [onDry].
  void onHydrate() {}

  /// Declares and restores a persistent model property during [onDry].
  T dry<T>(T fallback) => read<T>(fallback);

  /// Declares and restores a nested [GraftModel] during [onDry].
  M dryModel<M extends GraftModel>(M model) {
    readModel(model);
    return model;
  }

  /// Hydrates a nested [GraftModel] using the next value in the hydration sequence.
  void readModel(GraftModel model) {
    final buf = _hydrationBuffer;
    if (buf != null) {
      if (_hydrationReadIndex < buf.length) {
        final val = buf[_hydrationReadIndex++];
        if (val is List) {
          model.hydrate(val.cast<Object?>());
        } else if (val is GraftProps) {
          model.hydrate(val.cast<Object?>().toList());
        }
        return;
      }
      _hydrationReadIndex++;
      return;
    }
    final p = _probeProps;
    if (p != null && _hydrationReadIndex < p.length) {
      _hydrationReadIndex++;
      model.probeModel();
      return;
    }
    _hydrationReadIndex++;
  }

  /// Type-safe auto-incrementing property reader for Frame-0 hydration.
  T read<T>([T? fallback]) {
    final buf = _hydrationBuffer;
    if (buf != null) {
      if (_hydrationReadIndex < buf.length) {
        final val = buf[_hydrationReadIndex++];
        if (val == null && fallback != null) return fallback;
        if (val is T) return val;
        if (fallback != null) return fallback;
        return val as T;
      }
      _hydrationReadIndex++;
      if (fallback != null) return fallback;
      throw StateError('read() called beyond available model hydration data');
    }
    final p = _probeProps;
    if (p != null && _hydrationReadIndex < p.length) {
      final val = p[_hydrationReadIndex++];
      if (val is T) return val;
      if (fallback != null) return fallback;
      return val as T;
    }
    _hydrationReadIndex++;
    if (fallback != null) return fallback;
    return null as T;
  }

  /// In-place hydration method restoring domain fields and nested models.
  void hydrate(List<Object?> tuple) {
    _hydrationBuffer = tuple;
    _hydrationReadIndex = 0;
    try {
      onDry();
      final currentProps = props;
      for (int i = _hydrationReadIndex;
          i < currentProps.length && i < tuple.length;
          i++) {
        final prop = currentProps[i];
        final val = tuple[i];
        if (prop is GraftModel && val is List) {
          prop.hydrate(val.cast<Object?>());
        }
      }
    } finally {
      _hydrationBuffer = null;
    }
  }

  /// Internal probe execution when no cached data exists.
  void probeModel() {
    final p = props;
    _probeProps = List<Object?>.generate(p.length, (i) => p[i], growable: false);
    _hydrationReadIndex = 0;
    try {
      onDry();
      for (int i = _hydrationReadIndex; i < p.length; i++) {
        final prop = p[i];
        if (prop is GraftModel) {
          prop.probeModel();
        }
      }
    } finally {
      _probeProps = null;
    }
  }

  /// Convenience helper to create [GraftProps].
  GraftProps propsOf([
    Object? p0 = const _Sentinel(),
    Object? p1 = const _Sentinel(),
    Object? p2 = const _Sentinel(),
    Object? p3 = const _Sentinel(),
    Object? p4 = const _Sentinel(),
    Object? p5 = const _Sentinel(),
    Object? p6 = const _Sentinel(),
    Object? p7 = const _Sentinel(),
  ]) {
    final list = <Object?>[];
    if (p0 is! _Sentinel) list.add(p0);
    if (p1 is! _Sentinel) list.add(p1);
    if (p2 is! _Sentinel) list.add(p2);
    if (p3 is! _Sentinel) list.add(p3);
    if (p4 is! _Sentinel) list.add(p4);
    if (p5 is! _Sentinel) list.add(p5);
    if (p6 is! _Sentinel) list.add(p6);
    if (p7 is! _Sentinel) list.add(p7);
    return GraftProps.fromList(list);
  }
}

class _Sentinel {
  const _Sentinel();
}

