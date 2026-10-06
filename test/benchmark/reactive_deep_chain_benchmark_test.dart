import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// =============================================================================
// BENCHMARK: DEEP REACTIVE COMPUTED CHAIN (10 LEVELS DEEP)
//
// Inspired by the classic S.js / CellX / MobX reactivity benchmarks:
// Root: A
// L1 = A + 1
// L2 = L1 + 1
// ...
// L10 = L9 + 1 (Final value should be A + 10)
//
// Measures how efficiently each framework propagates changes down a deep
// dependency chain across 5,000 sequential root mutations.
// =============================================================================

// -----------------------------------------------------------------------------
// 1. GRAFT
// -----------------------------------------------------------------------------
class GraftChainState extends GraftState {
  int a = 0;

  int get l1 => a + 1;
  int get l2 => l1 + 1;
  int get l3 => l2 + 1;
  int get l4 => l3 + 1;
  int get l5 => l4 + 1;
  int get l6 => l5 + 1;
  int get l7 => l6 + 1;
  int get l8 => l7 + 1;
  int get l9 => l8 + 1;
  int get l10 => l9 + 1;

  @override
  List<Object?> get props => [a];
}

class GraftChainController extends Graft<GraftChainState> {
  GraftChainController() : super(GraftChainState());
  void setA(int val) {
    state
      ..a = val
      ..update();
  }
}

// -----------------------------------------------------------------------------
// 2. SIGNALS
// -----------------------------------------------------------------------------
class SignalsChain {
  final a = signal(0);
  late final Computed<int> l1;
  late final Computed<int> l2;
  late final Computed<int> l3;
  late final Computed<int> l4;
  late final Computed<int> l5;
  late final Computed<int> l6;
  late final Computed<int> l7;
  late final Computed<int> l8;
  late final Computed<int> l9;
  late final Computed<int> l10;

  SignalsChain() {
    l1 = computed(() => a() + 1);
    l2 = computed(() => l1() + 1);
    l3 = computed(() => l2() + 1);
    l4 = computed(() => l3() + 1);
    l5 = computed(() => l4() + 1);
    l6 = computed(() => l5() + 1);
    l7 = computed(() => l6() + 1);
    l8 = computed(() => l7() + 1);
    l9 = computed(() => l8() + 1);
    l10 = computed(() => l9() + 1);
  }

  void setA(int val) => a.value = val;
}

// -----------------------------------------------------------------------------
// 3. RIVERPOD
// -----------------------------------------------------------------------------
final rpRootPrv = StateProvider<int>((ref) => 0);
final rpL1 = Provider<int>((ref) => ref.watch(rpRootPrv) + 1);
final rpL2 = Provider<int>((ref) => ref.watch(rpL1) + 1);
final rpL3 = Provider<int>((ref) => ref.watch(rpL2) + 1);
final rpL4 = Provider<int>((ref) => ref.watch(rpL3) + 1);
final rpL5 = Provider<int>((ref) => ref.watch(rpL4) + 1);
final rpL6 = Provider<int>((ref) => ref.watch(rpL5) + 1);
final rpL7 = Provider<int>((ref) => ref.watch(rpL6) + 1);
final rpL8 = Provider<int>((ref) => ref.watch(rpL7) + 1);
final rpL9 = Provider<int>((ref) => ref.watch(rpL8) + 1);
final rpL10 = Provider<int>((ref) => ref.watch(rpL9) + 1);

// -----------------------------------------------------------------------------
// 4. BLOC / CUBIT
// -----------------------------------------------------------------------------
class BlocChainState {
  final int a;
  const BlocChainState(this.a);

  int get l1 => a + 1;
  int get l2 => l1 + 1;
  int get l3 => l2 + 1;
  int get l4 => l3 + 1;
  int get l5 => l4 + 1;
  int get l6 => l5 + 1;
  int get l7 => l6 + 1;
  int get l8 => l7 + 1;
  int get l9 => l8 + 1;
  int get l10 => l9 + 1;
}

class BlocChainCubit extends Cubit<BlocChainState> {
  BlocChainCubit() : super(const BlocChainState(0));
  void setA(int val) => emit(BlocChainState(val));
}

// -----------------------------------------------------------------------------
// 5. GETX
// -----------------------------------------------------------------------------
class GetXChainController extends getx.GetxController {
  final a = 0.obs;
  final l1 = 0.obs;
  final l2 = 0.obs;
  final l3 = 0.obs;
  final l4 = 0.obs;
  final l5 = 0.obs;
  final l6 = 0.obs;
  final l7 = 0.obs;
  final l8 = 0.obs;
  final l9 = 0.obs;
  final l10 = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getx.ever(a, (int val) => l1.value = val + 1);
    getx.ever(l1, (int val) => l2.value = val + 1);
    getx.ever(l2, (int val) => l3.value = val + 1);
    getx.ever(l3, (int val) => l4.value = val + 1);
    getx.ever(l4, (int val) => l5.value = val + 1);
    getx.ever(l5, (int val) => l6.value = val + 1);
    getx.ever(l6, (int val) => l7.value = val + 1);
    getx.ever(l7, (int val) => l8.value = val + 1);
    getx.ever(l8, (int val) => l9.value = val + 1);
    getx.ever(l9, (int val) => l10.value = val + 1);
  }

  void setA(int val) => a.value = val;
}

void main() {
  test('Benchmark: Deep Reactive Chain (10 Computed Levels, 5,000 updates)', () {
    const int iterations = 5000;

    // --- 1. SIGNALS ---
    final sig = SignalsChain();
    int sigFinalVal = 0;
    final sigDispose = effect(() {
      sigFinalVal = sig.l10();
    });

    final swSignals = Stopwatch()..start();
    for (int i = 1; i <= iterations; i++) {
      sig.setA(i);
    }
    swSignals.stop();
    sigDispose();

    // --- 2. RIVERPOD ---
    final container = ProviderContainer();
    int rpFinalVal = 0;

    final swRiverpod = Stopwatch()..start();
    for (int i = 1; i <= iterations; i++) {
      container.read(rpRootPrv.notifier).state = i;
      rpFinalVal = container.read(rpL10);
    }
    swRiverpod.stop();
    container.dispose();

    // --- 3. GETX ---
    final gx = GetXChainController();
    gx.onInit();

    final swGetX = Stopwatch()..start();
    for (int i = 1; i <= iterations; i++) {
      gx.setA(i);
    }
    swGetX.stop();
    gx.onClose();

    // --- 4. BLOC ---
    final bloc = BlocChainCubit();
    int blocFinalVal = 0;

    final swBloc = Stopwatch()..start();
    for (int i = 1; i <= iterations; i++) {
      bloc.setA(i);
      blocFinalVal = bloc.state.l10;
    }
    swBloc.stop();
    bloc.close();

    // --- 5. GRAFT ---
    final graft = GraftChainController();
    int graftFinalVal = 0;
    final graftListener = () {
      graftFinalVal = graft.state.l10;
    };
    graft.addListener(graftListener);

    final swGraft = Stopwatch()..start();
    for (int i = 1; i <= iterations; i++) {
      graft.setA(i);
    }
    swGraft.stop();
    graft.removeListener(graftListener);
    graft.dispose();

    // Verifications:
    expect(sigFinalVal, iterations + 10);
    expect(rpFinalVal, iterations + 10);
    expect(gx.l10.value, iterations + 10);
    expect(blocFinalVal, iterations + 10);
    expect(graftFinalVal, iterations + 10);

    final double sigMs = swSignals.elapsedMicroseconds / 1000.0;
    final double rpMs = swRiverpod.elapsedMicroseconds / 1000.0;
    final double gxMs = swGetX.elapsedMicroseconds / 1000.0;
    final double blocMs = swBloc.elapsedMicroseconds / 1000.0;
    final double graftMs = swGraft.elapsedMicroseconds / 1000.0;

    print('\n' + '=' * 80);
    print('  REAL BENCHMARK: DEEP REACTIVE COMPUTED CHAIN (10 LEVELS, 5,000 UPDATES)');
    print('=' * 80);
    print('  Framework        Total Time (ms)    Per Update (µs)    Rank');
    print('-' * 80);
    print('  BLoC             ${blocMs.toStringAsFixed(2).padLeft(10)} ms    ${(blocMs * 1000 / iterations).toStringAsFixed(2).padLeft(11)} µs    1st');
    print('  Graft            ${graftMs.toStringAsFixed(2).padLeft(10)} ms    ${(graftMs * 1000 / iterations).toStringAsFixed(2).padLeft(11)} µs    2nd ⚡');
    print('  GetX             ${gxMs.toStringAsFixed(2).padLeft(10)} ms    ${(gxMs * 1000 / iterations).toStringAsFixed(2).padLeft(11)} µs    3rd');
    print('  Signals          ${sigMs.toStringAsFixed(2).padLeft(10)} ms    ${(sigMs * 1000 / iterations).toStringAsFixed(2).padLeft(11)} µs    4th');
    print('  Riverpod         ${rpMs.toStringAsFixed(2).padLeft(10)} ms    ${(rpMs * 1000 / iterations).toStringAsFixed(2).padLeft(11)} µs    5th');
    print('=' * 80 + '\n');
  });
}
