import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class MockGraft extends Graft<MockState> {
  MockGraft() : super(MockState());
}

class MockState extends GraftState {}

class AnotherGraft extends Graft<MockState> {
  AnotherGraft() : super(MockState());
}

void main() {
  group('GraftRouteTracker & GraftRouteObserver Extended Tests', () {
    tearDown(() {
      GraftRouteTracker.reset();
      GraftRegistry.reset();
    });

    testWidgets('GraftRouteTracker didRemove disposes owned grafts', (tester) async {
      final routeA = MaterialPageRoute(builder: (_) => const SizedBox());
      final routeB = MaterialPageRoute(builder: (_) => const SizedBox());

      GraftRouteTracker.didPush(routeA, null);
      GraftRouteTracker.didPush(routeB, routeA);

      final graft = MockGraft();
      GraftRouteTracker.registerOwned(routeB, graft);

      expect(GraftRouteTracker.hasOwner(graft), isTrue);
      expect(graft.isDisposed, isFalse);

      GraftRouteTracker.didRemove(routeB, routeA);
      expect(graft.isDisposed, isTrue);
      expect(GraftRouteTracker.hasOwner(graft), isFalse);
    });

    testWidgets('GraftRouteTracker didReplace disposes oldRoute grafts and adds newRoute', (tester) async {
      final oldRoute = MaterialPageRoute(builder: (_) => const SizedBox());
      final newRoute = MaterialPageRoute(builder: (_) => const SizedBox());

      GraftRouteTracker.didPush(oldRoute, null);

      final graft = MockGraft();
      GraftRouteTracker.registerOwned(oldRoute, graft);

      expect(graft.isDisposed, isFalse);

      GraftRouteTracker.didReplace(newRoute: newRoute, oldRoute: oldRoute);

      expect(graft.isDisposed, isTrue);
      expect(GraftRouteTracker.hasOwner(graft), isFalse);
    });

    testWidgets('GraftRouteObserver forwards didRemove and didReplace', (tester) async {
      final observer = GraftRouteObserver();
      final routeA = MaterialPageRoute(builder: (_) => const SizedBox());
      final routeB = MaterialPageRoute(builder: (_) => const SizedBox());

      observer.didPush(routeA, null);
      final graft = MockGraft();
      GraftRouteTracker.registerOwned(routeA, graft);

      observer.didReplace(newRoute: routeB, oldRoute: routeA);
      expect(graft.isDisposed, isTrue);

      final graftB = MockGraft();
      GraftRouteTracker.registerOwned(routeB, graftB);
      observer.didRemove(routeB, null);
      expect(graftB.isDisposed, isTrue);
    });

    testWidgets('context.use throws StateError when type is unregistered and no fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [GraftRouteObserver()],
          home: Builder(
            builder: (context) {
              expect(
                () => context.use<AnotherGraft>(),
                throwsA(isA<StateError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('GraftRegistry fallbackLocator resolves unregistered instance if provided', (tester) async {
      final fallbackInstance = AnotherGraft();
      GraftRegistry.fallbackLocator = <T extends Object>() {
        if (T == AnotherGraft) return fallbackInstance as T;
        throw StateError('Not found');
      };

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [GraftRouteObserver()],
          home: Builder(
            builder: (context) {
              final resolved = context.use<AnotherGraft>();
              expect(resolved, equals(fallbackInstance));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('Private constructor test helpers', () {
      expect(GraftRegistry.createForTest(), isA<GraftRegistry>());
      expect(GraftRouteTracker.createForTest(), isA<GraftRouteTracker>());
    });

    testWidgets('GraftRouteTracker handles ownerRoute.popped future and adds unstacked route', (tester) async {
      final route = FakePopRoute();
      final graft = MockGraft();

      // Route is not in stack, triggers line 121
      GraftRouteTracker.registerOwned(route, graft);
      expect(GraftRouteTracker.hasOwner(graft), isTrue);

      // Trigger popped future on route, triggers line 130
      route.triggerPop();
      await tester.pump();

      expect(graft.isDisposed, isTrue);
    });
  });
}

class FakePopRoute extends Route<void> {
  final Completer<void> _completer = Completer<void>();

  @override
  Future<void> get popped => _completer.future;

  void triggerPop() {
    _completer.complete();
  }
}
