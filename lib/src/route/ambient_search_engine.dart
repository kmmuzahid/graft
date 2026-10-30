part of 'graft_route_tracker.dart';

void _trackerRegisterPrivate<T extends Graft>(Route<dynamic> route, T instance) {
  final effectiveRoute = _trackerResolveOwnerRoute(route);
  if (!GraftRouteTracker._routeStack.contains(effectiveRoute)) {
    GraftRouteTracker._routeStack.add(effectiveRoute);
  }
  GraftRouteTracker._owners[instance] = effectiveRoute;
  GraftRouteTracker._privateRouteInstances.putIfAbsent(effectiveRoute, () => []).add(instance);

  effectiveRoute.popped.then((_) {
    _trackerDisposePrivateInstance(effectiveRoute, instance);
  });
}

T? _trackerFindInStack<T extends Graft>(Route<dynamic>? currentRoute) {
  final ambient = _trackerGetAmbient<T>(requestingRoute: currentRoute);
  if (ambient != null) return ambient;
  if (currentRoute == null) return null;

  final effectiveCurrent = _trackerResolveOwnerRoute(currentRoute);
  final currentInstances = GraftRouteTracker._routeInstances[effectiveCurrent];
  if (currentInstances != null && currentInstances.containsKey(T)) {
    return currentInstances[T] as T;
  }

  final tombstoned = GraftRouteTracker._tombstones[effectiveCurrent];
  if (tombstoned != null && tombstoned.containsKey(T)) {
    return tombstoned[T] as T;
  }

  final currentIndex = GraftRouteTracker._routeStack.lastIndexOf(effectiveCurrent);
  final startIndex = currentIndex != -1 ? currentIndex - 1 : GraftRouteTracker._routeStack.length - 1;

  for (int i = startIndex; i >= 0; i--) {
    final ancestorRoute = GraftRouteTracker._routeStack[i];
    if (effectiveCurrent.navigator != null &&
        ancestorRoute.navigator != null &&
        ancestorRoute.navigator != effectiveCurrent.navigator) {
      continue;
    }
    final ancestorInstances = GraftRouteTracker._routeInstances[ancestorRoute];
    if (ancestorInstances != null && ancestorInstances.containsKey(T)) {
      final existing = ancestorInstances[T] as T;
      GraftRouteTracker._routeInstances.putIfAbsent(effectiveCurrent, () => {})[T] = existing;
      return existing;
    }
  }
  return null;
}

void _trackerReset() {
  GraftRouteTracker._routeStack.clear();
  for (final list in GraftRouteTracker._ambientPool.values) {
    for (final entry in list) {
      if (!entry.instance.isDisposed) {
        entry.instance.dispose();
      }
    }
  }
  GraftRouteTracker._ambientPool.clear();
  for (final list in GraftRouteTracker._privateRouteInstances.values) {
    for (final graft in list) {
      if (!graft.isDisposed) {
        graft.dispose();
      }
    }
  }
  GraftRouteTracker._privateRouteInstances.clear();
  for (final graft in GraftRouteTracker._owners.keys) {
    if (!graft.isDisposed) {
      graft.dispose();
    }
  }
  GraftRouteTracker._owners.clear();
  GraftRouteTracker._routeInstances.clear();
  GraftRouteTracker._tombstones.clear();
}

