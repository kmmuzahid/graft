import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class UserState extends GraftState {
  String name;
  String email;
  String phone;

  UserState({
    this.name = 'Alice',
    this.email = 'alice@example.com',
    this.phone = '123-456-7890',
  });

  @override
  GraftProps get props => propsOf(name, email, phone);
}

void main() {
  group('Graft Multi-Child Slots API', () {
    testWidgets('implements exact core API with direct Column(children: slots) and isolated rebuilds',
        (tester) async {
      // 1. Direct Graft<UserState> instantiation without needing a subclass
      final userGraft = Graft<UserState>(UserState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: userGraft.slots(
              layout: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: slots,
              ),
              slots: [
                (s) => Text(s.name),
                (s) => Text(s.email),
                const SizedBox(height: 16),
                const Divider(),
                (s) => Text(s.phone),
              ],
            ),
          ),
        ),
      );

      // Verify initial layout and content
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('123-456-7890'), findsOneWidget);

      final engineState = tester.state(
        find.byType(GraftMultiChildDiffEngine<UserState>),
      ) as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;

      expect(slotTable[0].rebuildCount, 0);
      expect(slotTable[1].rebuildCount, 0);
      expect(slotTable[2].rebuildCount, 0); // Static SizedBox
      expect(slotTable[3].rebuildCount, 0); // Static Divider
      expect(slotTable[4].rebuildCount, 0);

      // Mutate ONLY name
      userGraft.mutate((s) => s.name = 'Bob');
      await tester.pump();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 1, reason: 'Slot 0 (name) rebuilt');
      expect(slotTable[1].rebuildCount, 0,
          reason: 'Untouched sibling slot 1 must have 0 rebuilds');
      expect(slotTable[2].rebuildCount, 0,
          reason: 'Static SizedBox must have 0 rebuilds');
      expect(slotTable[3].rebuildCount, 0,
          reason: 'Static Divider must have 0 rebuilds');
      expect(slotTable[4].rebuildCount, 0,
          reason: 'Untouched sibling slot 4 must have 0 rebuilds');

      // Mutate ONLY email
      userGraft.mutate((s) => s.email = 'bob@example.com');
      await tester.pump();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 1,
          reason: 'Slot 0 was not modified and stays at 1');
      expect(slotTable[1].rebuildCount, 1, reason: 'Slot 1 (email) rebuilt');
      expect(slotTable[2].rebuildCount, 0);
      expect(slotTable[3].rebuildCount, 0);
      expect(slotTable[4].rebuildCount, 0,
          reason: 'Untouched sibling slot 4 must have 0 rebuilds');

      // Mutate ONLY phone
      userGraft.mutate((s) => s.phone = '987-654-3210');
      await tester.pump();

      expect(find.text('987-654-3210'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 1);
      expect(slotTable[1].rebuildCount, 1);
      expect(slotTable[2].rebuildCount, 0);
      expect(slotTable[3].rebuildCount, 0);
      expect(slotTable[4].rebuildCount, 1, reason: 'Slot 4 (phone) rebuilt');

      userGraft.dispose();
    });

    testWidgets('supports static widgets directly without closure wrappers',
        (tester) async {
      final userGraft = Graft<UserState>(
        UserState(
          name: 'Charlie',
          email: 'charlie@example.com',
          phone: '555-0199',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: userGraft.slots(
              layout: Row(
                children: slots,
              ),
              slots: [
                const Text('Static Label:'),
                const SizedBox(width: 8),
                (s) => Text(s.name),
                const SizedBox(width: 8),
                Text('Direct Non-Const Widget'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Static Label:'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Direct Non-Const Widget'), findsOneWidget);

      final engineState = tester.state(
        find.byType(GraftMultiChildDiffEngine<UserState>),
      ) as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;
      expect(slotTable[0].isStatic, isTrue);
      expect(slotTable[1].isStatic, isTrue);
      expect(slotTable[2].isStatic, isFalse);
      expect(slotTable[3].isStatic, isTrue);
      expect(slotTable[4].isStatic, isTrue);

      userGraft.dispose();
    });

    testWidgets('is layout agnostic and works with Stack, Wrap, and builder functions',
        (tester) async {
      final userGraft = Graft<UserState>(UserState(name: 'Dana'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: userGraft.slots(
              layout: Stack(
                alignment: Alignment.center,
                children: slots,
              ),
              slots: [
                (s) => Text(s.name),
                const Positioned(
                  bottom: 0,
                  child: Text('Footer'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Dana'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);

      userGraft.mutate((s) => s.name = 'Dana Updated');
      await tester.pump();

      expect(find.text('Dana Updated'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);

      userGraft.dispose();
    });

    testWidgets('supports builder functions for custom layout logic',
        (tester) async {
      final userGraft = Graft<UserState>(UserState(name: 'Custom'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: userGraft.slots(
              layout: (children) => Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
              slots: [
                (s) => Text(s.name),
                const Divider(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      userGraft.dispose();
    });
  });
}
