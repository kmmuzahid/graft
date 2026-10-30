part of 'scope_node.dart';

extension ScopeResolution on ScopeNode {
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

