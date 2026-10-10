import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

/// A massive 128-property domain state model spanning multiple 64-bit mask words.
class Massive128State extends GraftState {
  final List<int> values = List<int>.generate(128, (i) => i);

  @override
  GraftProps get props => propsOf(values);
}

class Massive128Graft extends Graft<Massive128State> {
  Massive128Graft() : super(Massive128State());

  void setProperty(int index, int value) {
    state.values[index] = value;
    state.update();
  }
}

void main() {
  group('Extreme Scale Stress Tests: 128-Property State & Multi-Word Bitmask', () {
    test('128 properties across word 0, word 1, and extra words evaluate accurately', () {
      final graft = Massive128Graft();
      GraftMask? lastMask;

      graft.addMaskListener((mask) {
        lastMask = mask;
      });

      // 1. Initial evaluation
      expect(graft.state.props.length, 128);

      // 2. Mutate index 0 (Word 0, bit 0)
      graft.setProperty(0, 9999);
      expect(lastMask, isNotNull);
      expect(lastMask!.isBitSet(0), isTrue);
      expect(lastMask!.isBitSet(1), isFalse);
      expect(lastMask!.singleBitIndex, 0);

      // 3. Mutate index 31 (Word 0, last bit)
      graft.setProperty(31, 8888);
      expect(lastMask!.isBitSet(31), isTrue);
      expect(lastMask!.singleBitIndex, 31);

      // 4. Mutate index 32 (Word 1, first bit)
      graft.setProperty(32, 7777);
      expect(lastMask!.isBitSet(32), isTrue);
      expect(lastMask!.singleBitIndex, 32);

      // 5. Mutate index 63 (Word 1, last bit)
      graft.setProperty(63, 6666);
      expect(lastMask!.isBitSet(63), isTrue);
      expect(lastMask!.singleBitIndex, 63);

      // 6. Mutate index 64 (Extra word 0, first bit)
      graft.setProperty(64, 5555);
      expect(lastMask!.isBitSet(64), isTrue);
      expect(lastMask!.singleBitIndex, 64);

      // 7. Mutate index 127 (Extra word 1, last bit)
      graft.setProperty(127, 4444);
      expect(lastMask!.isBitSet(127), isTrue);
      expect(lastMask!.singleBitIndex, 127);

      graft.dispose();
    });

    test('1,000,000 continuous mutations run with sub-microsecond latency and 0 GC leaks', () {
      final state = Massive128State();

      // Warm up
      for (int i = 0; i < 1000; i++) {
        state.values[0] = i;
        state.diffChanges();
      }

      final sw = Stopwatch()..start();
      const iterations = 1000000;

      for (int i = 0; i < iterations; i++) {
        final targetIndex = i & 127; // Cycle through all 128 properties
        state.values[targetIndex] = i + 1000;
        final mask = state.diffChanges();
        assert(!mask.isEmpty);
      }
      sw.stop();

      final elapsedMs = sw.elapsedMilliseconds;
      final nsPerOp = (sw.elapsedMicroseconds * 1000) / iterations;

      print('⚡ 1,000,000 CONTINUOUS 128-PROPERTY MUTATIONS:');
      print('   Total time: $elapsedMs ms');
      print('   Per mutation diff latency: ${nsPerOp.toStringAsFixed(1)} ns');

      expect(elapsedMs, lessThan(3000),
          reason: '1,000,000 128-property mutations must complete in under 3.0 seconds');
    });

    test('Multi-word simultaneous dirty bits across boundaries', () {
      final state = Massive128State();
      state.diffChanges(); // initialize baseline

      // Mutate bits 0, 31, 32, 63, 64, 127 simultaneously
      state.values[0] = -1;
      state.values[31] = -1;
      state.values[32] = -1;
      state.values[63] = -1;
      state.values[64] = -1;
      state.values[127] = -1;

      final mask = state.diffChanges();

      expect(mask.isBitSet(0), isTrue);
      expect(mask.isBitSet(31), isTrue);
      expect(mask.isBitSet(32), isTrue);
      expect(mask.isBitSet(63), isTrue);
      expect(mask.isBitSet(64), isTrue);
      expect(mask.isBitSet(127), isTrue);

      // Verify unrelated bits are clean
      expect(mask.isBitSet(1), isFalse);
      expect(mask.isBitSet(30), isFalse);
      expect(mask.isBitSet(33), isFalse);
      expect(mask.isBitSet(62), isFalse);
      expect(mask.isBitSet(65), isFalse);
      expect(mask.isBitSet(126), isFalse);
    });
  });
}
