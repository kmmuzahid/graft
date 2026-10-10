import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class ThemedTestState extends GraftState {
  String title;
  int count;

  ThemedTestState({this.title = 'Card Title', this.count = 0});

  @override
  GraftProps get props => propsOf(title, count);
}

class ThemedTestGraft extends Graft<ThemedTestState> {
  ThemedTestGraft() : super(ThemedTestState());

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void updateTitle(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }
}

class IsolatedThemedCard extends StatelessWidget {
  final String title;
  const IsolatedThemedCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Reads Theme from context - must NOT leak dependency to ancestor diff engine
    final primary = Theme.of(context).primaryColor;
    return Container(
      color: primary,
      child: Text(title),
    );
  }
}

void main() {
  group('Pillar 2: NoSubscriptionContext & Inherited Isolation Tests', () {
    testWidgets('Custom StatelessWidget reading Theme does not contaminate ancestor DiffEngine', (tester) async {
      final graft = ThemedTestGraft();
      int layoutBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: graft.slots(
              layout: (children) {
                layoutBuilds++;
                return Column(children: children);
              },
              slots: [
                (s) => IsolatedThemedCard(title: s.title),
                (s) => Text('Count: ${s.count}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);
      expect(layoutBuilds, 1);

      final engineState = tester.state(
        find.byType(GraftMultiChildDiffEngine<ThemedTestState>),
      ) as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;

      expect(slotTable[0].rebuildCount, 0);
      expect(slotTable[1].rebuildCount, 0);

      // Mutate count only (field index 1)
      // Themed card depends on title (field index 0), so it MUST have 0 rebuilds!
      graft.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(slotTable[0].rebuildCount, 0,
          reason: 'Slot 0 (ThemedCard) must have 0 rebuilds when only count changes');
      expect(slotTable[1].rebuildCount, 1,
          reason: 'Slot 1 (Count) must have exactly 1 rebuild');
      expect(layoutBuilds, 1,
          reason: 'Ancestor layout container must experience 0 element rebuilds');

      graft.dispose();
    });
  });
}
