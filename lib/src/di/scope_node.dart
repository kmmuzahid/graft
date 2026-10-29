/// Flat array resolution, in-degree reverse DAG tracking, and teardown for a scope.
library;

import 'dart:async';
import '../core/graft.dart';
import 'async_binding.dart';
import 'disposable.dart';
import 'scope_tier.dart';
import 'type_id.dart';

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

  Future<T> resolveAsync<T>() {
    final id = TypeId.of<T>();

    if (id < _instances.length && _instances[id] != null) {
      return Future<T>.value(_instances[id] as T);
    }

    if (_asyncBindings.containsKey(id)) {
      return _asyncBindings[id]!.resolve().then((v) => v as T);
    }

    if (_factories.containsKey(id)) {
      return Future<T>.value(resolve<T>());
    }

    if (parent != null) {
      return parent!.resolveAsync<T>();
    }

    throw StateError(
        'Graft DI: Type $T is not registered in active scope hierarchy.');
  }

  T _instantiate<T>(int id) {
    assert(() {
      if (_activeResolutionStack.contains(id)) {
        final cycle = [..._activeResolutionStack, id]
            .map((i) => 'TypeId#$i')
            .join(' ──▶ ');
        throw StateError('Graft DI Circular Dependency: $cycle');
      }
      return true;
    }());

    _activeResolutionStack.add(id);
    final Object? instance;
    try {
      instance = _factories[id]!();
      if (isSingleton(id)) {
        while (_instances.length <= id) {
          _instances.add(null);
        }
        _instances[id] = instance;
      }
    } finally {
      _activeResolutionStack.removeLast();
    }

    if (instance is GraftInitializable) {
      instance.onInit();
    }

    return instance as T;
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

  void drop() {
    final activeMembers = activeMemberTypes;
    final allRegistered = _registeredTypes.values.toList();
    if (scopeId != null && scopeId != 'root') {
      Graft.observer?.onScopeDropped(
        scopeId!,
        members: activeMembers,
        registeredTypes: allRegistered,
      );
    }

    final consumerCount = {
      for (final e in _dependents.entries) e.key: e.value.length
    };
    final queue = <int>[
      for (int i = 0; i < _instances.length; i++)
        if (_instances[i] != null && (consumerCount[i] ?? 0) == 0) i,
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final instance = _instances[current];
      if (instance is Disposable) instance.dispose();
      _instances[current] = null;

      final dependencies = _dependenciesOf[current];
      if (dependencies != null) {
        for (final dep in dependencies) {
          final count = (consumerCount[dep] ?? 1) - 1;
          consumerCount[dep] = count;
          if (count == 0 &&
              _instances.length > dep &&
              _instances[dep] != null) {
            queue.add(dep);
          }
        }
      }
    }

    for (int i = 0; i < _instances.length; i++) {
      final instance = _instances[i];
      if (instance is Disposable) instance.dispose();
      _instances[i] = null;
    }

    for (final binding in _asyncBindings.values) {
      final inst = binding.resolvedInstance;
      if (inst is Disposable) inst.dispose();
      binding.reset();
    }

    _instances.clear();
    _dependents.clear();
    _dependenciesOf.clear();
    _activeLeases.clear();
    parent?.children.remove(this);
  }
}
