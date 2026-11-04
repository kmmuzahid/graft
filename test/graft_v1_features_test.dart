import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

// =============================================================================
// 1. STATE & GRAFT MODELS FOR TESTING
// =============================================================================

class ProfileTestState extends GraftState {
  String name;
  int score;
  String bio;

  ProfileTestState({
    this.name = 'Alice',
    this.score = 50,
    this.bio = 'Flutter Engineer & OSS Enthusiast',
  });

  @override
  GraftProps get props => propsOf(name, score, bio);
}

class ProfileTestGraft extends Graft<ProfileTestState> {
  ProfileTestGraft() : super(ProfileTestState());

  void updateProfile(String newName, int newScore) {
    state
      ..name = newName
      ..score = newScore
      ..update();
  }

  Future<void> fetchBioAsync({bool shouldFail = false}) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldFail) throw Exception('Network timeout');
    state
      ..bio = 'Updated bio'
      ..update();
  }
}

class MockObserver extends GraftObserver {
  final List<GraftChange<dynamic>> changes = [];

  @override
  void onChange(dynamic graft, GraftChange change) {
    changes.add(change);
  }
}

// =============================================================================
// 2. TEST SUITES
// =============================================================================

void main() {
  group('In-Place Cascade Mutation and Property Snapshots', () {
    test(
        'state..update() dispatches GraftChange with automated pre- and post-mutation props',
        () {
      final observer = MockObserver();
      Graft.observer = observer;

      final graft = ProfileTestGraft();
      expect(graft.state.name, 'Alice');
      expect(graft.state.score, 50);

      graft.updateProfile('Bob', 100);

      expect(graft.state.name, 'Bob');
      expect(graft.state.score, 100);
      expect(observer.changes.length, 1);

      final change = observer.changes.first;

      // Automated zero-boilerplate property tracking verification:
      expect(change.previousProps, ['Alice', 50, 'Flutter Engineer & OSS Enthusiast']);
      expect(change.nextProps, ['Bob', 100, 'Flutter Engineer & OSS Enthusiast']);
      expect(change.dirtyMask.isBitSet(0), isTrue); // bit 0 modified (name)
      expect(change.dirtyMask.isBitSet(1), isTrue); // bit 1 modified (score)
      expect(change.dirtyMask.isBitSet(2), isFalse); // bit 2 unchanged (bio)
      expect(change.isDirty(0), isTrue);
      expect(change.isDirty(1), isTrue);
      expect(change.isDirty(2), isFalse);

      graft.dispose();
      Graft.observer = null;
    });

    test('Standard async method updates state and notifies cleanly', () async {
      final graft = ProfileTestGraft();
      await graft.fetchBioAsync();
      expect(graft.state.bio, 'Updated bio');
      graft.dispose();
    });
  });
}
