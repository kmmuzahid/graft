part of 'graft_route_tracker.dart';

T? _trackerGetAmbient<T extends Graft>({
  Object? key,
  Route<dynamic>? requestingRoute,
}) {
  final ambientKey = AmbientKey(T, key);
  final entries = GraftRouteTracker._ambientPool[ambientKey];
  if (entries == null || entries.isEmpty) return null;

  for (final entry in entries) {
    if (entry.isRoot) return entry.instance as T;
  }
  if (requestingRoute == null) return entries.last.instance as T;

  final effectiveRequest = _trackerResolveOwnerRoute(requestingRoute);
  for (final entry in entries) {
    final matches = entry.borrowerRoutes.any((borrower) {
      if (effectiveRequest.navigator == null || borrower.navigator == null) {
        return true;
      }
      return effectiveRequest.navigator == borrower.navigator;
    });
    if (matches) return entry.instance as T;
  }
  return null;
}

AmbientEntry<T>? _trackerGetAmbientEntry<T extends Graft>({
  Object? key,
  Route<dynamic>? requestingRoute,
}) {
  final ambientKey = AmbientKey(T, key);
  final entries = GraftRouteTracker._ambientPool[ambientKey];
  if (entries == null || entries.isEmpty) return null;

  for (final entry in entries) {
    if (entry.isRoot) return entry as AmbientEntry<T>;
  }
  if (requestingRoute == null) return entries.last as AmbientEntry<T>;

  final effectiveRequest = _trackerResolveOwnerRoute(requestingRoute);
  for (final entry in entries) {
    final matches = entry.borrowerRoutes.any((borrower) {
      if (effectiveRequest.navigator == null || borrower.navigator == null) {
        return true;
      }
      return effectiveRequest.navigator == borrower.navigator;
    });
    if (matches) return entry as AmbientEntry<T>;
  }
  return null;
}

void _trackerBorrowAmbient<T extends Graft>(
  Route<dynamic> route, {
  Object? key,
}) {
  final effectiveRoute = _trackerResolveOwnerRoute(route);
  final ambientKey = AmbientKey(T, key);
  final entries = GraftRouteTracker._ambientPool[ambientKey];
  if (entries == null || entries.isEmpty) return;

  if (!GraftRouteTracker._routeStack.contains(effectiveRoute)) {
    GraftRouteTracker._routeStack.add(effectiveRoute);
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
      _trackerReleaseAmbientBorrower<T>(effectiveRoute, key: key);
    });
  }
}

void _trackerRegisterAmbientRoot<T extends Graft>(T instance, {Object? key}) {
  final ambientKey = AmbientKey(T, key);
  final entry = AmbientEntry<T>(instance: instance, refCount: 1, isRoot: true);
  GraftRouteTracker._ambientPool.putIfAbsent(ambientKey, () => []).add(entry);
}

void _trackerRegisterAmbientRoute<T extends Graft>(
  Route<dynamic> route,
  T instance, {
  Object? key,
}) {
  final effectiveRoute = _trackerResolveOwnerRoute(route);
  if (!GraftRouteTracker._routeStack.contains(effectiveRoute)) {
    GraftRouteTracker._routeStack.add(effectiveRoute);
  }

  final ambientKey = AmbientKey(T, key);
  final entry = AmbientEntry<T>(instance: instance, refCount: 1, isRoot: false);
  entry.borrowerRoutes.add(effectiveRoute);
  GraftRouteTracker._ambientPool.putIfAbsent(ambientKey, () => []).add(entry);
  GraftRouteTracker._owners[instance] = effectiveRoute;
  GraftRouteTracker._routeInstances.putIfAbsent(effectiveRoute, () => {})[T] = instance;

  effectiveRoute.popped.then((_) {
    _trackerReleaseAmbientBorrower<T>(effectiveRoute, key: key);
  });
}
