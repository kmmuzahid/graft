import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// =============================================================================
// REAL-WORLD 5-FIELD DOMAIN STATE MODEL
// =============================================================================

// 1. GRAFT: Mutable In-Place Domain State
class RealGraftState extends GraftState {
  String name = 'Alice';
  int count = 0;
  String email = 'alice@example.com';
  bool isOnline = true;
  double score = 98.5;

  @override
  GraftProps get props => propsOf(name, count, email, isOnline, score);
}

class RealGraftController extends Graft<RealGraftState> {
  RealGraftController() : super(RealGraftState());

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

// 2. BLOC: Standard Immutable State with copyWith & Equatable props
class RealBlocState {
  final String name;
  final int count;
  final String email;
  final bool isOnline;
  final double score;

  const RealBlocState({
    this.name = 'Alice',
    this.count = 0,
    this.email = 'alice@example.com',
    this.isOnline = true,
    this.score = 98.5,
  });

  RealBlocState copyWith({
    String? name,
    int? count,
    String? email,
    bool? isOnline,
    double? score,
  }) {
    return RealBlocState(
      name: name ?? this.name,
      count: count ?? this.count,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealBlocState &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          count == other.count &&
          email == other.email &&
          isOnline == other.isOnline &&
          score == other.score;

  @override
  int get hashCode => Object.hash(name, count, email, isOnline, score);
}

class RealBlocCubit extends Cubit<RealBlocState> {
  RealBlocCubit() : super(const RealBlocState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }
}

// 3. RIVERPOD: Standard Immutable StateNotifier with copyWith
class RealRiverpodNotifier extends StateNotifier<RealBlocState> {
  RealRiverpodNotifier() : super(const RealBlocState());

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }
}

final realRiverpodProvider =
    StateNotifierProvider<RealRiverpodNotifier, RealBlocState>(
  (ref) => RealRiverpodNotifier(),
);

// 4. GETX: Real-World Multi-Field Controller
class RealGetXController extends getx.GetxController {
  final name = 'Alice'.obs;
  final count = 0.obs;
  final email = 'alice@example.com'.obs;
  final isOnline = true.obs;
  final score = 98.5.obs;

  void increment() => count.value++;
}

// 5. SIGNALS: Real-World Controller with individual signals
class RealSignalsController {
  final name = signal('Alice');
  final count = signal(0);
  final email = signal('alice@example.com');
  final isOnline = signal(true);
  final score = signal(98.5);

  void increment() => count.value++;
}

void main() {
  const int iterations = 10000;

  test('Benchmark: Real-World 5-Field Production State (10,000 Updates)', () {
    // -------------------------------------------------------------------------
    // Warm-up
    // -------------------------------------------------------------------------
    final warmGraft = RealGraftController();
    final warmBloc = RealBlocCubit();
    final warmSignals = RealSignalsController();
    final warmGetX = RealGetXController();
    for (int i = 0; i < 500; i++) {
      warmGraft.increment();
      warmBloc.increment();
      warmSignals.increment();
      warmGetX.increment();
    }

    // -------------------------------------------------------------------------
    // 1. GRAFT
    // -------------------------------------------------------------------------
    final graft = RealGraftController();
    int graftFires = 0;
    graft.addListener(() => graftFires++);

    final graftSw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      graft.increment();
    }
    graftSw.stop();
    final graftUs = graftSw.elapsedMicroseconds;

    // -------------------------------------------------------------------------
    // 2. BLOC (Real copyWith + State class + Stream)
    // -------------------------------------------------------------------------
    final bloc = RealBlocCubit();
    int blocFires = 0;
    final blocSub = bloc.stream.listen((_) => blocFires++);

    final blocSw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      bloc.increment();
    }
    blocSw.stop();
    final blocUs = blocSw.elapsedMicroseconds;
    blocSub.cancel();

    // -------------------------------------------------------------------------
    // 3. RIVERPOD (Real copyWith + StateNotifier + listener)
    // -------------------------------------------------------------------------
    final container = ProviderContainer();
    final riverpodNotifier = container.read(realRiverpodProvider.notifier);
    int riverpodFires = 0;
    final riverpodSub = container.listen(
      realRiverpodProvider,
      (_, __) => riverpodFires++,
    );

    final riverpodSw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      riverpodNotifier.increment();
    }
    riverpodSw.stop();
    final riverpodUs = riverpodSw.elapsedMicroseconds;
    riverpodSub.close();
    container.dispose();

    // -------------------------------------------------------------------------
    // 4. SIGNALS (Real controller with signals)
    // -------------------------------------------------------------------------
    final signalsCtrl = RealSignalsController();
    int signalsFires = 0;
    final disposeSignal = effect(() {
      signalsCtrl.count.value;
      signalsFires++;
    });

    final signalsSw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      signalsCtrl.increment();
    }
    signalsSw.stop();
    final signalsUs = signalsSw.elapsedMicroseconds;
    expect(signalsFires, isPositive);
    disposeSignal();

    // -------------------------------------------------------------------------
    // 5. GETX (Real controller with multiple obs fields)
    // -------------------------------------------------------------------------
    final getxCtrl = RealGetXController();
    int getxFires = 0;
    final getxWorker = getx.ever(getxCtrl.count, (_) => getxFires++);

    final getxSw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      getxCtrl.increment();
    }
    getxSw.stop();
    final getxUs = getxSw.elapsedMicroseconds;
    getxWorker.dispose();

    // -------------------------------------------------------------------------
    // PRINT RESULTS
    // -------------------------------------------------------------------------
    final results = [
      {'name': 'GetX (Controller)', 'timeUs': getxUs},
      {'name': 'BLoC (copyWith State)', 'timeUs': blocUs},
      {'name': 'Riverpod (copyWith State)', 'timeUs': riverpodUs},
      {'name': 'Graft (In-place State)', 'timeUs': graftUs},
      {'name': 'Signals (Controller)', 'timeUs': signalsUs},
    ];

    results.sort((a, b) => (a['timeUs'] as int).compareTo(b['timeUs'] as int));

    // ignore: avoid_print
    print('''
================================================================================
  REALISTIC PRODUCTION BENCHMARK: 5-FIELD DOMAIN MODEL (10,000 UPDATES)
================================================================================
  Framework                   Total Time (ms)    Per Mutation (ns)    Ops / Sec
--------------------------------------------------------------------------------''');

    for (final r in results) {
      final name = (r['name'] as String).padRight(27);
      final timeMs = ((r['timeUs'] as int) / 1000).toStringAsFixed(2).padLeft(10);
      final nsPerOp = (((r['timeUs'] as int) * 1000) / iterations).toStringAsFixed(1).padLeft(12);
      final opsPerSec = ((iterations / (r['timeUs'] as int)) * 1000000).toStringAsFixed(0).padLeft(14);
      // ignore: avoid_print
      print('  $name $timeMs ms       $nsPerOp ns    $opsPerSec ops/s');
    }

    // ignore: avoid_print
    print('================================================================================');

    expect(graft.state.count, iterations);
    expect(signalsCtrl.count.value, iterations);
  });
}
