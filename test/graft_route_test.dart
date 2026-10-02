import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TestState extends GraftState {
  final int count;
  TestState({this.count = 0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestState && count == other.count;

  @override
  int get hashCode => count.hashCode;
}

class TestGraft extends Graft<TestState> {
  TestGraft() : super(TestState());
}

void main() {
  setUp(() {
    GraftRouteTracker.reset();
    GraftRegistry.reset();
    GraftRegistry.register(TestGraft.new);
  });

  tearDown(() {
    GraftRouteTracker.reset();
    GraftRegistry.reset();
  });

  testWidgets('Route A creates and owns Graft; Route B borrows; Route B pop keeps alive; Route A pop disposes',
      (tester) async {
    TestGraft? graftOnRouteA;
    TestGraft? graftOnRouteB;

    final observer = GraftRouteObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  graftOnRouteA = context.use<TestGraft>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (childContext) {
                        graftOnRouteB = childContext.use<TestGraft>();
                        return Scaffold(
                          body: ElevatedButton(
                            onPressed: () => Navigator.of(childContext).pop(),
                            child: const Text('Pop B'),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open B'),
              ),
            );
          },
        ),
      ),
    );

    // 1. Click button on Screen A to create Graft and push Screen B
    await tester.tap(find.text('Open B'));
    await tester.pumpAndSettle();

    // Verify both screens reference the EXACT same instance
    expect(graftOnRouteA, isNotNull);
    expect(graftOnRouteB, isNotNull);
    expect(identical(graftOnRouteA, graftOnRouteB), isTrue);
    expect(graftOnRouteA!.isDisposed, false);

    // 2. Pop Screen B
    await tester.tap(find.text('Pop B'));
    await tester.pumpAndSettle();

    // Verify Graft is STILL alive because Screen B was only a borrower
    expect(graftOnRouteA!.isDisposed, false);

    // 3. Pop Screen A (Owner)
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Verify Graft is now disposed because Screen A (the owner) was popped
    expect(graftOnRouteA!.isDisposed, isTrue);
  });

  testWidgets('context.create forces creating a brand new isolated instance',
      (tester) async {
    TestGraft? graftOnRouteA;
    TestGraft? graftOnRouteB;

    final observer = GraftRouteObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  graftOnRouteA = context.use<TestGraft>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (childContext) {
                        graftOnRouteB = childContext.create<TestGraft>();
                        return const Scaffold(body: Text('Screen B'));
                      },
                    ),
                  );
                },
                child: const Text('Open B'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open B'));
    await tester.pumpAndSettle();

    expect(graftOnRouteA, isNotNull);
    expect(graftOnRouteB, isNotNull);
    // Verified distinct instances
    expect(identical(graftOnRouteA, graftOnRouteB), isFalse);
  });

  testWidgets(
      'GraftRegistry.registerSingleton is lazy by default, never re-created, and never route-disposed',
      (tester) async {
    // Register as global persistent singleton (lazy by default)
    GraftRegistry.registerSingleton<TestGraft>(TestGraft.new);

    TestGraft? graftOnRouteA;
    TestGraft? graftOnRouteB;

    final observer = GraftRouteObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  graftOnRouteA = context.use<TestGraft>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (childContext) {
                        // Even create() must return the singleton and never re-create!
                        graftOnRouteB = childContext.create<TestGraft>();
                        return Scaffold(
                          body: ElevatedButton(
                            onPressed: () => Navigator.of(childContext).pop(),
                            child: const Text('Pop B'),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open B'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open B'));
    await tester.pumpAndSettle();

    expect(graftOnRouteA, isNotNull);
    expect(graftOnRouteB, isNotNull);
    // Verified: Both receive the exact same singleton instance even with create()!
    expect(identical(graftOnRouteA, graftOnRouteB), isTrue);

    // Pop Route B
    await tester.tap(find.text('Pop B'));
    await tester.pumpAndSettle();
    expect(graftOnRouteA!.isDisposed, isFalse);

    // Pop Route A
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Verified: NOT disposed even when Route A is popped!
    expect(graftOnRouteA!.isDisposed, isFalse);
  });

  test('GraftRegistry.registerSingleton with lazy: false instantiates immediately', () {
    int creations = 0;
    TestGraft createFn() {
      creations++;
      return TestGraft();
    }

    // Eager creation (lazy: false)
    GraftRegistry.registerSingleton<TestGraft>(createFn, lazy: false);
    expect(creations, 1, reason: 'Should have instantiated immediately at registration');

    final instance1 = GraftRegistry.getOrCreateSingleton<TestGraft>();
    final instance2 = GraftRegistry.getOrCreateSingleton<TestGraft>();
    expect(creations, 1);
    expect(identical(instance1, instance2), isTrue);
  });

  testWidgets(
      'Multi-hop route stack inheritance: Route A -> Route B -> Route C reuses instance; popping B and C keeps alive; popping A disposes',
      (tester) async {
    TestGraft? graftA;
    TestGraft? graftB;
    TestGraft? graftC;

    final observer = GraftRouteObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Builder(
          builder: (contextA) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  graftA = contextA.use<TestGraft>();
                  Navigator.of(contextA).push(
                    MaterialPageRoute(
                      builder: (contextB) {
                        graftB = contextB.use<TestGraft>();
                        return Scaffold(
                          body: ElevatedButton(
                            onPressed: () {
                              Navigator.of(contextB).push(
                                MaterialPageRoute(
                                  builder: (contextC) {
                                    graftC = contextC.use<TestGraft>();
                                    return Scaffold(
                                      body: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(contextC).pop(),
                                        child: const Text('Pop C'),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text('Open C'),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open B'),
              ),
            );
          },
        ),
      ),
    );

    // Open B
    await tester.tap(find.text('Open B'));
    await tester.pumpAndSettle();

    // Open C
    await tester.tap(find.text('Open C'));
    await tester.pumpAndSettle();

    // Verify all 3 screens share the exact same instance from Screen A!
    expect(identical(graftA, graftB), isTrue);
    expect(identical(graftB, graftC), isTrue);
    expect(graftA!.isDisposed, isFalse);

    // Pop C
    await tester.tap(find.text('Pop C'));
    await tester.pumpAndSettle();
    expect(graftA!.isDisposed, isFalse);

    // Pop B
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pop();
    await tester.pumpAndSettle();
    expect(graftA!.isDisposed, isFalse);

    // Pop A (Owner)
    nav.pop();
    await tester.pumpAndSettle();
    expect(graftA!.isDisposed, isTrue);
  });
}
