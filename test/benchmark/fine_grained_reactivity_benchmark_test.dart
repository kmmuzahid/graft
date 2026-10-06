import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// =============================================================================
// BENCHMARK: FINE-GRAINED REACTIVITY (50 INDEPENDENT FIELDS & 50 CONSUMERS)
//
// In fine-grained reactivity (SolidJS, Preact Signals, S.js):
// When 1 field out of 50 changes:
// - A true fine-grained system executes ONLY the 1 consumer that cares (1 eval).
// - A coarse / selector-based system must run ALL 50 selector closures to check
//   if their slice changed (50 evals per mutation = 250,000 evals for 5,000 mutations!).
//
// This benchmark measures:
// Part A: Pure Dart Fine-Grained Selector / Observer Execution (5,000 targeted mutations)
// Part B: Flutter Widget Tree Fine-Grained Isolation (50 widgets in Column, 60 frames)
// =============================================================================

// -----------------------------------------------------------------------------
// 1. GRAFT IMPLEMENTATION (50 fields, learned bitmask per slot)
// -----------------------------------------------------------------------------
class Graft50State extends GraftState {
  final List<int> values = List<int>.filled(50, 0);

  int get(int i) => values[i];
  void set(int i, int val) => values[i] = val;

  @override
  List<Object?> get props => List.unmodifiable(values);
}

class Graft50Controller extends Graft<Graft50State> {
  Graft50Controller() : super(Graft50State());

  void updateField(int index, int value) {
    state
      ..set(index, value)
      ..update();
  }
}

// -----------------------------------------------------------------------------
// 2. SIGNALS IMPLEMENTATION (50 individual signals)
// -----------------------------------------------------------------------------
class Signals50 {
  final List<Signal<int>> signals = List.generate(50, (_) => signal(0));

  void updateField(int index, int value) {
    signals[index].value = value;
  }
}

// -----------------------------------------------------------------------------
// 3. BLOC IMPLEMENTATION (Immutable state with 50 fields)
// -----------------------------------------------------------------------------
class Bloc50State {
  final List<int> values;
  Bloc50State(this.values);

  Bloc50State copyWith(int index, int value) {
    final next = List<int>.from(values);
    next[index] = value;
    return Bloc50State(next);
  }
}

class Bloc50Cubit extends Cubit<Bloc50State> {
  Bloc50Cubit() : super(Bloc50State(List<int>.filled(50, 0)));

  void updateField(int index, int value) {
    emit(state.copyWith(index, value));
  }
}

// -----------------------------------------------------------------------------
// 4. RIVERPOD IMPLEMENTATION
// -----------------------------------------------------------------------------
class Riverpod50Notifier extends StateNotifier<List<int>> {
  Riverpod50Notifier() : super(List<int>.filled(50, 0));

  void updateField(int index, int value) {
    final next = List<int>.from(state);
    next[index] = value;
    state = next;
  }
}

final riverpod50Provider =
    StateNotifierProvider<Riverpod50Notifier, List<int>>(
  (ref) => Riverpod50Notifier(),
);

// -----------------------------------------------------------------------------
// 5. GETX IMPLEMENTATION (50 individual Rx variables)
// -----------------------------------------------------------------------------
class GetX50Controller extends getx.GetxController {
  final List<getx.RxInt> values = List.generate(50, (_) => 0.obs);

  void updateField(int index, int value) {
    values[index].value = value;
  }
}

class FineGrainedCounterWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const FineGrainedCounterWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! FineGrainedCounterWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(label);
  }
}

void main() {
  test(
      'Fine-Grained Reactivity Part A: 5,000 Targeted Mutations across 50 Independent Observers',
      () {
    const int totalMutations = 5000;
    const int fieldCount = 50;

    // --- 1. SIGNALS ---
    final sig = Signals50();
    final sigEvalCounts = List<int>.filled(fieldCount, 0);
    final sigDisposers = <VoidCallback>[];

    for (int i = 0; i < fieldCount; i++) {
      final idx = i;
      sigDisposers.add(effect(() {
        final _ = sig.signals[idx]();
        sigEvalCounts[idx]++;
      }));
    }

    final swSignals = Stopwatch()..start();
    for (int m = 0; m < totalMutations; m++) {
      final targetField = m % fieldCount;
      sig.updateField(targetField, m + 1);
    }
    swSignals.stop();
    for (final d in sigDisposers) {
      d();
    }

    // --- 2. GETX ---
    final gx = GetX50Controller();
    final gxEvalCounts = List<int>.filled(fieldCount, 0);
    for (int i = 0; i < fieldCount; i++) {
      final idx = i;
      getx.ever(gx.values[idx], (_) => gxEvalCounts[idx]++);
    }

    final swGetX = Stopwatch()..start();
    for (int m = 0; m < totalMutations; m++) {
      final targetField = m % fieldCount;
      gx.updateField(targetField, m + 1);
    }
    swGetX.stop();

    // --- 3. BLOC (Selector pattern) ---
    final bloc = Bloc50Cubit();
    int blocSelectorExecutions = 0;
    final blocEvalCounts = List<int>.filled(fieldCount, 0);
    List<int> blocLastKnownValues = List<int>.filled(fieldCount, 0);

    // Each state emission, all 50 selectors run in BLoC
    void onBlocState(Bloc50State s) {
      for (int i = 0; i < fieldCount; i++) {
        blocSelectorExecutions++;
        final val = s.values[i];
        if (val != blocLastKnownValues[i]) {
          blocLastKnownValues[i] = val;
          blocEvalCounts[i]++;
        }
      }
    }

    final swBloc = Stopwatch()..start();
    for (int m = 0; m < totalMutations; m++) {
      final targetField = m % fieldCount;
      bloc.updateField(targetField, m + 1);
      onBlocState(bloc.state);
    }
    swBloc.stop();
    bloc.close();

    // --- 4. RIVERPOD (Selector pattern) ---
    final container = ProviderContainer();
    int rpSelectorExecutions = 0;
    final rpEvalCounts = List<int>.filled(fieldCount, 0);
    final rpSubs = <ProviderSubscription<int>>[];

    for (int i = 0; i < fieldCount; i++) {
      final idx = i;
      final sel = riverpod50Provider.select((list) {
        rpSelectorExecutions++;
        return list[idx];
      });
      rpSubs.add(container.listen(sel, (prev, next) {
        rpEvalCounts[idx]++;
      }, fireImmediately: false));
    }

    final swRiverpod = Stopwatch()..start();
    for (int m = 0; m < totalMutations; m++) {
      final targetField = m % fieldCount;
      container.read(riverpod50Provider.notifier).updateField(targetField, m + 1);
    }
    swRiverpod.stop();
    for (final s in rpSubs) {
      s.close();
    }
    container.dispose();

    // --- 5. GRAFT (Hardware bitmask listener dispatch) ---
    final graft = Graft50Controller();
    int graftBitmaskChecks = 0;
    final graftEvalCounts = List<int>.filled(fieldCount, 0);

    // Register 50 fine-grained bitmask listeners (same mechanism as graft((s) => ...))
    for (int i = 0; i < fieldCount; i++) {
      final idx = i;
      final myMask = GraftMask.fromIndex(idx);
      graft.addMaskListener((dirtyMask) {
        graftBitmaskChecks++;
        // Hardware bitwise AND: 1 clock cycle!
        if (dirtyMask.intersects(myMask)) {
          graftEvalCounts[idx]++;
        }
      });
    }

    final swGraft = Stopwatch()..start();
    for (int m = 0; m < totalMutations; m++) {
      final targetField = m % fieldCount;
      graft.updateField(targetField, m + 1);
    }
    swGraft.stop();
    graft.dispose();

    // Total evaluations triggered:
    final totalSigEvals = sigEvalCounts.reduce((a, b) => a + b) - fieldCount; // minus initial effect run
    final totalGxEvals = gxEvalCounts.reduce((a, b) => a + b);
    final totalBlocEvals = blocEvalCounts.reduce((a, b) => a + b);
    final totalRpEvals = rpEvalCounts.reduce((a, b) => a + b);
    final totalGraftEvals = graftEvalCounts.reduce((a, b) => a + b);

    final double sigMs = swSignals.elapsedMicroseconds / 1000.0;
    final double gxMs = swGetX.elapsedMicroseconds / 1000.0;
    final double blocMs = swBloc.elapsedMicroseconds / 1000.0;
    final double rpMs = swRiverpod.elapsedMicroseconds / 1000.0;
    final double graftMs = swGraft.elapsedMicroseconds / 1000.0;

    print('\n' + '=' * 80);
    print('  BENCHMARK: FINE-GRAINED REACTIVITY ACROSS 50 INDEPENDENT NODES');
    print('  (5,000 single-field mutations across 50 independent consumers)');
    print('=' * 80);
    print('  Framework        Total Time (ms)    Consumer Dispatches    Selector / Check Runs');
    print('-' * 80);
    print('  GetX             ${gxMs.toStringAsFixed(2).padLeft(10)} ms    ${totalGxEvals.toString().padLeft(19)}    ${totalGxEvals.toString().padLeft(21)}');
    print('  Graft            ${graftMs.toStringAsFixed(2).padLeft(10)} ms    ${totalGraftEvals.toString().padLeft(19)}    ${graftBitmaskChecks.toString().padLeft(21)} (1-cycle bitmask) ⚡');
    print('  Signals          ${sigMs.toStringAsFixed(2).padLeft(10)} ms    ${totalSigEvals.toString().padLeft(19)}    ${totalSigEvals.toString().padLeft(21)} (DAG nodes)');
    print('  BLoC             ${blocMs.toStringAsFixed(2).padLeft(10)} ms    ${totalBlocEvals.toString().padLeft(19)}    ${blocSelectorExecutions.toString().padLeft(21)} (50x selector runs)');
    print('  Riverpod         ${rpMs.toStringAsFixed(2).padLeft(10)} ms    ${totalRpEvals.toString().padLeft(19)}    ${rpSelectorExecutions.toString().padLeft(21)} (50x selector runs)');
    print('=' * 80 + '\n');
  });

  testWidgets(
      'Fine-Grained Reactivity Part B: 50-Widget Layout Column Pipeline (60 Frames)',
      (tester) async {
    const int fieldCount = 50;

    // -------------------------------------------------------------------------
    // 1. GRAFT 50 SLOTS TEST
    // -------------------------------------------------------------------------
    final graft = Graft50Controller();
    final graftBuildCounts = List<int>.filled(fieldCount, 0);

    final graftWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(fieldCount, (i) {
            return graft((s) {
              return FineGrainedCounterWidget(
                label: 'Field $i: ${s.get(i)}',
                onBuild: () => graftBuildCounts[i]++,
              );
            });
          }),
        ),
      ),
    );

    await tester.pumpWidget(graftWidget);
    // Initial build: all 50 build once
    expect(graftBuildCounts.every((c) => c == 1), isTrue);
    for (int i = 0; i < fieldCount; i++) graftBuildCounts[i] = 0;

    final swGraftUI = Stopwatch()..start();
    for (int f = 1; f <= 60; f++) {
      graft.updateField(7, f);
      await tester.pump();
    }
    swGraftUI.stop();

    expect(graftBuildCounts[7], 60);
    int graftWastedBuilds = 0;
    for (int i = 0; i < fieldCount; i++) {
      if (i != 7) graftWastedBuilds += graftBuildCounts[i];
    }
    expect(graftWastedBuilds, 0);

    // -------------------------------------------------------------------------
    // 2. SIGNALS 50 WATCHERS TEST
    // -------------------------------------------------------------------------
    final sig = Signals50();
    final sigBuildCounts = List<int>.filled(fieldCount, 0);

    final sigWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(fieldCount, (i) {
            return Watch((context) {
              final val = sig.signals[i]();
              return FineGrainedCounterWidget(
                label: 'Field $i: $val',
                onBuild: () => sigBuildCounts[i]++,
              );
            });
          }),
        ),
      ),
    );

    await tester.pumpWidget(sigWidget);
    for (int i = 0; i < fieldCount; i++) sigBuildCounts[i] = 0;

    final swSigUI = Stopwatch()..start();
    for (int f = 1; f <= 60; f++) {
      sig.updateField(7, f);
      await tester.pump();
    }
    swSigUI.stop();

    expect(sigBuildCounts[7], 60);
    int sigWastedBuilds = 0;
    for (int i = 0; i < fieldCount; i++) {
      if (i != 7) sigWastedBuilds += sigBuildCounts[i];
    }
    expect(sigWastedBuilds, 0);

    // -------------------------------------------------------------------------
    // 3. RIVERPOD 50 CONSUMERS TEST
    // -------------------------------------------------------------------------
    final rpContainer = ProviderContainer();
    final rpBuildCounts = List<int>.filled(fieldCount, 0);

    final rpWidget = UncontrolledProviderScope(
      container: rpContainer,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(fieldCount, (i) {
              return Consumer(
                builder: (context, ref, _) {
                  final val = ref.watch(riverpod50Provider.select((list) => list[i]));
                  return FineGrainedCounterWidget(
                    label: 'Field $i: $val',
                    onBuild: () => rpBuildCounts[i]++,
                  );
                },
              );
            }),
          ),
        ),
      ),
    );

    await tester.pumpWidget(rpWidget);
    for (int i = 0; i < fieldCount; i++) rpBuildCounts[i] = 0;

    final swRpUI = Stopwatch()..start();
    for (int f = 1; f <= 60; f++) {
      rpContainer.read(riverpod50Provider.notifier).updateField(7, f);
      await tester.pump();
    }
    swRpUI.stop();

    expect(rpBuildCounts[7], 60);
    int rpWastedBuilds = 0;
    for (int i = 0; i < fieldCount; i++) {
      if (i != 7) rpWastedBuilds += rpBuildCounts[i];
    }
    expect(rpWastedBuilds, 0);

    // -------------------------------------------------------------------------
    // 4. BLOC 50 SELECTORS TEST
    // -------------------------------------------------------------------------
    final bloc = Bloc50Cubit();
    final blocBuildCounts = List<int>.filled(fieldCount, 0);

    final blocWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(fieldCount, (i) {
            return BlocSelector<Bloc50Cubit, Bloc50State, int>(
              bloc: bloc,
              selector: (state) => state.values[i],
              builder: (context, val) {
                return FineGrainedCounterWidget(
                  label: 'Field $i: $val',
                  onBuild: () => blocBuildCounts[i]++,
                );
              },
            );
          }),
        ),
      ),
    );

    await tester.pumpWidget(blocWidget);
    for (int i = 0; i < fieldCount; i++) blocBuildCounts[i] = 0;

    final swBlocUI = Stopwatch()..start();
    for (int f = 1; f <= 60; f++) {
      bloc.updateField(7, f);
      await tester.pump(Duration.zero);
    }
    swBlocUI.stop();

    expect(blocBuildCounts[7], 60);
    int blocWastedBuilds = 0;
    for (int i = 0; i < fieldCount; i++) {
      if (i != 7) blocWastedBuilds += blocBuildCounts[i];
    }
    expect(blocWastedBuilds, 0);

    // -------------------------------------------------------------------------
    // 5. GETX 50 OBX TEST
    // -------------------------------------------------------------------------
    final gx = GetX50Controller();
    final gxBuildCounts = List<int>.filled(fieldCount, 0);

    final gxWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(fieldCount, (i) {
            return getx.Obx(() {
              final val = gx.values[i].value;
              return FineGrainedCounterWidget(
                label: 'Field $i: $val',
                onBuild: () => gxBuildCounts[i]++,
              );
            });
          }),
        ),
      ),
    );

    await tester.pumpWidget(gxWidget);
    for (int i = 0; i < fieldCount; i++) gxBuildCounts[i] = 0;

    final swGxUI = Stopwatch()..start();
    for (int f = 1; f <= 60; f++) {
      gx.updateField(7, f);
      await tester.pump();
    }
    swGxUI.stop();

    expect(gxBuildCounts[7], 60);
    int gxWastedBuilds = 0;
    for (int i = 0; i < fieldCount; i++) {
      if (i != 7) gxWastedBuilds += gxBuildCounts[i];
    }
    expect(gxWastedBuilds, 0);

    final double graftMs = swGraftUI.elapsedMicroseconds / 1000.0;
    final double sigMs = swSigUI.elapsedMicroseconds / 1000.0;
    final double rpMs = swRpUI.elapsedMicroseconds / 1000.0;
    final double blocMs = swBlocUI.elapsedMicroseconds / 1000.0;
    final double gxMs = swGxUI.elapsedMicroseconds / 1000.0;

    print('\n' + '=' * 80);
    print('  BENCHMARK: 50-WIDGET SCREEN LAYOUT REBUILD PIPELINE (60 FRAMES)');
    print('  (1 Dynamic Widget + 49 Static Widgets in Layout)');
    print('=' * 80);
    print('  Framework        Pipeline Time (ms)    Target Builds    Wasted Builds    Status');
    print('-' * 80);
    print('  GetX             ${gxMs.toStringAsFixed(2).padLeft(10)} ms    60 / 60          0 (0.0%)         100% Isolated');
    print('  Signals          ${sigMs.toStringAsFixed(2).padLeft(10)} ms    60 / 60          0 (0.0%)         100% Isolated');
    print('  Riverpod         ${rpMs.toStringAsFixed(2).padLeft(10)} ms    60 / 60          0 (0.0%)         100% Isolated');
    print('  BLoC             ${blocMs.toStringAsFixed(2).padLeft(10)} ms    60 / 60          0 (0.0%)         100% Isolated');
    print('  Graft            ${graftMs.toStringAsFixed(2).padLeft(10)} ms    60 / 60          0 (0.0%)         100% Isolated ⚡');
    print('=' * 80 + '\n');
  });
}
