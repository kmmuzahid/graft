import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class TabCounterState extends GraftState {
  int count;
  TabCounterState({this.count = 0});

  @override
  List<Object?> get props => [count];
}

class TabCounterGraft extends Graft<TabCounterState> {
  TabCounterGraft() : super(TabCounterState());

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    final graft = context.use<TabCounterGraft>();
    return graft((s) => Text('Screen A Count: ${s.count}'));
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({super.key});

  @override
  Widget build(BuildContext context) {
    // Borrows instance from Screen A in the same navigator
    final graft = context.use<TabCounterGraft>();
    return graft((s) => Text('Screen B Count: ${s.count}'));
  }
}

void main() {
  setUp(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
    GraftRegistry.register<TabCounterGraft>(TabCounterGraft.new);
  });

  tearDown(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
  });

  group('Pillar 4: Nested Route & Declarative Navigator Isolation Tests', () {
    testWidgets('context.use<T>() in local ModalRoute disposes automatically when route.popped fires', (tester) async {
      late TabCounterGraft capturedGraft;

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [GraftRouteObserver()],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) {
                          capturedGraft = ctx.use<TabCounterGraft>();
                          return const ScreenA();
                        },
                      ),
                    );
                  },
                  child: const Text('Push'),
                );
              },
            ),
          ),
        ),
      );

      // Push Route
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.text('Screen A Count: 0'), findsOneWidget);
      expect(capturedGraft.isDisposed, isFalse);

      // Pop Route
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.pop();
      await tester.pumpAndSettle();

      // Captured graft must be disposed on pop
      expect(capturedGraft.isDisposed, isTrue);
    });

    testWidgets('Two parallel navigators (Bottom Tabs) maintain completely isolated Graft instances', (tester) async {
      late TabCounterGraft tab1Graft;
      late TabCounterGraft tab2Graft;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute(
                      builder: (ctx) {
                        tab1Graft = ctx.use<TabCounterGraft>();
                        return Column(
                          children: [
                            tab1Graft((s) => Text('Tab 1: ${s.count}')),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute(
                      builder: (ctx) {
                        tab2Graft = ctx.use<TabCounterGraft>();
                        return Column(
                          children: [
                            tab2Graft((s) => Text('Tab 2: ${s.count}')),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tab 1: 0'), findsOneWidget);
      expect(find.text('Tab 2: 0'), findsOneWidget);

      // Two different navigators MUST NOT borrow each other's instances:
      expect(identical(tab1Graft, tab2Graft), isFalse);

      // Mutate Tab 1
      tab1Graft.increment();
      await tester.pump();

      expect(find.text('Tab 1: 1'), findsOneWidget);
      expect(find.text('Tab 2: 0'), findsOneWidget);

      // Mutate Tab 2
      tab2Graft.increment();
      tab2Graft.increment();
      await tester.pump();

      expect(find.text('Tab 1: 1'), findsOneWidget);
      expect(find.text('Tab 2: 2'), findsOneWidget);
    });

    testWidgets('Screen B borrows Screen A instance within the same Navigator', (tester) async {
      late TabCounterGraft graftA;
      late TabCounterGraft graftB;

      final key = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          navigatorObservers: [GraftRouteObserver()],
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                graftA = ctx.use<TabCounterGraft>();
                return const ScreenA();
              },
            ),
          ),
        ),
      );

      expect(find.text('Screen A Count: 0'), findsOneWidget);

      // Push Screen B inside the SAME navigator
      key.currentState!.push(
        MaterialPageRoute(
          builder: (ctx) {
            graftB = ctx.use<TabCounterGraft>();
            return const ScreenB();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Screen B Count: 0'), findsOneWidget);
      // Within the same navigator, Screen B borrows Screen A's instance:
      expect(identical(graftA, graftB), isTrue);

      graftA.increment();
      await tester.pump();

      expect(find.text('Screen B Count: 1'), findsOneWidget);
    });
  });
}
