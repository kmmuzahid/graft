import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class CounterState extends GraftState {
  int count;
  CounterState(this.count);

  @override
  List<Object?> get props => [count];

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
      final devObserver = GraftDevObserver(logRebuilds: true);
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
  });
}
