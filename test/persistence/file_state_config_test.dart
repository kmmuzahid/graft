import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/persistence/file_state_config.dart';

void main() {
  group('FileStateConfig Tests', () {
    late Directory tempDir;
    late FileStateConfig config;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('graft_test_storage_');
      config = FileStateConfig(tempDir);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('writes, reads, and deletes binary state files', () async {
      expect(await config.read('key1'), isNull);

      final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
      await config.write('key1', payload);
      expect(await config.read('key1'), equals(payload));

      await config.delete('key1');
      expect(await config.read('key1'), isNull);
    });

    test('readAllSync reads all .bin files synchronously for Frame-0 pre-warm', () async {
      final p1 = Uint8List.fromList([10, 20]);
      final p2 = Uint8List.fromList([30, 40]);

      await config.write('item1', p1);
      await config.write('item2', p2);

      final all = config.readAllSync();
      expect(all.length, equals(2));
      expect(all['item1'], equals(p1));
      expect(all['item2'], equals(p2));
    });
  });
}
