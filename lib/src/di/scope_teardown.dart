part of 'scope_node.dart';

extension ScopeTeardown on ScopeNode {
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
      _teardownInstance(_instances[current]);
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
      _teardownInstance(_instances[i]);
      _instances[i] = null;
    }

    for (final binding in _asyncBindings.values) {
      _teardownInstance(binding.resolvedInstance);
      binding.reset();
    }

    _factories.clear();
    _asyncBindings.clear();
    _singletons.clear();
    _instances.clear();
    _dependents.clear();
    _dependenciesOf.clear();
    _activeLeases.clear();
    parent?.children.remove(this);
  }

  void _teardownInstance(Object? instance) {
    if (instance == null) return;
    if (instance is Graft) {
      if (!instance.isDisposed) {
        instance.dispose();
      }
    } else if (instance is GraftService) {
      instance.dispose();
    } else if (instance is ChangeNotifier) {
      try {
        instance.dispose();
      } catch (_) {}
    }
  }
}

