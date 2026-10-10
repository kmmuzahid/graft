import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class MultiSlotState extends GraftState {
  String title;
  int counter;
  double unobservedField;

  MultiSlotState({
    this.title = 'Hello',
    this.counter = 0,
    this.unobservedField = 0.0,
  });

  @override
  GraftProps get props => propsOf(title, counter, unobservedField);
}

class MultiSlotController extends Graft<MultiSlotState> {
  MultiSlotController() : super(MultiSlotState());

  void increment() => state..counter += 1..update();
  void setTitle(String t) => state..title = t..update();
  void setUnobserved(double v) => state..unobservedField = v..update();
}

class TrackedTextWidget extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback? onBuild;

  const TrackedTextWidget(this.text, {super.key, this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedTextWidget && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    return Text(text);
  }
}

void main() {
  group('Adaptive Slot Pre-Flight Short-Circuit Tests', () {
    testWidgets('childrenBuilder is completely bypassed when dirtyMask is covered by all slots ignoredMask',
        (WidgetTester tester) async {
      final controller = MultiSlotController();
      int titleSlotCalls = 0;
      int counterSlotCalls = 0;
      int titleBuildCount = 0;
      int counterBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: controller.slots(
              layout: (children) => Column(children: children),
              slots: [
                (s) {
                  titleSlotCalls++;
                  return TrackedTextWidget(s.title, onBuild: () => titleBuildCount++);
                },
                (s) {
                  counterSlotCalls++;
                  return TrackedTextWidget('Count: ${s.counter}', onBuild: () => counterBuildCount++);
                },
              ],
            ),
          ),
        ),
      );

      expect(titleSlotCalls, 1);
      expect(counterSlotCalls, 1);
      expect(titleBuildCount, 1);
      expect(counterBuildCount, 1);

      // 1. Prime the slots: Update counter (bit 1)
      // Slot 0 (title) learns that it ignores bit 1
      controller.increment();
      await tester.pump();

      expect(titleBuildCount, 1); // 0 rebuilds for title!
      expect(counterBuildCount, 2);

      // 2. Prime the slots: Update title (bit 0)
      // Slot 1 (counter) learns that it ignores bit 0
      controller.setTitle('New Title');
      await tester.pump();

      expect(titleBuildCount, 2);
      expect(counterBuildCount, 2); // 0 rebuilds for counter!

      // 3. Now mutate unobservedField (bit 2)
      // On first pass with bit 2, both slots learn that they ignore bit 2
      controller.setUnobserved(42.0);
      await tester.pump();

      expect(titleBuildCount, 2); // 0 rebuilds
      expect(counterBuildCount, 2); // 0 rebuilds

      // 4. NOW: Mutate unobservedField AGAIN!
      // All slots have learned that they ignore bit 2.
      // Therefore, layout reconciliation is bypassed completely in 1 CPU instruction!
      final titleCallsAfterFirst = titleSlotCalls;
      final counterCallsAfterFirst = counterSlotCalls;
      controller.setUnobserved(99.0);
      await tester.pump();

      expect(titleSlotCalls, titleCallsAfterFirst,
          reason: 'Slot closures were bypassed completely because all slots ignore field index 2');
      expect(counterSlotCalls, counterCallsAfterFirst,
          reason: 'Slot closures were bypassed completely because all slots ignore field index 2');
      expect(titleBuildCount, 2);
      expect(counterBuildCount, 2);

      controller.dispose();
    });

    testWidgets('Reassemble clears ignoredMask and re-evaluates slots safely',
        (WidgetTester tester) async {
      final controller = MultiSlotController();
      int counterBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: controller.slots(
              layout: (children) => Column(children: children),
              slots: [
                (s) => TrackedTextWidget('Count: ${s.counter}', onBuild: () => counterBuildCount++),
              ],
            ),
          ),
        ),
      );

      expect(counterBuildCount, 1);

      controller.increment();
      await tester.pump();
      expect(counterBuildCount, 2);

      // Trigger reassemble (hot-reload simulation)
      tester.binding.reassembleApplication();
      await tester.pump();
      expect(counterBuildCount, 3, reason: 'Reassemble triggers an allDirty rebuild pass');

      // Subsequent state updates continue to rebuild surgically
      controller.increment();
      await tester.pump();
      expect(counterBuildCount, 4, reason: 'Next update increments rebuild count to 4');

      controller.dispose();
    });
  });
}
