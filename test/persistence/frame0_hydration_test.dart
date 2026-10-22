import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

class AddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String street;
  String city;

  AddressModel([this.street = '', this.city = '']);

  @override
  GraftProps get props => propsOf(street, city);

  @override
  Function get factory => AddressModel.new;
}

class HydratedCheckoutState extends GraftState {
  @override
  int get schemaVersion => 1;

  String customerName;
  String notes;
  AddressModel address;

  HydratedCheckoutState([
    this.customerName = '',
    this.notes = '',
    AddressModel? address,
  ]) : address = address ?? AddressModel();

  @override
  GraftProps get props => propsOf(customerName, notes, address);
}

class CustomKeyCheckoutState extends GraftState {
  @override
  int get schemaVersion => 1;

  String customerName;

  CustomKeyCheckoutState([this.customerName = '']);

  @override
  String get dryKey => 'custom_checkout_key';

  @override
  GraftProps get props => propsOf(customerName);
}

class HydratedCheckoutGraft extends Graft<HydratedCheckoutState> {
  String observedNameOnInit = '';

  HydratedCheckoutGraft() : super.dry(HydratedCheckoutState.new);

  @override
  void onInit() {
    super.onInit();
    observedNameOnInit = state.customerName;
  }
}

class TearOffAddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String street;
  String city;

  TearOffAddressModel([this.street = '123 Main', this.city = 'Springfield']);

  @override
  GraftProps get props => propsOf(street, city);

  @override
  Function get factory => TearOffAddressModel.new;
}

class TearOffCheckoutState extends GraftState {
  @override
  int get schemaVersion => 1;

  String customerName;
  String notes;
  TearOffAddressModel address;

  TearOffCheckoutState([
    this.customerName = 'Default Alice',
    this.notes = 'Default Note',
    TearOffAddressModel? address,
  ]) : address = address ?? TearOffAddressModel();

  @override
  GraftProps get props => propsOf(customerName, notes, address);
}

class TearOffCheckoutGraft extends Graft<TearOffCheckoutState> {
  TearOffCheckoutGraft() : super.dry(TearOffCheckoutState.new);
}

class SameTypeState extends GraftState {
  @override
  int get schemaVersion => 1;

  String firstName;
  String lastName;
  String email;
  String phone;

  SameTypeState([
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
  ]);

  @override
  GraftProps get props => propsOf(firstName, lastName, email, phone);
}

class FivePropertyState extends GraftState {
  @override
  int get schemaVersion => 1;

  String name;
  int score;

  // Transient local UI flags (not in props -> never persisted!)
  bool isLoading = false;
  String? errorMessage;
  int activeTab = 0;

  FivePropertyState([
    this.name = 'Guest',
    this.score = 0,
  ]);

  @override
  GraftProps get props => propsOf(name, score);
}

class FivePropertyGraft extends Graft<FivePropertyState> {
  FivePropertyGraft() : super.dry(FivePropertyState.new);
}

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  group('Frame-0 Hydration Tests', () {
    test('hydrates synchronously on Frame 0 before onInit() with binary bytes', () {
      final probeState = HydratedCheckoutState();
      final fp = SchemaFingerprint.compute(
        probeState.props,
        schemaVersion: probeState.schemaVersion,
      );

      final preWarmedPayload = BinarySerializer.encode(
        probeState.propsOf(
          'Alice Cooper',
          'Leave at door',
          probeState.address.propsOf('5th Ave', 'New York'),
        ),
        fp,
      );

      // Pre-warm L1 RAM Cache with default class name key:
      ambientStorageCoordinator.write('HydratedCheckoutState', preWarmedPayload);

      // Instantiate Graft: constructor executes Frame-0 hydration then onInit()
      final graft = HydratedCheckoutGraft();

      expect(graft.state.customerName, equals('Alice Cooper'));
      expect(graft.state.notes, equals('Leave at door'));
      expect(graft.state.address.street, equals('5th Ave'));
      expect(graft.state.address.city, equals('New York'));
      expect(graft.observedNameOnInit, equals('Alice Cooper'));
    });

    test('schema mismatch safely discards stale binary data and falls back to defaults', () {
      final stalePayload = BinarySerializer.encode(
        GraftProps.fromList(['Stale User', 999]),
        0xDEADBEEF, // Different schema fingerprint
      );

      ambientStorageCoordinator.write('HydratedCheckoutState', stalePayload);

      final graft = HydratedCheckoutGraft();

      expect(graft.state.customerName, equals(''));
      expect(graft.state.notes, equals(''));
      expect(graft.observedNameOnInit, equals(''));
    });

    test('custom dryKey override is respected', () {
      final probeState = CustomKeyCheckoutState();
      final fp = SchemaFingerprint.compute(
        probeState.props,
        schemaVersion: probeState.schemaVersion,
      );
      final payload = BinarySerializer.encode(probeState.propsOf('Bob Marley'), fp);

      ambientStorageCoordinator.write('custom_checkout_key', payload);

      final graft = Graft<CustomKeyCheckoutState>.dry(CustomKeyCheckoutState.new);
      expect(graft.state.customerName, equals('Bob Marley'));
      expect(graft.state.dryKey, equals('custom_checkout_key'));
    });

    test('correctly maps multiple properties having the exact same type (FIFO cursor)', () {
      final state = SameTypeState();
      final fp = SchemaFingerprint.compute(
        state.props,
        schemaVersion: state.schemaVersion,
      );
      final payload = BinarySerializer.encode(
        state.propsOf('John', 'Doe', 'john@example.com', '+1-555-0199'),
        fp,
      );

      ambientStorageCoordinator.write('SameTypeState', payload);

      final graft = Graft<SameTypeState>.dry(SameTypeState.new);
      expect(graft.state.firstName, equals('John'));
      expect(graft.state.lastName, equals('Doe'));
      expect(graft.state.email, equals('john@example.com'));
      expect(graft.state.phone, equals('+1-555-0199'));
    });

    test('Concept 1: Graft.dry(State.new) restores constructor defaults on first run', () {
      final graft = TearOffCheckoutGraft();
      expect(graft.state.customerName, equals('Default Alice'));
      expect(graft.state.notes, equals('Default Note'));
      expect(graft.state.address.street, equals('123 Main'));
      expect(graft.state.address.city, equals('Springfield'));
    });

    test('Concept 1: Graft.dry(State.new) saves on update and restores directly on Frame 0 with ZERO onHydrate', () {
      final graft1 = TearOffCheckoutGraft();
      graft1.state.customerName = 'Bob Dylan';
      graft1.state.notes = 'Ring bell twice';
      graft1.state.address.street = '8th Avenue';
      graft1.state.address.city = 'New York';
      graft1.state.update();

      // Fresh instance simulating app launch on Frame 0
      final graft2 = TearOffCheckoutGraft();
      expect(graft2.state.customerName, equals('Bob Dylan'));
      expect(graft2.state.notes, equals('Ring bell twice'));
      expect(graft2.state.address.street, equals('8th Avenue'));
      expect(graft2.state.address.city, equals('New York'));
    });

    test('Concept 1: Graft.dry respects custom key parameter', () {
      final graft = Graft<TearOffCheckoutState>.dry(
        TearOffCheckoutState.new,
        key: 'my_custom_key',
      );
      expect(graft.state.dryKey, equals('my_custom_key'));
    });

    test('5-property state: only dry fields are persisted, transient fields start fresh', () {
      final graft1 = FivePropertyGraft();
      graft1.state
        ..name = 'Alice'
        ..score = 999
        ..isLoading = true
        ..errorMessage = 'Something went wrong'
        ..activeTab = 3
        ..update();

      // Restart app simulating Frame 0:
      final graft2 = FivePropertyGraft();
      expect(graft2.state.name, equals('Alice'));
      expect(graft2.state.score, equals(999));
      expect(graft2.state.isLoading, isFalse);
      expect(graft2.state.errorMessage, isNull);
      expect(graft2.state.activeTab, equals(0));
    });
  });
}
