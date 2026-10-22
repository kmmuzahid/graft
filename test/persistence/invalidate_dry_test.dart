import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

enum AppScope { checkout, profile }

class CheckoutFormState extends GraftState {
  @override
  int get schemaVersion => 1;

  String notes;

  CheckoutFormState([this.notes = 'Urgent delivery']);

  @override
  String get dryKey => 'checkout_form';

  @override
  GraftProps get props => propsOf(notes);
}

class CheckoutFormGraft extends Graft<CheckoutFormState> {
  CheckoutFormGraft() : super.dry(CheckoutFormState.new);
}

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  group('InvalidateDry Tests', () {
    test('invalidateDry freezes state and prevents future writes', () {
      final graft = CheckoutFormGraft();
      graft.state..notes = 'Updated notes'..update();

      expect(ambientStorageCoordinator.readSync('checkout_form'), isNotNull);

      // Invalidate state
      graft.invalidateDry();

      expect(ambientStorageCoordinator.readSync('checkout_form'), isNull);

      // Subsequent update after invalidation produces 0 writes
      graft.state..notes = 'Post-invalidation notes'..update();
      expect(ambientStorageCoordinator.readSync('checkout_form'), isNull);
    });

    test('scope.invalidateDry purges matching keys flow-wide', () {
      final s1 = CheckoutFormState();
      final fp1 = SchemaFingerprint.compute(s1.props, schemaVersion: 1);
      ambientStorageCoordinator.write(
        'checkout_step1',
        BinarySerializer.encode(s1.propsOf('step 1 data'), fp1),
      );
      ambientStorageCoordinator.write(
        'checkout_step2',
        BinarySerializer.encode(s1.propsOf('step 2 data'), fp1),
      );
      ambientStorageCoordinator.write(
        'profile_user',
        BinarySerializer.encode(s1.propsOf('profile data'), fp1),
      );

      expect(ambientStorageCoordinator.readSync('checkout_step1'), isNotNull);
      expect(ambientStorageCoordinator.readSync('checkout_step2'), isNotNull);
      expect(ambientStorageCoordinator.readSync('profile_user'), isNotNull);

      // Purge entire checkout scope
      AppScope.checkout.invalidateDry();

      expect(ambientStorageCoordinator.readSync('checkout_step1'), isNull);
      expect(ambientStorageCoordinator.readSync('checkout_step2'), isNull);
      // Profile data must remain untouched!
      expect(ambientStorageCoordinator.readSync('profile_user'), isNotNull);
    });
  });
}
