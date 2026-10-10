import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/widgets/slot_metadata.dart';

class LifecycleState extends GraftState {
  String text;
  LifecycleState(this.text);

  @override
  GraftProps get props => propsOf(text);
}

class LifecycleGraft extends Graft<LifecycleState> {
  LifecycleGraft() : super(LifecycleState('initial'));

  void setText(String s) {
    state
      ..text = s
      ..update();
  }
}

void main() {
  group('Graft & Slot Engine Lifecycle and Memory Cleanup', () {
    test('Mask listeners add, remove, and disposed protection', () {
      final graft = LifecycleGraft();
      int maskCalls = 0;
      GraftMask lastMask = GraftMask.empty;

      void listener(GraftMask mask) {
        maskCalls++;
        lastMask = mask;
      }

      graft.addMaskListener(listener);

      graft.setText('first');
      expect(maskCalls, 1);
      expect(lastMask.isBitSet(0), isTrue);

      // Remove listener
      graft.removeMaskListener(listener);
      graft.setText('second');
      expect(maskCalls, 1, reason: 'Removed listener must not be called');

      // Dispose graft
      graft.dispose();
      expect(graft.isDisposed, isTrue);

      // Subsequent actions must be no-ops without throwing
      graft.addMaskListener(listener);
      graft.notifyMask(GraftMask.fromIndex(0));
      expect(maskCalls, 1);
    });

    testWidgets(
        'GraftMultiChildDiffEngine unmount disposes all SlotMetadata notifiers and unregisters listeners',
        (tester) async {
      final graft = LifecycleGraft();

      Widget app(bool showSlots) {
        return MaterialApp(
          home: Scaffold(
            body: showSlots
                ? graft.slots(
                    layout: Column(children: slots),
                    slots: [
                      (s) => Text('Text: ${s.text}'),
                      const Text('Static Header'),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        );
      }

      // Mount slots
      await tester.pumpWidget(app(true));
      expect(find.text('Text: initial'), findsOneWidget);

      final engineState =
          tester.state(find.byType(GraftMultiChildDiffEngine<LifecycleState>))
              as dynamic;
      final slotTable = engineState.slotTable as List<SlotMetadata>;
      expect(slotTable.length, 2);

      final notifier0 = slotTable[0].notifier;
      final notifier1 = slotTable[1].notifier;

      // ignore: invalid_use_of_protected_member
      expect(notifier0.hasListeners, isTrue);
      // ignore: invalid_use_of_protected_member
      expect(notifier1.hasListeners, isTrue);

      // Unmount the slots widget completely
      await tester.pumpWidget(app(false));
      expect(
          find.byType(GraftMultiChildDiffEngine<LifecycleState>), findsNothing);

      // Verify slot notifiers are disposed and unlinked
      expect(() => notifier0.addListener(() {}), throwsFlutterError);
      expect(() => notifier1.addListener(() {}), throwsFlutterError);

      // Verify mutating state after unmount causes no errors
      expect(() => graft.setText('after unmount'), returnsNormally);

      graft.dispose();
    });
  });
}
