import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/model/tuple_serializer.dart';

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
  TestAddress address = TestAddress();

  @override
  GraftProps get props => propsOf(name, age, address);
}

void main() {
  group('TupleSerializer Tests', () {
    test('recursively serializes GraftProps and nested GraftModel', () {
      final user = TestUser();
      final tuple = TupleSerializer.toTuple(user.props);

      expect(tuple.length, equals(3));
      expect(tuple[0], equals('Alice'));
      expect(tuple[1], equals(30));
      expect(tuple[2], equals(['Broadway', 'NYC', 10001]));
    });

    test('encodes and decodes with schema fingerprint', () {
      final user = TestUser();
      final encoded = TupleSerializer.encode(user.props, 0xABC123);

      expect(encoded, contains('"f":11256099'));
      expect(encoded, contains('"d":["Alice",30,["Broadway","NYC",10001]]'));

      final decoded = TupleSerializer.decode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.fingerprint, equals(0xABC123));
      expect(decoded.data[0], equals('Alice'));
      expect(decoded.data[1], equals(30));
      expect(decoded.data[2], equals(['Broadway', 'NYC', 10001]));
    });

    test('returns null on invalid or corrupted json', () {
      expect(TupleSerializer.decode('not-json'), isNull);
      expect(TupleSerializer.decode('{"f": "not_an_int"}'), isNull);
    });
  });
}
