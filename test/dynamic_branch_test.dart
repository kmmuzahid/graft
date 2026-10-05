import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class DynamicBranchState extends GraftState {
  String title;
  bool showDetails;
  List<String> tags;

  DynamicBranchState({
    this.title = 'Main Item',
    this.showDetails = false,
    this.tags = const ['Flutter', 'Dart'],
  });

  @override
  List<Object?> get props => [title, showDetails, tags.length];
}

class DynamicBranchGraft extends Graft<DynamicBranchState> {
  DynamicBranchGraft() : super(DynamicBranchState());

  void toggleDetails() {
    state
      ..showDetails = !state.showDetails
      ..update();
  }

  void updateTitle(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }

  void addTag(String tag) {
    state
      ..tags = [...state.tags, tag]
      ..update();
  }

  void removeTag() {
    if (state.tags.isNotEmpty) {
      state
        ..tags = state.tags.sublist(0, state.tags.length - 1)
        ..update();
    }
  }
}

void main() {
  testWidgets(
      'graft.slots dynamic branching: list resizing, slot table reconciliation and memory safety',
      (tester) async {
    final graft = DynamicBranchGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            layout: (children) => Column(children: children),
            children: (s) => [
              Text('Title: ${s.title}'),
              if (s.showDetails) const Text('EXPANDED DETAILS BANNER'),
              for (final tag in s.tags) Text('Tag: $tag'),
              const Text('STATIC FOOTER'),
            ],
          ),
        ),
      ),
    );

    // Initial state: showDetails=false, tags=2 => Total slots = 1 (title) + 2 (tags) + 1 (footer) = 4
    expect(find.text('Title: Main Item'), findsOneWidget);
    expect(find.text('EXPANDED DETAILS BANNER'), findsNothing);
    expect(find.text('Tag: Flutter'), findsOneWidget);
    expect(find.text('Tag: Dart'), findsOneWidget);
    expect(find.text('STATIC FOOTER'), findsOneWidget);

    var engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<DynamicBranchState>))
            as dynamic;
    expect((engineState.slotTable as List<SlotMetadata>).length, 4);

    // 1. Expand branch: showDetails becomes true => Total slots = 5
    graft.toggleDetails();
    await tester.pump();

    expect(find.text('EXPANDED DETAILS BANNER'), findsOneWidget);
    engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<DynamicBranchState>))
            as dynamic;
    expect((engineState.slotTable as List<SlotMetadata>).length, 5);

    // 2. Add tag via dynamic loop => Total slots = 6
    graft.addTag('Graft');
    await tester.pump();

    expect(find.text('Tag: Graft'), findsOneWidget);
    engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<DynamicBranchState>))
            as dynamic;
    expect((engineState.slotTable as List<SlotMetadata>).length, 6);

    // 3. Mutate title (Slot 0) while resized -> ensures diffing still works correctly
    graft.updateTitle('Updated Master Item');
    await tester.pump();

    expect(find.text('Title: Updated Master Item'), findsOneWidget);

    // 4. Contract branch: collapse details and remove tag => Total slots = 4
    graft.toggleDetails();
    graft.removeTag();
    await tester.pump();

    expect(find.text('EXPANDED DETAILS BANNER'), findsNothing);
    expect(find.text('Tag: Graft'), findsNothing);
    engineState =
        tester.state(find.byType(GraftMultiChildDiffEngine<DynamicBranchState>))
            as dynamic;
    expect((engineState.slotTable as List<SlotMetadata>).length, 4);

    // 5. Mutate title again on contracted list -> ensures no stale listener references or errors
    graft.updateTitle('Final Title Check');
    await tester.pump();

    expect(find.text('Title: Final Title Check'), findsOneWidget);

    graft.dispose();
  });
}
