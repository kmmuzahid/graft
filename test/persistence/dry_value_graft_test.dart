import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  group('DryValueGraft Tests', () {
    test('restores single primitive value on Frame 0', () {
      final probe = GraftValue<int>(42);
      final fp = SchemaFingerprint.compute(probe.props);
      final preWarmed = BinarySerializer.encode(probe.propsOf(100), fp);

      ambientStorageCoordinator.write('counter_key', preWarmed);

      final counter = ValueGraft<int>.dry(0, key: 'counter_key');

      expect(counter.value, equals(100));

      counter.value = 101;
      expect(counter.value, equals(101));

      final updatedCached = ambientStorageCoordinator.readSync('counter_key');
      expect(updatedCached, isNotNull);
      final decoded = BinarySerializer.decode(updatedCached!);
      expect(decoded!.data[0], equals(101));
    });
  });
}
