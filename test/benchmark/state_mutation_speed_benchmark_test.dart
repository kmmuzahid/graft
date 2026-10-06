import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// =============================================================================
// 1. GRAFT IMPLEMENTATION
// =============================================================================
class GraftBenchmarkState extends GraftState {
  int count = 0;
  @override
  List<Object?> get props => [count];
}

class GraftBenchmarkController extends Graft<GraftBenchmarkState> {
  GraftBenchmarkController() : super(GraftBenchmarkState());

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

// =============================================================================
// 2. BLOC (CUBIT) IMPLEMENTATION
// =============================================================================
class BlocBenchmarkCubit extends Cubit<int> {
  BlocBenchmarkCubit() : super(0);
  void increment() => emit(state + 1);
}

// =============================================================================
// 3. RIVERPOD IMPLEMENTATION
// =============================================================================
class RiverpodBenchmarkNotifier extends StateNotifier<int> {
  RiverpodBenchmarkNotifier() : super(0);
  void increment() => state = state + 1;
}

final riverpodBenchmarkProvider =
    StateNotifierProvider<RiverpodBenchmarkNotifier, int>(
  (ref) => RiverpodBenchmarkNotifier(),
);

// =============================================================================
// 4. GETX IMPLEMENTATION
// =============================================================================
class GetXBenchmarkController extends getx.GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}

void main() {
  const int iterations = 10000;

  test('Benchmark: Raw 10,000 State Mutation Speed (Graft vs BLoC vs Riverpod vs Signals vs GetX)', () {
    // -------------------------------------------------------------------------
    // Warm-up JIT
    // -------------------------------------------------------------------------
    final warmGraft = GraftBenchmarkController();
    final warmBloc = BlocBenchmarkCubit();
    final warmSignals = signal(0);
    final warmGetX = GetXBenchmarkController();
    for (int i = 0; i < 500; i++) {
      warmGraft.increment();
      warmBloc.increment();
      warmSignals.value++;
      warmGetX.increment();
    }

    // -------------------------------------------------------------------------
    // 1. GRAFT
    // -------------------------------------------------------------------------
    final graft = GraftBenchmarkController();
    int graftListenerFires = 0;
    graft.addListener(() => graftListenerFires++);

    final graftWatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      graft.increment();
    }
    graftWatch.stop();
    final graftTimeUs = graftWatch.elapsedMicroseconds;

    // -------------------------------------------------------------------------
    // 2. BLOC (Cubit)
    // -------------------------------------------------------------------------
    final bloc = BlocBenchmarkCubit();
    int blocListenerFires = 0;
    final blocSub = bloc.stream.listen((_) => blocListenerFires++);

    final blocWatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      bloc.increment();
    }
    blocWatch.stop();
    final blocTimeUs = blocWatch.elapsedMicroseconds;
    blocSub.cancel();

    // -------------------------------------------------------------------------
    // 3. RIVERPOD
    // -------------------------------------------------------------------------
    final container = ProviderContainer();
    final riverpodNotifier = container.read(riverpodBenchmarkProvider.notifier);
    int riverpodListenerFires = 0;
    final riverpodSub = container.listen(
      riverpodBenchmarkProvider,
      (_, __) => riverpodListenerFires++,
    );

    final riverpodWatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      riverpodNotifier.increment();
    }
    riverpodWatch.stop();
    final riverpodTimeUs = riverpodWatch.elapsedMicroseconds;
    riverpodSub.close();
    container.dispose();

    // -------------------------------------------------------------------------
    // 4. SIGNALS
    // -------------------------------------------------------------------------
    final counterSignal = signal(0);
    int signalsListenerFires = 0;
    final disposeSignal = effect(() {
      counterSignal.value;
      signalsListenerFires++;
    });

    final signalsWatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      counterSignal.value++;
    }
    signalsWatch.stop();
    final signalsTimeUs = signalsWatch.elapsedMicroseconds;
    disposeSignal();

    // -------------------------------------------------------------------------
    // 5. GETX
    // -------------------------------------------------------------------------
    final getxController = GetXBenchmarkController();
    int getxListenerFires = 0;
    final getxWorker = getx.ever(getxController.count, (_) => getxListenerFires++);

    final getxWatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      getxController.increment();
    }
    getxWatch.stop();
    final getxTimeUs = getxWatch.elapsedMicroseconds;
    getxWorker.dispose();

    // -------------------------------------------------------------------------
    // PRINT FORMATTED REPORT
    // -------------------------------------------------------------------------
    final results = [
      {'name': 'Graft', 'timeUs': graftTimeUs, 'fires': graftListenerFires},
      {'name': 'Signals', 'timeUs': signalsTimeUs, 'fires': signalsListenerFires - 1},
      {'name': 'Riverpod', 'timeUs': riverpodTimeUs, 'fires': riverpodListenerFires},
      {'name': 'GetX', 'timeUs': getxTimeUs, 'fires': getxListenerFires},
      {'name': 'BLoC (Cubit)', 'timeUs': blocTimeUs, 'fires': blocListenerFires},
    ];

    results.sort((a, b) => (a['timeUs'] as int).compareTo(b['timeUs'] as int));

    // ignore: avoid_print
    print('''
================================================================================
  REAL BENCHMARK: RAW 10,000 SYNCHRONOUS MUTATIONS
================================================================================
  Framework      Total Time (ms)    Per Mutation (ns)    Ops / Sec
--------------------------------------------------------------------------------''');

    for (final r in results) {
      final name = (r['name'] as String).padRight(14);
      final timeMs = ((r['timeUs'] as int) / 1000).toStringAsFixed(2).padLeft(10);
      final nsPerOp = (((r['timeUs'] as int) * 1000) / iterations).toStringAsFixed(1).padLeft(12);
      final opsPerSec = ((iterations / (r['timeUs'] as int)) * 1000000).toStringAsFixed(0).padLeft(14);
      // ignore: avoid_print
      print('  $name $timeMs ms       $nsPerOp ns    $opsPerSec ops/s');
    }

    // ignore: avoid_print
    print('================================================================================');

    expect(graft.state.count, iterations);
    expect(counterSignal.value, iterations);
  });
}
