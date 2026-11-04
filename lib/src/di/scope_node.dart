/// Flat array resolution, in-degree reverse DAG tracking, and teardown for a scope.
library;

import 'package:flutter/foundation.dart';
import '../core/graft.dart';
import 'graft_service.dart';
import 'scope_tier.dart';
import 'type_id.dart';

part 'scope_resolution.dart';
part 'scope_teardown.dart';

/// Container node in the hierarchical dependency injection DAG.
final class ScopeNode {
  static final List<int> _activeResolutionStack = [];

  final Object? scopeId;
  @internal
  final ScopeTier tier;
  @internal
  final ScopeNode? parent;
  @internal
  final List<ScopeNode> children = [];

  final Map<int, Type> _registeredTypes = {};
  final Map<int, Object? Function()> _factories = {};
  final List<Object?> _instances = [];
  final Set<int> _singletons = {};
  final Set<int> _preserved = {};
  final Map<int, Set<int>> _dependents = {};
  final Map<int, Set<int>> _dependenciesOf = {};
  final Set<RouteLeaseToken> _activeLeases = {};

  ScopeNode({this.scopeId, this.tier = ScopeTier.transient, this.parent}) {
    parent?.children.add(this);
  }

  /// Returns the runtime types of all currently instantiated members in this scope.
  @internal
  List<Type> get activeMemberTypes {
    final types = <Type>[];
    for (int i = 0; i < _instances.length; i++) {
      final inst = _instances[i];
      if (inst != null) {
        types.add(_registeredTypes[i] ?? inst.runtimeType);
      }
    }
    return types;
  }

  void bind<T>(T Function() factory,
      {bool singleton = true, bool preserved = false}) {
    final id = TypeId.of<T>();
    _registeredTypes[id] = T;
    _factories[id] = factory;
    if (singleton) _singletons.add(id);
    if (preserved) _preserved.add(id);
    Graft.observer?.onDependencyBound(
      T,
      scopeId: scopeId,
      singleton: singleton,
      preserved: preserved,
    );
  }

  bool isRegistered<T>() {
    final id = TypeId.of<T>();
    if (_factories.containsKey(id)) {
      return true;
    }
    return parent?.isRegistered<T>() ?? false;
  }

  @internal
  bool isSingleton(int id) => _singletons.contains(id);

  T resolve<T>() {
    final id = TypeId.of<T>();

    if (_activeResolutionStack.isNotEmpty) {
      final consumerId = _activeResolutionStack.last;
      if (consumerId != id) {
        _dependents.putIfAbsent(id, () => <int>{}).add(consumerId);
        _dependenciesOf.putIfAbsent(consumerId, () => <int>{}).add(id);
      }
    }

    if (id < _instances.length && _instances[id] != null) {
      return _instances[id] as T;
    }

    if (_factories.containsKey(id)) {
      return _instantiate<T>(id);
    }

    if (parent != null) return parent!.resolve<T>();
    throw StateError(
        'Graft DI: Type $T is not registered in active scope hierarchy.');
  }

  @internal
  void acquireLease(RouteLeaseToken token) => _activeLeases.add(token);

  @internal
  bool releaseLease(RouteLeaseToken token) {
    _activeLeases.remove(token);
    if (_activeLeases.isEmpty && tier == ScopeTier.transient) {
      drop();
      return true;
    }
    return false;
  }
}
