import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class MultiFieldState extends GraftState {
  String firstName;
  String lastName;
  int score;
  String email;

  MultiFieldState({
    this.firstName = 'Alice',
    this.lastName = 'Smith',
    this.score = 100,
    this.email = 'alice@example.com',
  });

  @override
  List<Object?> get props => [firstName, lastName, score, email];
}

class MultiFieldGraft extends Graft<MultiFieldState> {
  MultiFieldGraft() : super(MultiFieldState());

  void updateFirstName(String name) {
    state
      ..firstName = name
      ..update();
  }

  void updateLastName(String name) {
    state
      ..lastName = name
      ..update();
  }

  void updateScore(int score) {
    state
      ..score = score
      ..update();
  }

  void updateEmail(String email) {
    state
      ..email = email
      ..update();
  }

  void updateMulti({String? firstName, int? score}) {
    state
      ..firstName = firstName ?? state.firstName
      ..score = score ?? state.score
      ..update();
  }
}

class TrackedSlotWidget extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback onBuild;

  const TrackedSlotWidget(this.text, {super.key, required this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedSlotWidget && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(text);
  }
}

void main() {
  testWidgets(
      'Multi-field slot correctly rebuilds when either or both dependent fields change',
      (tester) async {
    final graft = MultiFieldGraft();

    int multiFieldBuilds = 0;
    int scoreBuilds = 0;
    int staticBuilds = 0;
    int emailBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            layout: (children) => Column(children: children),
            children: (s) => [
              // Slot 0: Depends on BOTH firstName (field 0) AND lastName (field 1)
              TrackedSlotWidget('Full: ${s.firstName} ${s.lastName}',
                  onBuild: () => multiFieldBuilds++),
              // Slot 1: Depends only on score (field 2)
              TrackedSlotWidget('Score: ${s.score}',
                  onBuild: () => scoreBuilds++),
              // Slot 2: Static banner (0 fields)
              TrackedSlotWidget('STATIC BANNER', onBuild: () => staticBuilds++),
              // Slot 3: Depends only on email (field 3)
              TrackedSlotWidget('Email: ${s.email}',
                  onBuild: () => emailBuilds++),
            ],
          ),
        ),
      ),
    );

    // Initial mount: all 4 slots build once
    expect(multiFieldBuilds, 1);
    expect(scoreBuilds, 1);
    expect(staticBuilds, 1);
    expect(emailBuilds, 1);

    // 1. Mutate ONLY firstName (field 0) -> Slot 0 must rebuild
    graft.updateFirstName('Alicia');
    await tester.pump();

    expect(multiFieldBuilds, 2,
        reason: 'Slot 0 must rebuild when firstName changes');
    expect(scoreBuilds, 1, reason: 'Slot 1 (score) must NOT rebuild');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must NOT rebuild');
    expect(emailBuilds, 1, reason: 'Slot 3 (email) must NOT rebuild');

    // 2. Mutate ONLY lastName (field 1) -> Slot 0 must rebuild as well!
    // In old buggy implementation with single boundFieldIndex, this was permanently dropped!
    graft.updateLastName('Wonderland');
    await tester.pump();

    expect(multiFieldBuilds, 3,
        reason:
            'Slot 0 must rebuild when lastName changes even after firstName was learned');
    expect(scoreBuilds, 1, reason: 'Slot 1 (score) must NOT rebuild');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must NOT rebuild');
    expect(emailBuilds, 1, reason: 'Slot 3 (email) must NOT rebuild');

    // 3. Mutate ONLY score (field 2) -> Slot 0 must NOT rebuild, Slot 1 must rebuild
    graft.updateScore(999);
    await tester.pump();

    expect(multiFieldBuilds, 3,
        reason: 'Slot 0 must NOT rebuild when unrelated score changes');
    expect(scoreBuilds, 2, reason: 'Slot 1 (score) must rebuild');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must NOT rebuild');
    expect(emailBuilds, 1, reason: 'Slot 3 (email) must NOT rebuild');

    // 4. Mutate BOTH firstName (field 0) and score (field 2) together
    graft.updateMulti(firstName: 'AliceInChains', score: 777);
    await tester.pump();

    expect(multiFieldBuilds, 4,
        reason: 'Slot 0 must rebuild when firstName changes in multi-update');
    expect(scoreBuilds, 3,
        reason: 'Slot 1 must rebuild when score changes in multi-update');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must NOT rebuild');
    expect(emailBuilds, 1, reason: 'Slot 3 (email) must NOT rebuild');

    // 5. Verify learned bitmasks on slotTable
    final engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<MultiFieldState>))
            as dynamic;
    final slotTable = engineState.slotTable as List<SlotMetadata>;

    // Slot 0 depends on bit 0 (firstName) and bit 1 (lastName) -> GraftMask with bits 0 and 1
    expect(slotTable[0].fieldDependenciesMask, GraftMask.fromIndex(0).withBit(1),
        reason: 'Slot 0 must accumulate bits 0 and 1');
    // Slot 1 depends on bit 2 (score) -> GraftMask with bit 2
    expect(slotTable[1].fieldDependenciesMask, GraftMask.fromIndex(2),
        reason: 'Slot 1 must have bit 2');
    expect(slotTable[1].boundFieldIndex, 2,
        reason: 'Single-field slot reports boundFieldIndex == 2');
    // Slot 2 static
    expect(slotTable[2].rebuildCount, 0, reason: 'Static slot never rebuilt');

    graft.dispose();
  });
}
