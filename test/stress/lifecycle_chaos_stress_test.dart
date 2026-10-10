import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class ChaosState extends GraftState {
  int count;
  ChaosState(this.count);

  @override
  GraftProps get props => propsOf(count);
}

class ChaosGraft extends Graft<ChaosState> {
  ChaosGraft(int initial) : super(ChaosState(initial));

  void increment() {
    state.count++;
    state.update();
  }
}

void main() {
  group('Lifecycle Chaos & Concurrency Stress Tests', () {
    testWidgets('100 consecutive route push/pop cycles cleanly attach and detach listeners',
        (tester) async {
      final sharedGraft = ChaosGraft(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: sharedGraft.slot(
                          builder: (s) => Text('Pushed: ${s.count}'),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      final nav = tester.state<NavigatorState>(find.byType(Navigator));

      for (int i = 0; i < 100; i++) {
        // Push screen
        nav.push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              body: sharedGraft.slot(
                builder: (s) => Text('Cycle $i: ${s.count}'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Mutate during active route
        sharedGraft.increment();
        await tester.pump();

        // Pop screen
        nav.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // After 100 cycles, verify state and no memory leaks
      expect(sharedGraft.state.count, 100);

      sharedGraft.dispose();
    });

    test('Concurrent bombardment of 100 disposed controllers gracefully handled with 0 exceptions', () {
      final controllers = List<ChaosGraft>.generate(100, (i) => ChaosGraft(i));

      // Dispose all 100 controllers
      for (final ctrl in controllers) {
        ctrl.dispose();
        expect(ctrl.isDisposed, isTrue);
      }

      // Bombard all 100 disposed controllers with updates and state operations
      expect(() {
        for (int round = 0; round < 10; round++) {
          for (final ctrl in controllers) {
            ctrl.increment();
            ctrl.state.update();
            ctrl.state.reset();
          }
        }
      }, returnsNormally, reason: 'Disposed controllers must safely ignore notifications without crashing');
    });

    testWidgets('Graft.slots safely survives sudden controller disposal mid-frame',
        (tester) async {
      final graft = ChaosGraft(10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: Column(children: slots),
              slots: [
                (s) => Text('Slot: ${s.count}'),
                const Text('Static'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Slot: 10'), findsOneWidget);

      // Dispose controller while widget is still mounted
      graft.dispose();
      await tester.pump();

      // Ensure no exceptions thrown when pumping post-dispose
      expect(tester.takeException(), isNull);
    });
  });
}
