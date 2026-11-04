import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';
import 'package:graft/src/persistence/ambient_locator.dart';

enum AppScope with GraftScope {
  auth,
  checkout,
  profile,
}

class ScopedAuthService extends GraftService {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }
}

class ScopedCheckoutService extends GraftService {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }
}

void main() {
  setUp(() {
    GraftTesting.resetAll();
  });

  tearDown(() {
    GraftTesting.resetAll();
  });

  group('GraftScope Enum Mixin Tests', () {
    test('scope() registers bindings into scope and scope.drop() tears them down', () {
      scope(AppScope.auth, () {
        bind(ScopedAuthService.new);
      });

      scope(AppScope.checkout, () {
        bind(ScopedCheckoutService.new);
      });

      final authScope = GraftDI.getScope(AppScope.auth);
      final checkoutScope = GraftDI.getScope(AppScope.checkout);

      final authService = authScope.resolve<ScopedAuthService>();
      final checkoutService = checkoutScope.resolve<ScopedCheckoutService>();

      expect(authService.isDisposed, isFalse);
      expect(checkoutService.isDisposed, isFalse);

      // Drop only auth scope via enum method
      AppScope.auth.drop();

      expect(authService.isDisposed, isTrue);
      // Checkout service remains unaffected
      expect(checkoutService.isDisposed, isFalse);

      // Drop checkout scope
      AppScope.checkout.drop();
      expect(checkoutService.isDisposed, isTrue);
    });

    test('scope.invalidateDry() selectively purges storage prefixed with the scope name', () {
      resetAmbientPersistence();

      ambientStorageCoordinator.write('auth_token', Uint8List.fromList([1, 2, 3]));
      ambientStorageCoordinator.write('checkout_cart', Uint8List.fromList([4, 5, 6]));
      ambientStorageCoordinator.write('profile_user', Uint8List.fromList([7, 8, 9]));

      expect(ambientStorageCoordinator.readSync('auth_token'), isNotNull);
      expect(ambientStorageCoordinator.readSync('checkout_cart'), isNotNull);
      expect(ambientStorageCoordinator.readSync('profile_user'), isNotNull);

      // Invalidate checkout scope
      AppScope.checkout.invalidateDry();

      expect(ambientStorageCoordinator.readSync('checkout_cart'), isNull);
      expect(ambientStorageCoordinator.readSync('auth_token'), isNotNull);
      expect(ambientStorageCoordinator.readSync('profile_user'), isNotNull);

      // Invalidate auth scope
      AppScope.auth.invalidateDry();
      expect(ambientStorageCoordinator.readSync('auth_token'), isNull);
      expect(ambientStorageCoordinator.readSync('profile_user'), isNotNull);

      resetAmbientPersistence();
    });
  });
}

