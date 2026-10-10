import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// Tracking widget that counts build invocations
class BuildCounterWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const BuildCounterWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! BuildCounterWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(label);
  }
}

// -----------------------------------------------------------------------------
// 1. GRAFT CONTROLLER
// -----------------------------------------------------------------------------
class GraftUIState extends GraftState {
  int count = 0;
  @override
  GraftProps get props => propsOf(count);
}

class GraftUIController extends Graft<GraftUIState> {
  GraftUIController() : super(GraftUIState());
  void increment() => state..count += 1..update();
}

// -----------------------------------------------------------------------------
// 2. BLOC CUBIT
// -----------------------------------------------------------------------------
class BlocUICubit extends Cubit<int> {
  BlocUICubit() : super(0);
  void increment() => emit(state + 1);
}

// -----------------------------------------------------------------------------
// 3. RIVERPOD NOTIFIER
// -----------------------------------------------------------------------------
class RiverpodUINotifier extends StateNotifier<int> {
  RiverpodUINotifier() : super(0);
  void increment() => state = state + 1;
}

final riverpodUIProvider =
    StateNotifierProvider<RiverpodUINotifier, int>((ref) => RiverpodUINotifier());

// -----------------------------------------------------------------------------
// 4. GETX CONTROLLER
// -----------------------------------------------------------------------------
class GetXUIController extends getx.GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}

void main() {
  const int totalFrames = 60;
  const int staticChildCount = 9;

  testWidgets('Benchmark: 60-Frame Widget Tree Rebuild & Pump Pipeline (Graft vs BLoC vs Riverpod vs Signals vs GetX vs Vanilla)',
      (WidgetTester tester) async {
    final benchmarkResults = <Map<String, dynamic>>[];

    // =========================================================================
    // 0. VANILLA FLUTTER (setState / Monolithic Rebuild baseline)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      int counter = 0;
      late StateSetter stateSetter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                stateSetter = setState;
                return Column(
                  children: [
                    BuildCounterWidget(
                      label: 'Dynamic: $counter',
                      onBuild: () => dynamicBuilds++,
                    ),
                    for (int i = 0; i < staticChildCount; i++)
                      BuildCounterWidget(
                        label: 'Static $i',
                        onBuild: () => staticBuilds[i]++,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        stateSetter(() => counter++);
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'Vanilla setState',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
    }

    // =========================================================================
    // 1. GRAFT (graft.slots / graft.column)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final graft = GraftUIController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: Column(children: slots),
              slots: [
                (s) => BuildCounterWidget(
                  label: 'Dynamic: ${s.count}',
                  onBuild: () => dynamicBuilds++,
                ),
                for (int i = 0; i < staticChildCount; i++)
                  BuildCounterWidget(
                    label: 'Static $i',
                    onBuild: () => staticBuilds[i]++,
                  ),
              ],
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        graft.increment();
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'Graft (slots)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
      graft.dispose();
    }

    // =========================================================================
    // 1b. GRAFT (Single slot: graft((s) => ...))
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final graft = GraftUIController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                graft((s) => BuildCounterWidget(
                  label: 'Dynamic: ${s.count}',
                  onBuild: () => dynamicBuilds++,
                )),
                for (int i = 0; i < staticChildCount; i++)
                  BuildCounterWidget(
                    label: 'Static $i',
                    onBuild: () => staticBuilds[i]++,
                  ),
              ],
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        graft.increment();
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'Graft (single slot)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
      graft.dispose();
    }

    // =========================================================================
    // 2. BLOC (BlocSelector on dynamic child)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final cubit = BlocUICubit();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Column(
                children: [
                  BlocSelector<BlocUICubit, int, int>(
                    selector: (state) => state,
                    builder: (context, count) {
                      return BuildCounterWidget(
                        label: 'Dynamic: $count',
                        onBuild: () => dynamicBuilds++,
                      );
                    },
                  ),
                  for (int i = 0; i < staticChildCount; i++)
                    BuildCounterWidget(
                      label: 'Static $i',
                      onBuild: () => staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        cubit.increment();
        await tester.pump(Duration.zero);
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'BLoC (Selector)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
      cubit.close();
    }

    // =========================================================================
    // 3. RIVERPOD (Consumer on dynamic child)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(riverpodUIProvider);
                      return BuildCounterWidget(
                        label: 'Dynamic: $count',
                        onBuild: () => dynamicBuilds++,
                      );
                    },
                  ),
                  for (int i = 0; i < staticChildCount; i++)
                    BuildCounterWidget(
                      label: 'Static $i',
                      onBuild: () => staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        container.read(riverpodUIProvider.notifier).increment();
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'Riverpod (Consumer)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
      container.dispose();
    }

    // =========================================================================
    // 4. SIGNALS (Watch on dynamic child)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final countSignal = signal(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Watch((context) {
                  return BuildCounterWidget(
                    label: 'Dynamic: ${countSignal.value}',
                    onBuild: () => dynamicBuilds++,
                  );
                }),
                for (int i = 0; i < staticChildCount; i++)
                  BuildCounterWidget(
                    label: 'Static $i',
                    onBuild: () => staticBuilds[i]++,
                  ),
              ],
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        countSignal.value++;
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'Signals (Watch)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
    }

    // =========================================================================
    // 5. GETX (Obx on dynamic child)
    // =========================================================================
    {
      int dynamicBuilds = 0;
      final staticBuilds = List.filled(staticChildCount, 0);
      final getxCtrl = GetXUIController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                getx.Obx(() {
                  return BuildCounterWidget(
                    label: 'Dynamic: ${getxCtrl.count.value}',
                    onBuild: () => dynamicBuilds++,
                  );
                }),
                for (int i = 0; i < staticChildCount; i++)
                  BuildCounterWidget(
                    label: 'Static $i',
                    onBuild: () => staticBuilds[i]++,
                  ),
              ],
            ),
          ),
        ),
      );

      dynamicBuilds = 0;
      for (int i = 0; i < staticChildCount; i++) staticBuilds[i] = 0;

      final sw = Stopwatch()..start();
      for (int f = 0; f < totalFrames; f++) {
        getxCtrl.increment();
        await tester.pump();
      }
      sw.stop();

      final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
      benchmarkResults.add({
        'name': 'GetX (Obx)',
        'timeUs': sw.elapsedMicroseconds,
        'dynamic': dynamicBuilds,
        'static': totalStatic,
        'totalBuilds': dynamicBuilds + totalStatic,
      });
    }

    // =========================================================================
    // PRINT COMPREHENSIVE COMPARISON TABLE
    // =========================================================================
    benchmarkResults.sort((a, b) => (a['timeUs'] as int).compareTo(b['timeUs'] as int));

    // ignore: avoid_print
    print('''
================================================================================
  REAL FLUTTER BENCHMARK: 60-FRAME WIDGET TREE REBUILD PIPELINE
  (1 Dynamic Counter Child + 9 Static Sibling Children in Column)
================================================================================
  Framework            Total Time (ms)  Dynamic Builds  Static Builds  Wasted Builds
--------------------------------------------------------------------------------''');

    for (final r in benchmarkResults) {
      final name = (r['name'] as String).padRight(20);
      final timeMs = ((r['timeUs'] as int) / 1000).toStringAsFixed(2).padLeft(11);
      final dynamicB = '${r['dynamic']}'.padLeft(14);
      final staticB = '${r['static']}'.padLeft(14);
      final wasted = r['static'] == 0 ? '0 (0.0%)'.padLeft(14) : '${r['static']} (FAILED)'.padLeft(14);
      // ignore: avoid_print
      print('  $name $timeMs ms $dynamicB $staticB $wasted');
    }

    // ignore: avoid_print
    print('================================================================================');

    // All reactive frameworks must have 0 static rebuilds
    for (final r in benchmarkResults) {
      if (r['name'] != 'Vanilla setState') {
        expect(r['static'], 0,
            reason: '${r['name']} must isolate static siblings with 0 rebuilds');
        expect(r['dynamic'], totalFrames);
      }
    }
  });
}
