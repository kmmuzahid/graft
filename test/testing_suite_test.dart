import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/testing.dart';

abstract class AuthService {
  String get username;
}

class RealAuthService implements AuthService {
  @override
  String get username => 'real_user';
}

class MockAuthService implements AuthService {
  @override
  String get username => 'mock_user';
}

class CounterState extends GraftState {
  int count;
  CounterState({this.count = 0});

  @override
  GraftProps get props => propsOf(count);
}

class CounterGraft extends Graft<CounterState> {
  CounterGraft([CounterState? initial]) : super(initial ?? CounterState());

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void triggerError(Object error) {
    addError(error);
  }
}

void main() {
  setUp(() {
    GraftTesting.resetAll();
  });

  tearDown(() {
    GraftTesting.resetAll();
  });

  group('GraftTesting Suite & graftTest Upgrade Tests', () {
    test('GraftTesting.runWithOverrides runs block with scoped mock dependency', () async {
      bind<AuthService>(RealAuthService.new);

      // Outside overrides: real service
      expect(use<AuthService>().username, 'real_user');

      // Inside overrides: mock service
      GraftTesting.runWithOverrides(
        {
          AuthService: MockAuthService(),
        },
        () {
          expect(use<AuthService>().username, 'mock_user');
        },
      );

      // Outside again: real service
      expect(use<AuthService>().username, 'real_user');
    });

    test('GraftTesting.recordChanges captures all GraftChange events', () {
      final graft = CounterGraft();

      final changes = GraftTesting.recordChanges(graft, () {
        graft.increment();
        graft.increment();
      });

      expect(changes.length, 2);
      expect(changes[0].nextProps, [1]);
      expect(changes[0].previousProps, [0]);
      expect(changes[1].nextProps, [2]);
      expect(changes[1].previousProps, [1]);

      graft.dispose();
    });

    graftTest<CounterGraft, CounterState>(
      'graftTest with overrides, seed, and expectChanges verification',
      overrides: {
        AuthService: MockAuthService(),
      },
      seed: (graft) {
        graft.state
          ..count = 10
          ..update();
      },
      build: () => CounterGraft(),
      act: (graft) {
        expect(use<AuthService>().username, 'mock_user');
        graft.increment();
      },
      expectChanges: () => [
        isA<GraftChange>(),
        isA<GraftChange>(),
      ],
      verify: (graft) {
        expect(graft.state.count, 11);
      },
    );

    graftTest<CounterGraft, CounterState>(
      'graftTest captures errors gracefully in errors list',
      build: () => CounterGraft(),
      act: (graft) {
        graft.triggerError(Exception('Failure A'));
      },
      errors: () => [
        isA<Exception>(),
      ],
    );
  });
}

