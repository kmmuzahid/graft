import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AddressState extends GraftState {
  String city;
  int zip;

  AddressState({this.city = 'London', this.zip = 10001});

  @override
  GraftProps get props => propsOf(city, zip);
}

class UserProfileState extends GraftState {
  String username;
  AddressState address;
  List<String> hobbies;

  UserProfileState({
    this.username = 'Alice',
    required this.address,
    required this.hobbies,
  });

  @override
  GraftProps get props => propsOf(username, address, hobbies);
}

class UserProfileGraft extends Graft<UserProfileState> {
  UserProfileGraft()
      : super(UserProfileState(
          address: AddressState(),
          hobbies: ['coding', 'reading'],
        ));

  void updateCity(String newCity) {
    state
      ..address.city = newCity
      ..update();
  }

  void addHobby(String hobby) {
    state
      ..hobbies.add(hobby)
      ..update();
  }

  void modifyHobby(int index, String newValue) {
    state
      ..hobbies[index] = newValue
      ..update();
  }
}

void main() {
  group('Pillar 1: Deep & Recursive Snapshotting Engine Tests', () {
    test('Nested GraftState in-place cascade mutation sets dirty bit for nested prop', () {
      final graft = UserProfileGraft();
      final state = graft.state;

      // Initial diff is clean
      expect(state.diffChanges(), GraftMask.empty);

      // Mutate nested AddressState in-place
      graft.updateCity('Berlin');

      // Index 1 (address) must be marked dirty in bitmask!
      expect(state.dirtyMask.isBitSet(1), isTrue,
          reason: 'Nested AddressState mutation must be detected by recursive snapshotting');
      expect(state.dirtyMask.isBitSet(0), isFalse,
          reason: 'Username index 0 must be untouched');
      expect(state.dirtyMask.isBitSet(2), isFalse,
          reason: 'Hobbies index 2 must be untouched');

      // Subsequent diff without changes must be clean
      expect(state.diffChanges(), GraftMask.empty);

      graft.dispose();
    });

    test('Collection in-place item addition triggers dirty bit', () {
      final graft = UserProfileGraft();
      final state = graft.state;

      expect(state.diffChanges(), GraftMask.empty);

      // Add hobby in-place
      graft.addHobby('gaming');

      expect(state.dirtyMask.isBitSet(2), isTrue,
          reason: 'List item addition must trigger dirty bit at index 2');
      expect(state.dirtyMask.isBitSet(0), isFalse);
      expect(state.dirtyMask.isBitSet(1), isFalse);

      graft.dispose();
    });

    test('Collection in-place item modification triggers dirty bit', () {
      final graft = UserProfileGraft();
      final state = graft.state;

      expect(state.diffChanges(), GraftMask.empty);

      // Modify existing element in-place without replacing list instance
      graft.modifyHobby(0, 'architecture');

      expect(state.dirtyMask.isBitSet(2), isTrue,
          reason: 'List in-place index update must trigger dirty bit at index 2');
      expect(state.dirtyMask.isBitSet(0), isFalse);
      expect(state.dirtyMask.isBitSet(1), isFalse);

      graft.dispose();
    });
  });
}
