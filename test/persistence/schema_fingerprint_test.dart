import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

class AddressV1 extends GraftModel {
  @override
  int get schemaVersion => 1;
  String street = 'Main';
  @override
  GraftProps get props => propsOf(street);
}

class AddressV2 extends GraftModel {
  @override
  int get schemaVersion => 1;
  String street = 'Main';
  int zip = 12345;
  @override
  GraftProps get props => propsOf(street, zip);
}

class StateA extends GraftState {
  @override
  int get schemaVersion => 1;
  String name = 'Alice';
  int count = 1;
  @override
  GraftProps get props => propsOf(name, count);
}

class StateB extends GraftState {
  @override
  int get schemaVersion => 1;
  int count = 1;
  String name = 'Alice';
  @override
  GraftProps get props => propsOf(count, name);
}

class TenStringStateV1 extends GraftState {
  @override
  int get schemaVersion => 1;
  String p0 = 'a', p1 = 'b', p2 = 'c', p3 = 'd', p4 = 'e';
  String p5 = 'f', p6 = 'g', p7 = 'h', p8 = 'i', p9 = 'j';
  @override
  GraftProps get props => propsOf(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9);
}

class TenStringStateV2 extends GraftState {
  @override
  int get schemaVersion => 2;
  String p9 = 'j', p0 = 'a', p1 = 'b', p2 = 'c', p3 = 'd';
  String p4 = 'e', p5 = 'f', p6 = 'g', p7 = 'h', p8 = 'i';
  @override
  GraftProps get props => propsOf(p9, p0, p1, p2, p3, p4, p5, p6, p7, p8);
}

class StateWithModelV1 extends GraftState {
  @override
  int get schemaVersion => 1;
  AddressV1 address = AddressV1();
  @override
  GraftProps get props => propsOf(address);
}

class StateWithModelV2 extends GraftState {
  @override
  int get schemaVersion => 1;
  AddressV2 address = AddressV2();
  @override
  GraftProps get props => propsOf(address);
}

void main() {
  group('SchemaFingerprint Tests', () {
    test('computes deterministic structural hash', () {
      final s1 = StateA();
      final s2 = StateA();
      expect(
        SchemaFingerprint.compute(s1.props),
        equals(SchemaFingerprint.compute(s2.props)),
      );
    });

    test('computes identical deterministic hash across separate Dart Isolates', () async {
      final s = StateA();
      final mainFp = SchemaFingerprint.compute(s.props);
      final isolateFp = await Isolate.run(() {
        final isolateState = StateA();
        return SchemaFingerprint.compute(isolateState.props);
      });
      expect(mainFp, equals(isolateFp));
    });

    test('reordering types changes fingerprint', () {
      final a = StateA();
      final b = StateB();
      expect(
        SchemaFingerprint.compute(a.props),
        isNot(equals(SchemaFingerprint.compute(b.props))),
      );
    });

    test('10 same-type properties reordered with schemaVersion => 2 strictly changes fingerprint', () {
      final v1 = TenStringStateV1();
      final v2 = TenStringStateV2();
      final fp1 = SchemaFingerprint.compute(
        v1.props,
        schemaVersion: v1.schemaVersion,
      );
      final fp2 = SchemaFingerprint.compute(
        v2.props,
        schemaVersion: v2.schemaVersion,
      );
      expect(fp1, isNot(equals(fp2)));
    });

    test('modifying nested GraftModel schema changes fingerprint', () {
      final v1 = StateWithModelV1();
      final v2 = StateWithModelV2();
      expect(
        SchemaFingerprint.compute(v1.props),
        isNot(equals(SchemaFingerprint.compute(v2.props))),
      );
    });
  });
}
