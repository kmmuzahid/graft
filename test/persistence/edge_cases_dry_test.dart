import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

class TypedListState extends GraftState {
  @override
  int get schemaVersion => 1;

  List<String> tags;
  List<int> numbers;

  TypedListState([
    this.tags = const ['initial'],
    this.numbers = const [1, 2, 3],
  ]);

  @override
  GraftProps get props => propsOf(tags, numbers);
}

class HierarchicalKeyState extends GraftState {
  @override
  int get schemaVersion => 1;

  String token;

  HierarchicalKeyState([this.token = 'default_token']);

  @override
  String get dryKey => 'auth/user:profile';

  @override
  GraftProps get props => propsOf(token);
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('graft_edge_case_test_');
    resetAmbientPersistence();
    configurePersistence(FileStateConfig(tempDir));
  });

  tearDown(() {
    resetAmbientPersistence();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Edge Case Fortification Tests', () {
    test('persists and restores typed collections (List<String>, List<int>) without TypeError', () async {
      final graft1 = Graft<TypedListState>.dry(TypedListState.new);
      graft1.state
        ..tags = ['flutter', 'dart', 'graft']
        ..numbers = [10, 20, 30]
        ..update();

      await ambientStorageCoordinator.flush();

      // Cold restart simulation:
      resetAmbientPersistence();
      configurePersistence(FileStateConfig(tempDir));

      final graft2 = Graft<TypedListState>.dry(TypedListState.new);
      expect(graft2.state.tags, equals(['flutter', 'dart', 'graft']));
      expect(graft2.state.tags, isA<List<String>>());
      expect(graft2.state.numbers, equals([10, 20, 30]));
      expect(graft2.state.numbers, isA<List<int>>());
    });

    test('truncated binary file (8 bytes with 7-byte header) safely returns null and does not throw RangeError', () {
      final state = TypedListState();
      final fp = SchemaFingerprint.compute(state.props, schemaVersion: state.schemaVersion);

      // Construct malformed payload: 7-byte valid header claiming 5 properties, followed by 1 byte
      final bd = ByteData(8);
      bd.setInt32(0, fp);
      bd.setUint8(4, 1); // Version
      bd.setUint16(5, 5); // Count 5 props
      bd.setUint8(7, 3); // Tag 3 (int64) with 0 bytes following!

      final truncatedBytes = bd.buffer.asUint8List();

      // Ensure BinarySerializer.decode returns null safely
      final decoded = BinarySerializer.decode(truncatedBytes);
      expect(decoded, isNull);

      // Write truncated payload to disk
      ambientStorageCoordinator.write(state.dryKey, truncatedBytes);

      // Launch Graft on Frame 0: must not crash with RangeError!
      final graft = Graft<TypedListState>.dry(TypedListState.new);
      expect(graft.state.tags, equals(const ['initial']));
      expect(graft.state.numbers, equals(const [1, 2, 3]));
    });

    test('reversible URI keys with slashes and colons restore accurately across cold restart', () async {
      final graft1 = Graft<HierarchicalKeyState>.dry(HierarchicalKeyState.new);
      graft1.state
        ..token = 'jwt_secret_token_abc123'
        ..update();

      await ambientStorageCoordinator.flush();

      // Cold restart simulation:
      resetAmbientPersistence();
      configurePersistence(FileStateConfig(tempDir));

      final graft2 = Graft<HierarchicalKeyState>.dry(HierarchicalKeyState.new);
      expect(graft2.state.token, equals('jwt_secret_token_abc123'));
    });

    test('atomic file write creates temporary file and cleans it up after atomic rename', () async {
      final graft = Graft<HierarchicalKeyState>.dry(HierarchicalKeyState.new);
      graft.state
        ..token = 'atomic_write_test'
        ..update();

      await ambientStorageCoordinator.flush();

      // Check directory contents: only .bin should exist, no leftover .tmp
      final files = tempDir.listSync().map((e) => e.uri.pathSegments.last).toList();
      expect(files.any((f) => f.endsWith('.tmp')), isFalse);
      expect(files.any((f) => f.endsWith('.bin')), isTrue);
    });
  });
}
