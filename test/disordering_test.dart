import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class DisorderState extends GraftState {
  String name;
  int score;
  String email;
  bool isVerified;

  DisorderState({
    this.name = 'Alice',
    this.score = 100,
    this.email = 'alice@example.com',
    this.isVerified = false,
  });

  @override
  GraftProps get props => propsOf(name, score, email, isVerified);
}

class DisorderGraft extends Graft<DisorderState> {
  DisorderGraft() : super(DisorderState());

  void updateName(String name) {
    state
      ..name = name
      ..update();
  }

  void updateEmail(String email) {
    state
      ..email = email
      ..update();
  }

  void updateScore(int score) {
    state
      ..score = score
      ..update();
  }

  void updateVerified(bool verified) {
    state
      ..isVerified = verified
      ..update();
  }

  void updateMulti({String? name, int? score}) {
    state
      ..name = name ?? state.name
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
      'Disordered slot order relative to tracked fields resolves surgical leaf rebuilds',
      (tester) async {
    final graft = DisorderGraft();

    int emailBuilds = 0;
    int nameBuilds = 0;
    int staticBuilds = 0;
    int scoreBuilds = 0;
    int verifiedBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            layout: (children) => Column(children: children),
            slots: [
              // Slot 0: email (field index 2)
              (s) => TrackedSlotWidget('Email: ${s.email}',
                  onBuild: () => emailBuilds++),
              // Slot 1: name (field index 0)
              (s) => TrackedSlotWidget('Name: ${s.name}', onBuild: () => nameBuilds++),
              // Slot 2: static
              (_) => TrackedSlotWidget('STATIC BANNER', onBuild: () => staticBuilds++),
              // Slot 3: score (field index 1)
              (s) => TrackedSlotWidget('Score: ${s.score}',
                  onBuild: () => scoreBuilds++),
              // Slot 4: verified (field index 3)
              (s) => TrackedSlotWidget('Verified: ${s.isVerified}',
                  onBuild: () => verifiedBuilds++),
            ],
          ),
        ),
      ),
    );

    // Initial mount builds each slot once
    expect(emailBuilds, 1);
    expect(nameBuilds, 1);
    expect(staticBuilds, 1);
    expect(scoreBuilds, 1);
    expect(verifiedBuilds, 1);

    // 1. Mutate only email (field index 2 -> Slot 0)
    graft.updateEmail('alice.new@example.com');
    await tester.pump();

    expect(emailBuilds, 2, reason: 'Slot 0 (email) must rebuild once');
    expect(nameBuilds, 1, reason: 'Slot 1 (name) must have 0 rebuilds');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must have 0 rebuilds');
    expect(scoreBuilds, 1, reason: 'Slot 3 (score) must have 0 rebuilds');
    expect(verifiedBuilds, 1, reason: 'Slot 4 (verified) must have 0 rebuilds');

    // 2. Mutate only score (field index 1 -> Slot 3)
    graft.updateScore(999);
    await tester.pump();

    expect(emailBuilds, 2, reason: 'Slot 0 must have 0 rebuilds');
    expect(nameBuilds, 1, reason: 'Slot 1 must have 0 rebuilds');
    expect(staticBuilds, 1, reason: 'Slot 2 must have 0 rebuilds');
    expect(scoreBuilds, 2, reason: 'Slot 3 (score) must rebuild once');
    expect(verifiedBuilds, 1, reason: 'Slot 4 must have 0 rebuilds');

    // 3. Mutate only name (field index 0 -> Slot 1)
    graft.updateName('Bob');
    await tester.pump();

    expect(emailBuilds, 2, reason: 'Slot 0 must have 0 rebuilds');
    expect(nameBuilds, 2, reason: 'Slot 1 (name) must rebuild once');
    expect(staticBuilds, 1, reason: 'Slot 2 must have 0 rebuilds');
    expect(scoreBuilds, 2, reason: 'Slot 3 must have 0 rebuilds');
    expect(verifiedBuilds, 1, reason: 'Slot 4 must have 0 rebuilds');

    // 4. Mutate both name (field 0) and score (field 1) together
    graft.updateMulti(name: 'Charlie', score: 500);
    await tester.pump();

    expect(emailBuilds, 2, reason: 'Slot 0 must have 0 rebuilds');
    expect(nameBuilds, 3, reason: 'Slot 1 (name) must rebuild');
    expect(staticBuilds, 1, reason: 'Slot 2 must have 0 rebuilds');
    expect(scoreBuilds, 3, reason: 'Slot 3 (score) must rebuild');
    expect(verifiedBuilds, 1, reason: 'Slot 4 must have 0 rebuilds');

    // Verify self-optimized learned indices on slot table
    final engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<DisorderState>))
            as dynamic;
    final slotTable = engineState.slotTable as List<SlotMetadata>;

    expect(slotTable[0].boundFieldIndex, 2,
        reason: 'Slot 0 mapped to email (field 2)');
    expect(slotTable[1].boundFieldIndex, 0,
        reason: 'Slot 1 mapped to name (field 0)');
    expect(slotTable[3].boundFieldIndex, 1,
        reason: 'Slot 3 mapped to score (field 1)');

    // Verify slotTable rebuild counts
    expect(slotTable[0].rebuildCount, 1,
        reason: 'Slot 0 rebuilt once (on email change)');
    expect(slotTable[1].rebuildCount, 2,
        reason: 'Slot 1 rebuilt twice (on name changes)');
    expect(slotTable[2].rebuildCount, 0,
        reason: 'Static banner rebuilt 0 times');
    expect(slotTable[3].rebuildCount, 2,
        reason: 'Slot 3 rebuilt twice (on score changes)');
    expect(slotTable[4].rebuildCount, 0,
        reason: 'Verified slot rebuilt 0 times');

    graft.dispose();
  });

  testWidgets(
      'DisorderState with tracked order [score, name, isVerified, email] passes completely',
      (tester) async {
    final graft = DisorderInvertedGraft();

    int emailBuilds = 0;
    int nameBuilds = 0;
    int staticBuilds = 0;
    int scoreBuilds = 0;
    int verifiedBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            layout: (children) => Column(children: children),
            slots: [
              // Slot 0: email (field index 3 in tracked)
              (s) => TrackedSlotWidget('Email: ${s.email}',
                  onBuild: () => emailBuilds++),
              // Slot 1: name (field index 1 in tracked)
              (s) => TrackedSlotWidget('Name: ${s.name}', onBuild: () => nameBuilds++),
              // Slot 2: static
              (_) => TrackedSlotWidget('STATIC BANNER', onBuild: () => staticBuilds++),
              // Slot 3: score (field index 0 in tracked)
              (s) => TrackedSlotWidget('Score: ${s.score}',
                  onBuild: () => scoreBuilds++),
              // Slot 4: verified (field index 2 in tracked)
              (s) => TrackedSlotWidget('Verified: ${s.isVerified}',
                  onBuild: () => verifiedBuilds++),
            ],
          ),
        ),
      ),
    );

    expect(emailBuilds, 1);
    expect(nameBuilds, 1);
    expect(staticBuilds, 1);
    expect(scoreBuilds, 1);
    expect(verifiedBuilds, 1);

    // 1. Mutate only email (field index 3 -> Slot 0)
    graft.updateEmail('inverted@example.com');
    await tester.pump();

    expect(emailBuilds, 2, reason: 'Slot 0 (email) must rebuild');
    expect(nameBuilds, 1, reason: 'Slot 1 (name) must have 0 rebuilds');
    expect(staticBuilds, 1, reason: 'Slot 2 (static) must have 0 rebuilds');
    expect(scoreBuilds, 1, reason: 'Slot 3 (score) must have 0 rebuilds');
    expect(verifiedBuilds, 1, reason: 'Slot 4 (verified) must have 0 rebuilds');

    // 2. Mutate only score (field index 0 -> Slot 3)
    graft.updateScore(777);
    await tester.pump();

    expect(emailBuilds, 2);
    expect(nameBuilds, 1);
    expect(staticBuilds, 1);
    expect(scoreBuilds, 2, reason: 'Slot 3 (score) must rebuild');
    expect(verifiedBuilds, 1);

    // 3. Mutate only name (field index 1 -> Slot 1)
    graft.updateName('Bob Inverted');
    await tester.pump();

    expect(emailBuilds, 2);
    expect(nameBuilds, 2, reason: 'Slot 1 (name) must rebuild');
    expect(staticBuilds, 1);
    expect(scoreBuilds, 2);
    expect(verifiedBuilds, 1);

    // Verify self-optimized learned indices on slot table
    final engineState = tester.state(
            find.byType(GraftMultiChildDiffEngine<DisorderStateInverted>))
        as dynamic;
    final slotTable = engineState.slotTable as List<SlotMetadata>;

    // In [score, name, isVerified, email]:
    // score = index 0
    // name = index 1
    // isVerified = index 2
    // email = index 3
    expect(slotTable[0].boundFieldIndex, 3,
        reason: 'Slot 0 (email) mapped to field index 3');
    expect(slotTable[1].boundFieldIndex, 1,
        reason: 'Slot 1 (name) mapped to field index 1');
    expect(slotTable[3].boundFieldIndex, 0,
        reason: 'Slot 3 (score) mapped to field index 0');

    graft.dispose();
  });
}

class DisorderStateInverted extends GraftState {
  String name;
  int score;
  String email;
  bool isVerified;

  DisorderStateInverted({
    this.name = 'Alice',
    this.score = 100,
    this.email = 'alice@example.com',
    this.isVerified = false,
  });

  @override
  GraftProps get props => propsOf(score, name, isVerified, email);
}

class DisorderInvertedGraft extends Graft<DisorderStateInverted> {
  DisorderInvertedGraft() : super(DisorderStateInverted());

  void updateName(String name) {
    state
      ..name = name
      ..update();
  }

  void updateEmail(String email) {
    state
      ..email = email
      ..update();
  }

  void updateScore(int score) {
    state
      ..score = score
      ..update();
  }
}
