import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class TestProfileState extends GraftState {
  String name;
  String email;
  bool isVerified;
  bool isAdmin;
  List<String> tags;

  TestProfileState({
    this.name = 'Alice',
    this.email = 'alice@example.com',
    this.isVerified = false,
    this.isAdmin = false,
    List<String>? tags,
  }) : tags = tags ?? ['flutter', 'dart'];

  @override
  GraftProps get props => propsOf(name, email, isVerified, isAdmin, tags);
}

void main() {
  group('Graft Unified List-Builder Mode', () {
    testWidgets('renders list builder and preserves fine-grained leaf isolation',
        (tester) async {
      final profileGraft = Graft<TestProfileState>(TestProfileState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: profileGraft.slots(
              layout: Column(children: slots),
              slots: (s) => [
                Text(s.name),
                Text(s.email),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);

      final engineState = tester.state(
        find.byType(GraftMultiChildDiffEngine<TestProfileState>),
      ) as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;

      expect(slotTable[0].rebuildCount, 0);
      expect(slotTable[1].rebuildCount, 0);
      expect(slotTable[2].rebuildCount, 0);

      // Mutate ONLY name
      profileGraft.mutate((s) => s.name = 'Bob');
      await tester.pump();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 1, reason: 'Slot 0 (name) rebuilt');
      expect(slotTable[1].rebuildCount, 0,
          reason: 'Untouched Slot 1 (email) must have 0 rebuilds');
      expect(slotTable[2].rebuildCount, 0,
          reason: 'Static SizedBox must have 0 rebuilds');

      // Mutate ONLY email
      profileGraft.mutate((s) => s.email = 'bob@example.com');
      await tester.pump();

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 1,
          reason: 'Slot 0 (name) untouched, stays at 1');
      expect(slotTable[1].rebuildCount, 1, reason: 'Slot 1 (email) rebuilt');
      expect(slotTable[2].rebuildCount, 0,
          reason: 'Static SizedBox must have 0 rebuilds');
    });

    testWidgets('supports native Dart collection-if toggling dynamically',
        (tester) async {
      final profileGraft = Graft<TestProfileState>(TestProfileState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: profileGraft.slots(
              layout: Column(children: slots),
              slots: (s) => [
                Text(s.name),
                if (s.isVerified)
                  Chip(label: Text('Verified: ${s.name}')),
                Text(s.email),
              ],
            ),
          ),
        ),
      );

      // Initially isVerified is false
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);

      // Toggle isVerified to true
      profileGraft.mutate((s) => s.isVerified = true);
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Verified: Alice'), findsOneWidget);

      // Toggle isVerified back to false
      profileGraft.mutate((s) => s.isVerified = false);
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('supports native Dart collection-if with else branch',
        (tester) async {
      final profileGraft =
          Graft<TestProfileState>(TestProfileState(isAdmin: true));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: profileGraft.slots(
              layout: Column(children: slots),
              slots: (s) => [
                Text(s.name),
                if (s.isAdmin)
                  const Text('Role: Administrator')
                else
                  const Text('Role: Member'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Role: Administrator'), findsOneWidget);
      expect(find.text('Role: Member'), findsNothing);

      // Switch role to member
      profileGraft.mutate((s) => s.isAdmin = false);
      await tester.pump();

      expect(find.text('Role: Administrator'), findsNothing);
      expect(find.text('Role: Member'), findsOneWidget);
    });

    testWidgets('supports native Dart collection-for loop', (tester) async {
      final profileGraft = Graft<TestProfileState>(TestProfileState());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: profileGraft.slots(
              layout: Column(children: slots),
              slots: (s) => [
                Text(s.name),
                for (final tag in s.tags)
                  Chip(label: Text(tag)),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);

      // Add a third tag
      profileGraft.mutate((s) => s.tags = ['flutter', 'dart', 'graft']);
      await tester.pump();

      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('graft'), findsOneWidget);
    });
  });
}
