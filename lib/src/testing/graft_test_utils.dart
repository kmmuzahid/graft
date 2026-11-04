import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import '../core/graft.dart';
import '../core/graft_change.dart';
import '../core/graft_observer.dart';
import '../core/graft_state.dart';
import '../di/graft_di.dart';
import '../di/graft_registry.dart';
import '../persistence/ambient_locator.dart';
import '../route/graft_route_tracker.dart';

/// Comprehensive hermetic testing suite and mock isolation registry for Graft.
abstract final class GraftTesting {
  /// 1. Hermetic Resets
  /// Wipes all DI scopes, root bindings, route ambient pools, persistence caches, and observers.
  static void resetAll() {
    GraftDI.reset();
    GraftRegistry.reset();
    GraftRouteTracker.reset();
    resetAmbientPersistence();
    Graft.observer = null;
  }

  /// Resets all DI scopes and root singletons.
  static void resetDI() => GraftDI.reset();

  /// Resets the ambient route registry and ownership pool.
  static void resetRoutes() => GraftRouteTracker.reset();

  /// Resets ambient persistence coordinator and L1 RAM caches.
  static void resetPersistence() => resetAmbientPersistence();

  /// 2. Dependency & Controller Overrides
  /// Overrides an ambient dependency [T] for `use<T>()`.
  static void override<T extends Object>(T mockInstance) {
    GraftDI.root.bind<T>(() => mockInstance, singleton: true);
  }

  /// Overrides a controller [G] for `context.use<G>()` and `context.create<G>()`.
  static void overrideController<G extends Graft>(G mockController) {
    GraftRegistry.registerSingleton<G>(() => mockController);
  }

  /// Executes [body] inside a scoped Zone where [overrides] are active.
  static R runWithOverrides<R>(Map<Type, Object?> overrides, R Function() body) {
    return runZoned(
      body,
      zoneValues: {GraftDI.testZoneKey: overrides},
    );
  }

  /// 3. Frame-0 Dry Persistence Testing
  /// Synchronously flushes all pending debounced disk writes for immediate verification.
  static Future<void> flushPersistence() => ambientStorageCoordinator.flush();

  /// 4. Telemetry & Change Spy
  /// Records and returns all [GraftChange] events triggered by [action].
  static List<GraftChange> recordChanges(Graft graft, void Function() action) {
    final recorded = <GraftChange>[];
    final originalObserver = Graft.observer;
    final spy = _GraftSpyObserver(graft, recorded);
    Graft.observer = spy;
    try {
      action();
      return List<GraftChange>.unmodifiable(recorded);
    } finally {
      Graft.observer = originalObserver;
    }
  }
}

class _GraftSpyObserver extends GraftObserver {
  final Graft target;
  final List<GraftChange> recorded;
  _GraftSpyObserver(this.target, this.recorded);

  @override
  void onChange(dynamic graft, GraftChange change) {
    if (identical(graft, target)) {
      recorded.add(change);
    }
  }
}

class _GraftTestObserver extends GraftObserver {
  final Graft targetGraft;
  final List<GraftChange> changes = [];
  final List<Object> errors = [];

  _GraftTestObserver(this.targetGraft);

  @override
  void onChange(dynamic graft, GraftChange change) {
    if (identical(graft, targetGraft)) {
      changes.add(change);
    }
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    if (identical(graft, targetGraft)) {
      errors.add(error);
    }
  }
}

/// Declarative testing utility for [Graft], modeled after `blocTest`.
///
/// ### Why use graftTest?
/// - **Blazing Fast (Sub-Millisecond):** Executes pure Dart unit tests without pumping widgets or inflating elements.
/// - **Clean Structure:** Standardizes tests into declarative phases: `build`, `setUp`, `seed`, `act`, `expect`, `expectChanges`, `errors`, `verify`, and `tearDown`.
/// - **Automatic Teardown:** Automatically removes listeners and disposes the [Graft] instance after the test finishes, preventing memory leaks.
/// - **Timeouts & Delays:** Easily handles asynchronous debounce or network latencies via [wait].
void graftTest<G extends Graft<S>, S extends GraftState>(
  String description, {
  required G Function() build,
  Map<Type, Object?>? overrides,
  void Function(G graft)? setUp,
  void Function(G graft)? seed,
  FutureOr<void> Function(G graft)? act,
  Duration? wait,
  dynamic Function()? expect,
  dynamic Function()? expectChanges,
  dynamic Function()? errors,
  void Function(G graft)? verify,
  void Function(G graft)? tearDown,
  dynamic tags,
}) {
  test(
    description,
    () async {
      Future<void> runTestBody() async {
        final states = <S>[];
        final graft = build();

        final originalObserver = Graft.observer;
        final testObserver = _GraftTestObserver(graft);
        Graft.observer = testObserver;

        setUp?.call(graft);
        seed?.call(graft);

        // Listen for emitted states
        void listener() {
          states.add(graft.state);
        }

        graft.addListener(listener);

        try {
          if (act != null) {
            try {
              await act(graft);
            } catch (error) {
              testObserver.errors.add(error);
            }
          }

          if (wait != null) {
            await Future.delayed(wait);
          }

          if (expect != null) {
            final expected = expect();
            expectLater(states, expected);
          }

          if (expectChanges != null) {
            final expectedChanges = expectChanges();
            expectLater(testObserver.changes, expectedChanges);
          }

          if (errors != null) {
            final expectedErrors = errors();
            expectLater(testObserver.errors, expectedErrors);
          } else if (testObserver.errors.isNotEmpty) {
            final firstError = testObserver.errors.first;
            throw firstError;
          }

          verify?.call(graft);
        } finally {
          graft.removeListener(listener);
          Graft.observer = originalObserver;
          tearDown?.call(graft);
          if (!graft.isDisposed) {
            graft.dispose();
          }
        }
      }

      if (overrides != null && overrides.isNotEmpty) {
        await runZoned(
          () => runTestBody(),
          zoneValues: {GraftDI.testZoneKey: overrides},
        );
      } else {
        await runTestBody();
      }
    },
    tags: tags,
  );
}
