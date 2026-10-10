import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

class CounterState extends GraftState {
  int count;
  CounterState(this.count);

  @override
  GraftProps get props => propsOf(count);

  @override
  void onReset() {
    count = 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CounterState && count == other.count;

  @override
  int get hashCode => count.hashCode;
}

class CounterGraft extends Graft<CounterState> {
  CounterGraft() : super(CounterState(0));

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void add(int amount) {
    state
      ..count += amount
      ..update();
  }

  Future<void> delayedIncrement() async {
    await Future.delayed(const Duration(milliseconds: 50));
    increment();
  }
}

void main() {
  group('graftTest Harness Tests', () {
    graftTest<CounterGraft, CounterState>(
      'emits [CounterState(1)] when increment is called',
      build: () => CounterGraft(),
      act: (graft) => graft.increment(),
      expect: () => [
        CounterState(1),
      ],
    );

    graftTest<CounterGraft, CounterState>(
      'supports async delays with wait parameter',
      build: () => CounterGraft(),
      act: (graft) => graft.delayedIncrement(),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        CounterState(1),
      ],
    );

    var setUpCalled = false;
    var verifyCalled = false;
    var tearDownCalled = false;

    graftTest<CounterGraft, CounterState>(
      'supports setUp, verify, and tearDown hooks',
      build: () => CounterGraft(),
      setUp: (graft) => setUpCalled = true,
      act: (graft) => graft.increment(),
      expect: () => [CounterState(1)],
      verify: (graft) {
        verifyCalled = true;
        expect(graft.state.count, 1);
      },
      tearDown: (graft) => tearDownCalled = true,
    );

    test('verifies hooks were executed', () {
      expect(setUpCalled, isTrue);
      expect(verifyCalled, isTrue);
      expect(tearDownCalled, isTrue);
    });
  });
}
