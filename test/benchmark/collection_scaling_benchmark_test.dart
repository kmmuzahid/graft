import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// -----------------------------------------------------------------------------
// 1. GRAFT
// -----------------------------------------------------------------------------
class GraftListState extends GraftState {
  List<String> items = [];
  @override
  List<Object?> get props => [items];
}

class GraftListController extends Graft<GraftListState> {
  GraftListController() : super(GraftListState());
  void addItem(String item) {
    state
      ..items.add(item)
      ..update();
  }
}

// -----------------------------------------------------------------------------
// 2. BLOC
// -----------------------------------------------------------------------------
class BlocListCubit extends Cubit<List<String>> {
  BlocListCubit() : super([]);
  void addItem(String item) => emit([...state, item]);
}

// -----------------------------------------------------------------------------
// 3. RIVERPOD
// -----------------------------------------------------------------------------
class RiverpodListNotifier extends StateNotifier<List<String>> {
  RiverpodListNotifier() : super([]);
  void addItem(String item) => state = [...state, item];
}

final riverpodListProvider =
    StateNotifierProvider<RiverpodListNotifier, List<String>>(
  (ref) => RiverpodListNotifier(),
);

// -----------------------------------------------------------------------------
// 4. SIGNALS
// -----------------------------------------------------------------------------
// Signals uses a list inside a signal
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 5. GETX
// -----------------------------------------------------------------------------
class GetXListController extends getx.GetxController {
  final items = <String>[].obs;
  void addItem(String item) => items.add(item);
}

void main() {
  const int operations = 500;

  test('Benchmark: Collection Scaling (500 Sequential Appends to Growing List)', () {
    // -------------------------------------------------------------------------
    // 1. GRAFT
    // -------------------------------------------------------------------------
    final graft = GraftListController();
    final graftSw = Stopwatch()..start();
    for (int i = 0; i < operations; i++) {
      graft.addItem('Item $i');
    }
    graftSw.stop();
    final graftTimeUs = graftSw.elapsedMicroseconds;

    // -------------------------------------------------------------------------
    // 2. BLOC (Immutable spread [...state, item])
    // -------------------------------------------------------------------------
    final bloc = BlocListCubit();
    final blocSw = Stopwatch()..start();
    for (int i = 0; i < operations; i++) {
      bloc.addItem('Item $i');
    }
    blocSw.stop();
    final blocTimeUs = blocSw.elapsedMicroseconds;
    bloc.close();

    // -------------------------------------------------------------------------
    // 3. RIVERPOD (Immutable spread [...state, item])
    // -------------------------------------------------------------------------
    final container = ProviderContainer();
    final riverpodNotifier = container.read(riverpodListProvider.notifier);
    final riverpodSw = Stopwatch()..start();
    for (int i = 0; i < operations; i++) {
      riverpodNotifier.addItem('Item $i');
    }
    riverpodSw.stop();
    final riverpodTimeUs = riverpodSw.elapsedMicroseconds;
    container.dispose();

    // -------------------------------------------------------------------------
    // 4. SIGNALS (Signal with list copy)
    // -------------------------------------------------------------------------
    final itemsSignal = signal<List<String>>([]);
    final signalsSw = Stopwatch()..start();
    for (int i = 0; i < operations; i++) {
      itemsSignal.value = [...itemsSignal.value, 'Item $i'];
    }
    signalsSw.stop();
    final signalsTimeUs = signalsSw.elapsedMicroseconds;

    // -------------------------------------------------------------------------
    // 5. GETX (RxList in-place add)
    // -------------------------------------------------------------------------
    final getxCtrl = GetXListController();
    final getxSw = Stopwatch()..start();
    for (int i = 0; i < operations; i++) {
      getxCtrl.addItem('Item $i');
    }
    getxSw.stop();
    final getxTimeUs = getxSw.elapsedMicroseconds;

    // -------------------------------------------------------------------------
    // PRINT RESULTS
    // -------------------------------------------------------------------------
    final results = [
      {'name': 'GetX (RxList)', 'timeUs': getxTimeUs},
      {'name': 'Graft (In-place List)', 'timeUs': graftTimeUs},
      {'name': 'Signals (Spread)', 'timeUs': signalsTimeUs},
      {'name': 'Riverpod (Spread)', 'timeUs': riverpodTimeUs},
      {'name': 'BLoC (Spread)', 'timeUs': blocTimeUs},
    ];

    results.sort((a, b) => (a['timeUs'] as int).compareTo(b['timeUs'] as int));

    // ignore: avoid_print
    print('''
================================================================================
  REAL BENCHMARK: COLLECTION SCALING (500 SEQUENTIAL APPENDS)
================================================================================
  Framework                Total Time (ms)    Per Append (µs)
--------------------------------------------------------------------------------''');

    for (final r in results) {
      final name = (r['name'] as String).padRight(24);
      final timeMs = ((r['timeUs'] as int) / 1000).toStringAsFixed(2).padLeft(10);
      final usPerOp = ((r['timeUs'] as int) / operations).toStringAsFixed(1).padLeft(14);
      // ignore: avoid_print
      print('  $name $timeMs ms       $usPerOp µs');
    }

    // ignore: avoid_print
    print('================================================================================');

    expect(graft.state.items.length, operations);
    expect(itemsSignal.value.length, operations);
  });
}
