import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'benchmark_models.dart';

// =============================================================================
// DOMAIN MODELS FOR SCENARIO F: THE REACTIVE "DIAMOND DEPENDENCY"
//
//          [ A ] (Root source)
//          /   \
//      [ B ]   [ C ] (Derived: B = A * 2, C = A * 3)
//          \   /
//          [ D ] (Bottom Derived: D = B + C)
// =============================================================================

// 1. Graft
class GraftDiamondState extends GraftState {
  int a = 0;
  int get b => a * 2;
  int get c => a * 3;
  int get d => b + c;

  @override
  GraftProps get props => propsOf(a);
}

class GraftDiamondController extends Graft<GraftDiamondState> {
  GraftDiamondController() : super(GraftDiamondState());
  late final _s = state;
  void setA(int val) => _s..a = val..update();
}

// 2. Signals (Preact / SolidJS style DAG)
class SignalsDiamond {
  final a = signals_pkg.signal(0);
  late final signals_pkg.Computed<int> b;
  late final signals_pkg.Computed<int> c;
  late final signals_pkg.Computed<int> d;
  int dEvalCount = 0;
  int glitchCount = 0;

  SignalsDiamond() {
    b = signals_pkg.computed(() => a() * 2);
    c = signals_pkg.computed(() => a() * 3);
    d = signals_pkg.computed(() {
      dEvalCount++;
      final currentB = b();
      final currentC = c();
      if (currentB * 3 != currentC * 2) {
        glitchCount++;
      }
      return currentB + currentC;
    });
  }

  void setA(int val) => a.value = val;
}

// 3. Riverpod
final riverpodAPrv = riverpod_pkg.StateProvider<int>((ref) => 0);
final riverpodBPrv = riverpod_pkg.Provider<int>((ref) => ref.watch(riverpodAPrv) * 2);
final riverpodCPrv = riverpod_pkg.Provider<int>((ref) => ref.watch(riverpodAPrv) * 3);

class RiverpodDiamondTracker {
  int dEvalCount = 0;
  int glitchCount = 0;
  late final riverpod_pkg.Provider<int> dPrv;

  RiverpodDiamondTracker() {
    dPrv = riverpod_pkg.Provider<int>((ref) {
      dEvalCount++;
      final b = ref.watch(riverpodBPrv);
      final c = ref.watch(riverpodCPrv);
      if (b * 3 != c * 2) {
        glitchCount++;
      }
      return b + c;
    });
  }
}

// 4. BLoC (Cubit)
class BlocDiamondState {
  final int a;
  const BlocDiamondState(this.a);
  int get b => a * 2;
  int get c => a * 3;
  int get d => b + c;
}

class BlocDiamondCubit extends bloc_pkg.Cubit<BlocDiamondState> {
  BlocDiamondCubit() : super(const BlocDiamondState(0));
  void setA(int val) => emit(BlocDiamondState(val));
}

// 5. GetX (Observer-based graph with workers)
class GetXDiamondController extends getx.GetxController {
  final a = 0.obs;
  final b = 0.obs;
  final c = 0.obs;
  final d = 0.obs;
  int dEvalCount = 0;
  int glitchCount = 0;

  @override
  void onInit() {
    super.onInit();
    getx.ever(a, (int val) => b.value = val * 2);
    getx.ever(a, (int val) => c.value = val * 3);
    getx.ever(b, (_) => _evaluateD());
    getx.ever(c, (_) => _evaluateD());
  }

  void _evaluateD() {
    dEvalCount++;
    final curB = b.value;
    final curC = c.value;
    if (curB * 3 != curC * 2) {
      glitchCount++;
    }
    d.value = curB + curC;
  }

  void setA(int val) => a.value = val;
}

// =============================================================================
// SCENARIO F RUNNER
// =============================================================================
class ScenarioFReactiveDiamondRunner {
  static const int warmUpRuns = 10;
  static const int measuredRuns = 15;
  static const int updates = 5000;

  static List<BenchmarkStats> runAll() {
    final results = <BenchmarkStats>[];
    const scenarioName = 'F1_reactive_diamond_glitch_test';

    // 1. Graft
    {
      final samples = <double>[];
      int lastGlitches = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final graft = GraftDiamondController();
        int graftGlitchCount = 0;
        int graftLastVal = 0;
        final graftListener = () {
          final s = graft.state;
          if (s.b * 3 != s.c * 2) {
            graftGlitchCount++;
          }
          graftLastVal = s.d;
        };
        graft.addListener(graftListener);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= updates; i++) {
          graft.setA(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastGlitches = graftGlitchCount;
        }
        expect(graftLastVal, updates * 5);
        graft.removeListener(graftListener);
        graft.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        glitchesDetected: lastGlitches,
        isPassed: lastGlitches == 0,
        notes: 'Glitch-free 1-pass synchronous domain getters',
      ));
    }

    // 2. Signals
    {
      final samples = <double>[];
      int lastGlitches = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final sig = SignalsDiamond();
        int sigLastVal = 0;
        final sigDispose = signals_pkg.effect(() {
          sigLastVal = sig.d();
        });

        final sw = Stopwatch()..start();
        for (int i = 1; i <= updates; i++) {
          sig.setA(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastGlitches = sig.glitchCount;
        }
        expect(sigLastVal, updates * 5);
        sigDispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        glitchesDetected: lastGlitches,
        isPassed: lastGlitches == 0,
        notes: 'Glitch-free topological reactive DAG',
      ));
    }

    // 3. Riverpod
    {
      final samples = <double>[];
      int lastGlitches = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final rpTracker = RiverpodDiamondTracker();
        int rpLastVal = 0;
        final rpSub = container.listen<int>(rpTracker.dPrv, (_, next) {
          rpLastVal = next;
        }, fireImmediately: true);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= updates; i++) {
          container.read(riverpodAPrv.notifier).state = i;
          rpLastVal = container.read(rpTracker.dPrv);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastGlitches = rpTracker.glitchCount;
        }
        expect(rpLastVal, updates * 5);
        rpSub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        glitchesDetected: lastGlitches,
        isPassed: lastGlitches == 0,
        notes: 'Glitch-free provider dependency graph',
      ));
    }

    // 4. BLoC (Cubit)
    {
      final samples = <double>[];
      int lastGlitches = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final bloc = BlocDiamondCubit();
        int blocGlitchCount = 0;
        int blocLastVal = 0;

        final sw = Stopwatch()..start();
        for (int i = 1; i <= updates; i++) {
          bloc.setA(i);
          final st = bloc.state;
          if (st.b * 3 != st.c * 2) {
            blocGlitchCount++;
          }
          blocLastVal = st.d;
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastGlitches = blocGlitchCount;
        }
        expect(blocLastVal, updates * 5);
        bloc.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        glitchesDetected: lastGlitches,
        isPassed: lastGlitches == 0,
        notes: 'Glitch-free immutable model getters',
      ));
    }

    // 5. GetX
    {
      final samples = <double>[];
      int lastGlitches = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final gx = GetXDiamondController();
        gx.onInit();

        final sw = Stopwatch()..start();
        for (int i = 1; i <= updates; i++) {
          gx.setA(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastGlitches = gx.glitchCount;
        }
        expect(gx.d.value, updates * 5);
        gx.onClose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        glitchesDetected: lastGlitches,
        isPassed: lastGlitches == 0,
        failureReason: '$lastGlitches intermediate state glitches detected (unsorted workers)',
        notes: 'Unsorted workers cause 2x evals and 5,000 glitches',
      ));
    }

    return results;
  }
}

