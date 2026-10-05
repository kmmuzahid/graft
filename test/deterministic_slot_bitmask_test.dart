import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class MultiFieldBatchState extends GraftState {
  String firstName;
  String lastName;
  int age;
  String email;
  String phone;

  MultiFieldBatchState({
    this.firstName = 'John',
    this.lastName = 'Doe',
    this.age = 30,
    this.email = 'john@example.com',
    this.phone = '1234567890',
  });

  @override
  List<Object?> get props => [firstName, lastName, age, email, phone];
}

class MultiFieldBatchGraft extends Graft<MultiFieldBatchState> {
  MultiFieldBatchGraft() : super(MultiFieldBatchState());

  void updateBatchProfile({
    required String first,
    required String last,
    required int newAge,
  }) {
    state
      ..firstName = first
      ..lastName = last
      ..age = newAge
      ..update();
  }

  void updateContact({
    required String newEmail,
    required String newPhone,
  }) {
    state
      ..email = newEmail
      ..phone = newPhone
      ..update();
  }
}

void main() {
  group('Pillar 4: Deterministic Multi-Field Slot Diffing Tests', () {
    testWidgets('Simultaneous 3-field mutation updates dependent slots while untouched slots have 0 rebuilds', (tester) async {
      final graft = MultiFieldBatchGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              children: (s) => [
                // Slot 0: firstName & lastName (indices 0, 1)
                Text('Name: ${s.firstName} ${s.lastName}'),
                // Slot 1: age (index 2)
                Text('Age: ${s.age}'),
                // Slot 2: email (index 3)
                Text('Email: ${s.email}'),
                // Slot 3: phone (index 4)
                Text('Phone: ${s.phone}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Name: John Doe'), findsOneWidget);
      expect(find.text('Age: 30'), findsOneWidget);
      expect(find.text('Email: john@example.com'), findsOneWidget);
      expect(find.text('Phone: 1234567890'), findsOneWidget);

      final engineState = tester.state(
        find.byType(GraftMultiChildDiffEngine<MultiFieldBatchState>),
      ) as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;

      expect(slotTable[0].rebuildCount, 0);
      expect(slotTable[1].rebuildCount, 0);
      expect(slotTable[2].rebuildCount, 0);
      expect(slotTable[3].rebuildCount, 0);

      // Mutate firstName, lastName, and age together in 1 atomic cascade:
      graft.updateBatchProfile(first: 'Alice', last: 'Wonderland', newAge: 25);
      await tester.pump();

      expect(find.text('Name: Alice Wonderland'), findsOneWidget);
      expect(find.text('Age: 25'), findsOneWidget);

      // Slot 0 and Slot 1 must rebuild exactly once:
      expect(slotTable[0].rebuildCount, 1,
          reason: 'Slot 0 (Name) must rebuild on batch update');
      expect(slotTable[1].rebuildCount, 1,
          reason: 'Slot 1 (Age) must rebuild on batch update');

      // 🛡️ CRITICAL ASSERTION: Untouched slots (email, phone) must have strictly ZERO rebuilds!
      expect(slotTable[2].rebuildCount, 0,
          reason: 'Slot 2 (Email) was not modified and must have 0 rebuilds');
      expect(slotTable[3].rebuildCount, 0,
          reason: 'Slot 3 (Phone) was not modified and must have 0 rebuilds');

      // Now mutate contact fields (email & phone):
      graft.updateContact(newEmail: 'alice@wonderland.com', newPhone: '9876543210');
      await tester.pump();

      expect(find.text('Email: alice@wonderland.com'), findsOneWidget);
      expect(find.text('Phone: 9876543210'), findsOneWidget);

      // Name and Age slots must NOT rebuild now:
      expect(slotTable[0].rebuildCount, 1,
          reason: 'Slot 0 (Name) must not rebuild when only contacts update');
      expect(slotTable[1].rebuildCount, 1,
          reason: 'Slot 1 (Age) must not rebuild when only contacts update');

      // Contact slots must now have rebuilt once:
      expect(slotTable[2].rebuildCount, 1);
      expect(slotTable[3].rebuildCount, 1);

      graft.dispose();
    });
  });
}
