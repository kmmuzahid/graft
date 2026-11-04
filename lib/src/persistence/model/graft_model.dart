/// Cascaded mutable domain model contract for nested state properties.
library;

import 'package:flutter/foundation.dart';
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
  final Function? _factory;

  /// Creates a domain model.
  ///
  /// When embedded in a state used with Frame-0 dry persistence ([Graft.dry]),
  /// pass its constructor tear-off to super:
  /// ```dart
  /// class AddressModel extends GraftModel {
  ///   AddressModel([this.street = '', this.city = '']) : super(AddressModel.new);
  /// }
  /// ```
  const GraftModel([Function? factory]) : _factory = factory;

  @override
  @nonVirtual
  bool operator ==(Object other) => identical(this, other);

  @override
  @nonVirtual
  int get hashCode => identityHashCode(this);

  /// Defines domain properties for serialization and diffing.
  @protected
  GraftProps get props;

  /// Schema version for deterministic persistence and safe evolution across app restarts.
  ///
  /// When embedded in a state used with [Graft.dry] or `super.dry(State.new)`,
  /// this must be overridden to a positive integer:
  /// ```dart
  /// @override
  /// int get schemaVersion => 1;
  /// ```
  @protected
  int get schemaVersion => 0;

  /// Convenience helper to create [GraftProps].
  @protected
  @nonVirtual
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

/// Internal engine accessor for [GraftModel].
/// Internal to package:graft; never exported in public API.
@internal
abstract final class GraftModelEngine {
  /// Returns domain properties of [model] for serialization and diffing.
  static GraftProps props(GraftModel model) => model.props;

  /// Returns schema version of [model] for persistence migrations.
  static int schemaVersion(GraftModel model) => model.schemaVersion;

  /// Returns constructor tear-off for Frame-0 hydration.
  static Function? factory(GraftModel model) => model._factory;
}

class _Sentinel {
  const _Sentinel();
}
