import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../persistence/lifecycle_observer.dart';

/// Unique key for ambient pool lookups, supporting optional family/tag keys.
@immutable
class AmbientKey {
  final Type type;
  final Object? key;

  const AmbientKey(this.type, [this.key]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbientKey &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          key == other.key;

  @override
  int get hashCode => Object.hash(type, key);

  @override
  String toString() => key == null ? '$type' : '$type(key: $key)';
}

/// Ref-counted lifecycle container for an ambient [Graft] instance.
class AmbientEntry<T extends Graft> {
  final T instance;
  int refCount;
  final bool isRoot;
  final Set<Route<dynamic>> borrowerRoutes;

  AmbientEntry({
    required this.instance,
    this.refCount = 1,
    this.isRoot = false,
  }) : borrowerRoutes = <Route<dynamic>>{};
}

/// Manages route-stack scoping, ambient dependency borrowing, and ref-counted automatic disposal
/// for [Graft] instances.
///
/// ### Why use GraftRouteTracker?
/// - **Zero-Wrapper Ambient Engine:** Screens inherit active controllers across navigation flows
///   with zero configuration and zero scope wrappers (`context.use<T>()`).
/// - **Ref-Counted Disposal:** Instances are kept alive across route pushes (including `pushReplacement`),
///   and are automatically disposed when the last borrower route pops off the stack.
/// - **App-Root Auto-Promotion:** When `context.use<T>()` is called above `Navigator` (`route == null`),
///   the controller is auto-promoted to a permanent app-wide singleton (`isRoot: true`).
/// - **Branch Hierarchy Isolation:** Independent tabs with separate navigators maintain isolated
///   instances automatically.
/// - **Private Route Isolation:** `context.create<T>()` anchors isolated controllers to the caller
///   route without polluting the ambient pool.
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
  static final Map<AmbientKey, List<AmbientEntry<Graft>>> _ambientPool = {};
  static final Map<Route<dynamic>, List<Graft>> _privateRouteInstances = {};
  static final Map<Route<dynamic>, Map<Type, Graft>> _routeInstances = {};
  static final Map<Graft, Route<dynamic>> _owners = {};
  static final Map<Route<dynamic>, Map<Type, Graft>> _tombstones = {};

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
  /// Automatically disposes all [Graft] instances owned or borrowed exclusively by [route].
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
  /// Automatically disposes all [Graft] instances owned or borrowed exclusively by [route].
  @internal
  static void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeStack.remove(route);
    _disposeOwnedGrafts(route);
  }

  /// Called when a route is replaced in the navigator.
  ///
  /// Automatically disposes any [Graft] instances owned or borrowed exclusively by [oldRoute].
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

  /// Disposes all [Graft] instances owned or borrowed exclusively by [route].
  static void _disposeOwnedGrafts(Route<dynamic> route) {
    // 1. Release all ambient entries where route was a registered borrower
    final emptyKeys = <AmbientKey>[];
    for (final entryMap in _ambientPool.entries) {
      final entries = entryMap.value;
      final deadEntries = <AmbientEntry<Graft>>[];
      for (final entry in entries) {
        if (entry.borrowerRoutes.remove(route)) {
          entry.refCount--;
          if (entry.refCount <= 0 && !entry.isRoot) {
            deadEntries.add(entry);
          }
        }
      }
      for (final dead in deadEntries) {
        entries.remove(dead);
        _owners.remove(dead.instance);
        _tombstones.putIfAbsent(route, () => {})[dead.instance.runtimeType] =
            dead.instance;
        route.popped.whenComplete(() {
          _tombstones[route]?.remove(dead.instance.runtimeType);
        });
        if (!dead.instance.isDisposed) {
          dead.instance.dispose();
        }
      }
      if (entries.isEmpty) {
        emptyKeys.add(entryMap.key);
      }
    }
    for (final k in emptyKeys) {
      _ambientPool.remove(k);
    }

    // 2. Dispose all private instances for this route (context.create)
    final privates = _privateRouteInstances.remove(route);
    if (privates != null) {
      for (final graft in privates) {
        _owners.remove(graft);
        if (!graft.isDisposed) {
          graft.dispose();
        }
      }
    }

    // 3. Clean up legacy routeInstances and owners (only if not actively borrowed by other routes)
    if (_owners.isNotEmpty) {
      final ownedGrafts = <Graft>[];
      for (final entry in _owners.entries) {
        if (identical(entry.value, route)) {
          final isStillBorrowed = _ambientPool.values.any(
            (list) => list.any(
              (ambientEntry) =>
                  identical(ambientEntry.instance, entry.key) &&
                  ambientEntry.refCount > 0,
            ),
          );
          if (!isStillBorrowed) {
            ownedGrafts.add(entry.key);
          }
        }
      }
      for (final graft in ownedGrafts) {
        if (!graft.isDisposed) {
          graft.dispose();
        }
        _owners.remove(graft);
      }
    }
    final removed = _routeInstances.remove(route);
    if (removed != null && removed.isNotEmpty) {
      _tombstones[route] = removed;
      route.popped.whenComplete(() {
        _tombstones.remove(route);
      });
    }
  }

  /// Checks whether [route] has been disposed and is currently in unmount/tombstone phase.
  @internal
  static bool isRouteTombstoned(Route<dynamic> route) =>
      _tombstones.containsKey(resolveOwnerRoute(route));

  /// Resolves the true persistent owner route for [requestedRoute].
  ///
  /// If [requestedRoute] is a transient route (such as a [PopupRoute] used for
  /// Dialogs, Menus, or BottomSheets), walks backwards through the navigation stack
  /// to anchor ownership to the underlying persistent [PageRoute].
  @internal
  static Route<dynamic> resolveOwnerRoute(Route<dynamic> requestedRoute) {
    if (requestedRoute is PopupRoute) {
      final currentIndex = _routeStack.lastIndexOf(requestedRoute);
      final startIndex =
          currentIndex != -1 ? currentIndex - 1 : _routeStack.length - 1;
      for (int i = startIndex; i >= 0; i--) {
        final ancestor = _routeStack[i];
        if (ancestor is! PopupRoute) {
          return ancestor;
        }
      }
    }
    return requestedRoute;
  }

  /// Resolves an active ambient instance of type [T] from the ambient pool, or null if absent.
  @internal
  static T? getAmbient<T extends Graft>({
    Object? key,
    Route<dynamic>? requestingRoute,
  }) {
    final ambientKey = AmbientKey(T, key);
    final entries = _ambientPool[ambientKey];
    if (entries == null || entries.isEmpty) return null;

    // 1. If there's an App-Root entry, it's global for the entire app
    for (final entry in entries) {
      if (entry.isRoot) {
        return entry.instance as T;
      }
    }

    if (requestingRoute == null) {
      return entries.last.instance as T;
    }

    final effectiveRequest = resolveOwnerRoute(requestingRoute);

    // 2. Find entry whose borrowers belong to the same Navigator branch
    for (final entry in entries) {
      final matches = entry.borrowerRoutes.any((borrower) {
        if (effectiveRequest.navigator == null || borrower.navigator == null) {
          return true;
        }
        return effectiveRequest.navigator == borrower.navigator;
      });
      if (matches) {
        return entry.instance as T;
      }
    }

    return null;
  }

  /// Resolves the internal ambient entry for [T], useful for testing refCounts.
  @visibleForTesting
  static AmbientEntry<T>? getAmbientEntry<T extends Graft>({
    Object? key,
    Route<dynamic>? requestingRoute,
  }) {
    final ambientKey = AmbientKey(T, key);
    final entries = _ambientPool[ambientKey];
    if (entries == null || entries.isEmpty) return null;

    for (final entry in entries) {
      if (entry.isRoot) {
        return entry as AmbientEntry<T>;
      }
    }

    if (requestingRoute == null) {
      return entries.last as AmbientEntry<T>;
    }

    final effectiveRequest = resolveOwnerRoute(requestingRoute);

    for (final entry in entries) {
      final matches = entry.borrowerRoutes.any((borrower) {
        if (effectiveRequest.navigator == null || borrower.navigator == null) {
          return true;
        }
        return effectiveRequest.navigator == borrower.navigator;
      });
      if (matches) {
        return entry as AmbientEntry<T>;
      }
    }

    return null;
  }

  /// Borrows an existing ambient instance on behalf of [route].
  ///
  /// Increments `refCount` if [route] has not already borrowed it.
  @internal
  static void borrowAmbient<T extends Graft>(
    Route<dynamic> route, {
    Object? key,
  }) {
    final effectiveRoute = resolveOwnerRoute(route);
    final ambientKey = AmbientKey(T, key);
    final entries = _ambientPool[ambientKey];
    if (entries == null || entries.isEmpty) return;

    if (!_routeStack.contains(effectiveRoute)) {
      _routeStack.add(effectiveRoute);
    }

    AmbientEntry<Graft>? targetEntry;
    for (final entry in entries) {
      if (entry.isRoot) {
        targetEntry = entry;
        break;
      }
      final matches = entry.borrowerRoutes.any((borrower) {
        if (effectiveRoute.navigator == null || borrower.navigator == null) {
          return true;
        }
        return effectiveRoute.navigator == borrower.navigator;
      });
      if (matches) {
        targetEntry = entry;
        break;
      }
    }

    targetEntry ??= entries.last;

    if (targetEntry.borrowerRoutes.add(effectiveRoute)) {
      targetEntry.refCount++;
      effectiveRoute.popped.then((_) {
        releaseAmbientBorrower<T>(effectiveRoute, key: key);
      });
    }
  }

  /// Registers [instance] as a permanent App-Root singleton (`isRoot: true`).
  ///
  /// App-Root instances remain alive for the entire session and are never auto-disposed.
  @internal
  static void registerAmbientRoot<T extends Graft>(
    T instance, {
    Object? key,
  }) {
    final ambientKey = AmbientKey(T, key);
    final entry = AmbientEntry<T>(
      instance: instance,
      refCount: 1,
      isRoot: true,
    );
    _ambientPool.putIfAbsent(ambientKey, () => []).add(entry);
  }

  /// Registers [instance] into the ambient pool with [route] as its first borrower.
  @internal
  static void registerAmbientRoute<T extends Graft>(
    Route<dynamic> route,
    T instance, {
    Object? key,
  }) {
    final effectiveRoute = resolveOwnerRoute(route);
    if (!_routeStack.contains(effectiveRoute)) {
      _routeStack.add(effectiveRoute);
    }

    final ambientKey = AmbientKey(T, key);
    final entry = AmbientEntry<T>(
      instance: instance,
      refCount: 1,
      isRoot: false,
    );
    entry.borrowerRoutes.add(effectiveRoute);
    _ambientPool.putIfAbsent(ambientKey, () => []).add(entry);
    _owners[instance] = effectiveRoute;
    _routeInstances.putIfAbsent(effectiveRoute, () => {})[T] = instance;

    effectiveRoute.popped.then((_) {
      releaseAmbientBorrower<T>(effectiveRoute, key: key);
    });
  }

  /// Releases a borrower [route] from the ambient entry of type [T].
  ///
  /// When `refCount <= 0` and `!isRoot`, automatically disposes the instance and purges the entry.
  @internal
  static void releaseAmbientBorrower<T extends Graft>(
    Route<dynamic> route, {
    Object? key,
  }) {
    final effectiveRoute = resolveOwnerRoute(route);
    final ambientKey = AmbientKey(T, key);
    final entries = _ambientPool[ambientKey];
    if (entries == null || entries.isEmpty) return;

    final deadEntries = <AmbientEntry<Graft>>[];
    for (final entry in entries) {
      if (entry.borrowerRoutes.remove(effectiveRoute)) {
        entry.refCount--;
        if (entry.refCount <= 0 && !entry.isRoot) {
          deadEntries.add(entry);
        }
      }
    }

    for (final dead in deadEntries) {
      entries.remove(dead);
      _owners.remove(dead.instance);
      final instMap = _routeInstances[effectiveRoute];
      if (instMap != null) {
        instMap.remove(T);
        if (instMap.isEmpty) _routeInstances.remove(effectiveRoute);
      }
      _tombstones.putIfAbsent(effectiveRoute, () => {})[T] = dead.instance;
      effectiveRoute.popped.whenComplete(() {
        _tombstones[effectiveRoute]?.remove(T);
        if (_tombstones[effectiveRoute]?.isEmpty ?? false) {
          _tombstones.remove(effectiveRoute);
        }
      });
      if (!dead.instance.isDisposed) {
        dead.instance.dispose();
      }
    }

    if (entries.isEmpty) {
      _ambientPool.remove(ambientKey);
    }
  }

  /// Registers [instance] as a private route-owned controller (`context.create`).
  ///
  /// Bypasses the ambient pool entirely and disposes when [route] pops.
  @internal
  static void registerPrivate<T extends Graft>(
    Route<dynamic> route,
    T instance,
  ) {
    final effectiveRoute = resolveOwnerRoute(route);
    if (!_routeStack.contains(effectiveRoute)) {
      _routeStack.add(effectiveRoute);
    }
    _owners[instance] = effectiveRoute;
    _privateRouteInstances.putIfAbsent(effectiveRoute, () => []).add(instance);

    effectiveRoute.popped.then((_) {
      _disposePrivateInstance(effectiveRoute, instance);
    });
  }

  static void _disposePrivateInstance(Route<dynamic> route, Graft instance) {
    _owners.remove(instance);
    _privateRouteInstances[route]?.remove(instance);
    if (!instance.isDisposed) {
      instance.dispose();
    }
  }

  /// Looks up an existing [Graft] of type [T] in [currentRoute] or predecessor ancestor routes.
  @internal
  static T? findInStack<T extends Graft>(Route<dynamic>? currentRoute) {
    final ambient = getAmbient<T>(requestingRoute: currentRoute);
    if (ambient != null) return ambient;

    if (currentRoute == null) return null;
    final effectiveCurrent = resolveOwnerRoute(currentRoute);

    final currentInstances = _routeInstances[effectiveCurrent];
    if (currentInstances != null && currentInstances.containsKey(T)) {
      return currentInstances[T] as T;
    }

    final tombstoned = _tombstones[effectiveCurrent];
    if (tombstoned != null && tombstoned.containsKey(T)) {
      return tombstoned[T] as T;
    }

    final currentIndex = _routeStack.lastIndexOf(effectiveCurrent);
    final startIndex =
        currentIndex != -1 ? currentIndex - 1 : _routeStack.length - 1;

    for (int i = startIndex; i >= 0; i--) {
      final ancestorRoute = _routeStack[i];
      if (effectiveCurrent.navigator != null &&
          ancestorRoute.navigator != null &&
          ancestorRoute.navigator != effectiveCurrent.navigator) {
        continue;
      }
      final ancestorInstances = _routeInstances[ancestorRoute];
      if (ancestorInstances != null && ancestorInstances.containsKey(T)) {
        final existing = ancestorInstances[T] as T;
        _routeInstances.putIfAbsent(effectiveCurrent, () => {})[T] = existing;
        return existing;
      }
    }

    return null;
  }

  /// Registers [graft] as owned by [ownerRoute].
  @internal
  static void registerOwned<T extends Graft>(
    Route<dynamic> ownerRoute,
    T graft,
  ) {
    registerAmbientRoute<T>(ownerRoute, graft);
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

    for (final list in _ambientPool.values) {
      for (final entry in list) {
        if (!entry.instance.isDisposed) {
          entry.instance.dispose();
        }
      }
    }
    _ambientPool.clear();

    for (final list in _privateRouteInstances.values) {
      for (final graft in list) {
        if (!graft.isDisposed) {
          graft.dispose();
        }
      }
    }
    _privateRouteInstances.clear();

    for (final graft in _owners.keys) {
      if (!graft.isDisposed) {
        graft.dispose();
      }
    }
    _owners.clear();
    _routeInstances.clear();
    _tombstones.clear();
  }
}

/// Navigator observer that automatically keeps [GraftRouteTracker] in sync with navigation events.
class GraftRouteObserver extends NavigatorObserver {
  GraftRouteObserver() {
    GraftLifecycleObserver.instance.attach();
  }

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
