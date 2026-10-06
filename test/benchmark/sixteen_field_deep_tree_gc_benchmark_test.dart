import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:get/get.dart' as getx;

// Tracking widget to monitor build counts per slot
class TrackedSlotWidget extends StatelessWidget implements GraftEquivalent {
  final String label;
  final VoidCallback onBuild;

  const TrackedSlotWidget({
    super.key,
    required this.label,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! TrackedSlotWidget) return false;
    return label == other.label;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(label);
  }
}

// =============================================================================
// 16-FIELD PRODUCTION STATE MODEL (< 64 fields, 100% inlined register bitmask)
// =============================================================================

// 1. GRAFT (In-place cascade mutation, 0 new state allocations)
class State16Graft extends GraftState {
  int id = 1;
  String name = 'Alice';
  String email = 'alice@example.com';
  double balance = 5000.0; // Field 3: dynamic target
  bool isVip = true;
  int tier = 3;
  double score = 98.5;
  int unreadCount = 4;
  String lastLogin = '2026-10-06';
  String theme = 'dark';
  String locale = 'en_US';
  int rank = 12;
  int points = 850;
  bool isActive = true;
  double progress = 0.75;
  int level = 5;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        balance,
        isVip,
        tier,
        score,
        unreadCount,
        lastLogin,
        theme,
        locale,
        rank,
        points,
        isActive,
        progress,
        level,
      ];
}

class Controller16Graft extends Graft<State16Graft> {
  Controller16Graft() : super(State16Graft());
  void incrementBalance() => state..balance += 1.0..update();
}

// 2. BLOC (Immutable copyWith model)
class State16Bloc {
  final int id;
  final String name;
  final String email;
  final double balance;
  final bool isVip;
  final int tier;
  final double score;
  final int unreadCount;
  final String lastLogin;
  final String theme;
  final String locale;
  final int rank;
  final int points;
  final bool isActive;
  final double progress;
  final int level;

  const State16Bloc({
    this.id = 1,
    this.name = 'Alice',
    this.email = 'alice@example.com',
    this.balance = 5000.0,
    this.isVip = true,
    this.tier = 3,
    this.score = 98.5,
    this.unreadCount = 4,
    this.lastLogin = '2026-10-06',
    this.theme = 'dark',
    this.locale = 'en_US',
    this.rank = 12,
    this.points = 850,
    this.isActive = true,
    this.progress = 0.75,
    this.level = 5,
  });

  State16Bloc copyWith({double? balance}) => State16Bloc(
        id: id,
        name: name,
        email: email,
        balance: balance ?? this.balance,
        isVip: isVip,
        tier: tier,
        score: score,
        unreadCount: unreadCount,
        lastLogin: lastLogin,
        theme: theme,
        locale: locale,
        rank: rank,
        points: points,
        isActive: isActive,
        progress: progress,
        level: level,
      );
}

class Cubit16Bloc extends Cubit<State16Bloc> {
  Cubit16Bloc() : super(const State16Bloc());
  void incrementBalance() => emit(state.copyWith(balance: state.balance + 1.0));
}

// 3. RIVERPOD (Immutable StateNotifier with copyWith)
class Notifier16Riverpod extends StateNotifier<State16Bloc> {
  Notifier16Riverpod() : super(const State16Bloc());
  void incrementBalance() => state = state.copyWith(balance: state.balance + 1.0);
}

final provider16Riverpod =
    StateNotifierProvider<Notifier16Riverpod, State16Bloc>(
        (ref) => Notifier16Riverpod());

// 4. GETX (16 individual observable fields)
class Controller16GetX extends getx.GetxController {
  final id = 1.obs;
  final name = 'Alice'.obs;
  final email = 'alice@example.com'.obs;
  final balance = 5000.0.obs;
  final isVip = true.obs;
  final tier = 3.obs;
  final score = 98.5.obs;
  final unreadCount = 4.obs;
  final lastLogin = '2026-10-06'.obs;
  final theme = 'dark'.obs;
  final locale = 'en_US'.obs;
  final rank = 12.obs;
  final points = 850.obs;
  final isActive = true.obs;
  final progress = 0.75.obs;
  final level = 5.obs;

  void incrementBalance() => balance.value += 1.0;
}

// 5. SIGNALS (16 individual signal primitives)
class Controller16Signals {
  final id = signal(1);
  final name = signal('Alice');
  final email = signal('alice@example.com');
  final balance = signal(5000.0);
  final isVip = signal(true);
  final tier = signal(3);
  final score = signal(98.5);
  final unreadCount = signal(4);
  final lastLogin = signal('2026-10-06');
  final theme = signal('dark');
  final locale = signal('en_US');
  final rank = signal(12);
  final points = signal(850);
  final isActive = signal(true);
  final progress = signal(0.75);
  final level = signal(5);

  void incrementBalance() => balance.value += 1.0;
}

void main() {
  group('16-Field Enterprise State Benchmarks (< 64-field hardware register path)', () {
    const int mutationIterations = 20000;

    test('Benchmark A: 20,000 High-Frequency Mutations & Heap Churn Comparison', () {
      // 1. GRAFT: In-place state, zero state allocations
      final graft = Controller16Graft();
      int graftFires = 0;
      graft.addListener(() => graftFires++);

      final graftSw = Stopwatch()..start();
      for (int i = 0; i < mutationIterations; i++) {
        graft.incrementBalance();
      }
      graftSw.stop();
      final graftUs = graftSw.elapsedMicroseconds;

      // 2. BLOC: Allocates 20,000 new State16Bloc objects on heap
      final bloc = Cubit16Bloc();
      int blocFires = 0;
      final blocSub = bloc.stream.listen((_) => blocFires++);

      final blocSw = Stopwatch()..start();
      for (int i = 0; i < mutationIterations; i++) {
        bloc.incrementBalance();
      }
      blocSw.stop();
      final blocUs = blocSw.elapsedMicroseconds;
      blocSub.cancel();

      // 3. RIVERPOD: Allocates 20,000 new State16Bloc objects on heap
      final container = ProviderContainer();
      final riverpodNotifier = container.read(provider16Riverpod.notifier);
      int riverpodFires = 0;
      final riverpodSub = container.listen(
        provider16Riverpod,
        (_, __) => riverpodFires++,
      );

      final riverpodSw = Stopwatch()..start();
      for (int i = 0; i < mutationIterations; i++) {
        riverpodNotifier.incrementBalance();
      }
      riverpodSw.stop();
      final riverpodUs = riverpodSw.elapsedMicroseconds;
      riverpodSub.close();
      container.dispose();

      // 4. SIGNALS: 16 individual signals
      final signals = Controller16Signals();
      int signalsFires = 0;
      final disposeEffect = effect(() {
        signals.balance.value;
        signalsFires++;
      });

      final signalsSw = Stopwatch()..start();
      for (int i = 0; i < mutationIterations; i++) {
        signals.incrementBalance();
      }
      signalsSw.stop();
      final signalsUs = signalsSw.elapsedMicroseconds;
      expect(signalsFires, isPositive);
      disposeEffect();

      // 5. GETX: 16 individual obs
      final getxCtrl = Controller16GetX();
      int getxFires = 0;
      final getxWorker = getx.ever(getxCtrl.balance, (_) => getxFires++);

      final getxSw = Stopwatch()..start();
      for (int i = 0; i < mutationIterations; i++) {
        getxCtrl.incrementBalance();
      }
      getxSw.stop();
      final getxUs = getxSw.elapsedMicroseconds;
      getxWorker.dispose();

      // ignore: avoid_print
      print('''
================================================================================
  BENCHMARK A: 20,000 HIGH-FREQUENCY MUTATIONS (16-FIELD DOMAIN STATE)
================================================================================
  Framework             Total Time (ms)  Per Mutation (ns)  State Heap Allocations
--------------------------------------------------------------------------------
  GetX (16 obs)           ${(getxUs / 1000.0).toStringAsFixed(2).padLeft(8)} ms  ${(getxUs * 1000.0 / mutationIterations).toStringAsFixed(1).padLeft(12)} ns             0
  Graft (16-field in-place)${(graftUs / 1000.0).toStringAsFixed(2).padLeft(7)} ms  ${(graftUs * 1000.0 / mutationIterations).toStringAsFixed(1).padLeft(12)} ns             0 (ZERO GC) ⚡
  BLoC (16-field copyWith)${(blocUs / 1000.0).toStringAsFixed(2).padLeft(8)} ms  ${(blocUs * 1000.0 / mutationIterations).toStringAsFixed(1).padLeft(12)} ns        20,000 State Objects
  Riverpod (16-field copy)${(riverpodUs / 1000.0).toStringAsFixed(2).padLeft(8)} ms  ${(riverpodUs * 1000.0 / mutationIterations).toStringAsFixed(1).padLeft(12)} ns        20,000 State Objects
  Signals (16 signals)    ${(signalsUs / 1000.0).toStringAsFixed(2).padLeft(8)} ms  ${(signalsUs * 1000.0 / mutationIterations).toStringAsFixed(1).padLeft(12)} ns             0
================================================================================''');

      expect(graft.state.balance, 5000.0 + mutationIterations);
    });

    testWidgets(
        'Benchmark B: 16-Widget Screen Layout Rebuild Precision (Mutating 1 of 16 fields)',
        (WidgetTester tester) async {
      const int frames = 60;
      final results = <Map<String, dynamic>>[];

      // -----------------------------------------------------------------------
      // GRAFT (Single slot precision)
      // -----------------------------------------------------------------------
      {
        final graft = Controller16Graft();
        int dynamicBuilds = 0;
        final staticBuilds = List.filled(15, 0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  graft((s) => TrackedSlotWidget(
                        label: 'Balance: ${s.balance}',
                        onBuild: () => dynamicBuilds++,
                      )),
                  for (int i = 0; i < 15; i++)
                    TrackedSlotWidget(
                      label: 'Static Field $i',
                      onBuild: () => staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        dynamicBuilds = 0;
        for (int i = 0; i < 15; i++) staticBuilds[i] = 0;

        final sw = Stopwatch()..start();
        for (int f = 0; f < frames; f++) {
          graft.incrementBalance();
          await tester.pump();
        }
        sw.stop();

        final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
        results.add({
          'name': 'Graft (single slot)',
          'timeUs': sw.elapsedMicroseconds,
          'dynamic': dynamicBuilds,
          'static': totalStatic,
        });
        graft.dispose();
      }

      // -----------------------------------------------------------------------
      // SIGNALS (Watch on balance)
      // -----------------------------------------------------------------------
      {
        final signals = Controller16Signals();
        int dynamicBuilds = 0;
        final staticBuilds = List.filled(15, 0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Watch((context) => TrackedSlotWidget(
                        label: 'Balance: ${signals.balance.value}',
                        onBuild: () => dynamicBuilds++,
                      )),
                  for (int i = 0; i < 15; i++)
                    TrackedSlotWidget(
                      label: 'Static Field $i',
                      onBuild: () => staticBuilds[i]++,
                    ),
                ],
              ),
            ),
          ),
        );

        dynamicBuilds = 0;
        for (int i = 0; i < 15; i++) staticBuilds[i] = 0;

        final sw = Stopwatch()..start();
        for (int f = 0; f < frames; f++) {
          signals.incrementBalance();
          await tester.pump();
        }
        sw.stop();

        final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
        results.add({
          'name': 'Signals (Watch)',
          'timeUs': sw.elapsedMicroseconds,
          'dynamic': dynamicBuilds,
          'static': totalStatic,
        });
      }

      // -----------------------------------------------------------------------
      // RIVERPOD (Consumer on balance)
      // -----------------------------------------------------------------------
      {
        final container = ProviderContainer();
        int dynamicBuilds = 0;
        final staticBuilds = List.filled(15, 0);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Consumer(builder: (context, ref, _) {
                      final balance = ref.watch(
                          provider16Riverpod.select((s) => s.balance));
                      return TrackedSlotWidget(
                        label: 'Balance: $balance',
                        onBuild: () => dynamicBuilds++,
                      );
                    }),
                    for (int i = 0; i < 15; i++)
                      TrackedSlotWidget(
                        label: 'Static Field $i',
                        onBuild: () => staticBuilds[i]++,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        dynamicBuilds = 0;
        for (int i = 0; i < 15; i++) staticBuilds[i] = 0;

        final sw = Stopwatch()..start();
        for (int f = 0; f < frames; f++) {
          container.read(provider16Riverpod.notifier).incrementBalance();
          await tester.pump();
        }
        sw.stop();

        final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
        results.add({
          'name': 'Riverpod (select)',
          'timeUs': sw.elapsedMicroseconds,
          'dynamic': dynamicBuilds,
          'static': totalStatic,
        });
        container.dispose();
      }

      // -----------------------------------------------------------------------
      // BLOC (BlocSelector on balance)
      // -----------------------------------------------------------------------
      {
        final cubit = Cubit16Bloc();
        int dynamicBuilds = 0;
        final staticBuilds = List.filled(15, 0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: Column(
                  children: [
                    BlocSelector<Cubit16Bloc, State16Bloc, double>(
                      selector: (state) => state.balance,
                      builder: (context, balance) => TrackedSlotWidget(
                        label: 'Balance: $balance',
                        onBuild: () => dynamicBuilds++,
                      ),
                    ),
                    for (int i = 0; i < 15; i++)
                      TrackedSlotWidget(
                        label: 'Static Field $i',
                        onBuild: () => staticBuilds[i]++,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        dynamicBuilds = 0;
        for (int i = 0; i < 15; i++) staticBuilds[i] = 0;

        final sw = Stopwatch()..start();
        for (int f = 0; f < frames; f++) {
          cubit.incrementBalance();
          await tester.pump(Duration.zero);
        }
        sw.stop();

        final totalStatic = staticBuilds.fold(0, (sum, c) => sum + c);
        results.add({
          'name': 'BLoC (BlocSelector)',
          'timeUs': sw.elapsedMicroseconds,
          'dynamic': dynamicBuilds,
          'static': totalStatic,
        });
        cubit.close();
      }

      results.sort((a, b) => (a['timeUs'] as int).compareTo(b['timeUs'] as int));

      // ignore: avoid_print
      print('''
================================================================================
  BENCHMARK B: 16-WIDGET SCREEN LAYOUT REBUILD BENCHMARK (60 FRAMES)
  (1 Dynamic Field Widget + 15 Static Field Widgets in Column)
================================================================================
  Framework                 Pipeline Time (ms)  Target Builds  Static Builds
--------------------------------------------------------------------------------''');

      for (final r in results) {
        final name = (r['name'] as String).padRight(25);
        final timeMs = ((r['timeUs'] as int) / 1000).toStringAsFixed(2).padLeft(12);
        final target = '${r['dynamic']}'.padLeft(14);
        final staticB = '${r['static']} (0% leak)'.padLeft(14);
        // ignore: avoid_print
        print('  $name $timeMs ms $target $staticB');
      }

      // ignore: avoid_print
      print('================================================================================');

      for (final r in results) {
        expect(r['static'], 0);
        expect(r['dynamic'], frames);
      }
    });
  });
}
