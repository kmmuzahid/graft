part of 'graft_route_tracker.dart';

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

