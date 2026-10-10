import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class PreflightState extends GraftState {
  String firstName;
  String lastName;
  int score;
  String email;

  PreflightState({
    this.firstName = 'Alice',
    this.lastName = 'Smith',
    this.score = 100,
    this.email = 'alice@example.com',
  });

  @override
  GraftProps get props => propsOf(firstName, lastName, score, email);
}

class PreflightGraft extends Graft<PreflightState> {
  PreflightGraft() : super(PreflightState());

  void updateFirstName(String first) {
    state
      ..firstName = first
      ..update();
  }

  void updateLastName(String last) {
    state
      ..lastName = last
      ..update();
  }

  void updateScore(int newScore) {
    state
      ..score = newScore
      ..update();
  }

  void updateEmail(String newEmail) {
    state
      ..email = newEmail
      ..update();
  }
}

class _TrackedSlot extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback onBuild;
  const _TrackedSlot({required this.text, required this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is _TrackedSlot && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(text);
  }
}

void main() {
  group('Pillar 2: Hardware Bitmask Pre-Flight Filter Tests', () {
    testWidgets('Slot with learned bitmask bypasses diff engine when dirtyMask does not intersect', (tester) async {
      final graft = PreflightGraft();
      int slot0Builds = 0; // Bound to firstName (index 0)
      int slot1Builds = 0; // Bound to score (index 2)

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              slots: [
                (s) => _TrackedSlot(text: 'Name: ${s.firstName}', onBuild: () => slot0Builds++),
                (s) => _TrackedSlot(text: 'Score: ${s.score}', onBuild: () => slot1Builds++),
              ],
            ),
          ),
        ),
      );

      expect(slot0Builds, 1);
      expect(slot1Builds, 1);

      // Prime Slot 0 by updating firstName (dirtyMask is bit 0)
      graft.updateFirstName('Bob');
      await tester.pump();
      expect(slot0Builds, 2);
      expect(slot1Builds, 1);

      // Prime Slot 1 by updating score (dirtyMask is bit 2)
      graft.updateScore(200);
      await tester.pump();
      expect(slot0Builds, 2);
      expect(slot1Builds, 2);

      // Now both slots have learned their single-bit dependencies.
      // Update firstName again: Slot 1 MUST bypass in 1 CPU cycle
      graft.updateFirstName('Charlie');
      await tester.pump();
      expect(slot0Builds, 3);
      expect(slot1Builds, 2, reason: 'Slot 1 must bypass in 1 CPU cycle without rebuilding');

      // Update score again: Slot 0 MUST bypass in 1 CPU cycle
      graft.updateScore(300);
      await tester.pump();
      expect(slot0Builds, 3, reason: 'Slot 0 must bypass in 1 CPU cycle without rebuilding');
      expect(slot1Builds, 3);

      graft.dispose();
    });

    testWidgets('Multi-property slot rebuilds when ANY bound bit is dirty', (tester) async {
      final graft = PreflightGraft();
      int fullNameBuilds = 0; // Bound to firstName (0) and lastName (1)
      int emailBuilds = 0;    // Bound to email (3)

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              slots: [
                (s) => _TrackedSlot(
                  text: 'Full Name: ${s.firstName} ${s.lastName}',
                  onBuild: () => fullNameBuilds++,
                ),
                (s) => _TrackedSlot(
                  text: 'Email: ${s.email}',
                  onBuild: () => emailBuilds++,
                ),
              ],
            ),
          ),
        ),
      );

      expect(fullNameBuilds, 1);
      expect(emailBuilds, 1);

      // Mutate firstName (bit 0) alone -> fullName slot must rebuild
      graft.updateFirstName('Bob');
      await tester.pump();
      expect(fullNameBuilds, 2);
      expect(emailBuilds, 1);

      // Mutate lastName (bit 1) alone -> fullName slot must rebuild
      graft.updateLastName('Jones');
      await tester.pump();
      expect(fullNameBuilds, 3);
      expect(emailBuilds, 1);

      // Mutate email (bit 3) alone -> fullName slot MUST bypass in 1 CPU cycle
      graft.updateEmail('bob.jones@example.com');
      await tester.pump();
      expect(fullNameBuilds, 3, reason: 'FullName slot does not depend on email; must bypass with 0 rebuilds');
      expect(emailBuilds, 2);

      graft.dispose();
    });

    test('Benchmark: 10,000 slots bitmask evaluation completes in < 500 microseconds', () {
      final slots = List<SlotMetadata>.generate(10000, (i) {
        return SlotMetadata(
          slotIndex: i,
          isStatic: false,
          widgetType: Text,
          contentFingerprint: i,
          initialWidget: const Text('Slot'),
          fieldDependenciesMask: GraftMask.fromIndex(i % 64),
        );
      });

      final dirtyMask = GraftMask.fromIndex(5);

      final stopwatch = Stopwatch()..start();
      int dirtyCount = 0;
      for (int i = 0; i < 10000; i++) {
        if (slots[i].isDirty(dirtyMask)) {
          dirtyCount++;
        }
      }
      stopwatch.stop();

      expect(dirtyCount, 157);
      // Ensure 10,000 evaluations finish in less than 5,000 microseconds in the Dart VM
      expect(stopwatch.elapsedMicroseconds, lessThan(5000),
          reason: '10,000 bitmask evaluations took ${stopwatch.elapsedMicroseconds} µs');
    });
  });
}
