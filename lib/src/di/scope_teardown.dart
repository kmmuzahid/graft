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

