/// Flat array resolution, in-degree reverse DAG tracking, and teardown for a scope.
library;

import 'dart:async';
import '../core/graft.dart';
import 'async_binding.dart';
import 'disposable.dart';
import 'scope_tier.dart';
import 'type_id.dart';

part 'scope_resolution.dart';
part 'scope_teardown.dart';

/// Container node in the hierarchical dependency injection DAG.
final class ScopeNode {
  static final List<int> _activeResolutionStack = [];

  final Object? scopeId;
  final ScopeTier tier;
  final ScopeNode? parent;
  final List<ScopeNode> children = [];

  final Map<int, Type> _registeredTypes = {};
  final Map<int, Object? Function()> _factories = {};
  final Map<int, AsyncBinding<Object?>> _asyncBindings = {};
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
  List<Type> get activeMemberTypes {
    final types = <Type>[];
    for (int i = 0; i < _instances.length; i++) {
      final inst = _instances[i];
      if (inst != null) {
        types.add(_registeredTypes[i] ?? inst.runtimeType);
      }
    }
    for (final e in _asyncBindings.entries) {
      final inst = e.value.resolvedInstance;
      if (inst != null) {
        types.add(_registeredTypes[e.key] ?? inst.runtimeType);
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

  void bindAsync<T>(Future<T> Function() factory,
      {bool singleton = true, bool preserved = false, bool eager = false}) {
    final id = TypeId.of<T>();
    _registeredTypes[id] = T;
    final binding = AsyncBinding<Object?>(factory,
        singleton: singleton, preserved: preserved);
    _asyncBindings[id] = binding;
    if (singleton) _singletons.add(id);
    if (preserved) _preserved.add(id);
    Graft.observer?.onDependencyBound(
      T,
      scopeId: scopeId,
      singleton: singleton,
      preserved: preserved,
      isAsync: true,
    );
    if (eager) {
      binding.resolve();
    }
  }

  bool isRegistered<T>() {
    final id = TypeId.of<T>();
    if (_factories.containsKey(id) || _asyncBindings.containsKey(id)) {
      return true;
    }
    return parent?.isRegistered<T>() ?? false;
  }

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

    if (_asyncBindings.containsKey(id)) {
      final binding = _asyncBindings[id]!;
      if (binding.isCompleted) return binding.resolvedInstance as T;
      throw StateError(
        'Graft DI: Type $T was registered with bindAsync and is not completed. '
        'Use "await useAsync<$T>()" on Frame 0.',
      );
    }
    if (parent != null) return parent!.resolve<T>();
    throw StateError(
        'Graft DI: Type $T is not registered in active scope hierarchy.');
  }

  void acquireLease(RouteLeaseToken token) => _activeLeases.add(token);

  bool releaseLease(RouteLeaseToken token) {
    _activeLeases.remove(token);
    if (_activeLeases.isEmpty && tier == ScopeTier.transient) {
      drop();
      return true;
    }
    return false;
  }
}
