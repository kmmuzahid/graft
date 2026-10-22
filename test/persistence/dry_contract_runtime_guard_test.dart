import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/core/graft_state.dart';
import 'package:graft/src/persistence/ambient_locator.dart';

class StateWithoutVersion extends GraftState {
  String name = 'Test';
  @override
  GraftProps get props => propsOf(name);
}

class ValidVersionState extends GraftState {
  @override
  int get schemaVersion => 1;
  String name = 'Test';
  @override
  GraftProps get props => propsOf(name);
}

class ModelWithoutFactory extends GraftModel {
  @override
  int get schemaVersion => 1;
  String street = 'Main';
  @override
  GraftProps get props => propsOf(street);
}

class StateWithModelNoFactory extends GraftState {
  @override
  int get schemaVersion => 1;
  ModelWithoutFactory model = ModelWithoutFactory();
  @override
  GraftProps get props => propsOf(model);
}

class ModelWithoutVersion extends GraftModel {
  String street = 'Main';
  @override
  GraftProps get props => propsOf(street);
  @override
  Function get factory => ModelWithoutVersion.new;
}

class StateWithModelNoVersion extends GraftState {
  @override
  int get schemaVersion => 1;
  ModelWithoutVersion model = ModelWithoutVersion();
  @override
  GraftProps get props => propsOf(model);
}

void main() {
  setUp(() {
    resetAmbientPersistence();
  });

  tearDown(() {
    resetAmbientPersistence();
  });

  group('Dry Contract Runtime Guard Tests', () {
    test('throws StateError when Graft.dry is used with State lacking schemaVersion', () {
      expect(
        () => Graft.dry(StateWithoutVersion.new),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('must override "@override int get schemaVersion => 1;"'),
          ),
        ),
      );
    });

    test('throws StateError when nested GraftModel lacks factory tear-off', () {
      expect(
        () => Graft.dry(StateWithModelNoFactory.new),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('must override "@override Function get factory => ModelWithoutFactory.new;"'),
          ),
        ),
      );
    });

    test('throws StateError when nested GraftModel lacks schemaVersion', () {
      expect(
        () => Graft.dry(StateWithModelNoVersion.new),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('must override "@override int get schemaVersion => 1;"'),
          ),
        ),
      );
    });

    test('succeeds when all contracts are properly satisfied', () {
      final graft = Graft<ValidVersionState>.dry(ValidVersionState.new);
      expect(graft.state.name, equals('Test'));
      expect(GraftStateEngine.isDryEnabled(graft.state), isTrue);
    });
  });
}
