import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

// ============================================================================
// WORST CASE 1: Scrambled Order (Transient first, Dry middle, Transient end)
// ============================================================================
class ScrambledOrderState extends GraftState {
  @override
  int get schemaVersion => 1;

  String username;
  int balance;

  // Transients: local state not in props
  bool isHeaderLoading = false;
  int retryCount = 0;
  String? errorMsg;

  ScrambledOrderState([
    this.username = 'guest',
    this.balance = 100,
  ]);

  @override
  GraftProps get props => propsOf(username, balance);
}

// ============================================================================
// WORST CASE 2: Identical Types with Identical Initial Values
// ============================================================================
class IdenticalTypesState extends GraftState {
  @override
  int get schemaVersion => 1;

  String a;
  String b;
  String c;
  String d;

  IdenticalTypesState([
    this.a = '',
    this.b = '',
    this.c = '',
    this.d = '',
  ]);

  @override
  GraftProps get props => propsOf(a, b, c, d);
}

// ============================================================================
// WORST CASE 3: Reordered propsOf
// ============================================================================
class SwappedPropsState extends GraftState {
  @override
  int get schemaVersion => 1;

  String lastName;
  String firstName;

  SwappedPropsState([
    this.lastName = 'Last',
    this.firstName = 'First',
  ]);

  @override
  GraftProps get props => propsOf(lastName, firstName);
}

// ============================================================================
// WORST CASE 4: Nested Model with Mixed Transient & Dry fields
// ============================================================================
class TestAddressModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String street;
  String city;

  TestAddressModel([
    this.street = 'Main',
    this.city = 'NYC',
  ]);

  @override
  GraftProps get props => propsOf(street, city);

  @override
  Function get factory => TestAddressModel.new;
}

class MixedNestedState extends GraftState {
  @override
  int get schemaVersion => 1;

  String title;
  TestAddressModel address;
  int visitCount;

  // Transient
  bool isSyncing = false;

  MixedNestedState([
    this.title = 'Home',
    TestAddressModel? address,
    this.visitCount = 0,
  ]) : address = address ?? TestAddressModel();

  @override
  GraftProps get props => propsOf(title, address, visitCount);
}

// ============================================================================
// WORST CASE 8: V2 Swapped Order (int FIRST, String SECOND)
// ============================================================================
class V2SwappedOrderState extends GraftState {
  @override
  int get schemaVersion => 1;

  int score;
  String name;

  V2SwappedOrderState([
    this.score = 0,
    this.name = 'DefaultName',
  ]);

  @override
  GraftProps get props => propsOf(score, name);
}

// ============================================================================
// WORST CASE 9: Nullable Fields State
// ============================================================================
class NullableFieldsState extends GraftState {
  @override
  int get schemaVersion => 1;

  String? nickname;
  int? optionalScore;

  NullableFieldsState([
    this.nickname,
    this.optionalScore,
  ]);

  @override
  GraftProps get props => propsOf(nickname, optionalScore);
}

// ============================================================================
// WORST CASE 10: Deep 2-Level Nested Models
// ============================================================================
class OfficeModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String building;
  int floor;

  OfficeModel([
    this.building = 'HQ',
    this.floor = 1,
  ]);

  @override
  GraftProps get props => propsOf(building, floor);

  @override
  Function get factory => OfficeModel.new;
}

class DepartmentModel extends GraftModel {
  @override
  int get schemaVersion => 1;

  String deptName;
  OfficeModel office;

  DepartmentModel([
    this.deptName = 'General',
    OfficeModel? office,
  ]) : office = office ?? OfficeModel();

  @override
  GraftProps get props => propsOf(deptName, office);

  @override
  Function get factory => DepartmentModel.new;
}

class CompanyState extends GraftState {
  @override
  int get schemaVersion => 1;

  DepartmentModel dept;

  CompanyState([DepartmentModel? dept]) : dept = dept ?? DepartmentModel();

  @override
  GraftProps get props => propsOf(dept);
}

// ============================================================================
// WORST CASE 11: Pure Transient State
// ============================================================================
class PureTransientState extends GraftState {
  int counter = 0;

  @override
  GraftProps get props => propsOf(counter);
}

// ============================================================================
// WORST CASE 13: Multi-Instance State
// ============================================================================
class MultiInstanceState extends GraftState {
  @override
  int get schemaVersion => 1;

  String role;

  MultiInstanceState([this.role = 'Unknown']);

  @override
  GraftProps get props => propsOf(role);
}

// ============================================================================
// WORST CASE 14: Collection State
// ============================================================================
class CollectionState extends GraftState {
  @override
  int get schemaVersion => 1;

  List<String> tags;

  CollectionState([List<String>? tags]) : tags = tags ?? [];

  @override
  GraftProps get props => propsOf(tags);
}

// ============================================================================
// WORST CASE 15: Geo State (Doubles)
// ============================================================================
class GeoState extends GraftState {
  @override
  int get schemaVersion => 1;

  double latitude;
  double longitude;

  GeoState([
    this.latitude = 0.0,
    this.longitude = 0.0,
  ]);

  @override
  GraftProps get props => propsOf(latitude, longitude);
}

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  group('Worst-Case Persistence Scenarios', () {
    test('Worst Case 1: Scrambled order with mixed transient and dry fields', () {
      final graft1 = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      graft1.state
        ..isHeaderLoading = true
        ..username = 'super_admin'
        ..retryCount = 5
        ..balance = 9999
        ..errorMsg = 'Fatal server error'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      expect(graft2.state.username, equals('super_admin'));
      expect(graft2.state.balance, equals(9999));

      // Transients MUST start fresh:
      expect(graft2.state.isHeaderLoading, isFalse);
      expect(graft2.state.retryCount, equals(0));
      expect(graft2.state.errorMsg, isNull);
    });

    test('Worst Case 2: Multiple identical types with identical empty initial values', () {
      final graft1 = Graft<IdenticalTypesState>.dry(IdenticalTypesState.new);
      graft1.state
        ..a = 'Alpha'
        ..b = 'Beta'
        ..c = 'Gamma'
        ..d = 'Delta'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft<IdenticalTypesState>.dry(IdenticalTypesState.new);
      expect(graft2.state.a, equals('Alpha'));
      expect(graft2.state.b, equals('Beta'));
      expect(graft2.state.c, equals('Gamma'));
      expect(graft2.state.d, equals('Delta'));
    });

    test('Worst Case 3: Reordered propsOf maintains field assignment', () {
      final graft1 = Graft<SwappedPropsState>.dry(SwappedPropsState.new);
      graft1.state
        ..firstName = 'Bruce'
        ..lastName = 'Wayne'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft<SwappedPropsState>.dry(SwappedPropsState.new);
      expect(graft2.state.firstName, equals('Bruce'));
      expect(graft2.state.lastName, equals('Wayne'));
    });

    test('Worst Case 4: Nested GraftModel mixed with transient fields', () {
      final graft1 = Graft<MixedNestedState>.dry(MixedNestedState.new);
      graft1.state
        ..isSyncing = true
        ..title = 'Work Office'
        ..address.street = 'Wall Street 101'
        ..address.city = 'Manhattan'
        ..visitCount = 42
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft<MixedNestedState>.dry(MixedNestedState.new);
      expect(graft2.state.title, equals('Work Office'));
      expect(graft2.state.address.street, equals('Wall Street 101'));
      expect(graft2.state.address.city, equals('Manhattan'));
      expect(graft2.state.visitCount, equals(42));
      expect(graft2.state.isSyncing, isFalse); // Transient starts fresh
    });

    test('Worst Case 5: Schema mismatch discards stale cache safely without crash', () {
      final state = ScrambledOrderState();
      final stalePayload = Uint8List.fromList([
        0x01, 0x02, 0x03, 0x04, // Bad schema
      ]);
      ambientStorageCoordinator.write(state.dryKey, stalePayload);

      // App launches: must gracefully discard and use defaults
      final graft = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      expect(graft.state.username, equals('guest'));
      expect(graft.state.balance, equals(100));
      expect(graft.state.isHeaderLoading, isFalse);
    });

    test('Worst Case 6: Corrupted garbage binary bytes on disk are purged safely', () {
      final state = ScrambledOrderState();
      final corruptedBytes = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF, 0xFF, 0x00]);
      ambientStorageCoordinator.write(state.dryKey, corruptedBytes);

      // App launches on Frame 0: must not crash!
      final graft = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      expect(graft.state.username, equals('guest'));
      expect(graft.state.balance, equals(100));
    });

    test('Worst Case 7: 100 rapid mutations coalesce into final state correctly', () {
      final graft = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      for (int i = 0; i < 100; i++) {
        graft.state
          ..balance = i
          ..update();
      }

      // Check final state
      expect(graft.state.balance, equals(99));

      // Simulate Frame 0 restart:
      final graft2 = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      expect(graft2.state.balance, equals(99));
    });

    test('Worst Case 8: Order swapping of types in propsOf (Schema Evolution) is safely invalidated', () {
      // V1 has (String, int)
      final v1Payload = BinarySerializer.encode(
        GraftProps.fromList(['JohnDoe', 500]),
        SchemaFingerprint.compute(GraftProps.fromList(['JohnDoe', 500])),
      );
      ambientStorageCoordinator.write('V2SwappedOrderState', v1Payload);

      // App upgraded to V2 where fields are swapped to (int, String):
      final graftV2 = Graft<V2SwappedOrderState>.dry(V2SwappedOrderState.new);

      // Because fingerprint changed from (String, int) to (int, String),
      // stale cache must be discarded and defaults preserved!
      expect(graftV2.state.score, equals(0));
      expect(graftV2.state.name, equals('DefaultName'));
    });

    test('Worst Case 9: Nullable persistent fields starting as null, mutating, and returning to null', () {
      final graft1 = Graft<NullableFieldsState>.dry(NullableFieldsState.new);
      expect(graft1.state.nickname, isNull);
      expect(graft1.state.optionalScore, isNull);

      // Mutate to non-null
      graft1.state
        ..nickname = 'Speedy'
        ..optionalScore = 88
        ..update();

      // Restart Frame 0:
      final graft2 = Graft<NullableFieldsState>.dry(NullableFieldsState.new);
      expect(graft2.state.nickname, equals('Speedy'));
      expect(graft2.state.optionalScore, equals(88));

      // Mutate back to null:
      graft2.state
        ..nickname = null
        ..optionalScore = null
        ..update();

      // Restart Frame 0 again:
      final graft3 = Graft<NullableFieldsState>.dry(NullableFieldsState.new);
      expect(graft3.state.nickname, isNull);
      expect(graft3.state.optionalScore, isNull);
    });

    test('Worst Case 10: Deep 2-level nested models (State -> Dept -> Office)', () {
      final graft1 = Graft<CompanyState>.dry(CompanyState.new);
      graft1.state
        ..dept.deptName = 'Engineering'
        ..dept.office.building = 'Tower B'
        ..dept.office.floor = 42
        ..update();

      // Restart Frame 0:
      final graft2 = Graft<CompanyState>.dry(CompanyState.new);
      expect(graft2.state.dept.deptName, equals('Engineering'));
      expect(graft2.state.dept.office.building, equals('Tower B'));
      expect(graft2.state.dept.office.floor, equals(42));
    });

    test('Worst Case 11: Pure transient state with no dry constructor never writes to disk', () {
      final graft = Graft(PureTransientState());

      graft.state
        ..counter = 999
        ..update();

      // Storage should remain empty
      final cached = ambientStorageCoordinator.readSync('PureTransientState');
      expect(cached, isNull);

      // Next instance starts fresh
      final graft2 = Graft(PureTransientState());
      expect(graft2.state.counter, equals(0));
    });

    test('Worst Case 12: 1000 rapid mutations stress test preserves final values', () {
      final graft = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      for (int i = 0; i < 1000; i++) {
        graft.state
          ..balance = i
          ..update();
      }
      expect(graft.state.balance, equals(999));

      // Frame 0 restart
      final graft2 = Graft<ScrambledOrderState>.dry(ScrambledOrderState.new);
      expect(graft2.state.balance, equals(999));
    });

    test('Worst Case 13: Multiple concurrent instances with custom dryKey do not collide', () {
      final graftA = Graft<MultiInstanceState>.dry(MultiInstanceState.new, key: 'session_user_A');
      final graftB = Graft<MultiInstanceState>.dry(MultiInstanceState.new, key: 'session_user_B');

      graftA.state..role = 'Admin'..update();
      graftB.state..role = 'Guest'..update();

      // Frame 0 restart both:
      final reloadA = Graft<MultiInstanceState>.dry(MultiInstanceState.new, key: 'session_user_A');
      final reloadB = Graft<MultiInstanceState>.dry(MultiInstanceState.new, key: 'session_user_B');

      expect(reloadA.state.role, equals('Admin'));
      expect(reloadB.state.role, equals('Guest'));
    });

    test('Worst Case 14: List/Collection persistence', () {
      final graft1 = Graft<CollectionState>.dry(CollectionState.new);
      graft1.state
        ..tags = ['flutter', 'dart', 'graft', 'reactive']
        ..update();

      // Restart Frame 0:
      final graft2 = Graft<CollectionState>.dry(CollectionState.new);
      expect(graft2.state.tags, equals(['flutter', 'dart', 'graft', 'reactive']));
    });

    test('Worst Case 15: Double precision float values with high decimal precision', () {
      final graft1 = Graft<GeoState>.dry(GeoState.new);
      graft1.state
        ..latitude = 37.7749295
        ..longitude = -122.4194155
        ..update();

      // Restart Frame 0:
      final graft2 = Graft<GeoState>.dry(GeoState.new);
      expect(graft2.state.latitude, closeTo(37.7749295, 0.0000001));
      expect(graft2.state.longitude, closeTo(-122.4194155, 0.0000001));
    });
  });
}
