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
  bool isHeaderLoading = false; // Transient 1 (Index 0 in props)
  String username = 'guest'; // DRY 1 (Index 1 in props)
  int retryCount = 0; // Transient 2 (Index 2 in props)
  int balance = 100; // DRY 2 (Index 3 in props)
  String? errorMsg; // Transient 3 (Index 4 in props)

  @override
  GraftProps get props =>
      propsOf(isHeaderLoading, username, retryCount, balance, errorMsg);

  @override
  void onDry() {
    username = dry(username);
    balance = dry(balance);
  }
}

// ============================================================================
// WORST CASE 2: Identical Types with Identical Initial Values
// ============================================================================
class IdenticalTypesState extends GraftState {
  String a = '';
  String b = '';
  String c = '';
  String d = '';

  @override
  GraftProps get props => propsOf(a, b, c, d);

  @override
  void onDry() {
    a = dry(a);
    b = dry(b);
    c = dry(c);
    d = dry(d);
  }
}

// ============================================================================
// WORST CASE 3: Reordered propsOf vs onDry
// ============================================================================
class SwappedPropsState extends GraftState {
  String firstName = 'First';
  String lastName = 'Last';

  // propsOf has lastName FIRST, firstName SECOND:
  @override
  GraftProps get props => propsOf(lastName, firstName);

  // onDry has firstName FIRST, lastName SECOND:
  @override
  void onDry() {
    firstName = dry(firstName);
    lastName = dry(lastName);
  }
}

// ============================================================================
// WORST CASE 4: Nested Model with Mixed Transient & Dry fields
// ============================================================================
class TestAddressModel extends GraftModel {
  String street = 'Main';
  String city = 'NYC';

  @override
  GraftProps get props => propsOf(street, city);

  @override
  void onDry() {
    street = dry(street);
    city = dry(city);
  }
}

class MixedNestedState extends GraftState {
  bool isSyncing = false; // Transient
  String title = 'Home'; // Dry
  TestAddressModel address = TestAddressModel(); // Dry Model
  int visitCount = 0; // Dry

  @override
  GraftProps get props => propsOf(isSyncing, title, address, visitCount);

  @override
  void onDry() {
    title = dry(title);
    address = dryModel(address);
    visitCount = dry(visitCount);
  }
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
      final graft1 = Graft(ScrambledOrderState());
      graft1.state
        ..isHeaderLoading = true
        ..username = 'super_admin'
        ..retryCount = 5
        ..balance = 9999
        ..errorMsg = 'Fatal server error'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft(ScrambledOrderState());
      expect(graft2.state.username, equals('super_admin'));
      expect(graft2.state.balance, equals(9999));

      // Transients MUST start fresh:
      expect(graft2.state.isHeaderLoading, isFalse);
      expect(graft2.state.retryCount, equals(0));
      expect(graft2.state.errorMsg, isNull);
    });

    test('Worst Case 2: Multiple identical types with identical empty initial values', () {
      final graft1 = Graft(IdenticalTypesState());
      graft1.state
        ..a = 'Alpha'
        ..b = 'Beta'
        ..c = 'Gamma'
        ..d = 'Delta'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft(IdenticalTypesState());
      expect(graft2.state.a, equals('Alpha'));
      expect(graft2.state.b, equals('Beta'));
      expect(graft2.state.c, equals('Gamma'));
      expect(graft2.state.d, equals('Delta'));
    });

    test('Worst Case 3: Reordered propsOf vs onDry maintains field assignment', () {
      final graft1 = Graft(SwappedPropsState());
      graft1.state
        ..firstName = 'Bruce'
        ..lastName = 'Wayne'
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft(SwappedPropsState());
      expect(graft2.state.firstName, equals('Bruce'));
      expect(graft2.state.lastName, equals('Wayne'));
    });

    test('Worst Case 4: Nested GraftModel mixed with transient fields', () {
      final graft1 = Graft(MixedNestedState());
      graft1.state
        ..isSyncing = true
        ..title = 'Work Office'
        ..address.street = 'Wall Street 101'
        ..address.city = 'Manhattan'
        ..visitCount = 42
        ..update();

      // Restart app on Frame 0:
      final graft2 = Graft(MixedNestedState());
      expect(graft2.state.title, equals('Work Office'));
      expect(graft2.state.address.street, equals('Wall Street 101'));
      expect(graft2.state.address.city, equals('Manhattan'));
      expect(graft2.state.visitCount, equals(42));
      expect(graft2.state.isSyncing, isFalse); // Transient starts fresh
    });

    test('Worst Case 5: Schema mismatch discards stale cache safely without crash', () {
      // Simulate an old version writing a schema with 2 fields
      final state = ScrambledOrderState();
      final stalePayload = Uint8List.fromList([
        0x01, 0x02, 0x03, 0x04, // Bad schema
      ]);
      ambientStorageCoordinator.write(state.dryKey, stalePayload);

      // App launches: must gracefully discard and use defaults
      final graft = Graft(ScrambledOrderState());
      expect(graft.state.username, equals('guest'));
      expect(graft.state.balance, equals(100));
      expect(graft.state.isHeaderLoading, isFalse);
    });

    test('Worst Case 6: Corrupted garbage binary bytes on disk are purged safely', () {
      final state = ScrambledOrderState();
      final corruptedBytes = Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF, 0xFF, 0x00]);
      ambientStorageCoordinator.write(state.dryKey, corruptedBytes);

      // App launches on Frame 0: must not crash!
      final graft = Graft(ScrambledOrderState());
      expect(graft.state.username, equals('guest'));
      expect(graft.state.balance, equals(100));
    });

    test('Worst Case 7: 100 rapid mutations coalesce into final state correctly', () {
      final graft = Graft(ScrambledOrderState());
      for (int i = 0; i < 100; i++) {
        graft.state
          ..balance = i
          ..update();
      }

      // Check final state
      expect(graft.state.balance, equals(99));

      // Simulate Frame 0 restart:
      final graft2 = Graft(ScrambledOrderState());
      expect(graft2.state.balance, equals(99));
    });

    test('Worst Case 8: Order swapping of types in onDry (Schema Evolution) is safely invalidated', () {
      // V1 has (String, int)
      final v1Payload = BinarySerializer.encode(
        GraftProps.fromList(['JohnDoe', 500]),
        SchemaFingerprint.compute(GraftProps.fromList(['JohnDoe', 500])),
      );
      ambientStorageCoordinator.write('V2SwappedOrderState', v1Payload);

      // App upgraded to V2 where fields are swapped to (int, String):
      final graftV2 = Graft(V2SwappedOrderState());

      // Because fingerprint changed from (String, int) to (int, String),
      // stale cache must be discarded and defaults preserved!
      expect(graftV2.state.score, equals(0));
      expect(graftV2.state.name, equals('DefaultName'));
    });

    test('Worst Case 9: Nullable persistent fields starting as null, mutating, and returning to null', () {
      final graft1 = Graft(NullableFieldsState());
      expect(graft1.state.nickname, isNull);
      expect(graft1.state.optionalScore, isNull);

      // Mutate to non-null
      graft1.state
        ..nickname = 'Speedy'
        ..optionalScore = 88
        ..update();

      // Restart Frame 0:
      final graft2 = Graft(NullableFieldsState());
      expect(graft2.state.nickname, equals('Speedy'));
      expect(graft2.state.optionalScore, equals(88));

      // Mutate back to null:
      graft2.state
        ..nickname = null
        ..optionalScore = null
        ..update();

      // Restart Frame 0 again:
      final graft3 = Graft(NullableFieldsState());
      expect(graft3.state.nickname, isNull);
      expect(graft3.state.optionalScore, isNull);
    });

    test('Worst Case 10: Deep 2-level nested models (State -> Dept -> Office)', () {
      final graft1 = Graft(CompanyState());
      graft1.state
        ..dept.deptName = 'Engineering'
        ..dept.office.building = 'Tower B'
        ..dept.office.floor = 42
        ..update();

      // Restart Frame 0:
      final graft2 = Graft(CompanyState());
      expect(graft2.state.dept.deptName, equals('Engineering'));
      expect(graft2.state.dept.office.building, equals('Tower B'));
      expect(graft2.state.dept.office.floor, equals(42));
    });

    test('Worst Case 11: Pure transient state with no onDry override never writes to disk', () {
      final graft = Graft(PureTransientState());
      expect(graft.state.isDryEnabled, isFalse);

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
      final graft = Graft(ScrambledOrderState());
      for (int i = 0; i < 1000; i++) {
        graft.state
          ..balance = i
          ..update();
      }
      expect(graft.state.balance, equals(999));

      // Frame 0 restart
      final graft2 = Graft(ScrambledOrderState());
      expect(graft2.state.balance, equals(999));
    });

    test('Worst Case 13: Multiple concurrent instances with custom dryKey do not collide', () {
      final graftA = Graft(MultiInstanceState('session_user_A'));
      final graftB = Graft(MultiInstanceState('session_user_B'));

      graftA.state..role = 'Admin'..update();
      graftB.state..role = 'Guest'..update();

      // Frame 0 restart both:
      final reloadA = Graft(MultiInstanceState('session_user_A'));
      final reloadB = Graft(MultiInstanceState('session_user_B'));

      expect(reloadA.state.role, equals('Admin'));
      expect(reloadB.state.role, equals('Guest'));
    });

    test('Worst Case 14: List/Collection persistence', () {
      final graft1 = Graft(CollectionState());
      graft1.state
        ..tags = ['flutter', 'dart', 'graft', 'reactive']
        ..update();

      // Restart Frame 0:
      final graft2 = Graft(CollectionState());
      expect(graft2.state.tags, equals(['flutter', 'dart', 'graft', 'reactive']));
    });

    test('Worst Case 15: Double precision float values with high decimal precision', () {
      final graft1 = Graft(GeoState());
      graft1.state
        ..latitude = 37.7749295
        ..longitude = -122.4194155
        ..update();

      // Restart Frame 0:
      final graft2 = Graft(GeoState());
      expect(graft2.state.latitude, closeTo(37.7749295, 0.0000001));
      expect(graft2.state.longitude, closeTo(-122.4194155, 0.0000001));
    });
  });
}

// ============================================================================
// WORST CASE 8: V2 Swapped Order (int FIRST, String SECOND)
// ============================================================================
class V2SwappedOrderState extends GraftState {
  int score = 0;
  String name = 'DefaultName';

  @override
  GraftProps get props => propsOf(score, name);

  @override
  void onDry() {
    score = dry(score);
    name = dry(name);
  }
}

// ============================================================================
// WORST CASE 9: Nullable Fields State
// ============================================================================
class NullableFieldsState extends GraftState {
  String? nickname;
  int? optionalScore;

  @override
  GraftProps get props => propsOf(nickname, optionalScore);

  @override
  void onDry() {
    nickname = dry(nickname);
    optionalScore = dry(optionalScore);
  }
}

// ============================================================================
// WORST CASE 10: Deep 2-Level Nested Models
// ============================================================================
class OfficeModel extends GraftModel {
  String building = 'HQ';
  int floor = 1;

  @override
  GraftProps get props => propsOf(building, floor);

  @override
  void onDry() {
    building = dry(building);
    floor = dry(floor);
  }
}

class DepartmentModel extends GraftModel {
  String deptName = 'General';
  OfficeModel office = OfficeModel();

  @override
  GraftProps get props => propsOf(deptName, office);

  @override
  void onDry() {
    deptName = dry(deptName);
    office = dryModel(office);
  }
}

class CompanyState extends GraftState {
  DepartmentModel dept = DepartmentModel();

  @override
  GraftProps get props => propsOf(dept);

  @override
  void onDry() {
    dept = dryModel(dept);
  }
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
  final String _key;
  String role = 'Unknown';

  MultiInstanceState(this._key);

  @override
  String get dryKey => _key;

  @override
  GraftProps get props => propsOf(role);

  @override
  void onDry() {
    role = dry(role);
  }
}

// ============================================================================
// WORST CASE 14: Collection State
// ============================================================================
class CollectionState extends GraftState {
  List<dynamic> tags = [];

  @override
  GraftProps get props => propsOf(tags);

  @override
  void onDry() {
    tags = dry(tags);
  }
}

// ============================================================================
// WORST CASE 15: Geo State (Doubles)
// ============================================================================
class GeoState extends GraftState {
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  GraftProps get props => propsOf(latitude, longitude);

  @override
  void onDry() {
    latitude = dry(latitude);
    longitude = dry(longitude);
  }
}

