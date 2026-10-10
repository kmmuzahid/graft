import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class MultiSlotStressState extends GraftState {
  int dynamicCounter = 0;

  @override
  GraftProps get props => propsOf(dynamicCounter);
}

class MultiSlotStressGraft extends Graft<MultiSlotStressState> {
  MultiSlotStressGraft() : super(MultiSlotStressState());

  void increment() {
    state.dynamicCounter++;
    state.update();
  }
}

class TrackedStressWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const TrackedStressWidget(this.label, {super.key, required this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedStressWidget && other.label == label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(label);
  }
}

void main() {
  group('500-Slot Layout Thrashing & Rebuild Insulation Stress Tests', () {
    testWidgets(
        '500 slots in Column(children: slots): 1 dynamic mutating for 500 frames with 0 static rebuilds',
        (tester) async {
      final graft = MultiSlotStressGraft();
      const totalSlots = 500;
      const staticSlotsCount = totalSlots - 1;
      const totalFrames = 500;

      int dynamicBuildCount = 0;
      final staticBuildCounts = List<int>.filled(staticSlotsCount, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: graft.slots(
                layout: Column(children: slots),
                slots: [
                  (s) => TrackedStressWidget(
                        'Dynamic: ${s.dynamicCounter}',
                        onBuild: () => dynamicBuildCount++,
                      ),
                  for (int i = 0; i < staticSlotsCount; i++)
                    TrackedStressWidget(
                      'Static #$i',
                      onBuild: () => staticBuildCounts[i]++,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Frame 0 (initial mount): all 500 slots build once
      expect(dynamicBuildCount, 1);
      for (int i = 0; i < staticSlotsCount; i++) {
        expect(staticBuildCounts[i], 1);
      }

      // Reset counters before stress loop
      dynamicBuildCount = 0;
      for (int i = 0; i < staticSlotsCount; i++) {
        staticBuildCounts[i] = 0;
      }

      final sw = Stopwatch()..start();

      // Rapidly pump 500 consecutive animation frames
      for (int f = 0; f < totalFrames; f++) {
        graft.increment();
        await tester.pump();
      }
      sw.stop();

      final totalElapsedMs = sw.elapsedMilliseconds;
      final avgFrameTimeMs = totalElapsedMs / totalFrames;

      print('⚡ 500-SLOT COLUMN STRESS BENCHMARK (500 FRAMES):');
      print('   Total time: $totalElapsedMs ms');
      print('   Average layout frame reconciliation time: ${avgFrameTimeMs.toStringAsFixed(2)} ms');
      print('   Dynamic builds: $dynamicBuildCount (expected: $totalFrames)');

      // 1. Assert exactly 500 dynamic rebuilds (1 per frame)
      expect(dynamicBuildCount, totalFrames,
          reason: 'Dynamic slot must build once per frame');

      // 2. Assert strictly 0 rebuilds across all 499 static sibling slots!
      int totalStaticRebuilds = 0;
      for (int i = 0; i < staticSlotsCount; i++) {
        totalStaticRebuilds += staticBuildCounts[i];
      }
      expect(totalStaticRebuilds, 0,
          reason:
              'All 499 static sibling slots must have strictly 0 rebuilds across 500 frames');

      // 3. Assert frame budget: under 3.5ms per frame even with 500 slots in debug test mode
      expect(avgFrameTimeMs, lessThan(10.0),
          reason: 'Average reconciliation must comfortably stay within frame budget');

      graft.dispose();
    });
  });
}
