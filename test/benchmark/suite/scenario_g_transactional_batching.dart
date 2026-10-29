import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'benchmark_models.dart';

// =============================================================================
// DOMAIN MODELS FOR SCENARIO G: TRANSACTIONAL MULTI-FIELD BATCHING BURST
// (2,000 transactions, 5 fields each = 10,000 field mutations)
// =============================================================================

// 1. Graft
class GraftBatchState extends GraftState {
  int f1 = 0, f2 = 0, f3 = 0, f4 = 0, f5 = 0;
  @override
  GraftProps get props => propsOf(f1, f2, f3, f4, f5);
}

class GraftBatchController extends Graft<GraftBatchState> {
  GraftBatchController() : super(GraftBatchState());
  late final _s = state;
  void transaction(int val) {
    _s
      ..f1 = val
      ..f2 = val
      ..f3 = val
      ..f4 = val
      ..f5 = val
      ..update();
  }
}

// 2. Signals
class SignalsBatch {
  final f1 = signals_pkg.signal(0);
  final f2 = signals_pkg.signal(0);
  final f3 = signals_pkg.signal(0);
  final f4 = signals_pkg.signal(0);
  final f5 = signals_pkg.signal(0);

  void transaction(int val) {
    signals_pkg.batch(() {
      f1.value = val;
      f2.value = val;
      f3.value = val;
      f4.value = val;
      f5.value = val;
    });
  }
}

// 3. Riverpod
class RiverpodBatchData {
  final int f1, f2, f3, f4, f5;
  const RiverpodBatchData(this.f1, this.f2, this.f3, this.f4, this.f5);
}

class RiverpodBatchNotifier extends riverpod_pkg.StateNotifier<RiverpodBatchData> {
  RiverpodBatchNotifier() : super(const RiverpodBatchData(0, 0, 0, 0, 0));
  void transaction(int val) {
    state = RiverpodBatchData(val, val, val, val, val);
  }
}

final riverpodBatchProvider =
    riverpod_pkg.StateNotifierProvider<RiverpodBatchNotifier, RiverpodBatchData>(
  (ref) => RiverpodBatchNotifier(),
);

// 4. BLoC
class BlocBatchData {
  final int f1, f2, f3, f4, f5;
  const BlocBatchData(this.f1, this.f2, this.f3, this.f4, this.f5);
}

class BlocBatchCubit extends bloc_pkg.Cubit<BlocBatchData> {
  BlocBatchCubit() : super(const BlocBatchData(0, 0, 0, 0, 0));
  void transaction(int val) {
    emit(BlocBatchData(val, val, val, val, val));
  }
}

// 5. GetX
class GetXBatchController extends getx.GetxController {
  final f1 = 0.obs;
  final f2 = 0.obs;
  final f3 = 0.obs;
  final f4 = 0.obs;
  final f5 = 0.obs;

  void transaction(int val) {
    f1.value = val;
    f2.value = val;
    f3.value = val;
    f4.value = val;
    f5.value = val;
  }
}

// =============================================================================
// SCENARIO G RUNNER
// =============================================================================
class ScenarioGTransactionalBatchingRunner {
  static const int warmUpRuns = 10;
  static const int measuredRuns = 15;
  static const int transactions = 2000;

  static List<BenchmarkStats> runAll() {
    final results = <BenchmarkStats>[];
    const scenarioName = 'G1_transactional_multi_field_batching';

    // 1. BLoC
    {
      final samples = <double>[];
      int lastFires = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final bloc = BlocBatchCubit();
        int fires = 0;
        final sub = bloc.stream.listen((_) => fires++);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= transactions; i++) {
          bloc.transaction(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastFires = fires;
        }
        sub.cancel();
        bloc.close();
      }
      final wasted = lastFires > transactions ? lastFires - transactions : 0;
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        wastedNotifications: wasted,
        isPassed: wasted == 0,
        notes: '100% Batched (1 notification per transaction)',
      ));
    }

    // 2. Graft
    {
      final samples = <double>[];
      int lastFires = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final graft = GraftBatchController();
        int fires = 0;
        graft.addListener(() => fires++);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= transactions; i++) {
          graft.transaction(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastFires = fires;
        }
        expect(graft.state.f1, transactions);
        graft.dispose();
      }
      final wasted = lastFires > transactions ? lastFires - transactions : 0;
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        wastedNotifications: wasted,
        isPassed: wasted == 0,
        notes: '100% Batched (in-place cascade with 1 update())',
      ));
    }

    // 3. Riverpod
    {
      final samples = <double>[];
      int lastFires = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        int fires = 0;
        final sub = container.listen(riverpodBatchProvider, (_, __) => fires++);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= transactions; i++) {
          container.read(riverpodBatchProvider.notifier).transaction(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastFires = fires;
        }
        sub.close();
        container.dispose();
      }
      final wasted = lastFires > transactions ? lastFires - transactions : 0;
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        wastedNotifications: wasted,
        isPassed: wasted == 0,
        notes: '100% Batched (immutable state transition)',
      ));
    }

    // 4. Signals
    {
      final samples = <double>[];
      int lastFires = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final sig = SignalsBatch();
        int fires = 0;
        final disposeEffect = signals_pkg.effect(() {
          final _ = sig.f1() + sig.f2() + sig.f3() + sig.f4() + sig.f5();
          fires++;
        });

        final sw = Stopwatch()..start();
        for (int i = 1; i <= transactions; i++) {
          sig.transaction(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastFires = fires > 0 ? fires - 1 : 0; // subtract initial effect run
        }
        disposeEffect();
      }
      final wasted = lastFires > transactions ? lastFires - transactions : 0;
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        wastedNotifications: wasted,
        isPassed: wasted == 0,
        notes: '100% Batched (via batch() block)',
      ));
    }

    // 5. GetX
    {
      final samples = <double>[];
      int lastFires = 0;
      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final gx = GetXBatchController();
        int fires = 0;
        final w1 = getx.ever(gx.f1, (_) => fires++);
        final w2 = getx.ever(gx.f2, (_) => fires++);
        final w3 = getx.ever(gx.f3, (_) => fires++);
        final w4 = getx.ever(gx.f4, (_) => fires++);
        final w5 = getx.ever(gx.f5, (_) => fires++);

        final sw = Stopwatch()..start();
        for (int i = 1; i <= transactions; i++) {
          gx.transaction(i);
        }
        sw.stop();
        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
          lastFires = fires;
        }
        w1.dispose();
        w2.dispose();
        w3.dispose();
        w4.dispose();
        w5.dispose();
      }
      final wasted = lastFires > transactions ? lastFires - transactions : 0;
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        wastedNotifications: wasted,
        isPassed: wasted == 0,
        failureReason: '$wasted wasted notifications fired ($lastFires total fires for $transactions txns)',
        notes: 'UNBATCHED: 5 fires per transaction (8,000 wasted notifications)',
      ));
    }

    return results;
  }
}

