import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

// =============================================================================
// MODELS FOR AUTOMATION TESTS
// =============================================================================

class AutoCounterState extends GraftState {
  int count;
  String title;

  AutoCounterState({this.count = 0, this.title = 'Counter'});

  @override
  List<Object?> get props => [count, title];

  @override
  void onReset() {
    count = 0;
    title = 'Counter';
  }
}

class AutoCounterGraft extends Graft<AutoCounterState> {
  AutoCounterGraft() : super(AutoCounterState());

  void increment() {
    state
      ..count += 1
      ..update();
  }

  void rename(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }
}

// =============================================================================
// TEST SUITE
// =============================================================================

void main() {
  setUp(() {
    GraftRouteTracker.reset();
    GraftRegistry.reset();
  });

  tearDown(() {
    GraftRouteTracker.reset();
    GraftRegistry.reset();
  });

  group('Automation & API Reduction Verifications', () {
    test('state..update() synchronously updates state and dispatches mask notifications',
        () {
      final graft = AutoCounterGraft();
      GraftMask? maskNotified;
      graft.addMaskListener((mask) => maskNotified = mask);

      graft.increment();

      expect(graft.state.count, 1);
      // count is index 0 -> isBitSet(0)
      expect(maskNotified, isNotNull);
      expect(maskNotified!.isBitSet(0), isTrue);

      graft.rename('New Title');
      expect(graft.state.title, 'New Title');
      // title is index 1 -> isBitSet(1)
      expect(maskNotified!.isBitSet(1), isTrue);

      graft.dispose();
    });

    testWidgets(
        'Callable graft((s) => ...) syntax renders and updates dynamically',
        (tester) async {
      final graft = AutoCounterGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Callable syntax: graft((s) => ...)
            body: graft((s) => Text('Count: ${s.count}')),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      graft.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      graft.dispose();
    });

    testWidgets(
        'graft.column and graft.row multi-child layout helpers diff cleanly',
        (tester) async {
      final graft = AutoCounterGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.column(
              children: (s) => [
                Text('Title: ${s.title}'),
                Text('Count: ${s.count}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Title: Counter'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      graft.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('Title: Counter'), findsOneWidget);

      graft.dispose();
    });

    testWidgets(
        'context.use(AutoCounterGraft.new) instantiates with ZERO setup in main()',
        (tester) async {
      // Clear any prior registry to prove zero pre-registration is needed
      GraftRegistry.reset();

      AutoCounterGraft? capturedGraft;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final graft = context.use(AutoCounterGraft.new);
              capturedGraft = graft;
              return Scaffold(
                body: graft((s) => Text('Resolved: ${s.count}')),
              );
            },
          ),
        ),
      );

      expect(find.text('Resolved: 0'), findsOneWidget);
      expect(capturedGraft, isNotNull);
      expect(capturedGraft!.state.count, 0);

      capturedGraft!.increment();
      await tester.pump();

      expect(find.text('Resolved: 1'), findsOneWidget);
    });

    testWidgets(
        'Route pop automatically disposes Graft via standard Flutter route.popped',
        (tester) async {
      AutoCounterGraft? screenGraft;

      final key = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      // Push second screen (without ANY GraftRouteObserver in navigatorObservers!)
      key.currentState!.push(
        MaterialPageRoute(
          builder: (context) {
            screenGraft = context.use(AutoCounterGraft.new);
            return const Scaffold(body: Text('Second Screen'));
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Second Screen'), findsOneWidget);
      expect(screenGraft, isNotNull);
      expect(screenGraft!.isDisposed, isFalse);

      // Pop the screen
      key.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      // Automatically cleaned up on route pop!
      expect(screenGraft!.isDisposed, isTrue,
          reason: 'Graft must auto-dispose on route pop via route.popped');
    });
  });
}
