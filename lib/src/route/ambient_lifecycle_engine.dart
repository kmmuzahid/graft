part of 'graft_route_tracker.dart';

void _trackerDisposeOwnedGrafts(Route<dynamic> route) {
  final emptyKeys = <AmbientKey>[];
  for (final entryMap in GraftRouteTracker._ambientPool.entries) {
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
      GraftRouteTracker._owners.remove(dead.instance);
      GraftRouteTracker._tombstones.putIfAbsent(route, () => {})[dead.instance.runtimeType] =
          dead.instance;
      route.popped.whenComplete(() {
        GraftRouteTracker._tombstones[route]?.remove(dead.instance.runtimeType);
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
    GraftRouteTracker._ambientPool.remove(k);
  }

  final privates = GraftRouteTracker._privateRouteInstances.remove(route);
  if (privates != null) {
    for (final graft in privates) {
      GraftRouteTracker._owners.remove(graft);
      if (!graft.isDisposed) {
        graft.dispose();
      }
    }
  }

  if (GraftRouteTracker._owners.isNotEmpty) {
    final ownedGrafts = <Graft>[];
    for (final entry in GraftRouteTracker._owners.entries) {
      if (identical(entry.value, route)) {
        final isStillBorrowed = GraftRouteTracker._ambientPool.values.any(
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
      GraftRouteTracker._owners.remove(graft);
    }
  }
  final removed = GraftRouteTracker._routeInstances.remove(route);
  if (removed != null && removed.isNotEmpty) {
    GraftRouteTracker._tombstones[route] = removed;
    route.popped.whenComplete(() {
      GraftRouteTracker._tombstones.remove(route);
    });
  }
}

Route<dynamic> _trackerResolveOwnerRoute(Route<dynamic> requestedRoute) {
  if (requestedRoute is PopupRoute) {
    final currentIndex = GraftRouteTracker._routeStack.lastIndexOf(requestedRoute);
    final startIndex =
        currentIndex != -1 ? currentIndex - 1 : GraftRouteTracker._routeStack.length - 1;
    for (int i = startIndex; i >= 0; i--) {
      final ancestor = GraftRouteTracker._routeStack[i];
      if (ancestor is! PopupRoute) {
        return ancestor;
      }
    }
  }
  return requestedRoute;
}

void _trackerDisposePrivateInstance(Route<dynamic> route, Graft instance) {
  GraftRouteTracker._owners.remove(instance);
  GraftRouteTracker._privateRouteInstances[route]?.remove(instance);
  if (!instance.isDisposed) {
    instance.dispose();
  }
}

void _trackerReleaseAmbientBorrower<T extends Graft>(
  Route<dynamic> route, {
  Object? key,
}) {
  final effectiveRoute = _trackerResolveOwnerRoute(route);
  final ambientKey = AmbientKey(T, key);
  final entries = GraftRouteTracker._ambientPool[ambientKey];
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
    GraftRouteTracker._owners.remove(dead.instance);
    final instMap = GraftRouteTracker._routeInstances[effectiveRoute];
    if (instMap != null) {
      instMap.remove(T);
      if (instMap.isEmpty) GraftRouteTracker._routeInstances.remove(effectiveRoute);
    }
    GraftRouteTracker._tombstones.putIfAbsent(effectiveRoute, () => {})[T] = dead.instance;
    effectiveRoute.popped.whenComplete(() {
      GraftRouteTracker._tombstones[effectiveRoute]?.remove(T);
      if (GraftRouteTracker._tombstones[effectiveRoute]?.isEmpty ?? false) {
        GraftRouteTracker._tombstones.remove(effectiveRoute);
      }
    });
    if (!dead.instance.isDisposed) {
      dead.instance.dispose();
    }
  }

  if (entries.isEmpty) {
    GraftRouteTracker._ambientPool.remove(ambientKey);
  }
}
