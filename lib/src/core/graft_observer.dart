import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'graft.dart';
import 'graft_change.dart';
import 'graft_state.dart';

part 'graft_dev_observer.dart';
part 'graft_dev_logger.dart';
part 'graft_dev_lifecycle_logger.dart';

/// Global observer interface for monitoring the lifecycle, transitions, dependency injection,
/// Frame-0 dry persistence, and errors across all Graft instances.
abstract class GraftObserver {
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
