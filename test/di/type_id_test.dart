import 'package:flutter_test/flutter_test.dart';
import 'package:graft/src/di/type_id.dart';

class ServiceA {}
class ServiceB {}
class ServiceC {}

void main() {
  group('TypeId Tests', () {
    test('assigns distinct, deterministic integer IDs to distinct types', () {
      final idA = TypeId.of<ServiceA>();
      final idB = TypeId.of<ServiceB>();
      final idC = TypeId.of<ServiceC>();

      expect(idA, isNonNegative);
      expect(idB, isNonNegative);
      expect(idC, isNonNegative);

      expect(idA, isNot(equals(idB)));
      expect(idB, isNot(equals(idC)));
      expect(idA, isNot(equals(idC)));

      // Repeated access returns identical ID (zero allocation)
      expect(TypeId.of<ServiceA>(), equals(idA));
      expect(TypeId.of<ServiceB>(), equals(idB));
    });
  });
}
