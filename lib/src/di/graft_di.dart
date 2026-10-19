/// Ambient service locator and Zone test override hooks.
library;

import 'dart:async';
import 'scope_node.dart';
import 'scope_tier.dart';

/// Global access point and Zone isolation registry for Graft DI.
final class GraftDI {
  GraftDI._();

  /// Immortal root scope node containing global singletons.
  static final ScopeNode root = ScopeNode(
    scopeId: 'root',
    tier: ScopeTier.root,
  );

  /// Key used by [graftTest] to provide isolated mock overrides.
  static final Object testZoneKey = Object();

  static final Map<Object, ScopeNode> _scopes = {};

  /// Retrieves or lazily creates a [ScopeNode] for [scopeId].
  static ScopeNode getScope(Object scopeId, {bool preserved = false}) {
    return _scopes.putIfAbsent(
      scopeId,
      () => ScopeNode(
        scopeId: scopeId,
        tier: preserved ? ScopeTier.preserved : ScopeTier.transient,
        parent: root,
      ),
    );
  }

  /// Drops and disposes an existing scope by its [scopeId].
  static void dropScope(Object scopeId) {
    final scope = _scopes.remove(scopeId);
    scope?.drop();
  }

  /// Resets all DI scopes and root dependencies (used in unit testing).
  static void reset() {
    for (final s in _scopes.values) {
      s.drop();
    }
    _scopes.clear();
    root.drop();
  }
}

/// Resolves an ambient dependency of type [T].
///
/// ### Performance:
/// - **Cold Lookup:** ≤ 12ns via monotonic integer [TypeId] array offset.
/// - **Hot Access:** Cache via `late final _repo = use<OrderRepo>();` for < 0.8ns V-table access.
T use<T>() {
  final overrides = Zone.current[GraftDI.testZoneKey];
  if (overrides is Map<Type, Object?> && overrides.containsKey(T)) {
    return overrides[T] as T;
  }
  return GraftDI.root.resolve<T>();
}

/// Resolves an ambient asynchronous dependency of type [T].
///
/// If called on Frame 0 before background initialization completes,
/// safely pauses and returns the instance the moment it is ready.
Future<T> useAsync<T>() {
  final overrides = Zone.current[GraftDI.testZoneKey];
  if (overrides is Map<Type, Object?> && overrides.containsKey(T)) {
    return Future<T>.value(overrides[T] as T);
  }
  return GraftDI.root.resolveAsync<T>();
}
