import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class LeafState extends GraftState {
  int value;
  LeafState(this.value);

  @override
  GraftProps get props => propsOf(value);
}

class BranchState extends GraftState {
  final GraftState child;
  BranchState(this.child);

  @override
  GraftProps get props => propsOf(child);
}

class RootTreeState extends GraftState {
  final GraftState head;
  RootTreeState(this.head);

  @override
  GraftProps get props => propsOf(head);
}

class TreeGraft extends Graft<RootTreeState> {
  final LeafState leaf;

  TreeGraft._(super.state, this.leaf);

  factory TreeGraft.depth(int depth, int initialLeafValue) {
    final leaf = LeafState(initialLeafValue);
    GraftState current = leaf;
    for (int i = 0; i < depth - 1; i++) {
      current = BranchState(current);
    }
    return TreeGraft._(RootTreeState(current), leaf);
  }

  void updateLeaf(int v) {
    leaf.value = v;
    state.update();
  }
}

class CollectionItemState extends GraftState {
  final int id;
  int score;
  CollectionItemState(this.id, this.score);

  @override
  GraftProps get props => propsOf(id, score);
}

class CollectionParentState extends GraftState {
  final List<CollectionItemState> items;
  CollectionParentState(this.items);

  @override
  GraftProps get props => propsOf(items);
}

void main() {
  group('Depth-20 Recursive Hierarchy & Collection Mutation Stress Tests', () {
    testWidgets('20-level deep nested state tree detects in-place mutation and rebuilds slot',
        (tester) async {
      const depth = 20;
      final graft = TreeGraft.depth(depth, 0);

      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slot(
              builder: (_) {
                buildCount++;
                return Text('Leaf: ${graft.leaf.value}');
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('Leaf: 0'), findsOneWidget);

      // Mutate leaf 20 levels deep in-place
      graft.updateLeaf(42);
      await tester.pump();

      expect(buildCount, 2,
          reason: 'Slot must rebuild when leaf 20 levels deep is mutated in-place');
      expect(find.text('Leaf: 42'), findsOneWidget);

      // No mutation update -> 0 rebuilds
      graft.state.update();
      await tester.pump();

      expect(buildCount, 2,
          reason: 'Slot must NOT rebuild when leaf value is unchanged');

      graft.dispose();
    });

    test('1,000-element collection of nested states detects in-place property mutations', () {
      final items = List<CollectionItemState>.generate(
        1000,
        (i) => CollectionItemState(i, 0),
      );
      final parent = CollectionParentState(items);

      // Initial baseline
      final initialMask = parent.diffChanges();
      expect(initialMask.isAllDirty, isTrue);

      // 1. Mutate element at index 500 in-place
      items[500].score = 999;
      final mask1 = parent.diffChanges();
      expect(mask1.isEmpty, isFalse,
          reason: 'In-place mutation of collection item must be marked dirty');

      // 2. Unchanged pass -> clean mask
      final mask2 = parent.diffChanges();
      expect(mask2.isEmpty, isTrue,
          reason: 'Clean pass without mutations must return empty mask');

      // 3. Mutate elements at index 0 and 999
      items[0].score = 111;
      items[999].score = 888;
      final mask3 = parent.diffChanges();
      expect(mask3.isEmpty, isFalse);
    });
  });
}
