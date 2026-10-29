import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

// =============================================================================
// 1. STATE & GRAFT MODELS FOR TESTING
// =============================================================================

class ProfileTestState extends GraftState {
  String name;
  int score;
  GraftAsync<String> bioAsync;

  ProfileTestState({
    this.name = 'Alice',
    this.score = 50,
    this.bioAsync = const GraftAsync.idle(),
  });

  @override
  GraftProps get props => propsOf(name, score, bioAsync);
}

class ProfileTestGraft extends Graft<ProfileTestState> {
  ProfileTestGraft() : super(ProfileTestState());

  void updateProfile(String newName, int newScore) {
    state
      ..name = newName
      ..score = newScore
      ..update();
  }

  Future<void> fetchBio({bool shouldFail = false}) async {
    await runAsync<String>(
      task: () async {
        if (shouldFail) throw Exception('Network timeout');
        return 'Flutter Engineer & OSS Enthusiast';
      },
      onUpdate: (asyncBio) {
        state
          ..bioAsync = asyncBio
          ..update();
      },
    );
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
      expect(change.previousProps, ['Alice', 50, const GraftAsync<String>.idle()]);
      expect(change.nextProps, ['Bob', 100, const GraftAsync<String>.idle()]);
      expect(change.dirtyMask.isBitSet(0), isTrue); // bit 0 modified (name)
      expect(change.dirtyMask.isBitSet(1), isTrue); // bit 1 modified (score)
      expect(change.dirtyMask.isBitSet(2), isFalse); // bit 2 unchanged (bioAsync)

      graft.dispose();
      Graft.observer = null;
    });
  });

  group('Phase 4: GraftAsync & runAsync First-Class Async State Engine', () {
    test('GraftAsync pattern matching and convenience getters', () {
      const idle = GraftAsync<int>.idle();
      const loading = GraftAsync<int>.loading();
      const data = GraftAsync<int>.data(42);
      final error = GraftAsync<int>.error('Failed');

      expect(idle.isIdle, isTrue);
      expect(loading.isLoading, isTrue);
      expect(data.hasData, isTrue);
      expect(data.dataOrNull, 42);
      expect(error.hasError, isTrue);
      expect(error.errorOrNull, 'Failed');

      final description = switch (data) {
        AsyncData(:final data) => 'Resolved: $data',
        AsyncLoading() => 'In flight',
        AsyncError(:final error) => 'Failed: $error',
        AsyncIdle() => 'Idle',
      };
      expect(description, 'Resolved: 42');
    });

    test('runAsync successfully transitions through loading and data',
        () async {
      final graft = ProfileTestGraft();
      expect(graft.state.bioAsync.isIdle, isTrue);

      final future = graft.fetchBio();
      // Synchronously, runAsync has set state to loading
      expect(graft.state.bioAsync.isLoading, isTrue);

      await future;

      expect(graft.state.bioAsync.hasData, isTrue);
      expect(
          graft.state.bioAsync.dataOrNull, 'Flutter Engineer & OSS Enthusiast');

      graft.dispose();
    });

    test('runAsync captures errors gracefully without crashing', () async {
      final graft = ProfileTestGraft();
      await graft.fetchBio(shouldFail: true);

      expect(graft.state.bioAsync.hasError, isTrue);
      expect(graft.state.bioAsync.errorOrNull.toString(),
          contains('Network timeout'));

      graft.dispose();
    });
  });
}
