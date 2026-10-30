part of 'graft_route_tracker.dart';

/// Unique key for ambient pool lookups, supporting optional family/tag keys.
@immutable
class AmbientKey {
  final Type type;
  final Object? key;

  const AmbientKey(this.type, [this.key]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientKey &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          key == other.key;

  @override
  int get hashCode => Object.hash(type, key);

  @override
  String toString() => key == null ? '$type' : '$type(key: $key)';
}

/// Ref-counted lifecycle container for an ambient [Graft] instance.
class AmbientEntry<T extends Graft> {
  final T instance;
  int refCount;
  final bool isRoot;
  final Set<Route<dynamic>> borrowerRoutes;

  AmbientEntry({
    required this.instance,
    this.refCount = 1,
    this.isRoot = false,
  }) : borrowerRoutes = <Route<dynamic>>{};
}

