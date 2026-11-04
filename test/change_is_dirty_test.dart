import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class UserProfileState extends GraftState {
  String name;
  int age;
  String email;

  UserProfileState({
    this.name = 'Alice',
    this.age = 25,
    this.email = 'alice@example.com',
  });

  @override
  GraftProps get props => propsOf(name, age, email);
}

class UserProfileGraft extends Graft<UserProfileState> {
  UserProfileGraft() : super(UserProfileState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update();
  }

  void updateAgeAndEmail(int newAge, String newEmail) {
    state
      ..age = newAge
      ..email = newEmail
      ..update();
  }
}

class ChangeTrackerObserver extends GraftObserver {
  final List<GraftChange<dynamic>> captured = [];

  @override
  void onChange(dynamic graft, GraftChange change) {
    captured.add(change);
  }
}

void main() {
  group('GraftChange.isDirty() Tests', () {
    test('isDirty accurately reports modified property indices', () {
      final observer = ChangeTrackerObserver();
      Graft.observer = observer;

      final graft = UserProfileGraft();

      // Mutation 1: update only name (index 0)
      graft.updateName('Bob');

      expect(observer.captured.length, 1);
      final change1 = observer.captured[0];
      expect(change1.isDirty(0), isTrue);
      expect(change1.isDirty(1), isFalse);
      expect(change1.isDirty(2), isFalse);

      // Mutation 2: update age (index 1) and email (index 2)
      graft.updateAgeAndEmail(26, 'bob@example.com');

      expect(observer.captured.length, 2);
      final change2 = observer.captured[1];
      expect(change2.isDirty(0), isFalse);
      expect(change2.isDirty(1), isTrue);
      expect(change2.isDirty(2), isTrue);

      graft.dispose();
      Graft.observer = null;
    });
  });
}

