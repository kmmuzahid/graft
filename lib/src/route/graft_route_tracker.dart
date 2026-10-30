import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../core/graft.dart';
import '../persistence/lifecycle_observer.dart';

part 'ambient_key.dart';
part 'graft_route_observer.dart';
part 'ambient_lifecycle_engine.dart';
part 'ambient_pool_engine.dart';
part 'ambient_search_engine.dart';

/// Manages route-stack scoping, ambient dependency borrowing, and ref-counted automatic disposal
/// for [Graft] instances.
class GraftRouteTracker {
  GraftRouteTracker._();

  @visibleForTesting
  static GraftRouteTracker createForTest() => GraftRouteTracker._();

  static final List<Route<dynamic>> _routeStack = [];
  static final Map<AmbientKey, List<AmbientEntry<Graft>>> _ambientPool = {};
  static final Map<Route<dynamic>, List<Graft>> _privateRouteInstances = {};
  static final Map<Route<dynamic>, Map<Type, Graft>> _routeInstances = {};
  static final Map<Graft, Route<dynamic>> _owners = {};
  static final Map<Route<dynamic>, Map<Type, Graft>> _tombstones = {};

  static final GraftRouteObserver observer = GraftRouteObserver();

  static Route<dynamic>? get currentRoute =>
      _routeStack.isNotEmpty ? _routeStack.last : null;

  static List<Route<dynamic>> get routeStack => List.unmodifiable(_routeStack);

  @internal
  static void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!_routeStack.contains(route)) {
      _routeStack.add(route);
    }
  }

  @internal
  static void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_routeStack.isNotEmpty && identical(_routeStack.last, route)) {
      _routeStack.removeLast();
    } else {
      _routeStack.remove(route);
    }
    _trackerDisposeOwnedGrafts(route);
  }

  @internal
  static void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeStack.remove(route);
    _trackerDisposeOwnedGrafts(route);
  }

  @internal
  static void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      _routeStack.remove(oldRoute);
      _trackerDisposeOwnedGrafts(oldRoute);
    }
    if (newRoute != null && !_routeStack.contains(newRoute)) {
      _routeStack.add(newRoute);
    }
  }

  @internal
  static bool isRouteTombstoned(Route<dynamic> route) =>
      _tombstones.containsKey(resolveOwnerRoute(route));

  @internal
  static Route<dynamic> resolveOwnerRoute(Route<dynamic> requestedRoute) =>
      _trackerResolveOwnerRoute(requestedRoute);

  @internal
  static T? getAmbient<T extends Graft>({
    Object? key,
    Route<dynamic>? requestingRoute,
  }) =>
      _trackerGetAmbient<T>(key: key, requestingRoute: requestingRoute);

  @visibleForTesting
  static AmbientEntry<T>? getAmbientEntry<T extends Graft>({
    Object? key,
    Route<dynamic>? requestingRoute,
  }) =>
      _trackerGetAmbientEntry<T>(key: key, requestingRoute: requestingRoute);

  @internal
  static void borrowAmbient<T extends Graft>(
    Route<dynamic> route, {
    Object? key,
  }) =>
      _trackerBorrowAmbient<T>(route, key: key);

  @internal
  static void registerAmbientRoot<T extends Graft>(
    T instance, {
    Object? key,
  }) =>
      _trackerRegisterAmbientRoot<T>(instance, key: key);

  @internal
  static void registerAmbientRoute<T extends Graft>(
    Route<dynamic> route,
    T instance, {
    Object? key,
  }) =>
      _trackerRegisterAmbientRoute<T>(route, instance, key: key);

  @internal
  static void releaseAmbientBorrower<T extends Graft>(
    Route<dynamic> route, {
    Object? key,
  }) =>
      _trackerReleaseAmbientBorrower<T>(route, key: key);

  @internal
  static void registerPrivate<T extends Graft>(
    Route<dynamic> route,
    T instance,
  ) =>
      _trackerRegisterPrivate<T>(route, instance);

  @internal
  static T? findInStack<T extends Graft>(Route<dynamic>? currentRoute) =>
      _trackerFindInStack<T>(currentRoute);

  @internal
  static void registerOwned<T extends Graft>(
    Route<dynamic> ownerRoute,
    T graft,
  ) =>
      registerAmbientRoute<T>(ownerRoute, graft);

  @visibleForTesting
  static bool hasOwner(Graft graft) => _owners.containsKey(graft);

  @visibleForTesting
  static void reset() => _trackerReset();
}
