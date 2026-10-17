import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/graft.dart';

/// Manages route-stack scoping, dependency inheritance, and owner-based automatic disposal
/// for [Graft] instances.
///
/// ### Why use GraftRouteTracker?
/// - **Route-Scoped Memory Management:** Screens down the navigation stack can inherit existing
///   controllers from ancestor screens without passing them through constructors or route arguments.
/// - **Owner-Based Auto-Disposal:** The screen that originally initiated a Graft is registered as its
///   **Owner**. When that owner screen pops off the navigation stack, its owned Grafts are automatically
///   disposed and freed from memory.
/// - **Zero Memory Leaks:** Avoids manual `dispose()` calls in `StatefulWidget.dispose()`.
///
/// ### Setup:
/// Add [GraftRouteObserver] to your application's `navigatorObservers`:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     GraftRouteObserver(), // Enables automatic route tracking
///   ],
///   home: const HomeScreen(),
/// );
/// ```
class GraftRouteTracker {
  GraftRouteTracker._();

  /// Internal constructor test helper.
  @visibleForTesting
  static GraftRouteTracker createForTest() => GraftRouteTracker._();

  static final List<Route<dynamic>> _routeStack = [];
  static final Map<Route<dynamic>, Map<Type, Graft>> _routeInstances = {};
  static final Map<Graft, Route<dynamic>> _owners = {};

  /// Shared [GraftRouteObserver] instance for convenient registration in `MaterialApp.navigatorObservers`.
  static final GraftRouteObserver observer = GraftRouteObserver();

  /// Returns the top-most active route, or null if no routes are currently tracked.
  static Route<dynamic>? get currentRoute =>
      _routeStack.isNotEmpty ? _routeStack.last : null;

  /// Returns the active route stack (read-only snapshot).
  static List<Route<dynamic>> get routeStack => List.unmodifiable(_routeStack);

  /// Called when a route is pushed onto the navigator stack.
  @internal
  static void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!_routeStack.contains(route)) {
      _routeStack.add(route);
    }
  }

  /// Called when a route is popped from the navigator stack.
  ///
  /// Automatically disposes all [Graft] instances owned by [route].
  @internal
  static void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_routeStack.isNotEmpty && identical(_routeStack.last, route)) {
      _routeStack.removeLast();
    } else {
      _routeStack.remove(route);
    }
    _disposeOwnedGrafts(route);
  }

  /// Called when a route is removed from the navigator.
  ///
  /// Automatically disposes all [Graft] instances owned by [route].
  @internal
  static void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeStack.remove(route);
    _disposeOwnedGrafts(route);
  }

  /// Called when a route is replaced in the navigator.
  ///
  /// Automatically disposes any [Graft] instances owned by [oldRoute].
  @internal
  static void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      _routeStack.remove(oldRoute);
      _disposeOwnedGrafts(oldRoute);
    }
    if (newRoute != null && !_routeStack.contains(newRoute)) {
      _routeStack.add(newRoute);
    }
  }

  /// Disposes all [Graft] instances owned by [route].
  static void _disposeOwnedGrafts(Route<dynamic> route) {
    if (_owners.isEmpty && _routeInstances.isEmpty) return;
    if (_owners.isNotEmpty) {
      final ownedGrafts = <Graft>[];
      for (final entry in _owners.entries) {
        if (identical(entry.value, route)) {
          ownedGrafts.add(entry.key);
        }
      }
      for (final graft in ownedGrafts) {
        if (!graft.isDisposed) {
          graft.dispose();
        }
        _owners.remove(graft);
      }
    }
    _routeInstances.remove(route);
  }

  /// Resolves the true persistent owner route for [requestedRoute].
  ///
  /// If [requestedRoute] is a transient route (such as a [PopupRoute] used for
  /// Dialogs, Menus, or BottomSheets), walks backwards through the navigation stack
  /// to anchor ownership to the underlying persistent [PageRoute].
  @internal
  static Route<dynamic> resolveOwnerRoute(Route<dynamic> requestedRoute) {
    if (requestedRoute is PopupRoute) {
      final currentIndex = _routeStack.lastIndexOf(requestedRoute);
      final startIndex = currentIndex != -1 ? currentIndex - 1 : _routeStack.length - 1;
      for (int i = startIndex; i >= 0; i--) {
        final ancestor = _routeStack[i];
        if (ancestor is! PopupRoute) {
          return ancestor;
        }
      }
    }
    return requestedRoute;
  }

  /// Looks up an existing [Graft] of type [T] in [currentRoute] or predecessor ancestor routes
  /// in the active navigation stack.
  ///
  /// Returns `null` if no active instance is found.
  @internal
  static T? findInStack<T extends Graft>(Route<dynamic>? currentRoute) {
    if (currentRoute == null) return null;

    final effectiveCurrent = resolveOwnerRoute(currentRoute);

    // 1. Check current route's instances
    final currentInstances = _routeInstances[effectiveCurrent];
    if (currentInstances != null && currentInstances.containsKey(T)) {
      return currentInstances[T] as T;
    }

    // 2. Search backwards in the active route stack
    final currentIndex = _routeStack.lastIndexOf(effectiveCurrent);
    final startIndex = currentIndex != -1 ? currentIndex - 1 : _routeStack.length - 1;

    for (int i = startIndex; i >= 0; i--) {
      final ancestorRoute = _routeStack[i];
      // Only inherit from ancestor routes that belong to the same Navigator:
      if (effectiveCurrent.navigator != null &&
          ancestorRoute.navigator != null &&
          ancestorRoute.navigator != effectiveCurrent.navigator) {
        continue;
      }
      final ancestorInstances = _routeInstances[ancestorRoute];
      if (ancestorInstances != null && ancestorInstances.containsKey(T)) {
        final existing = ancestorInstances[T] as T;
        // Cache reference on current route for faster subsequent lookups
        _routeInstances.putIfAbsent(effectiveCurrent, () => {})[T] = existing;
        return existing;
      }
    }

    return null;
  }

  /// Registers [graft] as owned by [ownerRoute].
  ///
  /// When [ownerRoute] pops, [graft] will be disposed automatically.
  @internal
  static void registerOwned<T extends Graft>(Route<dynamic> ownerRoute, T graft) {
    final effectiveOwner = resolveOwnerRoute(ownerRoute);

    if (!_routeStack.contains(effectiveOwner)) {
      _routeStack.add(effectiveOwner);
    }

    _owners[graft] = effectiveOwner;
    _routeInstances.putIfAbsent(effectiveOwner, () => {})[T] = graft;

    // Safety fallback: attach to route.popped future
    effectiveOwner.popped.then((_) {
      if (!graft.isDisposed) {
        graft.dispose();
      }
      _owners.remove(graft);
      _routeInstances.remove(effectiveOwner);
    });
  }

  /// Checks if [graft] is currently registered to an active owner route.
  @visibleForTesting
  static bool hasOwner(Graft graft) => _owners.containsKey(graft);

  /// Resets all route tracking state and disposes tracked instances.
  ///
  /// Call in unit/widget test `tearDown` to ensure clean test isolation:
  /// ```dart
  /// tearDown(() {
  ///   GraftRouteTracker.reset();
  /// });
  /// ```
  @visibleForTesting
  static void reset() {
    _routeStack.clear();
    for (final graft in _owners.keys) {
      if (!graft.isDisposed) {
        graft.dispose();
      }
    }
    _owners.clear();
    _routeInstances.clear();
  }
}

/// Navigator observer that automatically keeps [GraftRouteTracker] in sync with navigation events.
///
/// ### Why use GraftRouteObserver?
/// Adding this to `MaterialApp.navigatorObservers` enables seamless, automatic dependency
/// inheritance and memory management across Flutter routes.
///
/// ### Example:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     GraftRouteObserver(),
///   ],
///   home: const HomeScreen(),
/// );
/// ```
class GraftRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    GraftRouteTracker.didPush(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    GraftRouteTracker.didPop(route, previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    GraftRouteTracker.didRemove(route, previousRoute);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    GraftRouteTracker.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

