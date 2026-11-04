import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'graft.dart';
import 'graft_change.dart';
import 'graft_state.dart';

export 'graft_change.dart';

part 'graft_debug_observer.dart';
part 'graft_debug_logger.dart';
part 'graft_debug_lifecycle_logger.dart';

/// Global observer interface for monitoring the lifecycle, transitions, dependency injection,
/// Frame-0 dry persistence, and errors across all Graft instances.
abstract class GraftObserver {
  /// Default base constructor for custom observers.
  const GraftObserver();

  /// Called immediately when any [Graft] instance is created.
  void onCreate(dynamic graft) {}

  /// Called whenever a [Graft] transitions state or calls `state..update()`.
  void onChange(dynamic graft, GraftChange change) {}

  /// Called whenever an unhandled error is dispatched through [Graft.addError].
  void onError(dynamic graft, Object error, StackTrace stackTrace) {}

  /// Called immediately before any [Graft] instance is disposed.
  void onDispose(dynamic graft) {}

  /// Called whenever a slot widget inside [graft] rebuilds.
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) {}

  /// Called when a DI scope is created.
  void onScopeCreated(Object scopeId, {bool preserved = false}) {}

  /// Called when a DI scope is dropped and all contained dependencies are disposed.
  void onScopeDropped(
    Object scopeId, {
    List<Type> members = const [],
    List<Type> registeredTypes = const [],
  }) {}

  /// Called when a dependency binding is registered into a DI scope.
  void onDependencyBound(
    Type type, {
    Object? scopeId,
    bool singleton = true,
    bool preserved = false,
    bool isAsync = false,
  }) {}

  /// Called when a state instance is hydrated via Frame-0 dry persistence.
  void onDryHydrated(
    GraftState state, {
    required String key,
    required bool fromCache,
  }) {}

  /// Called when dry state is invalidated and purged from persistence.
  void onDryInvalidated(
    Object target, {
    required String key,
    bool isScopePurge = false,
  }) {}
}

/// Internal composite observer delegating events to two [GraftObserver] instances.
@internal
class CompositeGraftObserver extends GraftObserver {
  final GraftObserver a;
  final GraftObserver b;
  const CompositeGraftObserver(this.a, this.b);

  @override
  void onCreate(dynamic graft) {
    a.onCreate(graft);
    b.onCreate(graft);
  }

  @override
  void onChange(dynamic graft, GraftChange change) {
    a.onChange(graft, change);
    b.onChange(graft, change);
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    a.onError(graft, error, stackTrace);
    b.onError(graft, error, stackTrace);
  }

  @override
  void onDispose(dynamic graft) {
    a.onDispose(graft);
    b.onDispose(graft);
  }

  @override
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) {
    a.onSlotRebuild(graft, slotIndex, widget);
    b.onSlotRebuild(graft, slotIndex, widget);
  }

  @override
  void onScopeCreated(Object scopeId, {bool preserved = false}) {
    a.onScopeCreated(scopeId, preserved: preserved);
    b.onScopeCreated(scopeId, preserved: preserved);
  }

  @override
  void onScopeDropped(
    Object scopeId, {
    List<Type> members = const [],
    List<Type> registeredTypes = const [],
  }) {
    a.onScopeDropped(
      scopeId,
      members: members,
      registeredTypes: registeredTypes,
    );
    b.onScopeDropped(
      scopeId,
      members: members,
      registeredTypes: registeredTypes,
    );
  }

  @override
  void onDependencyBound(
    Type type, {
    Object? scopeId,
    bool singleton = true,
    bool preserved = false,
    bool isAsync = false,
  }) {
    a.onDependencyBound(
      type,
      scopeId: scopeId,
      singleton: singleton,
      preserved: preserved,
      isAsync: isAsync,
    );
    b.onDependencyBound(
      type,
      scopeId: scopeId,
      singleton: singleton,
      preserved: preserved,
      isAsync: isAsync,
    );
  }

  @override
  void onDryHydrated(
    GraftState state, {
    required String key,
    required bool fromCache,
  }) {
    a.onDryHydrated(state, key: key, fromCache: fromCache);
    b.onDryHydrated(state, key: key, fromCache: fromCache);
  }

  @override
  void onDryInvalidated(
    Object target, {
    required String key,
    bool isScopePurge = false,
  }) {
    a.onDryInvalidated(target, key: key, isScopePurge: isScopePurge);
    b.onDryInvalidated(target, key: key, isScopePurge: isScopePurge);
  }
}
