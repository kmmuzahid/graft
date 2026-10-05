import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class BenchmarkState extends GraftState {
  int counter;
  BenchmarkState(this.counter);

  @override
  List<Object?> get props => [counter];
}

class BenchmarkGraft extends Graft<BenchmarkState> {
  BenchmarkGraft() : super(BenchmarkState(0));

  void increment() {
    state
      ..counter += 1
      ..update();
  }
}

class TrackingObserver extends GraftObserver {
  int totalSlotRebuilds = 0;
  final Map<int, int> slotRebuildCounts = {};

  @override
  void onSlotRebuild(dynamic graft, int slotIndex, Widget widget) {
    totalSlotRebuilds++;
    slotRebuildCounts[slotIndex] = (slotRebuildCounts[slotIndex] ?? 0) + 1;
  }
}

class BenchmarkTrackingWidget extends StatelessWidget
    implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const BenchmarkTrackingWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! BenchmarkTrackingWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(label);
  }
}

void main() {
  testWidgets('Benchmark: graft.slots 10-slot Column 60-frame rebuild benchmark',
      (WidgetTester tester) async {
    final observer = TrackingObserver();
    Graft.observer = observer;

    final graft = BenchmarkGraft();
    int changingSlotBuildCount = 0;
    final List<int> staticSlotBuildCounts = List.filled(9, 0);

    // Initial mount with 10 slots
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            layout: (children) => Column(children: children),
            children: (s) => [
              BenchmarkTrackingWidget(
                label: 'Changing: ${s.counter}',
                onBuild: () => changingSlotBuildCount++,
              ),
              for (int i = 0; i < 9; i++)
                BenchmarkTrackingWidget(
                  label: 'Static $i',
                  onBuild: () => staticSlotBuildCounts[i]++,
                ),
            ],
          ),
        ),
      ),
    );

    // Initial assertions: each slot builds once on mount
    expect(changingSlotBuildCount, 1);
    for (int i = 0; i < 9; i++) {
      expect(staticSlotBuildCounts[i], 1,
          reason: 'Slot $i should only build once on initial mount');
    }

    // Reset build counts to isolate the 60 mutation frames
    changingSlotBuildCount = 0;
    for (int i = 0; i < 9; i++) {
      staticSlotBuildCounts[i] = 0;
    }
    observer.totalSlotRebuilds = 0;
    observer.slotRebuildCounts.clear();

    const int totalFrames = 60;
    final stopwatch = Stopwatch()..start();

    // Trigger 60 state mutations
    for (int frame = 0; frame < totalFrames; frame++) {
      graft.increment();
      await tester.pump();
    }

    stopwatch.stop();

    // Verify Graft Granular Rebuilds:
    // Slot 0 (changing): Exactly 60 rebuilds
    expect(changingSlotBuildCount, totalFrames);

    // Slots 1-9 (unchanged): Exactly 0 rebuilds
    for (int i = 0; i < 9; i++) {
      expect(staticSlotBuildCounts[i], 0,
          reason: 'Static slot $i must have 0 rebuilds across all 60 frames');
    }

    final int graftTotalRebuilds = changingSlotBuildCount +
        staticSlotBuildCounts.fold(0, (sum, count) => sum + count);

    // Compare with Traditional Rebuild Model:
    // In standard Flutter setState/BlocBuilder, all 10 children rebuild every frame
    const int traditionalTotalRebuilds = 10 * totalFrames; // 600 rebuilds
    final double reductionPercentage =
        ((traditionalTotalRebuilds - graftTotalRebuilds) /
                traditionalTotalRebuilds) *
            100;

    // Verify Observer Telemetry captured all slot rebuilds
    expect(observer.totalSlotRebuilds, totalFrames);
    expect(observer.slotRebuildCounts[0], totalFrames);

    // Print calibrated benchmark results
    // ignore: avoid_print
    print('''
================================================================================
  GRAFT REBUILD BENCHMARK (10-Slot Column, 60 State Updates)
================================================================================
  Traditional / Monolithic Rebuild Model:
    - Children in Column: 10
    - Frames / Updates:   60
    - Total Child Builds: 600 rebuilds (10 children * 60 updates)

  Graft Fine-Grained slot engine:
    - Slot 0 (Changing):  $changingSlotBuildCount rebuilds (1 per frame)
    - Slots 1-9 (Static): 0 rebuilds across all 60 frames
    - Total Child Builds: $graftTotalRebuilds rebuilds
    - Total Elapsed Time: ${stopwatch.elapsedMicroseconds} µs
    - Rebuild Reduction:  ${reductionPercentage.toStringAsFixed(1)}% LESS WORK!
================================================================================
''');

    expect(graftTotalRebuilds, 60);
    expect(reductionPercentage, 90.0);

    Graft.observer = null;
    graft.dispose();
  });
}
