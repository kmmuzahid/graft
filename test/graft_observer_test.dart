import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class CounterState extends GraftState {
  int count;
  CounterState(this.count);

  @override
  GraftProps get props => propsOf(count);

  @override
  void onReset() {
    count = 0;
  }
}

class CounterGraft extends Graft<CounterState> {
  CounterGraft() : super(CounterState(0));

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void setCount(int val) {
    state
      ..count = val
      ..update();
  }

  void triggerError(Object error) {
    addError(error);
  }
}

class TestObserver extends GraftObserver {
  final List<String> logs = [];

  @override
  void onCreate(dynamic graft) {
    super.onCreate(graft);
    logs.add('create: ${graft.runtimeType}');
  }

  @override
  void onChange(dynamic graft, GraftChange change) {
    super.onChange(graft, change);
    logs.add('change: ${change.currentState} -> ${change.nextState}');
  }

  @override
  void onError(dynamic graft, Object error, StackTrace stackTrace) {
    super.onError(graft, error, stackTrace);
    logs.add('error: $error');
  }

  @override
  void onDispose(dynamic graft) {
    super.onDispose(graft);
    logs.add('dispose: ${graft.runtimeType}');
  }
}

void main() {
  group('GraftObserver & GraftChange Tests', () {
    tearDown(() {
      Graft.observer = null;
    });

    test('Custom GraftObserver receives all lifecycle hooks', () {
      final observer = TestObserver();
      Graft.observer = observer;

      final graft = CounterGraft();
      expect(observer.logs, contains('create: CounterGraft'));

      graft.increment();
      expect(observer.logs.any((l) => l.startsWith('change:')), isTrue);

      final error = Exception('test failure');
      graft.triggerError(error);
      expect(observer.logs, contains('error: Exception: test failure'));

      graft.dispose();
      expect(observer.logs, contains('dispose: CounterGraft'));
    });

    test('GraftDevObserver formats and logs lifecycle events and slot rebuilds', () {
      final devObserver = GraftDevObserver(logRebuilds: true, enableTimeline: true);
      Graft.observer = devObserver;

      final graft = CounterGraft();
      graft.increment();
      devObserver.onSlotRebuild(graft, 0, const Text('slot'));
      graft.triggerError(Exception('sample error'));
      graft.dispose();

      expect(graft.isDisposed, isTrue);

      final defaultObserver = TestObserver();
      defaultObserver.onSlotRebuild(graft, 0, const Text('slot'));
    });

    test('GraftRouteTracker currentRoute and routeStack getters', () {
      expect(GraftRouteTracker.routeStack, isA<List<Route<dynamic>>>());
      // When empty, currentRoute is null
      if (GraftRouteTracker.routeStack.isEmpty) {
        expect(GraftRouteTracker.currentRoute, isNull);
      }
    });

    test('GraftChange equality, hashCode and toString', () {
      final s1 = CounterState(1);
      final s2 = CounterState(2);
      final change1 = GraftChange<CounterState>(currentState: s1, nextState: s2);
      final change2 = GraftChange<CounterState>(currentState: s1, nextState: s2);
      final change3 = GraftChange<CounterState>(currentState: s2, nextState: s1);

      expect(change1 == change2, isTrue);
      expect(change1 == change3, isFalse);
      expect(change1 == Object(), isFalse);
      expect(change1.hashCode, equals(change2.hashCode));
      expect(change1.toString(), contains('GraftChange(current:'));
    });

    test('Graft core listenable and disposed notify warnings', () {
      final graft = CounterGraft();

      // listenable
      expect(graft.listenable, isA<ValueListenable<CounterState>>());
      expect(graft.listenable.value.count, 0);

      // state update
      graft.setCount(10);
      expect(graft.state.count, 10);

      // listener add and remove
      var notified = false;
      void listener() => notified = true;
      graft.addListener(listener);
      graft.increment();
      expect(notified, isTrue);

      graft.removeListener(listener);
      notified = false;
      graft.increment();
      expect(notified, isFalse);

      // notify on disposed
      graft.dispose();
      expect(graft.isDisposed, isTrue);
      graft.notify(); // hits debugPrint warning
      graft.addListener(listener); // no-op when disposed
      graft.removeListener(listener); // no-op when disposed
    });

    test('GraftValue toString', () {
      final val = GraftValue<int>(42);
      expect(val.toString(), equals('42'));
    });

    test('GraftRegistry unregister and isRegistered', () {
      GraftRegistry.register<CounterGraft>(CounterGraft.new);
      expect(GraftRegistry.isRegistered<CounterGraft>(), isTrue);

      GraftRegistry.unregister<CounterGraft>();
      expect(GraftRegistry.isRegistered<CounterGraft>(), isFalse);
    });

    test('GraftObserver receives DI scope creation, bindings, and drop with active members', () {
      final scopeCreatedLogs = <String>[];
      final scopeDroppedLogs = <String>[];
      final boundTypes = <Type>[];

      final observer = _FullTestObserver(
        onScopeCreatedCallback: (s, {preserved = false}) =>
            scopeCreatedLogs.add('$s (preserved: $preserved)'),
        onScopeDroppedCallback: (s, {members = const [], registeredTypes = const []}) =>
            scopeDroppedLogs.add('$s: members=$members, registered=$registeredTypes'),
        onDependencyBoundCallback: (t, {scopeId, singleton = true, preserved = false, isAsync = false}) =>
            boundTypes.add(t),
      );
      Graft.observer = observer;

      scope(TestScope.auth, () {
        bind(CounterGraft.new);
        bindAsync(() async => 'async_val');
      });

      expect(scopeCreatedLogs, contains('${TestScope.auth} (preserved: false)'));
      expect(boundTypes, contains(CounterGraft));
      expect(boundTypes, contains(String));

      // Resolve member inside scope
      final resolved = GraftDI.getScope(TestScope.auth).resolve<CounterGraft>();
      expect(resolved, isNotNull);

      // Drop scope
      TestScope.auth.drop();

      expect(scopeDroppedLogs.length, 1);
      expect(scopeDroppedLogs.first, contains('${TestScope.auth}'));
      expect(scopeDroppedLogs.first, contains('CounterGraft'));
    });

    test('GraftObserver receives Frame-0 dry persistence hydration and invalidation events', () {
      resetAmbientPersistence();

      final dryHydratedLogs = <String>[];
      final dryInvalidatedLogs = <String>[];

      final observer = _FullTestObserver(
        onDryHydratedCallback: (state, {required key, required fromCache}) =>
            dryHydratedLogs.add('${state.runtimeType}: key=$key, fromCache=$fromCache'),
        onDryInvalidatedCallback: (target, {required key, isScopePurge = false}) =>
            dryInvalidatedLogs.add('key=$key, isScopePurge=$isScopePurge'),
      );
      Graft.observer = observer;

      final authGraft = AuthGraft();
      expect(dryHydratedLogs.any((l) => l.contains('AuthState')), isTrue);

      // Invalidate dry state
      authGraft.invalidateDry();
      expect(dryInvalidatedLogs.any((l) => l.contains('auth_session')), isTrue);

      // Invalidate via scope prefix
      TestScope.auth.invalidateDry();
      expect(dryInvalidatedLogs.any((l) => l.contains('auth') && l.contains('isScopePurge=true')), isTrue);

      authGraft.dispose();
      resetAmbientPersistence();
    });

    test('GraftDevObserver handles all DI and Dry persistence callbacks with selective flags', () {
      final devObserver = GraftDevObserver(
        logDI: true,
        logDry: true,
        logState: true,
        logBindings: true,
        logErrors: true,
      );
      Graft.observer = devObserver;

      // Exercise all methods on GraftDevObserver
      devObserver.onScopeCreated(TestScope.auth, preserved: false);
      devObserver.onDependencyBound(CounterGraft, scopeId: TestScope.auth);
      devObserver.onScopeDropped(TestScope.auth, members: [CounterGraft], registeredTypes: [CounterGraft]);
      devObserver.onScopeDropped(TestScope.cart, registeredTypes: [String]);
      devObserver.onScopeDropped('empty_scope');

      final authState = AuthState();
      devObserver.onDryHydrated(authState, key: 'auth_session', fromCache: true);
      devObserver.onDryHydrated(authState, key: 'auth_session', fromCache: false);
      devObserver.onDryInvalidated(authState, key: 'auth_session');
      devObserver.onDryInvalidated('auth', key: 'auth', isScopePurge: true);

      // Test with all flags disabled (0 output)
      final silentObserver = GraftDevObserver(
        logDI: false,
        logDry: false,
        logState: false,
        logBindings: false,
        logErrors: false,
        logRebuilds: false,
      );
      silentObserver.onScopeCreated(TestScope.auth);
      silentObserver.onScopeDropped(TestScope.auth, members: [CounterGraft]);
      silentObserver.onDependencyBound(CounterGraft);
      silentObserver.onDryHydrated(authState, key: 'k', fromCache: true);
      silentObserver.onDryInvalidated(authState, key: 'k');

      // Test default flags (state and changes disabled by default, DI and Dry enabled)
      final defaultDevObserver = GraftDevObserver();
      expect(defaultDevObserver.logState, isFalse);
      expect(defaultDevObserver.logChanges, isFalse);
      expect(defaultDevObserver.logDI, isTrue);
      expect(defaultDevObserver.logDry, isTrue);

      final changesObserver = GraftDevObserver(logChanges: true);
      expect(changesObserver.logChanges, isTrue);

      final stateObserver = GraftDevObserver(logState: true);
      expect(stateObserver.logState, isTrue);
      expect(stateObserver.logChanges, isTrue);

      final stateOnlyObserver = GraftDevObserver(logState: true, logChanges: false);
      expect(stateOnlyObserver.logState, isTrue);
      expect(stateOnlyObserver.logChanges, isFalse);

      // Test async vs sync logging modes
      final asyncObserver = GraftDevObserver(asyncLog: true);
      asyncObserver.onScopeCreated('async_scope');
      asyncObserver.flushLogs();

      final syncObserver = GraftDevObserver(asyncLog: false);
      syncObserver.onScopeCreated('sync_scope');
    });
  });
}

enum TestScope { auth, cart }

class AuthState extends GraftState {
  @override
  int get schemaVersion => 1;
  String token;
  AuthState([this.token = 'jwt']);
  @override
  String get dryKey => 'auth_session';
  @override
  GraftProps get props => propsOf(token);
}

class AuthGraft extends Graft<AuthState> {
  AuthGraft() : super.dry(AuthState.new, key: 'auth_session');
}

class _FullTestObserver extends GraftObserver {
  final void Function(Object scopeId, {bool preserved})? onScopeCreatedCallback;
  final void Function(Object scopeId, {List<Type> members, List<Type> registeredTypes})? onScopeDroppedCallback;
  final void Function(Type type, {Object? scopeId, bool singleton, bool preserved, bool isAsync})? onDependencyBoundCallback;
  final void Function(GraftState state, {required String key, required bool fromCache})? onDryHydratedCallback;
  final void Function(Object target, {required String key, bool isScopePurge})? onDryInvalidatedCallback;

  _FullTestObserver({
    this.onScopeCreatedCallback,
    this.onScopeDroppedCallback,
    this.onDependencyBoundCallback,
    this.onDryHydratedCallback,
    this.onDryInvalidatedCallback,
  });

  @override
  void onScopeCreated(Object scopeId, {bool preserved = false}) {
    onScopeCreatedCallback?.call(scopeId, preserved: preserved);
  }

  @override
  void onScopeDropped(Object scopeId, {List<Type> members = const [], List<Type> registeredTypes = const []}) {
    onScopeDroppedCallback?.call(scopeId, members: members, registeredTypes: registeredTypes);
  }

  @override
  void onDependencyBound(Type type, {Object? scopeId, bool singleton = true, bool preserved = false, bool isAsync = false}) {
    onDependencyBoundCallback?.call(type, scopeId: scopeId, singleton: singleton, preserved: preserved, isAsync: isAsync);
  }

  @override
  void onDryHydrated(GraftState state, {required String key, required bool fromCache}) {
    onDryHydratedCallback?.call(state, key: key, fromCache: fromCache);
  }

  @override
  void onDryInvalidated(Object target, {required String key, bool isScopePurge = false}) {
    onDryInvalidatedCallback?.call(target, key: key, isScopePurge: isScopePurge);
  }
}
