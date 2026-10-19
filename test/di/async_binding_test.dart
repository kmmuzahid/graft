import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/di/async_binding.dart';

class AsyncDb {
  final String path;
  AsyncDb(this.path);
}

void main() {
  group('AsyncBinding Tests', () {
    test('transparently pauses until background factory completes', () async {
      final completer = Completer<AsyncDb>();
      final binding = AsyncBinding<AsyncDb>(() => completer.future);

      expect(binding.isCompleted, isFalse);
      expect(binding.resolvedInstance, isNull);

      final futureResult = binding.resolve();

      completer.complete(AsyncDb('test.db'));
      final result = await futureResult;

      expect(result.path, equals('test.db'));
      expect(binding.isCompleted, isTrue);
      expect(binding.resolvedInstance, isNotNull);

      // Subsequent resolution returns immediately without new future
      final second = await binding.resolve();
      expect(identical(result, second), isTrue);
    });

    test('propagates error if async factory fails', () async {
      final binding = AsyncBinding<AsyncDb>(() async {
        throw Exception('DB Connection Failed');
      });

      expect(binding.resolve(), throwsException);
    });
  });
}
