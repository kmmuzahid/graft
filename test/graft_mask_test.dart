import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/core/graft_mask.dart';

void main() {
  group('GraftMask Unit Tests', () {
    test('empty and allDirty sentinels', () {
      const empty = GraftMask.empty;
      const allDirty = GraftMask.allDirty;

      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);
      expect(empty.isAllDirty, isFalse);

      expect(allDirty.isAllDirty, isTrue);
      expect(allDirty.isEmpty, isFalse);

      // allDirty intersects anything
      expect(allDirty.intersects(empty), isTrue);
      expect(allDirty.intersects(GraftMask.fromIndex(5)), isTrue);

      // empty intersects nothing except allDirty
      expect(empty.intersects(GraftMask.fromIndex(5)), isFalse);
    });

    test('Word 0 (bits 0 to 31) single bit and union', () {
      final m0 = GraftMask.fromIndex(0);
      final m5 = GraftMask.fromIndex(5);
      final m31 = GraftMask.fromIndex(31);

      expect(m0.isBitSet(0), isTrue);
      expect(m0.isBitSet(1), isFalse);
      expect(m0.singleBitIndex, equals(0));

      expect(m5.isBitSet(5), isTrue);
      expect(m5.singleBitIndex, equals(5));

      expect(m31.isBitSet(31), isTrue);
      expect(m31.singleBitIndex, equals(31));

      expect(m0.intersects(m5), isFalse);
      expect(m0.intersects(m0), isTrue);

      final union = m0.union(m5);
      expect(union.isBitSet(0), isTrue);
      expect(union.isBitSet(5), isTrue);
      expect(union.isBitSet(6), isFalse);
      expect(union.singleBitIndex, isNull); // 2 bits set
      expect(union.intersects(m0), isTrue);
      expect(union.intersects(m5), isTrue);
    });

    test('Word 1 (bits 32 to 63) boundary transition', () {
      final m31 = GraftMask.fromIndex(31); // last bit in word 0
      final m32 = GraftMask.fromIndex(32); // first bit in word 1
      final m63 = GraftMask.fromIndex(63); // last bit in word 1

      expect(m31.isBitSet(31), isTrue);
      expect(m31.isBitSet(32), isFalse);
      expect(m31.singleBitIndex, equals(31));

      expect(m32.isBitSet(32), isTrue);
      expect(m32.isBitSet(31), isFalse);
      expect(m32.singleBitIndex, equals(32));

      expect(m63.isBitSet(63), isTrue);
      expect(m63.singleBitIndex, equals(63));

      expect(m31.intersects(m32), isFalse);

      final combined = m31.union(m32).union(m63);
      expect(combined.isBitSet(31), isTrue);
      expect(combined.isBitSet(32), isTrue);
      expect(combined.isBitSet(63), isTrue);
      expect(combined.isBitSet(33), isFalse);
    });

    test('Extra Words (64+ bits, 128, 512, 1024 fields)', () {
      final m64 = GraftMask.fromIndex(64); // first bit in extra word 0
      final m127 = GraftMask.fromIndex(127);
      final m512 = GraftMask.fromIndex(512);
      final m1023 = GraftMask.fromIndex(1023);

      expect(m64.isBitSet(64), isTrue);
      expect(m64.isBitSet(63), isFalse);
      expect(m64.singleBitIndex, equals(64));

      expect(m127.isBitSet(127), isTrue);
      expect(m127.singleBitIndex, equals(127));

      expect(m512.isBitSet(512), isTrue);
      expect(m512.singleBitIndex, equals(512));

      expect(m1023.isBitSet(1023), isTrue);
      expect(m1023.singleBitIndex, equals(1023));

      expect(m64.intersects(m512), isFalse);

      final bigUnion = m64.union(m512);
      expect(bigUnion.isBitSet(64), isTrue);
      expect(bigUnion.isBitSet(512), isTrue);
      expect(bigUnion.isBitSet(127), isFalse);
      expect(bigUnion.intersects(m64), isTrue);
      expect(bigUnion.intersects(m512), isTrue);
      expect(bigUnion.intersects(m127), isFalse);
    });

    test('withBit immutably accumulates bits', () {
      var mask = GraftMask.empty;
      mask = mask.withBit(2);
      mask = mask.withBit(70);
      mask = mask.withBit(200);

      expect(mask.isBitSet(2), isTrue);
      expect(mask.isBitSet(70), isTrue);
      expect(mask.isBitSet(200), isTrue);
      expect(mask.isBitSet(3), isFalse);
      expect(mask.isBitSet(71), isFalse);
    });

    test('value equality and hashCode', () {
      final a = GraftMask.empty.withBit(5).withBit(90);
      final b = GraftMask.empty.withBit(5).withBit(90);
      final c = GraftMask.empty.withBit(5).withBit(91);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
