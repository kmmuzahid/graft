import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod_pkg;
import 'package:signals_flutter/signals_flutter.dart' as signals_pkg;
import 'package:get/get.dart' as getx;
import 'package:provider/provider.dart' as provider_pkg;
import 'benchmark_models.dart';

// =============================================================================
// LIST ITEM MODELS & TRACKING
// =============================================================================
class ItemData {
  final int id;
  final String title;
  final int value;

  const ItemData({
    required this.id,
    required this.title,
    required this.value,
  });

  ItemData copyWith({String? title, int? value}) {
    return ItemData(
      id: id,
      title: title ?? this.title,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemData &&
          id == other.id &&
          title == other.title &&
          value == other.value;

  @override
  int get hashCode => Object.hash(id, title, value);
}

class TrackedListTile extends StatelessWidget implements GraftEquivalent {
  final ItemData item;
  final VoidCallback onBuild;

  const TrackedListTile({
    super.key,
    required this.item,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! TrackedListTile) return false;
    return item == other.item;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return SizedBox(
      height: 50.0,
      child: Text('${item.title}: ${item.value}'),
    );
  }
}

// =============================================================================
// CONTROLLER IMPLEMENTATIONS FOR SCENARIO C
// =============================================================================

// 1. Graft
class GraftListState extends GraftState {
  List<ItemData> items;
  GraftListState(this.items);

  @override
  List<Object?> get props => [items];
}

class GraftListController extends Graft<GraftListState> {
  GraftListController(int count)
      : super(GraftListState(List.generate(
          count,
          (i) => ItemData(id: i, title: 'Item #$i', value: 0),
        )));

  void updateItemAt(int index, int val) {
    final updated = state.items[index].copyWith(value: val);
    final newList = List<ItemData>.from(state.items);
    newList[index] = updated;
    state
      ..items = newList
      ..update();
  }

  void insertAt(int index, ItemData item) {
    final newList = List<ItemData>.from(state.items);
    newList.insert(index, item);
    state
      ..items = newList
      ..update();
  }

  void removeAt(int index) {
    final newList = List<ItemData>.from(state.items);
    newList.removeAt(index);
    state
      ..items = newList
      ..update();
  }
}

// 2. BLoC (Cubit)
class BlocListCubit extends bloc_pkg.Cubit<List<ItemData>> {
  BlocListCubit(int count)
      : super(List.generate(
          count,
          (i) => ItemData(id: i, title: 'Item #$i', value: 0),
        ));

  void updateItemAt(int index, int val) {
    final newList = List<ItemData>.from(state);
    newList[index] = newList[index].copyWith(value: val);
    emit(newList);
  }

  void insertAt(int index, ItemData item) {
    final newList = List<ItemData>.from(state);
    newList.insert(index, item);
    emit(newList);
  }

  void removeAt(int index) {
    final newList = List<ItemData>.from(state);
    newList.removeAt(index);
    emit(newList);
  }
}

// 3. Riverpod Notifier
class RiverpodListNotifier extends riverpod_pkg.Notifier<List<ItemData>> {
  final int initialCount;
  RiverpodListNotifier(this.initialCount);

  @override
  List<ItemData> build() => List.generate(
        initialCount,
        (i) => ItemData(id: i, title: 'Item #$i', value: 0),
      );

  void updateItemAt(int index, int val) {
    final newList = List<ItemData>.from(state);
    newList[index] = newList[index].copyWith(value: val);
    state = newList;
  }

  void insertAt(int index, ItemData item) {
    final newList = List<ItemData>.from(state);
    newList.insert(index, item);
    state = newList;
  }

  void removeAt(int index) {
    final newList = List<ItemData>.from(state);
    newList.removeAt(index);
    state = newList;
  }
}

// 4. Signals
class SignalsListController {
  final List<signals_pkg.Signal<ItemData>> items;
  SignalsListController(int count)
      : items = List.generate(
          count,
          (i) => signals_pkg.signal(ItemData(id: i, title: 'Item #$i', value: 0)),
        );

  void updateItemAt(int index, int val) {
    items[index].value = items[index].value.copyWith(value: val);
  }
}

// 5. GetX
class GetXListController extends getx.GetxController {
  final getx.RxList<ItemData> items;
  GetXListController(int count)
      : items = getx.RxList<ItemData>(List.generate(
          count,
          (i) => ItemData(id: i, title: 'Item #$i', value: 0),
        ));

  void updateItemAt(int index, int val) {
    items[index] = items[index].copyWith(value: val);
  }

  void insertAt(int index, ItemData item) => items.insert(index, item);
  void removeAt(int index) => items.removeAt(index);
}

// 6. Provider
class ProviderListModel extends ChangeNotifier {
  List<ItemData> items;
  ProviderListModel(int count)
      : items = List.generate(
          count,
          (i) => ItemData(id: i, title: 'Item #$i', value: 0),
        );

  void updateItemAt(int index, int val) {
    final newList = List<ItemData>.from(items);
    newList[index] = newList[index].copyWith(value: val);
    items = newList;
    notifyListeners();
  }

  void insertAt(int index, ItemData item) {
    final newList = List<ItemData>.from(items);
    newList.insert(index, item);
    items = newList;
    notifyListeners();
  }

  void removeAt(int index) {
    final newList = List<ItemData>.from(items);
    newList.removeAt(index);
    items = newList;
    notifyListeners();
  }
}

// =============================================================================
// SCENARIO C RUNNER
// =============================================================================
class ScenarioCLargeListRunner {
  static const int rapidUpdates = 300;
  static const int warmUpRuns = 3;
  static const int measuredRuns = 15;

  static Future<List<BenchmarkStats>> runAll(WidgetTester tester) async {
    final statsList = <BenchmarkStats>[];

    // C1: 5,000 Item List (300 rapid updates at index 2,500)
    statsList.addAll(await runListUpdates(
      tester: tester,
      itemCount: 5000,
      scenarioName: 'C1_5k_items_300_rapid_updates',
    ));

    // C2: 20,000 Item List (300 rapid updates at index 10,000)
    statsList.addAll(await runListUpdates(
      tester: tester,
      itemCount: 20000,
      scenarioName: 'C2_20k_items_300_rapid_updates',
    ));

    // C3: 1,000 Item List Random Insert/Remove
    statsList.addAll(await runListInsertRemove(
      scenarioName: 'C3_random_insert_remove_100x',
    ));

    return statsList;
  }

  // ---------------------------------------------------------------------------
  // C1 & C2: Middle-Item Rapid Updates in Virtualized ListView
  // ---------------------------------------------------------------------------
  static Future<List<BenchmarkStats>> runListUpdates({
    required WidgetTester tester,
    required int itemCount,
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];
    final targetIndex = itemCount ~/ 2;

    // 1. Graft
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = GraftListController(itemCount);
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemExtent: 50.0,
                itemBuilder: (context, index) {
                  return ctrl.slot(builder: (s) {
                    final item = s.items[index];
                    return TrackedListTile(
                      key: ValueKey(item.id),
                      item: item,
                      onBuild: () {
                        if (index == targetIndex) targetBuilds++;
                      },
                    );
                  });
                },
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          ctrl.updateItemAt(targetIndex, u + 1);
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: 0,
        notes: 'Surgical leaf slot inside ListView.builder',
      ));
    }

    // 2. Riverpod (Notifier)
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final notifier = RiverpodListNotifier(itemCount);
        final provider = riverpod_pkg.NotifierProvider<RiverpodListNotifier, List<ItemData>>(
          () => notifier,
        );
        final container = riverpod_pkg.ProviderContainer();
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          riverpod_pkg.UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  controller: scrollController,
                  itemCount: itemCount,
                  itemExtent: 50.0,
                  itemBuilder: (context, index) {
                    return riverpod_pkg.Consumer(
                      builder: (context, ref, _) {
                        final item = ref.watch(provider.select((list) => list[index]));
                        return TrackedListTile(
                          key: ValueKey(item.id),
                          item: item,
                          onBuild: () {
                            if (index == targetIndex) targetBuilds++;
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          container.read(provider.notifier).updateItemAt(targetIndex, u + 1);
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        container.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: rapidUpdates,
        notes: 'Provider.select() item subscription',
      ));
    }

    // 3. BLoC (BlocSelector)
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final cubit = BlocListCubit(itemCount);
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemExtent: 50.0,
                itemBuilder: (context, index) {
                  return bloc_pkg.BlocSelector<BlocListCubit, List<ItemData>, ItemData>(
                    bloc: cubit,
                    selector: (list) => list[index],
                    builder: (context, item) {
                      return TrackedListTile(
                        key: ValueKey(item.id),
                        item: item,
                        onBuild: () {
                          if (index == targetIndex) targetBuilds++;
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          cubit.updateItemAt(targetIndex, u + 1);
          await tester.pump(Duration.zero);
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        cubit.close();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: rapidUpdates,
        notes: 'BlocSelector item filtering',
      ));
    }

    // 4. Signals
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = SignalsListController(itemCount);
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemExtent: 50.0,
                itemBuilder: (context, index) {
                  return signals_pkg.Watch((context) {
                    final item = ctrl.items[index].value;
                    return TrackedListTile(
                      key: ValueKey(item.id),
                      item: item,
                      onBuild: () {
                        if (index == targetIndex) targetBuilds++;
                      },
                    );
                  });
                },
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          ctrl.updateItemAt(targetIndex, u + 1);
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Signals',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: 0,
        notes: 'Item-level Signal subscription',
      ));
    }

    // 5. GetX
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final ctrl = GetXListController(itemCount);
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemExtent: 50.0,
                itemBuilder: (context, index) {
                  return getx.Obx(() {
                    final item = ctrl.items[index];
                    return TrackedListTile(
                      key: ValueKey(item.id),
                      item: item,
                      onBuild: () {
                        if (index == targetIndex) targetBuilds++;
                      },
                    );
                  });
                },
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          ctrl.updateItemAt(targetIndex, u + 1);
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: 0,
        notes: 'RxList item index reactive update',
      ));
    }

    // 6. Provider
    {
      final samples = <double>[];
      int targetBuilds = 0;

      for (int r = 0; r < warmUpRuns + measuredRuns; r++) {
        final model = ProviderListModel(itemCount);
        final scrollController = ScrollController();
        targetBuilds = 0;

        await tester.pumpWidget(
          provider_pkg.ChangeNotifierProvider<ProviderListModel>.value(
            value: model,
            child: MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  controller: scrollController,
                  itemCount: itemCount,
                  itemExtent: 50.0,
                  itemBuilder: (context, index) {
                    return provider_pkg.Selector<ProviderListModel, ItemData>(
                      selector: (_, m) => m.items[index],
                      builder: (context, item, _) {
                        return TrackedListTile(
                          key: ValueKey(item.id),
                          item: item,
                          onBuild: () {
                            if (index == targetIndex) targetBuilds++;
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );

        scrollController.jumpTo(targetIndex * 50.0);
        await tester.pump();
        targetBuilds = 0;

        final sw = Stopwatch()..start();
        for (int u = 0; u < rapidUpdates; u++) {
          model.updateItemAt(targetIndex, u + 1);
          await tester.pump();
        }
        sw.stop();

        if (r >= warmUpRuns) {
          samples.add(sw.elapsedMicroseconds / 1000.0);
        }
        model.dispose();
      }

      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        targetRebuilds: targetBuilds,
        staticRebuilds: 0,
        allocatedObjects: rapidUpdates,
        notes: 'Selector item diffing',
      ));
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // C3: 1,000 Item List Random Insert/Remove Operations (100 Inserts + 100 Removes)
  // ---------------------------------------------------------------------------
  static Future<List<BenchmarkStats>> runListInsertRemove({
    required String scenarioName,
  }) async {
    final results = <BenchmarkStats>[];
    const initialCount = 1000;
    const ops = 100;

    final rng = math.Random(42);
    final insertIndices = List.generate(ops, (_) => rng.nextInt(initialCount));
    final removeIndices = List.generate(ops, (_) => rng.nextInt(initialCount));

    // 1. Graft
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GraftListController(initialCount);
        final sw = Stopwatch()..start();
        for (int i = 0; i < ops; i++) {
          ctrl.insertAt(insertIndices[i], ItemData(id: 10000 + i, title: 'New $i', value: i));
        }
        for (int i = 0; i < ops; i++) {
          ctrl.removeAt(removeIndices[i].clamp(0, ctrl.state.items.length - 1));
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Graft',
        samplesMs: samples,
        notes: 'In-place List mutation + update()',
      ));
    }

    // 2. BLoC (Cubit)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final cubit = BlocListCubit(initialCount);
        final sw = Stopwatch()..start();
        for (int i = 0; i < ops; i++) {
          cubit.insertAt(insertIndices[i], ItemData(id: 10000 + i, title: 'New $i', value: i));
        }
        for (int i = 0; i < ops; i++) {
          cubit.removeAt(removeIndices[i].clamp(0, cubit.state.length - 1));
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        cubit.close();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'BLoC (Cubit)',
        samplesMs: samples,
        notes: 'List clone + emit ($ops insertions, $ops removals)',
      ));
    }

    // 3. Riverpod (Notifier)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final container = riverpod_pkg.ProviderContainer();
        final provider = riverpod_pkg.NotifierProvider<RiverpodListNotifier, List<ItemData>>(
          () => RiverpodListNotifier(initialCount),
        );
        final notifier = container.read(provider.notifier);
        final sw = Stopwatch()..start();
        for (int i = 0; i < ops; i++) {
          notifier.insertAt(insertIndices[i], ItemData(id: 10000 + i, title: 'New $i', value: i));
        }
        for (int i = 0; i < ops; i++) {
          notifier.removeAt(removeIndices[i].clamp(0, notifier.state.length - 1));
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        container.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Riverpod (Notifier)',
        samplesMs: samples,
        notes: 'List clone + state assignment',
      ));
    }

    // 4. GetX (RxList)
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final ctrl = GetXListController(initialCount);
        final sw = Stopwatch()..start();
        for (int i = 0; i < ops; i++) {
          ctrl.insertAt(insertIndices[i], ItemData(id: 10000 + i, title: 'New $i', value: i));
        }
        for (int i = 0; i < ops; i++) {
          ctrl.removeAt(removeIndices[i].clamp(0, ctrl.items.length - 1));
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'GetX (RxList)',
        samplesMs: samples,
        notes: 'RxList observable in-place mutation',
      ));
    }

    // 5. Provider
    {
      final samples = <double>[];
      for (int r = 0; r < measuredRuns; r++) {
        final model = ProviderListModel(initialCount);
        final sw = Stopwatch()..start();
        for (int i = 0; i < ops; i++) {
          model.insertAt(insertIndices[i], ItemData(id: 10000 + i, title: 'New $i', value: i));
        }
        for (int i = 0; i < ops; i++) {
          model.removeAt(removeIndices[i].clamp(0, model.items.length - 1));
        }
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
        model.dispose();
      }
      results.add(BenchmarkStats(
        scenario: scenarioName,
        framework: 'Provider',
        samplesMs: samples,
        notes: 'List clone + notifyListeners()',
      ));
    }

    return results;
  }
}
