import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../di/graft_registry.dart';
import '../route/graft_route_tracker.dart';

/// Extension on [BuildContext] providing ergonomic Graft lookups and zero-wrapper ambient lifecycle management.
extension GraftContextX on BuildContext {
  /// Resolves an active [Graft] of type [T] from the ambient pool, or creates one if absent.
  ///
  /// - **Borrow or Create:** If an active instance exists, borrows it and increments refCount.
  /// - **App-Root Promotion:** When invoked at App Root (`route == null`), auto-promotes to permanent singleton.
  /// - **Ref-Counted Disposal:** Disposed when all borrower routes pop (`refCount == 0`).
  /// - Pass optional [key] for parameterized entity screens.
  T use<T extends Graft>([T Function()? factory, Object? key]) {
    // If registered with isNewCreate: false, always return the permanent singleton
    if (!GraftRegistry.canCreateNew<T>()) {
      return GraftRegistry.getOrCreateSingleton<T>();
    }

    final route = ModalRoute.of(this) ?? GraftRouteTracker.currentRoute;
    final effectiveRoute =
        route != null ? GraftRouteTracker.resolveOwnerRoute(route) : null;

    // Check ambient pool
    final existing = GraftRouteTracker.getAmbient<T>(
      key: key,
      requestingRoute: effectiveRoute,
    );
    if (existing != null) {
      if (effectiveRoute != null) {
        GraftRouteTracker.borrowAmbient<T>(effectiveRoute, key: key);
      }
      return existing;
    }

    // If the route has already completed/popped or is in tombstone phase,
    // prevent instantiating and registering zombie instances during exit frames.
    if (effectiveRoute != null &&
        GraftRouteTracker.isRouteTombstoned(effectiveRoute)) {
      final ghost = factory != null ? factory() : GraftRegistry.create<T>();
      if (!ghost.isDisposed) {
        ghost.dispose();
      }
      return ghost;
    }

    final newInstance = factory != null ? factory() : GraftRegistry.create<T>();

    if (effectiveRoute == null) {
      // App Root: route == null -> permanent app-wide singleton (isRoot: true)
      GraftRouteTracker.registerAmbientRoot<T>(newInstance, key: key);
    } else {
      // Screen/Route: route != null -> ref-counted ambient instance (isRoot: false)
      GraftRouteTracker.registerAmbientRoute<T>(
        effectiveRoute,
        newInstance,
        key: key,
      );
    }

    return newInstance;
  }

  /// Force-creates a brand-new, isolated [Graft] of type [T] owned exclusively by the current route.
  ///
  /// ### Why use `context.create<T>()`?
  /// - Use this when you specifically do **NOT** want to inherit or borrow an active instance from
  ///   the ambient pool (e.g., an isolated wizard, comparison flow, or temporary form).
  /// - Bypasses the ambient pool entirely and anchors directly to the current route's private ownership list.
  /// - Automatically disposed when the owner route pops.
  ///
  /// *Note: If [T] was registered as a Global Singleton (`registerSingleton`), creation of new
  /// instances is disabled and this safely returns the singleton instead.*
  ///
  /// ### Example:
  /// ```dart
  /// // Creates a brand new, isolated ProfileGraft instance:
  /// final graft = context.create(ProfileGraft.new);
  /// ```
  T create<T extends Graft>([T Function()? factory, Object? key]) {
    // If registered with isNewCreate: false, new creations are disabled; return singleton
    if (!GraftRegistry.canCreateNew<T>()) {
      return GraftRegistry.getOrCreateSingleton<T>();
    }

    final newInstance = factory != null ? factory() : GraftRegistry.create<T>();

    final route = ModalRoute.of(this) ?? GraftRouteTracker.currentRoute;
    if (route != null) {
      final effectiveRoute = GraftRouteTracker.resolveOwnerRoute(route);
      GraftRouteTracker.registerPrivate<T>(effectiveRoute, newInstance);
    }

    return newInstance;
  }

  /// Resolves two active [Graft] controllers across the navigation stack using Dart 3 records.
  ///
  /// ```dart
  /// final (userGraft, cartGraft) = context.use2(UserGraft.new, CartGraft.new);
  /// ```
  (A, B) use2<A extends Graft, B extends Graft>([
    A Function()? factoryA,
    B Function()? factoryB,
  ]) {
    return (use<A>(factoryA), use<B>(factoryB));
  }

  /// Resolves three active [Graft] controllers across the navigation stack using Dart 3 records.
  ///
  /// ```dart
  /// final (user, cart, nav) = context.use3(UserGraft.new, CartGraft.new, NavGraft.new);
  /// ```
  (A, B, C) use3<A extends Graft, B extends Graft, C extends Graft>([
    A Function()? factoryA,
    B Function()? factoryB,
    C Function()? factoryC,
  ]) {
    return (use<A>(factoryA), use<B>(factoryB), use<C>(factoryC));
  }

  /// Resolves four active [Graft] controllers across the navigation stack using Dart 3 records.
  ///
  /// ```dart
  /// final (user, cart, nav, settings) = context.use4(
  ///   UserGraft.new,
  ///   CartGraft.new,
  ///   NavGraft.new,
  ///   SettingsGraft.new,
  /// );
  /// ```
  (A, B, C, D)
      use4<A extends Graft, B extends Graft, C extends Graft, D extends Graft>([
    A Function()? factoryA,
    B Function()? factoryB,
    C Function()? factoryC,
    D Function()? factoryD,
  ]) {
    return (
      use<A>(factoryA),
      use<B>(factoryB),
      use<C>(factoryC),
      use<D>(factoryD),
    );
  }
}
