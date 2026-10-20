/// Hierarchy tiers and route-lease tracking tokens for Graft DI scopes.
library;

import 'package:flutter/foundation.dart';

/// Declares the persistence tier of a DI scope node.
@internal
enum ScopeTier {
  /// Immortal root container. Never disposes during app lifetime.
  root,

  /// Preserved scope. Survives screen route pops until explicitly dropped.
  preserved,

  /// Transient scope. Binds to screen routes and auto-disposes on route pop.
  transient,
}

/// Opaque lease token held by a screen route to track scope usage.
final class RouteLeaseToken {
  /// The route identifier that holds this lease.
  final Object routeId;

  /// The timestamp or frame index when this lease was acquired.
  final int acquiredAt;

  const RouteLeaseToken(this.routeId, this.acquiredAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteLeaseToken &&
          runtimeType == other.runtimeType &&
          routeId == other.routeId;

  @override
  int get hashCode => routeId.hashCode;
}
