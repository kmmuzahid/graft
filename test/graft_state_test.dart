import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TestProfileState extends GraftState {
  String name;
  int age;
  bool isLoading;

  TestProfileState({
    this.name = '',
    this.age = 0,
    this.isLoading = false,
  });
}

class TestProfileGraft extends Graft<TestProfileState> {
  TestProfileGraft() : super(TestProfileState());

  void updateProfile({String? name, int? age, bool? isLoading}) {
    state
      ..name = name ?? state.name
      ..age = age ?? state.age
      ..isLoading = isLoading ?? state.isLoading
      ..update();
  }

  void silentUpdateAge(int newAge) {
    state.age = newAge;
    // No update() call -> silent update!
  }
}

class _SpyObserver extends GraftObserver {
  int changeCount = 0;
  GraftChange? lastChange;

  @override
  void onChange(dynamic graft, GraftChange change) {
    changeCount++;
    lastChange = change;
  }
}

class _ConstHeaderWidget extends StatelessWidget {
  static int buildCount = 0;
  const _ConstHeaderWidget();

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return const Text('Static Header');
  }
}

class _DynamicFieldWidget extends StatelessWidget implements GraftEquivalent {
  static int nameBuildCount = 0;
  static int ageBuildCount = 0;

  final String label;
  final String value;
  final bool isAge;

  const _DynamicFieldWidget({
    required this.label,
    required this.value,
    this.isAge = false,
  });

  @override
  bool isEquivalentTo(Widget other) {
    return other is _DynamicFieldWidget &&
        other.label == label &&
        other.value == value &&
        other.isAge == isAge;
  }

  @override
  Widget build(BuildContext context) {
    if (isAge) {
      ageBuildCount++;
    } else {
      nameBuildCount++;
    }
    return Text('$label: $value');
  }
}

void main() {
  setUp(() {
    _ConstHeaderWidget.buildCount = 0;
    _DynamicFieldWidget.nameBuildCount = 0;
    _DynamicFieldWidget.ageBuildCount = 0;
  });

  group('GraftState & Direct Cascade Updates', () {
    test('auto-binds GraftState and notifies listeners via state..update()', () {
      final graft = TestProfileGraft();
      int listenerCalls = 0;

      graft.addListener(() {
        listenerCalls++;
      });

      expect(graft.state.name, '');
      expect(graft.state.age, 0);

      // Perform direct cascade mutation
      graft.updateProfile(name: 'Alice', age: 25);

      expect(graft.state.name, 'Alice');
      expect(graft.state.age, 25);
      expect(listenerCalls, 1); // Exactly 1 batched notification!
    });

    test('silent update modifies memory without notifying listeners', () {
      final graft = TestProfileGraft();
      int listenerCalls = 0;

      graft.addListener(() {
        listenerCalls++;
      });

      // Silent update
      graft.silentUpdateAge(99);

      expect(graft.state.age, 99); // Memory is updated!
      expect(listenerCalls, 0); // 0 notifications triggered!

      // Subsequent update notifies with all accumulated values
      graft.updateProfile(name: 'Bob');

      expect(graft.state.name, 'Bob');
      expect(graft.state.age, 99);
      expect(listenerCalls, 1);
    });

    test('triggers GraftObserver.onChange on state..update()', () {
      final spy = _SpyObserver();
      Graft.observer = spy;

      final graft = TestProfileGraft();

      graft.updateProfile(name: 'Charlie', isLoading: true);

      expect(spy.changeCount, 1);
      expect(spy.lastChange, isNotNull);
      expect((spy.lastChange!.nextState as TestProfileState).name, 'Charlie');

      Graft.observer = null;
    });
  });

  group('GraftState + ChildSlotEngine (0-rebuild isolation with cascade)', () {
    testWidgets('diffs slots with 0 rebuilds for unchanged slots when using state..update()', (tester) async {
      final graft = TestProfileGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              children: (s) => [
                const _ConstHeaderWidget(),
                _DynamicFieldWidget(label: 'Name', value: s.name),
                _DynamicFieldWidget(label: 'Age', value: s.age.toString(), isAge: true),
              ],
            ),
          ),
        ),
      );

      // Initial build: every slot renders once
      expect(_ConstHeaderWidget.buildCount, 1);
      expect(_DynamicFieldWidget.nameBuildCount, 1);
      expect(_DynamicFieldWidget.ageBuildCount, 1);
      expect(find.text('Static Header'), findsOneWidget);
      expect(find.text('Name: '), findsOneWidget);
      expect(find.text('Age: 0'), findsOneWidget);

      // Mutate ONLY name via cascade
      graft.updateProfile(name: 'David');
      await tester.pump();

      // Verified 0-rebuild isolation:
      expect(_ConstHeaderWidget.buildCount, 1, reason: 'Static header must experience 0 extra rebuilds');
      expect(_DynamicFieldWidget.ageBuildCount, 1, reason: 'Unchanged age slot must experience 0 extra rebuilds');
      expect(_DynamicFieldWidget.nameBuildCount, 2, reason: 'Changed name slot must rebuild exactly once');

      expect(find.text('Name: David'), findsOneWidget);
      expect(find.text('Age: 0'), findsOneWidget);

      // Now mutate age via cascade
      graft.updateProfile(age: 30);
      await tester.pump();

      expect(_ConstHeaderWidget.buildCount, 1, reason: 'Static header must experience 0 extra rebuilds');
      expect(_DynamicFieldWidget.nameBuildCount, 2, reason: 'Unchanged name slot must experience 0 extra rebuilds');
      expect(_DynamicFieldWidget.ageBuildCount, 2, reason: 'Changed age slot must rebuild exactly once');

      expect(find.text('Name: David'), findsOneWidget);
      expect(find.text('Age: 30'), findsOneWidget);
    });
  });

  group('ValueGraft (Single-value primitive reactivity without state class)', () {
    test('updates primitive value and notifies listeners', () {
      final counter = _TestCounterGraft();
      int listenerCalls = 0;

      counter.addListener(() => listenerCalls++);

      expect(counter.value, 0);

      counter.increment();
      expect(counter.value, 1);
      expect(listenerCalls, 1);

      counter.increment();
      expect(counter.value, 2);
      expect(listenerCalls, 2);

      // Same value is a no-op:
      counter.value = 2;
      expect(listenerCalls, 2);
    });

    testWidgets('ValueGraft.slot renders reactive updates cleanly', (tester) async {
      final counter = _TestCounterGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                counter.slot(builder: (count) => Text('Slot Count: $count')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Slot Count: 0'), findsOneWidget);

      counter.increment();
      await tester.pump();

      expect(find.text('Slot Count: 1'), findsOneWidget);
    });
  });
}

class _TestCounterGraft extends ValueGraft<int> {
  _TestCounterGraft() : super(0);

  void increment() => value++;
  void decrement() => value--;
}
