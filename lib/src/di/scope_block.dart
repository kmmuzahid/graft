/// Declarative developer-defined Enum scope blocks and binding functions.
library;

import '../persistence/dry/dry_state_hook.dart';
import 'graft_di.dart';
import 'scope_node.dart';

ScopeNode _currentScope = GraftDI.root;

/// Registers a synchronous dependency factory into the active scope.
///
/// Execution is 100% lazy by default: the [factory] is only executed when
/// the dependency is first accessed via `use<T>()`.
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

/// Defines a cohesive scope block bound to a developer-defined [GraftScope] enum.
///
/// Any [bind] calls inside [block] are registered into this scope.
/// If `preserved: true` is set, the scope survives route pops.
void scope(
  GraftScope scope,
  void Function() block, {
  bool preserved = false,
}) {
  final previous = _currentScope;
  _currentScope = GraftDI.getScope(scope, preserved: preserved);
  try {
    block();
  } finally {
    _currentScope = previous;
  }
}

/// Mixin for developer-defined scope enums, granting direct access to [drop] and [invalidateDry].
///
/// ### Example:
/// ```dart
/// enum AppScope with GraftScope {
///   auth,
///   checkout,
/// }
///
/// AppScope.checkout.drop();
/// AppScope.checkout.invalidateDry();
/// ```
mixin GraftScope on Enum {
  /// Manually drops this entire scope and disposes all members in reverse DAG order.
  void drop() => GraftDI.dropScope(this);

  /// Permanently invalidates and purges all dry persisted state associated with this scope.
  void invalidateDry() => DryStateHook.invalidatePrefix(name);
}
