import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'package:provider/provider.dart' as provider_pkg;
import 'benchmark_isolation.dart';
import 'benchmark_models.dart';
import 'tracking_widget.dart';

// =============================================================================
// DOMAIN MODELS & CONTROLLERS FOR SCENARIO B
// =============================================================================
class GraftBState extends GraftState {
  int count = 0;
  @override
  GraftProps get props => propsOf(count);
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
// CANDIDATE RUNNER CONTRACT (HERMETIC ISOLATION)
// =============================================================================
abstract class _ScenarioBCandidate {
  String get name;
  String get notes;
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter);
  void triggerFrame();
  void dispose();
}

class _GraftLeafCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Graft (leaf slot)';
  @override
  String get notes => 'Depth-N parent rebuild insulation';

  GraftBController? _ctrl;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _ctrl = GraftBController();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              _ctrl!((s) => TrackingWidget(
                    label: 'Dynamic: ${s.count}',
                    onBuild: () => counter.dynamicBuilds++,
                  )),
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
  }

  @override
  void triggerFrame() => _ctrl!.increment();

  @override
  void dispose() => _ctrl?.dispose();
}

class _GraftSlotsCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Graft (slots)';
  @override
  String get notes => 'Direct multi-slot reconciliation';

  GraftBController? _ctrl;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _ctrl = GraftBController();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _ctrl!.slots(
            layout: Column(children: slots),
            slots: (s) => [
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
  }

  @override
  void triggerFrame() => _ctrl!.increment();

  @override
  void dispose() => _ctrl?.dispose();
}

class _RiverpodNotifierCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Riverpod (Notifier)';
  @override
  String get notes => 'Consumer scoped rebuild';

  riverpod_pkg.ProviderContainer? _container;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _container = riverpod_pkg.ProviderContainer();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      riverpod_pkg.UncontrolledProviderScope(
        container: _container!,
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
  }

  @override
  void triggerFrame() =>
      _container!.read(riverpodBNotifierProvider.notifier).increment();

  @override
  void dispose() => _container?.dispose();
}

class _RiverpodStateNotifierCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Riverpod (StateNotifier)';
  @override
  String get notes => 'Consumer scoped rebuild';

  riverpod_pkg.ProviderContainer? _container;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _container = riverpod_pkg.ProviderContainer();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      riverpod_pkg.UncontrolledProviderScope(
        container: _container!,
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
  }

  @override
  void triggerFrame() =>
      _container!.read(riverpodBStateNotifierProvider.notifier).increment();

  @override
  void dispose() => _container?.dispose();
}

class _BlocCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'BLoC (Cubit)';
  @override
  String get notes => 'BlocSelector fine-grained rebuild';

  BlocBCubit? _cubit;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _cubit = BlocBCubit();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              bloc_pkg.BlocSelector<BlocBCubit, int, int>(
                bloc: _cubit,
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
  }

  @override
  void triggerFrame() => _cubit!.increment();

  @override
  void dispose() => _cubit?.close();
}

class _SignalsCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Signals';
  @override
  String get notes => 'Watch reactive element rebuild';

  signals_pkg.Signal<int>? _countSignal;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _countSignal = signals_pkg.signal(0);
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              signals_pkg.Watch(key: ValueKey(_countSignal), (context) {
                final val = _countSignal!.watch(context);
                return TrackingWidget(
                  label: 'Dynamic: $val',
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
  }

  @override
  void triggerFrame() => _countSignal!.value++;

  @override
  void dispose() => _countSignal?.dispose();
}

class _GetXCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'GetX';
  @override
  String get notes => 'Obx micro-rebuild containment';

  GetXBController? _ctrl;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _ctrl = GetXBController();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              getx.Obx(() {
                return TrackingWidget(
                  label: 'Dynamic: ${_ctrl!.count.value}',
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
  }

  @override
  void triggerFrame() => _ctrl!.increment();

  @override
  void dispose() => _ctrl?.onClose();
}

class _ProviderCandidate implements _ScenarioBCandidate {
  @override
  String get name => 'Provider';
  @override
  String get notes => 'Selector rebuild containment';

  ProviderBModel? _model;

  @override
  Future<void> mount(
      WidgetTester tester, int slotCount, RebuildCounter counter) async {
    _model = ProviderBModel();
    final staticCount = slotCount - 1;
    await tester.pumpWidget(
      provider_pkg.ChangeNotifierProvider<ProviderBModel>.value(
        value: _model!,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                provider_pkg.Selector<ProviderBModel, int>(
                  selector: (_, m) => m.count,
                  builder: (_, count, __) {
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
  }

  @override
  void triggerFrame() => _model!.increment();

  @override
  void dispose() => _model?.dispose();
}

// =============================================================================
// SCENARIO B RUNNER (INTERLEAVED ROUND-ROBIN WITH HERMETIC ISOLATION)
// =============================================================================
class ScenarioBRebuildIsolationRunner {
  static const int totalFrames = 120;
  static const int warmUpRuns = 10;
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

    final candidates = <_ScenarioBCandidate>[
      _GraftLeafCandidate(),
      _GraftSlotsCandidate(),
      _RiverpodNotifierCandidate(),
      _RiverpodStateNotifierCandidate(),
      _BlocCandidate(),
      _SignalsCandidate(),
      _GetXCandidate(),
      _ProviderCandidate(),
    ];

    final samplesMap = {for (final c in candidates) c.name: <double>[]};
    final lastDynamicMap = {for (final c in candidates) c.name: 0};
    final lastStaticMap = {for (final c in candidates) c.name: 0};

    // 1. Interleaved Warm-Up Runs
    for (int w = 0; w < warmUpRuns; w++) {
      for (final candidate in candidates) {
        await BenchmarkIsolation.flushPipeline(tester);
        final counter = RebuildCounter(staticCount);
        await candidate.mount(tester, slotCount, counter);
        for (int f = 0; f < totalFrames; f++) {
          candidate.triggerFrame();
          await tester.pump(Duration.zero);
        }
        candidate.dispose();
      }
    }

    // 2. Interleaved Measured Runs (Order-Agnostic Sampling)
    for (int m = 0; m < measuredRuns; m++) {
      for (final candidate in candidates) {
        await BenchmarkIsolation.flushPipeline(tester);
        final counter = RebuildCounter(staticCount);
        await candidate.mount(tester, slotCount, counter);
        counter.reset();

        final sw = Stopwatch()..start();
        for (int f = 0; f < totalFrames; f++) {
          candidate.triggerFrame();
          await tester.pump(Duration.zero);
        }
        sw.stop();

        samplesMap[candidate.name]!.add(sw.elapsedMicroseconds / 1000.0);
        lastDynamicMap[candidate.name] = counter.dynamicBuilds;
        lastStaticMap[candidate.name] = counter.totalStaticBuilds;
        candidate.dispose();
      }
    }

    await BenchmarkIsolation.flushPipeline(tester);

    for (final candidate in candidates) {
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: candidate.name,
        samplesMs: samplesMap[candidate.name]!,
        targetRebuilds: lastDynamicMap[candidate.name]!,
        staticRebuilds: lastStaticMap[candidate.name]!,
        isPassed: lastDynamicMap[candidate.name]! == totalFrames &&
            lastStaticMap[candidate.name]! == 0,
        allocatedObjects: 0,
        notes: candidate.notes,
      ));
    }

    return results;
  }
}
