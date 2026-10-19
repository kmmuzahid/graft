import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/persistence/debounce_queue.dart';

void main() {
  group('DebounceQueue Tests', () {
    test('coalesces rapid writes into single execution', () async {
      final flushed = <String, Uint8List>{};
      int flushCount = 0;

      final queue = DebounceQueue(
        debounceDuration: const Duration(milliseconds: 50),
        onFlush: (key, value) async {
          flushed[key] = value;
          flushCount++;
        },
      );

      queue.enqueue('field1', Uint8List.fromList([1]));
      queue.enqueue('field1', Uint8List.fromList([2]));
      queue.enqueue('field1', Uint8List.fromList([3]));

      expect(queue.hasPending('field1'), isTrue);
      expect(flushCount, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(flushCount, equals(1));
      expect(flushed['field1'], equals(Uint8List.fromList([3])));
      expect(queue.hasPending('field1'), isFalse);
    });

    test('cancel aborts pending timer without writing', () async {
      int flushCount = 0;
      final queue = DebounceQueue(
        debounceDuration: const Duration(milliseconds: 50),
        onFlush: (key, value) async {
          flushCount++;
        },
      );

      queue.enqueue('cancelKey', Uint8List.fromList([42]));
      expect(queue.hasPending('cancelKey'), isTrue);
      queue.cancel('cancelKey');
      expect(queue.hasPending('cancelKey'), isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(flushCount, equals(0));
    });

    test('flush immediately writes all pending payloads', () async {
      final flushed = <String, Uint8List>{};
      final queue = DebounceQueue(
        debounceDuration: const Duration(milliseconds: 500),
        onFlush: (key, value) async {
          flushed[key] = value;
        },
      );

      queue.enqueue('k1', Uint8List.fromList([10]));
      queue.enqueue('k2', Uint8List.fromList([20]));

      await queue.flush();

      expect(flushed['k1'], equals(Uint8List.fromList([10])));
      expect(flushed['k2'], equals(Uint8List.fromList([20])));
      expect(queue.hasPending('k1'), isFalse);
      expect(queue.hasPending('k2'), isFalse);
    });
  });
}
