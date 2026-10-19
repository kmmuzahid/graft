import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

class AddressV1 extends GraftModel {
  String street = 'Main';
  @override
  GraftProps get props => propsOf(street);
}

class AddressV2 extends GraftModel {
  String street = 'Main';
  int zip = 12345;
  @override
  GraftProps get props => propsOf(street, zip);
}

class StateA extends GraftState {
  String name = 'Alice';
  int count = 1;
  @override
  GraftProps get props => propsOf(name, count);
}

class StateB extends GraftState {
  int count = 1;
  String name = 'Alice';
  @override
  GraftProps get props => propsOf(count, name);
}

class StateWithModelV1 extends GraftState {
  AddressV1 address = AddressV1();
  @override
  GraftProps get props => propsOf(address);
}

class StateWithModelV2 extends GraftState {
  AddressV2 address = AddressV2();
  @override
  GraftProps get props => propsOf(address);
}

void main() {
  group('SchemaFingerprint Tests', () {
    test('computes deterministic structural hash', () {
      final s1 = StateA();
      final s2 = StateA();
      expect(SchemaFingerprint.compute(s1.props), equals(SchemaFingerprint.compute(s2.props)));
    });

    test('reordering types changes fingerprint', () {
      final a = StateA();
      final b = StateB();
      expect(SchemaFingerprint.compute(a.props), isNot(equals(SchemaFingerprint.compute(b.props))));
    });

    test('modifying nested GraftModel schema changes fingerprint', () {
      final v1 = StateWithModelV1();
      final v2 = StateWithModelV2();
      expect(SchemaFingerprint.compute(v1.props), isNot(equals(SchemaFingerprint.compute(v2.props))));
    });
  });
}
