import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TaskItem {
  final String id;
  final String title;
  TaskItem(this.id, this.title);
}

class CollectionState extends GraftState {
  String name;
  List<TaskItem> tasks;
  Map<String, dynamic> metadata;
  Set<int> tags;

  CollectionState({
    this.name = 'Initial',
    List<TaskItem>? tasks,
    Map<String, dynamic>? metadata,
    Set<int>? tags,
  })  : tasks = tasks ?? [TaskItem('1', 'Task 1')],
        metadata = metadata ?? {'theme': 'light'},
        tags = tags ?? {1, 2};

  @override
  List<Object?> get props => [name, tasks, metadata, tags];
}

class CollectionGraft extends Graft<CollectionState> {
  CollectionGraft() : super(CollectionState());

  void updateName(String newName) {
    state
      ..name = newName
      ..update();
  }

  void addTask(TaskItem item) {
    state
      ..tasks.add(item)
      ..update();
  }

  void removeFirstTask() {
    state
      ..tasks.removeAt(0)
      ..update();
  }

  void updateMetadata(String key, dynamic value) {
    state
      ..metadata[key] = value
      ..update();
  }

  void addTag(int tag) {
    state
      ..tags.add(tag)
      ..update();
  }
}

void main() {
  group('Pillar 1: Collection Mutation & In-Place Diffing Tests', () {
    testWidgets('In-place List.add() mutation triggers dirtyMask and updates UI', (tester) async {
      final graft = CollectionGraft();
      int listBuildCount = 0;
      int nameBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              children: (s) {
                return [
                  _TrackedWidget(
                    text: 'Name: ${s.name}',
                    onBuild: () => nameBuildCount++,
                  ),
                  _TrackedWidget(
                    text: 'Tasks: ${s.tasks.map((t) => t.title).join(", ")}',
                    onBuild: () => listBuildCount++,
                  ),
                ];
              },
            ),
          ),
        ),
      );

      expect(find.text('Tasks: Task 1'), findsOneWidget);
      expect(nameBuildCount, 1);
      expect(listBuildCount, 1);

      // Mutate list in-place via cascade:
      graft.addTask(TaskItem('2', 'Task 2'));
      await tester.pump();

      expect(find.text('Tasks: Task 1, Task 2'), findsOneWidget);
      expect(listBuildCount, 2, reason: 'List slot must rebuild when item is added in-place');
      expect(nameBuildCount, 1, reason: 'Name slot must NOT rebuild when list is mutated');
      expect(graft.state.dirtyMask.intersects(GraftMask.fromIndex(1)), isTrue);

      graft.dispose();
    });

    testWidgets('In-place List.removeAt() mutation triggers dirtyMask and updates UI', (tester) async {
      final graft = CollectionGraft();
      int listBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: (children) => Column(children: children),
              children: (s) {
                listBuildCount++;
                return [
                  Column(
                    children: s.tasks.map((t) => Text(t.title)).toList(),
                  ),
                ];
              },
            ),
          ),
        ),
      );

      expect(find.text('Task 1'), findsOneWidget);
      expect(listBuildCount, 1);

      // Add then remove
      graft.addTask(TaskItem('2', 'Task 2'));
      await tester.pump();
      expect(find.text('Task 2'), findsOneWidget);

      graft.removeFirstTask();
      await tester.pump();

      expect(find.text('Task 1'), findsNothing);
      expect(find.text('Task 2'), findsOneWidget);
      expect(listBuildCount, 3);

      graft.dispose();
    });

    test('In-place Map entry update triggers dirtyMask', () {
      final graft = CollectionGraft();
      GraftMask? observedMask;

      graft.addMaskListener((mask) {
        observedMask = mask;
      });

      graft.updateMetadata('theme', 'dark');

      expect(observedMask, isNotNull);
      // Index 2 is metadata in props: [name (0), tasks (1), metadata (2), tags (3)]
      expect(observedMask!.intersects(GraftMask.fromIndex(2)), isTrue);
      expect(graft.state.metadata['theme'], 'dark');

      graft.dispose();
    });

    test('In-place Set.add() mutation triggers dirtyMask', () {
      final graft = CollectionGraft();
      GraftMask? observedMask;

      graft.addMaskListener((mask) {
        observedMask = mask;
      });

      graft.addTag(42);

      expect(observedMask, isNotNull);
      // Index 3 is tags in props
      expect(observedMask!.intersects(GraftMask.fromIndex(3)), isTrue);
      expect(graft.state.tags.contains(42), isTrue);

      graft.dispose();
    });

    test('Unrelated primitive field mutation does NOT flag collections as dirty', () {
      final graft = CollectionGraft();
      GraftMask? observedMask;

      graft.addMaskListener((mask) {
        observedMask = mask;
      });

      graft.updateName('Bob');

      expect(observedMask, isNotNull);
      // Bit 0 (name) must be dirty
      expect(observedMask!.intersects(GraftMask.fromIndex(0)), isTrue);
      // Bit 1 (tasks), Bit 2 (metadata), Bit 3 (tags) must be clean
      expect(observedMask!.intersects(GraftMask.fromIndex(1)), isFalse);
      expect(observedMask!.intersects(GraftMask.fromIndex(2)), isFalse);
      expect(observedMask!.intersects(GraftMask.fromIndex(3)), isFalse);

      graft.dispose();
    });

    test('GraftChange captures distinct before and after collection snapshots', () {
      final graft = CollectionGraft();
      GraftChange<dynamic>? capturedChange;

      Graft.observer = _TestObserver((change) {
        capturedChange = change;
      });

      graft.addTask(TaskItem('2', 'Task 2'));

      expect(capturedChange, isNotNull);
      final prevTasks = capturedChange!.previousProps[1] as List;
      final nextTasks = capturedChange!.nextProps[1] as List;

      expect(prevTasks.length, 1);
      expect(nextTasks.length, 2);
      expect(identical(prevTasks, nextTasks), isFalse, reason: 'Snapshots must be independent objects');

      Graft.observer = null;
      graft.dispose();
    });
  });
}

class _TestObserver extends GraftObserver {
  final void Function(GraftChange<dynamic>) onChangeCallback;
  _TestObserver(this.onChangeCallback);

  @override
  void onChange(dynamic graft, GraftChange change) {
    onChangeCallback(change);
  }
}

class _TrackedWidget extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback onBuild;
  const _TrackedWidget({required this.text, required this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is _TrackedWidget && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(text);
  }
}
