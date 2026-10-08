import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'package:provider/provider.dart' as provider_pkg;
import 'benchmark_models.dart';
import 'tracking_widget.dart';

// =============================================================================
// CONTROLLERS FOR SCENARIO B
// =============================================================================
class GraftBState extends GraftState {
  int count = 0;
  @override
  List<Object?> get props => [count];
}

class GraftBController extends Graft<GraftBState> {
  GraftBController() : super(GraftBState());
  void increment() => state..count += 1..update();
}

class BlocBCubit extends bloc_pkg.Cubit<int> {
  BlocBCubit() : super(0);
  void increment() => emit(state + 1);
}

class RiverpodBNotifier extends riverpod_pkg.Notifier<int> {
  @override
  int build() => 0;
  void increment() => state = state + 1;
}

final riverpodBNotifierProvider =
    riverpod_pkg.NotifierProvider<RiverpodBNotifier, int>(
  RiverpodBNotifier.new,
);

class RiverpodBStateNotifier extends riverpod_pkg.StateNotifier<int> {
  RiverpodBStateNotifier() : super(0);
  void increment() => state = state + 1;
}

final riverpodBStateNotifierProvider =
    riverpod_pkg.StateNotifierProvider<RiverpodBStateNotifier, int>(
  (ref) => RiverpodBStateNotifier(),
);

class GetXBController extends getx.GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}

class ProviderBModel extends ChangeNotifier {
  int count = 0;
  void increment() {
    count++;
    notifyListeners();
  }
}

// =============================================================================
// SCENARIO B RUNNER
// =============================================================================
class ScenarioBRebuildIsolationRunner {
  static const int totalFrames = 120;
  static const int warmUpRuns = 3;
  static const int measuredRuns = 15;

  static Future<List<BenchmarkStats>> runAll(WidgetTester tester) async {
    final statsList = <BenchmarkStats>[];

    // B1: 10-Slot Column (1 Dynamic + 9 Static)
    statsList.addAll(await runColumnRebuild(
      tester: tester,
      slotCount: 10,
      scenarioName: 'B1_10_slot_column_120_frames',
    ));

    // B2: 50-Slot Column (1 Dynamic + 49 Static)
    statsList.addAll(await runColumnRebuild(
      tester: tester,
      slotCount: 50,
      scenarioName: 'B2_50_slot_column_120_frames',
    ));

    return statsList;
  }

  static Future<List<BenchmarkStats>> runColumnRebuild({
    required WidgetTester tester,
    required int slotCount,
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];
    final staticCount = slotCount - 1;
    tester.view.physicalSize = const Size(1200, 3000);

    // -------------------------------------------------------------------------
    // 1. GRAFT (graft.slots engine)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = GraftBController();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ctrl.slots(
                layout: (children) => Column(children: children),
                children: (s) => [
                  TrackingWidget(
                    label: 'Dynamic: ${s.count}',
                    onBuild: () => counter.dynamicBuilds++,
                  ),
                  for (int i = 0; i < staticCount; i++)
                    TrackingWidget(
                      label: 'Static $i',
                      onBuild: () => counter.staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          ctrl.increment();
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft (slots)',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: '0 static rebuilds via hardware bitmask diff',
      ));
    }

    // -------------------------------------------------------------------------
    // 2. Riverpod (Notifier - Codegen style)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          riverpod_pkg.UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    riverpod_pkg.Consumer(
                      builder: (context, ref, _) {
                        final count = ref.watch(riverpodBNotifierProvider);
                        return TrackingWidget(
                          label: 'Dynamic: $count',
                          onBuild: () => counter.dynamicBuilds++,
                        );
                      },
                    ),
                    for (int i = 0; i < staticCount; i++)
                      TrackingWidget(
                        label: 'Static $i',
                        onBuild: () => counter.staticBuilds[i]++,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          container.read(riverpodBNotifierProvider.notifier).increment();
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
        container.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'Consumer scoped rebuild',
      ));
    }

    // -------------------------------------------------------------------------
    // 3. Riverpod (StateNotifier)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          riverpod_pkg.UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    riverpod_pkg.Consumer(
                      builder: (context, ref, _) {
                        final count = ref.watch(riverpodBStateNotifierProvider);
                        return TrackingWidget(
                          label: 'Dynamic: $count',
                          onBuild: () => counter.dynamicBuilds++,
                        );
                      },
                    ),
                    for (int i = 0; i < staticCount; i++)
                      TrackingWidget(
                        label: 'Static $i',
                        onBuild: () => counter.staticBuilds[i]++,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          container.read(riverpodBStateNotifierProvider.notifier).increment();
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
        container.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (StateNotifier)',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'Consumer scoped rebuild',
      ));
    }

    // -------------------------------------------------------------------------
    // 4. BLoC (BlocSelector)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final cubit = BlocBCubit();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  bloc_pkg.BlocSelector<BlocBCubit, int, int>(
                    bloc: cubit,
                    selector: (state) => state,
                    builder: (context, count) {
                      return TrackingWidget(
                        label: 'Dynamic: $count',
                        onBuild: () => counter.dynamicBuilds++,
                      );
                    },
                  ),
                  for (int i = 0; i < staticCount; i++)
                    TrackingWidget(
                      label: 'Static $i',
                      onBuild: () => counter.staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          cubit.increment();
          await tester.pump(Duration.zero);
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
        cubit.close();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'BlocSelector fine-grained boundary',
      ));
    }

    // -------------------------------------------------------------------------
    // 5. Signals (Watch)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final countSignal = signals_pkg.signal(0);
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  signals_pkg.Watch((context) {
                    return TrackingWidget(
                      label: 'Dynamic: ${countSignal.value}',
                      onBuild: () => counter.dynamicBuilds++,
                    );
                  }),
                  for (int i = 0; i < staticCount; i++)
                    TrackingWidget(
                      label: 'Static $i',
                      onBuild: () => counter.staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          countSignal.value++;
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'Watch reactive element rebuild',
      ));
    }

    // -------------------------------------------------------------------------
    // 6. GetX (Obx)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = GetXBController();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  getx.Obx(() {
                    return TrackingWidget(
                      label: 'Dynamic: ${ctrl.count.value}',
                      onBuild: () => counter.dynamicBuilds++,
                    );
                  }),
                  for (int i = 0; i < staticCount; i++)
                    TrackingWidget(
                      label: 'Static $i',
                      onBuild: () => counter.staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          ctrl.increment();
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'Obx reactive widget rebuild',
      ));
    }

    // -------------------------------------------------------------------------
    // 7. Provider (Selector)
    // -------------------------------------------------------------------------
    {
      final samples = <double>[];
      int lastDynamicBuilds = 0;
      int lastStaticBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final model = ProviderBModel();
        final counter = RebuildCounter(staticCount);

        await tester.pumpWidget(
          provider_pkg.ChangeNotifierProvider<ProviderBModel>.value(
            value: model,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    provider_pkg.Selector<ProviderBModel, int>(
                      selector: (_, m) => m.count,
                      builder: (context, count, _) {
                        return TrackingWidget(
                          label: 'Dynamic: $count',
                          onBuild: () => counter.dynamicBuilds++,
                        );
                      },
                    ),
                    for (int i = 0; i < staticCount; i++)
                      TrackingWidget(
                        label: 'Static $i',
                        onBuild: () => counter.staticBuilds[i]++,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        counter.reset();
        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          model.increment();
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastDynamicBuilds = counter.dynamicBuilds;
          lastStaticBuilds = counter.totalStaticBuilds;
        }
        model.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        targetRebuilds: lastDynamicBuilds,
        staticRebuilds: lastStaticBuilds,
        allocatedObjects: 0,
        notes: 'Selector fine-grained filter',
      ));
    }

    tester.view.resetPhysicalSize();
    return results;
  }
}
