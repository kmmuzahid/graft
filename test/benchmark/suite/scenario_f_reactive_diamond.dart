import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'benchmark_isolation.dart';
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
  void setA(int val) => state..a = val..update();
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocDiamondState &&
          runtimeType == other.runtimeType &&
          a == other.a;

  @override
  int get hashCode => a.hashCode;
}

class BlocDiamondCubit extends bloc_pkg.Cubit<BlocDiamondState> {
  final void Function(BlocDiamondState)? onNotification;
  BlocDiamondCubit({this.onNotification}) : super(const BlocDiamondState(0));
  void setA(int val) => emit(BlocDiamondState(val));

  @override
  void onChange(bloc_pkg.Change<BlocDiamondState> change) {
    super.onChange(change);
    onNotification?.call(change.nextState);
  }
}

// 5. GetX
class GetXDiamond {
  final a = 0.obs;
  final b = 0.obs;
  final c = 0.obs;
  final d = 0.obs;
  int dEvalCount = 0;
  int glitchCount = 0;

  GetXDiamond() {
    getx.ever(a, (int val) {
      b.value = val * 2;
      c.value = val * 3;
    });

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
// CANDIDATE CONTRACT (HERMETIC ISOLATION)
// =============================================================================
abstract class _ScenarioFCandidate {
  String get name;
  String get notes;
  void setup();
  void runUpdates(int count);
  int get glitches;
  bool get isPassed;
  void verify(int count);
  void dispose();
}

class _GraftFCandidate implements _ScenarioFCandidate {
  @override
  String get name => 'Graft';
  @override
  String get notes => 'Glitch-free 1-pass synchronous domain getters';

  GraftDiamondController? _ctrl;
  int _glitches = 0;
  int _lastVal = 0;
  void Function()? _listener;

  @override
  void setup() {
    _ctrl = GraftDiamondController();
    _glitches = 0;
    _lastVal = 0;
    _listener = () {
      final s = _ctrl!.state;
      if (s.b * 3 != s.c * 2) {
        _glitches++;
      }
      _lastVal = s.d;
    };
    _ctrl!.addListener(_listener!);
  }

  @override
  void runUpdates(int count) {
    for (int i = 1; i <= count; i++) {
      _ctrl!.setA(i);
    }
  }

  @override
  int get glitches => _glitches;

  @override
  bool get isPassed => _glitches == 0;

  @override
  void verify(int count) {
    expect(_lastVal, count * 5);
  }

  @override
  void dispose() {
    if (_listener != null) _ctrl?.removeListener(_listener!);
    _ctrl?.dispose();
  }
}

class _BlocFCandidate implements _ScenarioFCandidate {
  @override
  String get name => 'BLoC (Cubit)';
  @override
  String get notes => 'Glitch-free immutable model getters';

  BlocDiamondCubit? _cubit;
  int _glitches = 0;
  int _lastVal = 0;

  @override
  void setup() {
    _glitches = 0;
    _lastVal = 0;
    _cubit = BlocDiamondCubit(onNotification: (st) {
      if (st.b * 3 != st.c * 2) {
        _glitches++;
      }
      _lastVal = st.d;
    });
  }

  @override
  void runUpdates(int count) {
    for (int i = 1; i <= count; i++) {
      _cubit!.setA(i);
    }
  }

  @override
  int get glitches => _glitches;

  @override
  bool get isPassed => _glitches == 0;

  @override
  void verify(int count) {
    expect(_lastVal, count * 5);
  }

  @override
  void dispose() {
    _cubit?.close();
  }
}

class _SignalsFCandidate implements _ScenarioFCandidate {
  @override
  String get name => 'Signals';
  @override
  String get notes => 'Glitch-free topological reactive DAG';

  SignalsDiamond? _sig;
  int _lastVal = 0;
  void Function()? _sigDispose;

  @override
  void setup() {
    _sig = SignalsDiamond();
    _lastVal = 0;
    _sigDispose = signals_pkg.effect(() {
      _lastVal = _sig!.d();
    });
  }

  @override
  void runUpdates(int count) {
    for (int i = 1; i <= count; i++) {
      _sig!.setA(i);
    }
  }

  @override
  int get glitches => _sig!.glitchCount;

  @override
  bool get isPassed => _sig!.glitchCount == 0;

  @override
  void verify(int count) {
    expect(_lastVal, count * 5);
  }

  @override
  void dispose() {
    _sigDispose?.call();
  }
}

class _RiverpodFCandidate implements _ScenarioFCandidate {
  @override
  String get name => 'Riverpod (Notifier)';
  @override
  String get notes => 'Glitch-free provider dependency graph';

  riverpod_pkg.ProviderContainer? _container;
  RiverpodDiamondTracker? _tracker;
  riverpod_pkg.ProviderSubscription<int>? _sub;
  int _lastVal = 0;

  @override
  void setup() {
    _container = riverpod_pkg.ProviderContainer();
    _tracker = RiverpodDiamondTracker();
    _lastVal = 0;
    _sub = _container!.listen(_tracker!.dPrv, (_, next) {
      _lastVal = next;
    });
  }

  @override
  void runUpdates(int count) {
    for (int i = 1; i <= count; i++) {
      _container!.read(riverpodAPrv.notifier).state = i;
      _lastVal = _container!.read(_tracker!.dPrv);
    }
  }

  @override
  int get glitches => _tracker!.glitchCount;

  @override
  bool get isPassed => _tracker!.glitchCount == 0;

  @override
  void verify(int count) {
    expect(_lastVal, count * 5);
  }

  @override
  void dispose() {
    _sub?.close();
    _container?.dispose();
  }
}

class _GetXFCandidate implements _ScenarioFCandidate {
  @override
  String get name => 'GetX';
  @override
  String get notes => 'Glitch-prone uncoordinated reactive streams';

  GetXDiamond? _gx;

  @override
  void setup() {
    _gx = GetXDiamond();
  }

  @override
  void runUpdates(int count) {
    for (int i = 1; i <= count; i++) {
      _gx!.setA(i);
    }
  }

  @override
  int get glitches => _gx!.glitchCount;

  @override
  bool get isPassed => _gx!.glitchCount == 0;

  @override
  void verify(int count) {}

  @override
  void dispose() {}
}

// =============================================================================
// SCENARIO F RUNNER (INTERLEAVED ROUND-ROBIN WITH HERMETIC ISOLATION)
// =============================================================================
class ScenarioFReactiveDiamondRunner {
  static const int warmUpRuns = 10;
  static const int measuredRuns = 15;
  static const int updates = 50000;

  static List<BenchmarkStats> runAll() {
    final results = <BenchmarkStats>[];
    const scenarioName = 'F1_reactive_diamond_glitch_test';

    final candidates = <_ScenarioFCandidate>[
      _GraftFCandidate(),
      _BlocFCandidate(),
      _SignalsFCandidate(),
      _RiverpodFCandidate(),
      _GetXFCandidate(),
    ];

    final samplesMap = {for (final c in candidates) c.name: <double>[]};
    final lastGlitchesMap = {for (final c in candidates) c.name: 0};
    final isPassedMap = {for (final c in candidates) c.name: true};

    // 1. Interleaved Warm-Up Runs
    for (int w = 0; w < warmUpRuns; w++) {
      for (final candidate in candidates) {
        BenchmarkIsolation.flushHeap();
        candidate.setup();
        candidate.runUpdates(updates ~/ 5);
        candidate.dispose();
      }
    }

    // 2. Interleaved Measured Runs
    for (int m = 0; m < measuredRuns; m++) {
      for (final candidate in candidates) {
        BenchmarkIsolation.flushHeap();
        candidate.setup();

        final sw = Stopwatch()..start();
        candidate.runUpdates(updates);
        sw.stop();

        samplesMap[candidate.name]!.add(sw.elapsedMicroseconds / 1000.0);
        lastGlitchesMap[candidate.name] = candidate.glitches;
        isPassedMap[candidate.name] = candidate.isPassed;
        candidate.verify(updates);
        candidate.dispose();
      }
    }

    for (final candidate in candidates) {
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: candidate.name,
        samplesMs: samplesMap[candidate.name]!,
        glitchesDetected: lastGlitchesMap[candidate.name]!,
        isPassed: isPassedMap[candidate.name]!,
        notes: candidate.notes,
      ));
    }

    return results;
  }
}
