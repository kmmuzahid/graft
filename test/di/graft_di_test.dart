import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AuthService {
  String get user => 'RealUser';
}

class MockAuthService implements AuthService {
  @override
  String get user => 'MockUser';
}

void main() {
  setUp(() {
    GraftDI.reset();
  });

  group('GraftDI & use<T>() Tests', () {
    test('resolves registered root dependency', () {
      bind(AuthService.new);
      final auth = use<AuthService>();
      expect(auth.user, equals('RealUser'));
    });

    test('Zone test override takes precedence without clearing container', () {
      bind(AuthService.new);

      // In default zone, returns real service
      expect(use<AuthService>().user, equals('RealUser'));

      // In isolated zone, returns mock override
      runZoned(
        () {
          expect(use<AuthService>().user, equals('MockUser'));
        },
        zoneValues: {
          GraftDI.testZoneKey: {
            AuthService: MockAuthService(),
          },
        },
      );

      // Outside zone, still returns real service (zero contamination)
      expect(use<AuthService>().user, equals('RealUser'));
    });
  });
}
