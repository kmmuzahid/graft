import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

class BenchState extends GraftState {
  String name = '';
  int counter = 0;

  @override
  String get dryKey => 'bench_state';

  @override
  GraftProps get props => propsOf(name, counter);

  @override
  void onDry() {
    name = dry(name);
    counter = dry(counter);
  }
}

class BenchGraft extends Graft<BenchState> {
  BenchGraft() : super(BenchState());
}

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  test(
      'Frame-0 L1 cache synchronous hydration latency benchmark with BinarySerializer',
      () {
    final probe = BenchState();
    final fp = SchemaFingerprint.compute(probe.props);
    final payload = BinarySerializer.encode(probe.propsOf('John Doe', 42), fp);
    ambientStorageCoordinator.write('bench_state', payload);

    // Warm-up run
    for (int i = 0; i < 1000; i++) {
      final g = BenchGraft();
      expect(g.state.name, equals('John Doe'));
    }

    // Benchmark measurement
    const iterations = 50000;
    final sw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      BenchGraft();
    }
    sw.stop();

    final totalNanos = sw.elapsedMicroseconds * 1000;
    final avgNanosPerHydration = totalNanos / iterations;

    print('⚡ Frame-0 Binary Hydration Benchmark:');
    print('   Iterations: $iterations');
    print('   Total time: ${sw.elapsedMilliseconds} ms');
    print(
        '   Average latency per Frame-0 hydration: ${avgNanosPerHydration.toStringAsFixed(1)} ns');

    expect(avgNanosPerHydration, lessThan(2000.0)); // Strict sanity threshold
  });
}
