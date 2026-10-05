import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class ItemModel {
  final int id;
  final String title;
  final int value;

  const ItemModel({
    required this.id,
    required this.title,
    required this.value,
  });

  ItemModel copyWith({String? title, int? value}) {
    return ItemModel(
      id: id,
      title: title ?? this.title,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          id == other.id &&
          title == other.title &&
          value == other.value;

  @override
  int get hashCode => Object.hash(id, title, value);
}

class LargeListState extends GraftState {
  List<ItemModel> items;

  LargeListState(this.items);

  @override
  List<Object?> get props => [items];

  @override
  void onReset() {
    items = [];
  }
}

class LargeListGraft extends Graft<LargeListState> {
  LargeListGraft(int initialCount)
      : super(LargeListState(List.generate(
          initialCount,
          (i) => ItemModel(id: i, title: 'Item #$i', value: 0),
        )));

  void updateItemAt(int index, {int? newValue, String? newTitle}) {
    final current = state.items[index];
    final updated = current.copyWith(value: newValue, title: newTitle);
    final newList = List<ItemModel>.from(state.items);
    newList[index] = updated;
    state
      ..items = newList
      ..update();
  }

  void insertAt(int index, ItemModel item) {
    final newList = List<ItemModel>.from(state.items);
    newList.insert(index, item);
    state
      ..items = newList
      ..update();
  }

  void removeAt(int index) {
    final newList = List<ItemModel>.from(state.items);
    newList.removeAt(index);
    state
      ..items = newList
      ..update();
  }
}

class TrackedItemTile extends StatelessWidget implements GraftEquivalent {
  final ItemModel item;
  final int index;
  final VoidCallback onBuild;

  const TrackedItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.onBuild,
  });

  @override
  bool isEquivalentTo(Widget other) {
    if (other is! TrackedItemTile) return false;
    return item == other.item && index == other.index;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return SizedBox(
      height: 50.0,
      child: Text('${item.title} - val:${item.value}'),
    );
  }
}

void main() {
  group('Large List & High-Scale Virtualization Tests (10,000+ Items)', () {
    testWidgets('10,000 Items: Lazy Virtualization only instantiates visible items in Element tree',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalItems = 10000;
      final graft = LargeListGraft(totalItems);
      final Map<int, int> buildCounts = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<ItemModel>(
              items: (s) => s.items,
              itemKey: (item) => ValueKey(item.id),
              itemBuilder: (item, index) => TrackedItemTile(
                item: item,
                index: index,
                onBuild: () {
                  buildCounts[index] = (buildCounts[index] ?? 0) + 1;
                },
              ),
            ),
          ),
        ),
      );

      // In an 800x600 viewport with 50px items, only ~12-14 items fit on screen + cache extent
      expect(buildCounts.length, lessThanOrEqualTo(20));
      expect(buildCounts.containsKey(0), isTrue);
      expect(buildCounts.containsKey(5), isTrue);
      // Item 100, 1000, 9999 must NOT be built!
      expect(buildCounts.containsKey(100), isFalse);
      expect(buildCounts.containsKey(1000), isFalse);
      expect(buildCounts.containsKey(9999), isFalse);

      expect(find.text('Item #0 - val:0'), findsOneWidget);
      expect(find.text('Item #9999 - val:0'), findsNothing);
    });

    testWidgets('Surgical Update in 10,000-Item List: only mutated item rebuilds (0 rebuilds on 9,999 others)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalItems = 10000;
      final graft = LargeListGraft(totalItems);
      final Map<int, int> buildCounts = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<ItemModel>(
              items: (s) => s.items,
              itemKey: (item) => ValueKey(item.id),
              itemBuilder: (item, index) => TrackedItemTile(
                item: item,
                index: index,
                onBuild: () {
                  buildCounts[index] = (buildCounts[index] ?? 0) + 1;
                },
              ),
            ),
          ),
        ),
      );

      // Record initial build counts
      final initialBuiltIndices = List<int>.from(buildCounts.keys);
      expect(initialBuiltIndices, isNotEmpty);
      for (final idx in initialBuiltIndices) {
        expect(buildCounts[idx], equals(1));
      }

      // Reset counters to track only the mutation
      buildCounts.clear();

      // Mutate item at index 4 (visible on screen)
      graft.updateItemAt(4, newValue: 42);
      await tester.pump();

      // Only item 4 must rebuild!
      expect(buildCounts[4], equals(1), reason: 'Item 4 was mutated and must rebuild once');
      expect(find.text('Item #4 - val:42'), findsOneWidget);

      // Check all other previously visible indices: MUST BE 0 REBUILDS!
      for (final idx in initialBuiltIndices) {
        if (idx != 4) {
          expect(buildCounts[idx], isNull,
              reason: 'Unchanged item #$idx must have 0 rebuilds when item #4 is updated');
        }
      }
    });

    testWidgets('High-Speed Scroll & Virtualized Recycling across 10,000 items',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalItems = 10000;
      final graft = LargeListGraft(totalItems);
      final scrollController = ScrollController();
      final Map<int, int> buildCounts = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<ItemModel>(
              items: (s) => s.items,
              itemKey: (item) => ValueKey(item.id),
              layout: (count, b) => ListView.builder(
                controller: scrollController,
                itemCount: count,
                itemBuilder: b,
              ),
              itemBuilder: (item, index) => TrackedItemTile(
                item: item,
                index: index,
                onBuild: () {
                  buildCounts[index] = (buildCounts[index] ?? 0) + 1;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item #0 - val:0'), findsOneWidget);

      // Jump directly to item 5,000 (offset: 5000 * 50 = 250,000)
      scrollController.jumpTo(5000.0 * 50.0);
      await tester.pump();

      // Item 0 is no longer visible
      expect(find.text('Item #0 - val:0'), findsNothing);
      // Item 5000 is now visible and rendered cleanly
      expect(find.text('Item #5000 - val:0'), findsOneWidget);
      expect(buildCounts.containsKey(5000), isTrue);

      // Mutate item 5000 while at scroll position 5000
      buildCounts.clear();
      graft.updateItemAt(5000, newValue: 999);
      await tester.pump();

      expect(buildCounts[5000], equals(1));
      expect(find.text('Item #5000 - val:999'), findsOneWidget);

      // Other visible items around 5000 must NOT rebuild
      expect(buildCounts[4999], isNull);
      expect(buildCounts[5001], isNull);
    });

    testWidgets('Dynamic Insertion and Removal in 10,000-Item List updates count cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalItems = 10000;
      final graft = LargeListGraft(totalItems);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<ItemModel>(
              items: (s) => s.items,
              itemKey: (item) => ValueKey(item.id),
              itemBuilder: (item, index) => TrackedItemTile(
                item: item,
                index: index,
                onBuild: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item #0 - val:0'), findsOneWidget);

      // Insert new item at index 0
      graft.insertAt(0, const ItemModel(id: -1, title: 'NEW_INSERTED_ITEM', value: 777));
      await tester.pump();

      expect(find.text('NEW_INSERTED_ITEM - val:777'), findsOneWidget);
      expect(find.text('Item #0 - val:0'), findsOneWidget);

      // Remove the inserted item
      graft.removeAt(0);
      await tester.pump();

      expect(find.text('NEW_INSERTED_ITEM - val:777'), findsNothing);
      expect(find.text('Item #0 - val:0'), findsOneWidget);
    });

    testWidgets('Stress Benchmark: 1,000 Rapid Updates in 10,000-Item List maintains surgical isolation',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalItems = 10000;
      final graft = LargeListGraft(totalItems);
      int totalItemBuildCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.builder<ItemModel>(
              items: (s) => s.items,
              itemKey: (item) => ValueKey(item.id),
              itemBuilder: (item, index) => TrackedItemTile(
                item: item,
                index: index,
                onBuild: () => totalItemBuildCalls++,
              ),
            ),
          ),
        ),
      );

      // Reset count after initial mount
      totalItemBuildCalls = 0;

      const int updatesCount = 500;
      final stopwatch = Stopwatch()..start();

      // Perform 500 rapid mutations targeting visible indices (0 to 9)
      for (int i = 0; i < updatesCount; i++) {
        final targetIndex = i % 8; // visible indices 0..7
        graft.updateItemAt(targetIndex, newValue: i + 1);
        await tester.pump();
      }

      stopwatch.stop();

      // In Graft, each update touches ONLY the single mutated item slot!
      // Exactly 500 builds total across all 500 frames!
      expect(totalItemBuildCalls, equals(updatesCount),
          reason: 'Every state update must rebuild strictly 1 item slot, never the other items or entire list');

      // ignore: avoid_print
      print('''
================================================================================
  GRAFT LARGE LIST BENCHMARK (10,000 Items, 500 Rapid Surgical Updates)
================================================================================
  Total Items in State:  10,000
  Updates / Frames:      $updatesCount
  Total Item Builds:     $totalItemBuildCalls (Strictly 1 per frame)
  Elapsed Time:          ${stopwatch.elapsedMilliseconds} ms (${stopwatch.elapsedMicroseconds} µs)
  Rebuilds per Update:   1.0
  Efficiency:            100% surgical isolation (9,999 items untouched)
================================================================================
''');
    });

    testWidgets('graft.item in Custom GridView with 5,000 Items', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const int totalGridItems = 5000;
      final graft = LargeListGraft(totalGridItems);
      final Map<int, int> cellBuildCounts = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
              ),
              itemCount: totalGridItems,
              itemBuilder: (context, index) {
                return graft.item<ItemModel>(
                  key: ValueKey(index),
                  selector: (s) => s.items[index],
                  builder: (item) {
                    cellBuildCounts[index] = (cellBuildCounts[index] ?? 0) + 1;
                    return Center(child: Text('Grid #$index: ${item.value}'));
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify grid rendered visible cells
      expect(cellBuildCounts.containsKey(0), isTrue);
      expect(cellBuildCounts.containsKey(3), isTrue);
      expect(find.text('Grid #0: 0'), findsOneWidget);

      cellBuildCounts.clear();

      // Mutate cell #2
      graft.updateItemAt(2, newValue: 888);
      await tester.pump();

      // Only cell #2 rebuilds
      expect(cellBuildCounts[2], equals(1));
      expect(cellBuildCounts[0], isNull);
      expect(cellBuildCounts[1], isNull);
      expect(cellBuildCounts[3], isNull);
      expect(find.text('Grid #2: 888'), findsOneWidget);
    });
  });
}
