import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';
import 'package:graft/src/persistence/ambient_locator.dart';
import 'package:graft/src/persistence/model/binary_serializer.dart';
import 'package:graft/src/persistence/model/schema_fingerprint.dart';

// =============================================================================
// TEST GRAFTS
// =============================================================================

class ThemeState extends GraftState {
  String mode;
  ThemeState({this.mode = 'light'});

  @override
  GraftProps get props => propsOf(mode);
}

class ThemeGraft extends Graft<ThemeState> {
  ThemeGraft() : super(ThemeState());

  void toggle() {
    state
      ..mode = state.mode == 'light' ? 'dark' : 'light'
      ..update();
  }
}

class FlowState extends GraftState {
  int step;
  FlowState({this.step = 1});

  @override
  GraftProps get props => propsOf(step);
}

class FlowGraft extends Graft<FlowState> {
  FlowGraft() : super(FlowState());

  void next() {
    state
      ..step += 1
      ..update();
  }
}

class ItemState extends GraftState {
  final int id;
  String name;
  ItemState({this.id = 0, this.name = 'item'});

  @override
  GraftProps get props => propsOf(id, name);
}

class ItemGraft extends Graft<ItemState> {
  ItemGraft([int id = 0, String name = 'item'])
      : super(ItemState(id: id, name: name));

  void rename(String newName) {
    state
      ..name = newName
      ..update();
  }
}

class DryRootState extends GraftState {
  @override
  int get schemaVersion => 1;

  String username;
  DryRootState([this.username = 'default']);

  @override
  GraftProps get props => propsOf(username);
}

class DryRootGraft extends Graft<DryRootState> {
  DryRootGraft() : super.dry(DryRootState.new);
}

// =============================================================================
// AMBIENT ENGINE TEST SUITE
// =============================================================================

void main() {
  setUp(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
    resetAmbientPersistence();
  });

  tearDown(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
    resetAmbientPersistence();
  });

  group('Pillar 7: Ref-Counted Ambient Engine Tests', () {
    testWidgets('App-Root Ambient Test: route == null auto-promotes to permanent singleton',
        (tester) async {
      ThemeGraft? rootThemeGraft;
      ThemeGraft? settingsThemeGraft;

      final observer = GraftRouteObserver();
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [observer],
          builder: (context, child) {
            // Executed above Navigator: ModalRoute.of(context) == null
            rootThemeGraft = context.use(ThemeGraft.new);
            return Column(
              children: [
                rootThemeGraft!((s) => Text('Theme Mode: ${s.mode}')),
                Expanded(child: child!),
              ],
            );
          },
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  navKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (settingsCtx) {
                        settingsThemeGraft = settingsCtx.use<ThemeGraft>();
                        return Scaffold(
                          body: ElevatedButton(
                            onPressed: () => settingsThemeGraft!.toggle(),
                            child: const Text('Toggle Theme'),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      // Verify root instance created
      expect(rootThemeGraft, isNotNull);
      expect(rootThemeGraft!.isDisposed, isFalse);
      expect(find.text('Theme Mode: light'), findsOneWidget);

      final rootEntry = GraftRouteTracker.getAmbientEntry<ThemeGraft>();
      expect(rootEntry, isNotNull);
      expect(rootEntry!.isRoot, isTrue);

      // Push settings screen
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      // Settings screen borrows the root instance
      expect(settingsThemeGraft, isNotNull);
      expect(identical(rootThemeGraft, settingsThemeGraft), isTrue);

      // Mutate from settings -> root slot rebuilds!
      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();
      expect(find.text('Theme Mode: dark'), findsOneWidget);

      // Pop Settings
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      // Root instance stays alive forever (isRoot == true)
      expect(rootThemeGraft!.isDisposed, isFalse);
      expect(GraftRouteTracker.getAmbient<ThemeGraft>(), isNotNull);
    });

    testWidgets('Multi-Route Ref-Count Teardown: auto-disposes only when all borrower routes pop',
        (tester) async {
      FlowGraft? flowScreen1;
      FlowGraft? flowScreen2;
      FlowGraft? flowScreen3;

      final navKey = GlobalKey<NavigatorState>();
      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [observer],
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                flowScreen1 = ctx.use(FlowGraft.new);
                return flowScreen1!((s) => Text('Screen 1 Step: ${s.step}'));
              },
            ),
          ),
        ),
      );

      expect(flowScreen1, isNotNull);
      expect(flowScreen1!.isDisposed, isFalse);
      expect(find.text('Screen 1 Step: 1'), findsOneWidget);

      var entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry, isNotNull);
      expect(entry!.refCount, equals(1));
      expect(entry.isRoot, isFalse);

      // Push Screen 2
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (ctx) {
            flowScreen2 = ctx.use<FlowGraft>();
            return flowScreen2!((s) => Text('Screen 2 Step: ${s.step}'));
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(flowScreen2, isNotNull);
      expect(identical(flowScreen1, flowScreen2), isTrue);
      entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(2));

      // Push Screen 3
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (ctx) {
            flowScreen3 = ctx.use<FlowGraft>();
            return flowScreen3!((s) => Text('Screen 3 Step: ${s.step}'));
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(flowScreen3, isNotNull);
      expect(identical(flowScreen1, flowScreen3), isTrue);
      entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(3));

      // Pop Screen 3 -> refCount drops to 2, still alive
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(flowScreen1!.isDisposed, isFalse);
      entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(2));

      // Pop Screen 2 -> refCount drops to 1, still alive
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(flowScreen1!.isDisposed, isFalse);
      entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(1));

      // Pop Screen 1 (Root Route) -> refCount drops to 0, DISPOSED!
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(flowScreen1!.isDisposed, isTrue);
      expect(GraftRouteTracker.getAmbient<FlowGraft>(), isNull);
    });

    testWidgets('Re-entrant Rebuild Idempotency: multiple rebuilds do NOT balloon refCount',
        (tester) async {
      int buildCount = 0;
      void Function(void Function())? innerSetState;
      FlowGraft? capturedGraft;
      final navKey = GlobalKey<NavigatorState>();

      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [observer],
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, setState) {
                innerSetState = setState;
                buildCount++;
                capturedGraft = ctx.use(FlowGraft.new);
                return Text('Builds: $buildCount');
              },
            ),
          ),
        ),
      );

      expect(buildCount, equals(1));
      var entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(1));

      // Trigger 20 rebuilds on the same route
      for (int i = 0; i < 20; i++) {
        innerSetState!(() {});
        await tester.pump();
      }

      expect(buildCount, equals(21));
      // refCount MUST remain 1 because it is the same borrower route!
      entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(1),
          reason: 'Duplicate accesses on the same route must be idempotent');

      // Pop route
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(capturedGraft!.isDisposed, isTrue);
      expect(GraftRouteTracker.getAmbient<FlowGraft>(), isNull);
    });

    testWidgets('context.create isolation: creates private instance bypassing ambient pool',
        (tester) async {
      ItemGraft? ambientItem;
      ItemGraft? createdItem;

      final navKey = GlobalKey<NavigatorState>();

      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [observer],
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                ambientItem = ctx.use(() => ItemGraft(1, 'Ambient Item'));
                return Text('Ambient: ${ambientItem!.state.name}');
              },
            ),
          ),
        ),
      );

      expect(ambientItem, isNotNull);
      expect(GraftRouteTracker.getAmbient<ItemGraft>(), equals(ambientItem));

      // Push second screen using context.create
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (ctx) {
            createdItem = ctx.create(() => ItemGraft(2, 'Isolated Item'));
            return Text('Created: ${createdItem!.state.name}');
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(createdItem, isNotNull);
      // MUST NOT be identical!
      expect(identical(createdItem, ambientItem), isFalse);

      // Mutating created does not affect ambient
      createdItem!.rename('Mutated Isolated');
      expect(createdItem!.state.name, equals('Mutated Isolated'));
      expect(ambientItem!.state.name, equals('Ambient Item'));

      // Ambient pool still points to ambientItem
      expect(GraftRouteTracker.getAmbient<ItemGraft>(), equals(ambientItem));

      // Pop second screen -> createdItem is disposed, ambientItem remains alive!
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(createdItem!.isDisposed, isTrue);
      expect(ambientItem!.isDisposed, isFalse);
    });

    testWidgets('Push-Replacement Safety: graft stays alive when predecessor pops',
        (tester) async {
      FlowGraft? flowGraft;
      final navKey = GlobalKey<NavigatorState>();

      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [observer],
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                flowGraft = ctx.use(FlowGraft.new);
                return const Text('Screen 1');
              },
            ),
          ),
        ),
      );

      expect(flowGraft, isNotNull);
      expect(flowGraft!.isDisposed, isFalse);

      // Push Screen 2 which borrows FlowGraft
      navKey.currentState!.push(
        MaterialPageRoute(
          builder: (ctx) {
            final borrowed = ctx.use<FlowGraft>();
            return Text('Screen 2 Step: ${borrowed.state.step}');
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Screen 2 Step: 1'), findsOneWidget);
      var entry = GraftRouteTracker.getAmbientEntry<FlowGraft>();
      expect(entry!.refCount, equals(2));

      // Remove Screen 1 from navigator stack while Screen 2 is still active
      final screen1Route = GraftRouteTracker.routeStack.first;
      GraftRouteTracker.didPop(screen1Route, null);

      // Screen 1 was popped, but Screen 2 is still borrowing -> MUST NOT BE DISPOSED!
      expect(flowGraft!.isDisposed, isFalse,
          reason: 'Graft must survive predecessor pop as long as a successor screen borrows it');
      expect(entry.refCount, equals(1));

      // Pop Screen 2 -> now refCount drops to 0, DISPOSED!
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(flowGraft!.isDisposed, isTrue);
      expect(GraftRouteTracker.getAmbient<FlowGraft>(), isNull);
    });

    testWidgets('Keyed Ambient Resolution: family keys allow independent coexistence',
        (tester) async {
      ItemGraft? itemA;
      ItemGraft? itemB;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                itemA = ctx.use(() => ItemGraft(101, 'MacBook'), 'laptop');
                itemB = ctx.use(() => ItemGraft(102, 'iPhone'), 'phone');
                return Column(
                  children: [
                    Text('A: ${itemA!.state.name}'),
                    Text('B: ${itemB!.state.name}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(itemA, isNotNull);
      expect(itemB, isNotNull);
      expect(identical(itemA, itemB), isFalse);

      expect(itemA!.state.id, equals(101));
      expect(itemB!.state.id, equals(102));

      // Keyed lookups in tracker
      expect(GraftRouteTracker.getAmbient<ItemGraft>(key: 'laptop'), equals(itemA));
      expect(GraftRouteTracker.getAmbient<ItemGraft>(key: 'phone'), equals(itemB));
    });

    testWidgets('Frame-0 Dry Persistence Integration at App Root: hydrates synchronously & promotes to isRoot',
        (tester) async {
      final probeState = DryRootState();
      final fp = SchemaFingerprint.compute(
        probeState.props,
        schemaVersion: probeState.schemaVersion,
      );

      final preWarmedPayload = BinarySerializer.encode(
        probeState.propsOf('Persisted Commander'),
        fp,
      );

      // Pre-warm L1 RAM Cache
      ambientStorageCoordinator.write('DryRootState', preWarmedPayload);

      DryRootGraft? capturedRootDry;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            // App Root access (route == null)
            capturedRootDry = context.use(DryRootGraft.new);
            return child!;
          },
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                final borrowed = ctx.use<DryRootGraft>();
                return Text('User: ${borrowed.state.username}');
              },
            ),
          ),
        ),
      );

      expect(capturedRootDry, isNotNull);
      // Verified Frame-0 synchronous hydration!
      expect(capturedRootDry!.state.username, equals('Persisted Commander'));
      expect(find.text('User: Persisted Commander'), findsOneWidget);

      final entry = GraftRouteTracker.getAmbientEntry<DryRootGraft>();
      expect(entry, isNotNull);
      expect(entry!.isRoot, isTrue);
      expect(capturedRootDry!.isDisposed, isFalse);

      // Flush debounce write timer
      await tester.pump(const Duration(milliseconds: 350));
    });
  });
}
