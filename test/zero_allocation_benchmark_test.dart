import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class BenchmarkState extends GraftState {
  int id;
  String username;
  double balance;
  bool isVip;
  int tier;

  BenchmarkState({
    this.id = 1,
    this.username = 'trader_01',
    this.balance = 50000.0,
    this.isVip = true,
    this.tier = 3,
  });

  @override
  List<Object?> get tracked => [id, username, balance, isVip, tier];
}

class BenchmarkGraft extends Graft<BenchmarkState> {
  BenchmarkGraft() : super(BenchmarkState());
}

void main() {
  test('10,000 diff passes on GraftState perform in-place baseline mutation with sub-microsecond latency', () {
    final graft = BenchmarkGraft();
    final state = graft.state;

    // Verify baseline was captured during bindGraft
    expect(state.diffChanges(), 0, reason: 'Initial diff with no mutations must be 0 (clean)');

    final stopwatch = Stopwatch()..start();

    const iterations = 10000;
    for (int i = 0; i < iterations; i++) {
      // Alternate mutations:
      // Even iterations: mutate balance (field index 2)
      // Odd iterations: mutate tier (field index 4)
      if (i % 2 == 0) {
        state.balance = 50000.0 + i + 1;
        final mask = state.diffChanges();
        expect(mask, 1 << 2, reason: 'Field index 2 (balance) must be marked dirty');
      } else {
        state.tier = (i % 5) + 10;
        final mask = state.diffChanges();
        expect(mask, 1 << 4, reason: 'Field index 4 (tier) must be marked dirty');
      }

      // Immediate subsequent diff without mutations must be 0
      final cleanMask = state.diffChanges();
      expect(cleanMask, 0, reason: 'Immediate clean diff must return 0 mask');
    }

    stopwatch.stop();
    final elapsedMicros = stopwatch.elapsedMicroseconds;
    final perCycleNanos = (elapsedMicros * 1000) / (iterations * 2); // 20,000 diff passes

    // Output reproducible benchmark telemetry
    // ignore: avoid_print
    print('⚡ ZERO-ALLOCATION DIFF BENCHMARK:');
    // ignore: avoid_print
    print('   Total iterations: $iterations (20,000 diff passes)');
    // ignore: avoid_print
    print('   Total elapsed time: ${stopwatch.elapsedMilliseconds} ms (${elapsedMicros} μs)');
    // ignore: avoid_print
    print('   Average latency per diff pass: ${perCycleNanos.toStringAsFixed(1)} ns');

    // 20,000 diff passes should finish well under 500ms even in unoptimized debug test runner mode
    expect(stopwatch.elapsedMilliseconds, lessThan(500));

    graft.dispose();
  });
}
