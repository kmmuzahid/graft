/// Declarative developer-defined Enum scope blocks and binding functions.
library;

import '../persistence/dry/dry_state_hook.dart';
import 'graft_di.dart';
import 'scope_node.dart';

ScopeNode _currentScope = GraftDI.root;

/// Registers a synchronous dependency factory into the active scope.
///
/// Defaults to `singleton: true` (cached in scope, never duplicated).
/// Set `preserved: true` to keep this binding alive across route pops.
void bind<T>(
  T Function() factory, {
  bool singleton = true,
  bool preserved = false,
}) {
  _currentScope.bind<T>(
    factory,
    singleton: singleton,
    preserved: preserved,
  );
}

/// Registers an asynchronous dependency factory into the active scope.
///
/// Execution is non-blocking and lazy by default. Callers accessing [T]
/// via `useAsync<T>()` on Frame 0 will automatically await initialization.
/// Set `eager: true` to trigger initialization immediately in background.
void bindAsync<T>(
  Future<T> Function() factory, {
  bool singleton = true,
  bool preserved = false,
  bool eager = false,
}) {
  _currentScope.bindAsync<T>(
    factory,
    singleton: singleton,
    preserved: preserved,
    eager: eager,
  );
}

/// Defines a cohesive scope block bound to a developer-defined [Enum].
///
/// Any [bind] or [bindAsync] calls inside [block] are registered into
/// this scope. If `preserved: true` is set, the scope survives route pops.
void scope(
  Enum scopeEnum,
  void Function() block, {
  bool preserved = false,
}) {
  final previous = _currentScope;
  _currentScope = GraftDI.getScope(scopeEnum, preserved: preserved);
  try {
    block();
  } finally {
    _currentScope = previous;
  }
}

/// Type-safe operational actions on developer-defined scope enums.
extension GraftScopeEnumActions on Enum {
  /// Manually drops this entire scope and disposes all members in reverse DAG order.
  void drop() => GraftDI.dropScope(this);

  /// Permanently invalidates and purges all dry persisted state associated with this scope.
  void invalidateDry() => DryStateHook.invalidatePrefix(name);
}
