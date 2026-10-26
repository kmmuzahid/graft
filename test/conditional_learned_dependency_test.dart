import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class ConditionalState extends GraftState {
  String fieldA;
  String fieldB;
  bool showB;

  ConditionalState({
    this.fieldA = 'A_init',
    this.fieldB = 'B_init',
    this.showB = false,
  });

  @override
  GraftProps get props => propsOf(fieldA, fieldB, showB);

  @override
  void onReset() {
    fieldA = 'A_init';
    fieldB = 'B_init';
    showB = false;
  }
}

class ConditionalGraft extends Graft<ConditionalState> {
  ConditionalGraft() : super(ConditionalState());

  void setFieldA(String val) {
    state
      ..fieldA = val
      ..update();
  }

  void setFieldB(String val) {
    state
      ..fieldB = val
      ..update();
  }

  void setShowB(bool val) {
    state
      ..showB = val
      ..update();
  }
}

class TrackedText extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback? onBuild;

  const TrackedText(this.text, {super.key, this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedText && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    return Text(text);
  }
}

void main() {
  group('Learned Dependency Conditional Correctness Tests', () {
    testWidgets(
      'GraftBoundary: switching A -> B, changing A again, and switching back to A',
      (tester) async {
        final graft = ConditionalGraft();
        int builderCalls = 0;
        int elementBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GraftBoundary(
                builder: (context) {
                  builderCalls++;
                  final s = graft.state;
                  return TrackedText(
                    s.showB ? s.fieldB : s.fieldA,
                    onBuild: () => elementBuilds++,
                  );
                },
              ),
            ),
          ),
        );

        // Initial render: reads showB and fieldA
        expect(find.text('A_init'), findsOneWidget);
        expect(builderCalls, 1);
        expect(elementBuilds, 1);

        // 1. Mutate fieldA -> updates UI
        graft.setFieldA('A_updated1');
        await tester.pump();
        expect(find.text('A_updated1'), findsOneWidget);
        expect(builderCalls, 2);
        expect(elementBuilds, 2);

        // 2. Switch condition to showB = true -> UI shows fieldB
        graft.setShowB(true);
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(builderCalls, 3);
        expect(elementBuilds, 3);

        // 3. Mutate fieldA while UI only displays fieldB
        // Pass 1: Diff engine verifies equivalence; 0 Element rebuilds!
        graft.setFieldA('A_updated2');
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(elementBuilds, 3, reason: 'Element must not rebuild when unread field A mutates');
        final builderCallsAfterFirstUnread = builderCalls;

        // Pass 2: Mutate fieldA AGAIN -> Bypassed completely before running builder!
        graft.setFieldA('A_updated3');
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(builderCalls, builderCallsAfterFirstUnread,
            reason: 'GraftBoundary must bypass builder completely once fieldA is learned as ignored on this branch');
        expect(elementBuilds, 3);

        // 4. Mutate fieldB -> MUST react and update
        graft.setFieldB('B_updated1');
        await tester.pump();
        expect(find.text('B_updated1'), findsOneWidget);
        expect(elementBuilds, 4);

        // 5. Switch back to fieldA
        graft.setShowB(false);
        await tester.pump();
        expect(find.text('A_updated3'), findsOneWidget);
        expect(elementBuilds, 5);

        // 6. Mutate fieldA again -> MUST react and update!
        graft.setFieldA('A_final');
        await tester.pump();
        expect(find.text('A_final'), findsOneWidget);

        graft.dispose();
      },
    );

    testWidgets(
      'graft.slots: switching A -> B, mutating A (ignoredMask poisoning), switching back to A',
      (tester) async {
        final graft = ConditionalGraft();
        int slot0ElementBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: graft.slots(
                layout: (children) => Column(children: children),
                slots: (s) => [
                  TrackedText(
                    s.showB ? s.fieldB : s.fieldA,
                    onBuild: () => slot0ElementBuilds++,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('A_init'), findsOneWidget);
        expect(slot0ElementBuilds, 1);

        // 1. Mutate fieldA -> updates UI
        graft.setFieldA('A_updated1');
        await tester.pump();
        expect(find.text('A_updated1'), findsOneWidget);
        expect(slot0ElementBuilds, 2);

        // 2. Switch condition to showB = true
        graft.setShowB(true);
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(slot0ElementBuilds, 3);

        // 3. Mutate fieldA while displaying fieldB
        // In the buggy engine, this causes fieldA to be added to slot.ignoredMask!
        graft.setFieldA('A_updated2');
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(slot0ElementBuilds, 3, reason: 'Slot 0 should not rebuild element for fieldA');

        // 4. Switch condition back to showB = false (reading fieldA again)
        graft.setShowB(false);
        await tester.pump();
        expect(find.text('A_updated2'), findsOneWidget);
        expect(slot0ElementBuilds, 4);

        // 5. NOW mutate fieldA again!
        // BUG TEST: If fieldA is in slot.ignoredMask, this mutation is completely dropped!
        graft.setFieldA('A_final');
        await tester.pump();
        
        print('graft.slots content after mutating fieldA again: ${find.text('A_final').evaluate().isNotEmpty}');
        expect(find.text('A_final'), findsOneWidget,
            reason: 'Field A was blacklisted in ignoredMask during branch B and failed to update when branch A was restored!');

        graft.dispose();
      },
    );

    testWidgets(
      'graft((s) => ...): single-slot scope with conditional branch and ignoredMask poisoning',
      (tester) async {
        final graft = ConditionalGraft();
        int elementBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: graft(
                (s) => TrackedText(
                  s.showB ? s.fieldB : s.fieldA,
                  onBuild: () => elementBuilds++,
                ),
              ),
            ),
          ),
        );

        expect(find.text('A_init'), findsOneWidget);
        expect(elementBuilds, 1);

        // 1. Mutate fieldA -> updates
        graft.setFieldA('A_updated1');
        await tester.pump();
        expect(find.text('A_updated1'), findsOneWidget);
        expect(elementBuilds, 2);

        // 2. Switch to fieldB
        graft.setShowB(true);
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(elementBuilds, 3);

        // 3. Mutate fieldA while displaying fieldB (poisons _ignoredMask)
        graft.setFieldA('A_updated2');
        await tester.pump();
        expect(find.text('B_init'), findsOneWidget);
        expect(elementBuilds, 3);

        // 4. Switch back to fieldA
        graft.setShowB(false);
        await tester.pump();
        expect(find.text('A_updated2'), findsOneWidget);
        expect(elementBuilds, 4);

        // 5. Mutate fieldA again -> MUST update!
        graft.setFieldA('A_final');
        await tester.pump();

        expect(find.text('A_final'), findsOneWidget,
            reason: 'Single-slot scope failed to update because fieldA was poisoned in _ignoredMask');

        graft.dispose();
      },
    );

    testWidgets(
      'Disposal releases all subscriptions and listeners',
      (tester) async {
        final graft = ConditionalGraft();
        bool showWidget = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  if (!showWidget) return const SizedBox();
                  return GraftBoundary(
                    builder: (context) => Text(
                      graft.state.showB ? graft.state.fieldB : graft.state.fieldA,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('A_init'), findsOneWidget);

        // Dispose the boundary widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: SizedBox()),
          ),
        );

        // Mutating graft must not throw or cause updates on unmounted elements
        expect(() {
          graft.setFieldA('A_after_dispose');
          graft.setFieldB('B_after_dispose');
        }, returnsNormally);

        graft.dispose();
      },
    );
  });
}
