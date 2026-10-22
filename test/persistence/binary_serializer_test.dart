import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';

class TestAddress extends GraftModel {
  String street = 'Broadway';
  String city = 'NYC';
  int zip = 10001;

  @override
  GraftProps get props => propsOf(street, city, zip);
}

class TestUser extends GraftState {
  String name = 'Alice';
  int age = 30;
  double score = 98.5;
  bool isActive = true;
  TestAddress address = TestAddress();

  @override
  GraftProps get props => propsOf(name, age, score, isActive, address);
}

void main() {
  group('BinarySerializer Tests', () {
    test('encodes and decodes props, scalars, and nested models', () {
      final user = TestUser();
      const fp = 0x1A2B3C4D;
      final bytes = BinarySerializer.encode(user.props, fp);

      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(7));

      final decoded = BinarySerializer.decode(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.fingerprint, equals(fp));
      expect(decoded.data[0], equals('Alice'));
      expect(decoded.data[1], equals(30));
      expect((decoded.data[2] as double).toStringAsFixed(1), equals('98.5'));
      expect(decoded.data[3], isTrue);
      expect(decoded.data[4], equals(['Broadway', 'NYC', 10001]));
    });

    test('handles nulls, empty bytes, and corrupted payloads safely', () {
      expect(BinarySerializer.decode(Uint8List(0)), isNull);
      expect(BinarySerializer.decode(Uint8List(5)), isNull);

      final props = GraftProps.fromList([null, false, true, 'test']);
      final bytes = BinarySerializer.encode(props, 999);
      final decoded = BinarySerializer.decode(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.fingerprint, equals(999));
      expect(decoded.data[0], isNull);
      expect(decoded.data[1], isFalse);
      expect(decoded.data[2], isTrue);
      expect(decoded.data[3], equals('test'));
    });
  });
}
