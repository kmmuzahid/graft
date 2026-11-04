part of 'scope_node.dart';

extension ScopeResolution on ScopeNode {
  T _instantiate<T>(int id) {
    assert(() {
      if (ScopeNode._activeResolutionStack.contains(id)) {
        final cycle = [...ScopeNode._activeResolutionStack, id]
            .map((i) => 'TypeId#$i')
            .join(' ──▶ ');
        throw StateError('Graft DI Circular Dependency: $cycle');
      }
      return true;
    }());

    ScopeNode._activeResolutionStack.add(id);
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
      ScopeNode._activeResolutionStack.removeLast();
    }

    if (instance is GraftInitializable) {
      instance.onInit();
    }

    return instance as T;
  }
}
