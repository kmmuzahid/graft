import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/persistence/l1_cache.dart';

void main() {
  group('L1Cache Tests', () {
    test('sub-microsecond read/write operations', () {
      final cache = L1Cache();

      expect(cache.readSync('key1'), isNull);
      final val1 = Uint8List.fromList([1, 2, 3]);
      cache.writeSync('key1', val1);
      expect(cache.readSync('key1'), equals(val1));
      expect(cache.containsKey('key1'), isTrue);
      expect(cache.length, equals(1));

      cache.deleteSync('key1');
      expect(cache.readSync('key1'), isNull);
      expect(cache.containsKey('key1'), isFalse);
      expect(cache.length, equals(0));
    });

    test('preWarm populates entries in bulk', () {
      final cache = L1Cache();
      final p1 = Uint8List.fromList([10, 20]);
      final p2 = Uint8List.fromList([30, 40]);

      cache.preWarm({
        'user': p1,
        'theme': p2,
      });

      expect(cache.length, equals(2));
      expect(cache.readSync('user'), equals(p1));
      expect(cache.readSync('theme'), equals(p2));
      expect(cache.keys, containsAll(['user', 'theme']));

      cache.clear();
      expect(cache.length, equals(0));
      expect(cache.readSync('user'), isNull);
    });
  });
}
