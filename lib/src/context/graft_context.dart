import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../di/graft_registry.dart';
import '../route/graft_route_tracker.dart';
import '../widgets/graft_scope.dart';

/// Extension on [BuildContext] providing ergonomic Graft lookups and route-stack lifecycle management.
///
/// ### Why use BuildContext extensions?
/// - **Clean Screen Code:** Access controllers directly from `BuildContext` without wrappers:
///   `final userGraft = context.use<UserGraft>();`
/// - **Route Scoping:** Automatically scopes instances to the current route stack.
/// - **Leak Prevention:** Instances created with `context.use<T>()` or `context.create<T>()`
///   are automatically disposed when their owner route pops.
extension GraftContextX on BuildContext {
  /// Resolves an active [Graft] of type [T] across the navigation stack, or creates one if not found.
  ///
  /// ### Why use `context.use<T>()`?
  /// - **Route Stack Sharing:** If an ancestor screen in the navigation stack already created [T],
  ///   this screen **borrows** the existing instance.
  /// - **Subtree Scoping (`GraftScope`):** If within a [GraftScope] (e.g. `GoRouter` shell route,
  ///   nested tab, or modal dialog), resolves from the active scope.
  /// - **Automatic Ownership & Disposal:** The first screen that calls `context.use<T>()` becomes
  ///   the **Owner**. When that owner screen pops off the navigation stack, [T] is automatically disposed.
  ///   Borrower screens can push and pop freely without disposing the owner's instance.
  /// - **Global Singletons:** If [T] was registered with `registerSingleton` or `allowNew: false`,
  ///   always returns the permanent, un-scoped singleton instance.
  /// - **Zero Boilerplate:** No lambdas, no wrappers, just `final graft = context.use<MyGraft>();`.
  ///
  /// ### Example:
  /// ```dart
  /// class EditProfileScreen extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     // Borrows existing ProfileGraft from HomeScreen in the route stack:
  ///     final graft = context.use<ProfileGraft>();
  ///     return Scaffold(...);
  ///   }
  /// }
  /// ```
  T use<T extends Graft>([T Function()? factory]) {
    // If registered with isNewCreate: false, always return the permanent singleton
    if (!GraftRegistry.canCreateNew<T>()) {
      return GraftRegistry.getOrCreateSingleton<T>();
    }

    // 1. Check local GraftScope ancestor (GoRouter shell routes, tabs, modal sheets)
    final scoped = GraftScope.maybeOf<T>(this);
    if (scoped != null) {
      return scoped;
    }

    final route = ModalRoute.of(this) ?? GraftRouteTracker.currentRoute;

    if (route != null) {
      final existing = GraftRouteTracker.findInStack<T>(route);
      if (existing != null) {
        return existing;
      }
    }

    final newInstance = factory != null ? factory() : GraftRegistry.create<T>();

    // If inside a GraftScope, register for disposal with the scope
    final scopeState = findAncestorStateOfType<GraftScopeState>();
    if (scopeState != null) {
      scopeState.register<T>(newInstance);
      return newInstance;
    }

    if (route != null) {
      GraftRouteTracker.registerOwned<T>(route, newInstance);
      // Auto-attaches to standard Flutter Route.popped: cleans up even without GraftRouteObserver!
      route.popped.then((_) {
        if (!newInstance.isDisposed) {
          newInstance.dispose();
        }
      });
    }

    return newInstance;
  }

  /// Force-creates a brand-new, isolated [Graft] of type [T] owned exclusively by the current route or scope.
  ///
  /// ### Why use `context.create<T>()`?
  /// - Use this when you specifically do **NOT** want to inherit or borrow an active instance from
  ///   predecessor routes in the stack (e.g., an isolated wizard, comparison flow, or temporary form).
  /// - The current screen becomes the sole owner of this fresh instance and disposes it upon popping.
  ///
  /// *Note: If [T] was registered as a Global Singleton (`registerSingleton`), creation of new
  /// instances is disabled and this safely returns the singleton instead.*
  ///
  /// ### Example:
  /// ```dart
  /// // Creates a brand new, isolated ProfileGraft instance:
  /// final graft = context.create(ProfileGraft.new);
  /// ```
  T create<T extends Graft>([T Function()? factory]) {
    // If registered with isNewCreate: false, new creations are disabled; return singleton
    if (!GraftRegistry.canCreateNew<T>()) {
      return GraftRegistry.getOrCreateSingleton<T>();
    }

    final newInstance = factory != null ? factory() : GraftRegistry.create<T>();

    // 1. Register with local GraftScope if present
    final scopeState = findAncestorStateOfType<GraftScopeState>();
    if (scopeState != null) {
      scopeState.register<T>(newInstance);
      return newInstance;
    }

    final route = ModalRoute.of(this) ?? GraftRouteTracker.currentRoute;
    if (route != null) {
      GraftRouteTracker.registerOwned<T>(route, newInstance);
      route.popped.then((_) {
        if (!newInstance.isDisposed) {
          newInstance.dispose();
        }
      });
    }

    return newInstance;
  }
}
