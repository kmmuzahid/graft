import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'package:flutter/foundation.dart';
import 'benchmark_models.dart';

// =============================================================================
// DOMAIN MODELS FOR SCENARIO A
// =============================================================================

// -----------------------------------------------------------------------------
// 1. Single Field Models
// -----------------------------------------------------------------------------
class GraftSingleState extends GraftState {
  int count = 0;
  @override
  List<Object?> get props => [count];
}

class GraftSingleController extends Graft<GraftSingleState> {
  GraftSingleController() : super(GraftSingleState());
  void increment() => state..count += 1..update();
}

class BlocSingleCubit extends bloc_pkg.Cubit<int> {
  BlocSingleCubit() : super(0);
  void increment() => emit(state + 1);
}

class RiverpodSingleNotifier extends riverpod_pkg.Notifier<int> {
  @override
  int build() => 0;
  void increment() => state = state + 1;
}

final riverpodSingleNotifierProvider =
    riverpod_pkg.NotifierProvider<RiverpodSingleNotifier, int>(
  RiverpodSingleNotifier.new,
);

class RiverpodSingleStateNotifier extends riverpod_pkg.StateNotifier<int> {
  RiverpodSingleStateNotifier() : super(0);
  void increment() => state = state + 1;
}

final riverpodSingleStateNotifierProvider =
    riverpod_pkg.StateNotifierProvider<RiverpodSingleStateNotifier, int>(
  (ref) => RiverpodSingleStateNotifier(),
);

class GetXSingleController extends getx.GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}

class ProviderSingleModel extends ChangeNotifier {
  int count = 0;
  void increment() {
    count++;
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// 2. 5-Field Models (Multi-Field Update)
// -----------------------------------------------------------------------------
class Graft5FieldState extends GraftState {
  int f1 = 0;
  int f2 = 0;
  int f3 = 0;
  int f4 = 0;
  int f5 = 0;

  @override
  List<Object?> get props => [f1, f2, f3, f4, f5];
}

class Graft5FieldController extends Graft<Graft5FieldState> {
  Graft5FieldController() : super(Graft5FieldState());
  void updateAll(int v) {
    state
      ..f1 = v
      ..f2 = v
      ..f3 = v
      ..f4 = v
      ..f5 = v
      ..update();
  }
}

class Immutable5FieldState {
  final int f1, f2, f3, f4, f5;
  const Immutable5FieldState({
    this.f1 = 0,
    this.f2 = 0,
    this.f3 = 0,
    this.f4 = 0,
    this.f5 = 0,
  });

  Immutable5FieldState copyWith({int? f1, int? f2, int? f3, int? f4, int? f5}) {
    return Immutable5FieldState(
      f1: f1 ?? this.f1,
      f2: f2 ?? this.f2,
      f3: f3 ?? this.f3,
      f4: f4 ?? this.f4,
      f5: f5 ?? this.f5,
    );
  }
}

class Bloc5FieldCubit extends bloc_pkg.Cubit<Immutable5FieldState> {
  Bloc5FieldCubit() : super(const Immutable5FieldState());
  void updateAll(int v) => emit(state.copyWith(f1: v, f2: v, f3: v, f4: v, f5: v));
}

class Riverpod5FieldNotifier extends riverpod_pkg.Notifier<Immutable5FieldState> {
  @override
  Immutable5FieldState build() => const Immutable5FieldState();
  void updateAll(int v) => state = state.copyWith(f1: v, f2: v, f3: v, f4: v, f5: v);
}

final riverpod5FieldNotifierProvider =
    riverpod_pkg.NotifierProvider<Riverpod5FieldNotifier, Immutable5FieldState>(
  Riverpod5FieldNotifier.new,
);

class Riverpod5FieldStateNotifier extends riverpod_pkg.StateNotifier<Immutable5FieldState> {
  Riverpod5FieldStateNotifier() : super(const Immutable5FieldState());
  void updateAll(int v) => state = state.copyWith(f1: v, f2: v, f3: v, f4: v, f5: v);
}

final riverpod5FieldStateNotifierProvider =
    riverpod_pkg.StateNotifierProvider<Riverpod5FieldStateNotifier, Immutable5FieldState>(
  (ref) => Riverpod5FieldStateNotifier(),
);

class Signals5Field {
  final f1 = signals_pkg.signal(0);
  final f2 = signals_pkg.signal(0);
  final f3 = signals_pkg.signal(0);
  final f4 = signals_pkg.signal(0);
  final f5 = signals_pkg.signal(0);

  void updateAll(int v) {
    signals_pkg.batch(() {
      f1.value = v;
      f2.value = v;
      f3.value = v;
      f4.value = v;
      f5.value = v;
    });
  }
}

class GetX5FieldController extends getx.GetxController {
  final f1 = 0.obs;
  final f2 = 0.obs;
  final f3 = 0.obs;
  final f4 = 0.obs;
  final f5 = 0.obs;

  void updateAll(int v) {
    f1.value = v;
    f2.value = v;
    f3.value = v;
    f4.value = v;
    f5.value = v;
  }
}

class Provider5FieldModel extends ChangeNotifier {
  int f1 = 0, f2 = 0, f3 = 0, f4 = 0, f5 = 0;
  void updateAll(int v) {
    f1 = v;
    f2 = v;
    f3 = v;
    f4 = v;
    f5 = v;
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// 3. Depth-8 Nested Models
// -----------------------------------------------------------------------------
// Graft Depth-8:
class GraftNode8 extends GraftState {
  int value = 0;
  @override
  List<Object?> get props => [value];
}

class GraftNode7 extends GraftState {
  final child = GraftNode8();
  @override
  List<Object?> get props => [child];
}

class GraftNode6 extends GraftState {
  final child = GraftNode7();
  @override
  List<Object?> get props => [child];
}

class GraftNode5 extends GraftState {
  final child = GraftNode6();
  @override
  List<Object?> get props => [child];
}

class GraftNode4 extends GraftState {
  final child = GraftNode5();
  @override
  List<Object?> get props => [child];
}

class GraftNode3 extends GraftState {
  final child = GraftNode4();
  @override
  List<Object?> get props => [child];
}

class GraftNode2 extends GraftState {
  final child = GraftNode3();
  @override
  List<Object?> get props => [child];
}

class GraftNode1 extends GraftState {
  final child = GraftNode2();
  @override
  List<Object?> get props => [child];
}

class GraftNestedDepth8Controller extends Graft<GraftNode1> {
  GraftNestedDepth8Controller() : super(GraftNode1());

  void updateLeaf(int v) {
    state.child.child.child.child.child.child.child.value = v;
    state.update();
  }
}

// Immutable Depth-8:
class ImmutableNode8 {
  final int value;
  const ImmutableNode8(this.value);
  ImmutableNode8 copyWith({int? value}) => ImmutableNode8(value ?? this.value);
}

class ImmutableNode7 {
  final ImmutableNode8 child;
  const ImmutableNode7(this.child);
  ImmutableNode7 copyWith({ImmutableNode8? child}) => ImmutableNode7(child ?? this.child);
}

class ImmutableNode6 {
  final ImmutableNode7 child;
  const ImmutableNode6(this.child);
  ImmutableNode6 copyWith({ImmutableNode7? child}) => ImmutableNode6(child ?? this.child);
}

class ImmutableNode5 {
  final ImmutableNode6 child;
  const ImmutableNode5(this.child);
  ImmutableNode5 copyWith({ImmutableNode6? child}) => ImmutableNode5(child ?? this.child);
}

class ImmutableNode4 {
  final ImmutableNode5 child;
  const ImmutableNode4(this.child);
  ImmutableNode4 copyWith({ImmutableNode5? child}) => ImmutableNode4(child ?? this.child);
}

class ImmutableNode3 {
  final ImmutableNode4 child;
  const ImmutableNode3(this.child);
  ImmutableNode3 copyWith({ImmutableNode4? child}) => ImmutableNode3(child ?? this.child);
}

class ImmutableNode2 {
  final ImmutableNode3 child;
  const ImmutableNode2(this.child);
  ImmutableNode2 copyWith({ImmutableNode3? child}) => ImmutableNode2(child ?? this.child);
}

class ImmutableNode1 {
  final ImmutableNode2 child;
  const ImmutableNode1(this.child);
  ImmutableNode1 copyWith({ImmutableNode2? child}) => ImmutableNode1(child ?? this.child);

  static ImmutableNode1 initial() => const ImmutableNode1(
        ImmutableNode2(ImmutableNode3(ImmutableNode4(
            ImmutableNode5(ImmutableNode6(ImmutableNode7(ImmutableNode8(0))))))),
      );

  ImmutableNode1 updateLeaf(int v) {
    return copyWith(
      child: child.copyWith(
        child: child.child.copyWith(
          child: child.child.child.copyWith(
            child: child.child.child.child.copyWith(
              child: child.child.child.child.child.copyWith(
                child: child.child.child.child.child.child.copyWith(
                  child: child.child.child.child.child.child.child.copyWith(value: v),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlocNestedCubit extends bloc_pkg.Cubit<ImmutableNode1> {
  BlocNestedCubit() : super(ImmutableNode1.initial());
  void updateLeaf(int v) => emit(state.updateLeaf(v));
}

class RiverpodNestedNotifier extends riverpod_pkg.Notifier<ImmutableNode1> {
  @override
  ImmutableNode1 build() => ImmutableNode1.initial();
  void updateLeaf(int v) => state = state.updateLeaf(v);
}

final riverpodNestedNotifierProvider =
    riverpod_pkg.NotifierProvider<RiverpodNestedNotifier, ImmutableNode1>(
  RiverpodNestedNotifier.new,
);

class RiverpodNestedStateNotifier extends riverpod_pkg.StateNotifier<ImmutableNode1> {
  RiverpodNestedStateNotifier() : super(ImmutableNode1.initial());
  void updateLeaf(int v) => state = state.updateLeaf(v);
}

final riverpodNestedStateNotifierProvider =
    riverpod_pkg.StateNotifierProvider<RiverpodNestedStateNotifier, ImmutableNode1>(
  (ref) => RiverpodNestedStateNotifier(),
);

class SignalsDepth8 {
  final leaf = signals_pkg.signal(0);
  void updateLeaf(int v) => leaf.value = v;
}

class GetXDepth8Controller extends getx.GetxController {
  final leaf = 0.obs;
  void updateLeaf(int v) => leaf.value = v;
}

class ProviderDepth8Model extends ChangeNotifier {
  final root = GraftNode1();
  void updateLeaf(int v) {
    root.child.child.child.child.child.child.child.value = v;
    notifyListeners();
  }
}

// =============================================================================
// SCENARIO A RUNNER
// =============================================================================
class ScenarioAMicroMutationRunner {
  static const int warmUpRuns = 3;
  static const int measuredRuns = 15;

  static List<BenchmarkStats> runAll() {
    final statsList = <BenchmarkStats>[];

    // A1: 10,000 Synchronous Increments
    statsList.addAll(runSingleIncrement(iterations: 10000, scenarioName: 'A1_10k_increments'));

    // A2: 100,000 Synchronous Increments
    statsList.addAll(runSingleIncrement(iterations: 100000, scenarioName: 'A2_100k_increments'));

    // A3: Multi-field update (5 fields at once, 10,000 updates)
    statsList.addAll(run5FieldUpdate(iterations: 10000, scenarioName: 'A3_multi_field_5'));

    // A4: Deep nested state (depth 8, 1,000 leaf updates with diffing)
    statsList.addAll(runDepth8Nested(iterations: 1000, scenarioName: 'A4_depth8_nested'));

    return statsList;
  }

  // ---------------------------------------------------------------------------
  // A1 & A2: Single Field Increments
  // ---------------------------------------------------------------------------
  static List<BenchmarkStats> runSingleIncrement({
    required int iterations,
    required String scenarioName,
  }) {
    final results = <BenchmarkStats>[];

    // 1. Graft
    {
      for (int w = 0; w < warmUpRuns; w++) {
        final ctrl = GraftSingleController();
        for (int i = 0; i < iterations ~/ 10; i++) ctrl.increment();
      }
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GraftSingleController();
        int fires = 0;
        ctrl.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        expect(ctrl.state.count, iterations);
        expect(fires, iterations);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'In-place state mutation (Zero-GC)',
      ));
    }

    // 2. Riverpod (Notifier - Codegen style)
    {
      for (int w = 0; w < warmUpRuns; w++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpodSingleNotifierProvider.notifier);
        for (int i = 0; i < iterations ~/ 10; i++) n.increment();
        container.dispose();
      }
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpodSingleNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpodSingleNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Class-based Notifier architecture',
      ));
    }

    // 3. Riverpod (StateNotifier - without codegen)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpodSingleStateNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpodSingleStateNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (StateNotifier)',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'StateNotifier legacy architecture',
      ));
    }

    // 4. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = BlocSingleCubit();
        int fires = 0;
        final sub = cubit.stream.listen((_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) cubit.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.cancel();
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'StreamController async microtask dispatch',
      ));
    }

    // 5. Signals
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final s = signals_pkg.signal(0);
        int fires = 0;
        final disposeEffect = signals_pkg.effect(() {
          s.value;
          fires++;
        });
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) s.value++;
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        expect(fires, greaterThan(0));
        disposeEffect();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Fine-grained signal graph',
      ));
    }

    // 6. GetX
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GetXSingleController();
        int fires = 0;
        final worker = getx.ever(ctrl.count, (_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        worker.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'RxInt observer with worker',
      ));
    }

    // 7. Provider (ChangeNotifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final model = ProviderSingleModel();
        int fires = 0;
        model.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) model.increment();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        model.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Classical ChangeNotifier listener invocation',
      ));
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // A3: Multi-Field Update (5 Fields at once)
  // ---------------------------------------------------------------------------
  static List<BenchmarkStats> run5FieldUpdate({
    required int iterations,
    required String scenarioName,
  }) {
    final results = <BenchmarkStats>[];

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = Graft5FieldController();
        int fires = 0;
        ctrl.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: '1 dirty bitmask, 0 state allocations',
      ));
    }

    // 2. Riverpod (Notifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpod5FieldNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpod5FieldNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        allocatedObjects: iterations,
        notes: 'Immutable copyWith ($iterations allocations)',
      ));
    }

    // 3. Riverpod (StateNotifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpod5FieldStateNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpod5FieldStateNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (StateNotifier)',
        samplesMs: samples,
        allocatedObjects: iterations,
        notes: 'Immutable copyWith ($iterations allocations)',
      ));
    }

    // 4. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = Bloc5FieldCubit();
        int fires = 0;
        final sub = cubit.stream.listen((_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) cubit.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.cancel();
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        allocatedObjects: iterations,
        notes: 'Immutable copyWith ($iterations allocations)',
      ));
    }

    // 5. Signals
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final sig = Signals5Field();
        int fires = 0;
        final disposeEffect = signals_pkg.effect(() {
          sig.f1.value;
          sig.f2.value;
          sig.f3.value;
          sig.f4.value;
          sig.f5.value;
          fires++;
        });
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) sig.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        expect(fires, greaterThan(0));
        disposeEffect();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'batch() evaluation of 5 signals',
      ));
    }

    // 6. GetX
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GetX5FieldController();
        int fires = 0;
        final worker = getx.ever(ctrl.f1, (_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        worker.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: '5 individual Rx reactive updates',
      ));
    }

    // 7. Provider
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final model = Provider5FieldModel();
        int fires = 0;
        model.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) model.updateAll(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        model.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'In-place fields + notifyListeners()',
      ));
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // A4: Deep Nested State (Depth 8)
  // ---------------------------------------------------------------------------
  static List<BenchmarkStats> runDepth8Nested({
    required int iterations,
    required String scenarioName,
  }) {
    final results = <BenchmarkStats>[];

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GraftNestedDepth8Controller();
        int fires = 0;
        ctrl.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Cascade leaf mutation (0 copyWith objects)',
      ));
    }

    // 2. Riverpod (Notifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpodNestedNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpodNestedNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        allocatedObjects: iterations * 8,
        notes: 'Depth-8 copyWith (${iterations * 8} allocations)',
      ));
    }

    // 3. Riverpod (StateNotifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final n = container.read(riverpodNestedStateNotifierProvider.notifier);
        int fires = 0;
        final sub = container.listen(riverpodNestedStateNotifierProvider, (_, __) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) n.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.close();
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (StateNotifier)',
        samplesMs: samples,
        allocatedObjects: iterations * 8,
        notes: 'Depth-8 copyWith (${iterations * 8} allocations)',
      ));
    }

    // 4. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = BlocNestedCubit();
        int fires = 0;
        final sub = cubit.stream.listen((_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) cubit.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        sub.cancel();
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        allocatedObjects: iterations * 8,
        notes: 'Depth-8 copyWith (${iterations * 8} allocations)',
      ));
    }

    // 5. Signals
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final sig = SignalsDepth8();
        int fires = 0;
        final disposeEffect = signals_pkg.effect(() {
          sig.leaf.value;
          fires++;
        });
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) sig.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        expect(fires, greaterThan(0));
        disposeEffect();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Direct leaf signal update',
      ));
    }

    // 6. GetX
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GetXDepth8Controller();
        int fires = 0;
        final worker = getx.ever(ctrl.leaf, (_) => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) ctrl.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        worker.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'Direct leaf Rx update',
      ));
    }

    // 7. Provider
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final model = ProviderDepth8Model();
        int fires = 0;
        model.addListener(() => fires++);
        final sw = Stopwatch()..start();
        for (int i = 0; i < iterations; i++) model.updateLeaf(i);
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        model.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        allocatedObjects: 0,
        notes: 'In-place leaf mutate + notifyListeners()',
      ));
    }

    return results;
  }
}
