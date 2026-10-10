import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/native/graft_simd.dart';

void main() {
  group('Phase 4: GraftSimd Hardware Acceleration & Fallback Engine', () {
    test('reports availability and version or pure Dart fallback cleanly', () {
      expect(GraftSimd.isAvailable, isA<bool>());
      if (GraftSimd.isAvailable) {
        expect(GraftSimd.version, greaterThanOrEqualTo(100));
      } else {
        expect(GraftSimd.version, -1);
      }
    });

    test('diffInt64 returns empty mask for identical buffers', () {
      final a = Int64List.fromList(List.generate(128, (i) => i * 42));
      final b = Int64List.fromList(List.generate(128, (i) => i * 42));

      final mask = GraftSimd.diffInt64(a, b);
      expect(mask.isEmpty, isTrue);
    });

    test('diffInt64 accurately detects bit mutations at low, mid, and high indices', () {
      final a = Int64List.fromList(List.generate(128, (i) => 100 + i));
      final b = Int64List.fromList(List.generate(128, (i) => 100 + i));

      // Mutate index 0, 63, 64, and 127
      b[0] = 999;
      b[63] = 999;
      b[64] = 999;
      b[127] = 999;

      final mask = GraftSimd.diffInt64(a, b);
      expect(mask.isEmpty, isFalse);
      expect(mask.isBitSet(0), isTrue);
      expect(mask.isBitSet(63), isTrue);
      expect(mask.isBitSet(64), isTrue);
      expect(mask.isBitSet(127), isTrue);

      // Sibling bits must remain clean (0)
      expect(mask.isBitSet(1), isFalse);
      expect(mask.isBitSet(62), isFalse);
      expect(mask.isBitSet(65), isFalse);
      expect(mask.isBitSet(126), isFalse);
    });

    test('diffInt64 performs microsecond diff on massive 1000-field state', () {
      const count = 1024;
      final a = Int64List(count);
      final b = Int64List(count);
      for (int i = 0; i < count; i++) {
        a[i] = i * 17;
        b[i] = i * 17;
      }

      b[500] = 777777;

      final sw = Stopwatch()..start();
      final mask = GraftSimd.diffInt64(a, b);
      sw.stop();

      expect(mask.isBitSet(500), isTrue);
      expect(mask.isBitSet(499), isFalse);
      expect(mask.isBitSet(501), isFalse);

      // Diffing 1024 fields should execute in a fraction of a millisecond
      expect(sw.elapsedMicroseconds, lessThan(2000));
    });
  });
}
