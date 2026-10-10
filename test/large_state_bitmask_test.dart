import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class Large128State extends GraftState {
  final List<int> values = List.generate(128, (i) => i * 10);

  @override
  GraftProps get props => propsOfMany(values);
}

class Large128Graft extends Graft<Large128State> {
  Large128Graft() : super(Large128State());

  void setField(int index, int val) {
    state
      ..values[index] = val
      ..update();
  }
}

class Large500State extends GraftState {
  final List<String> entries = List.generate(500, (i) => 'init_$i');

  @override
  GraftProps get props => propsOfMany(entries);
}

class Large500Graft extends Graft<Large500State> {
  Large500Graft() : super(Large500State());

  void setFields(Map<int, String> updates) {
    for (final entry in updates.entries) {
      state.entries[entry.key] = entry.value;
    }
    state.update();
  }
}

void main() {
  group('Large State Unbounded Bitmask Tests', () {
    test('128-Field State Diffing across word boundaries', () {
      final graft = Large128Graft();
      GraftMask? capturedMask;
      graft.addMaskListener((mask) {
        capturedMask = mask;
      });

      // Mutate bit 0 (word 0)
      graft.setField(0, 999);
      expect(capturedMask, isNotNull);
      expect(capturedMask!.isBitSet(0), isTrue);
      expect(capturedMask!.isBitSet(1), isFalse);
      expect(capturedMask!.singleBitIndex, equals(0));

      // Mutate bit 64 (word 1 boundary)
      graft.setField(64, 888);
      expect(capturedMask!.isBitSet(64), isTrue);
      expect(capturedMask!.isBitSet(63), isFalse);
      expect(capturedMask!.singleBitIndex, equals(64));

      // Mutate bit 127 (last bit in word 3)
      graft.setField(127, 777);
      expect(capturedMask!.isBitSet(127), isTrue);
      expect(capturedMask!.singleBitIndex, equals(127));
    });

    test('500-Field State Diffing with non-contiguous simultaneous mutations', () {
      final graft = Large500Graft();
      GraftMask? capturedMask;
      graft.addMaskListener((mask) {
        capturedMask = mask;
      });

      // Mutate bits 10, 150, 499 simultaneously
      graft.setFields({
        10: 'updated_10',
        150: 'updated_150',
        499: 'updated_499',
      });

      expect(capturedMask, isNotNull);
      expect(capturedMask!.isBitSet(10), isTrue);
      expect(capturedMask!.isBitSet(150), isTrue);
      expect(capturedMask!.isBitSet(499), isTrue);

      // Verify unmutated fields are clean
      expect(capturedMask!.isBitSet(9), isFalse);
      expect(capturedMask!.isBitSet(11), isFalse);
      expect(capturedMask!.isBitSet(149), isFalse);
      expect(capturedMask!.isBitSet(151), isFalse);
      expect(capturedMask!.isBitSet(498), isFalse);
    });
  });
}
