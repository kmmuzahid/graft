import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class CounterState extends GraftState {
  int count;
  CounterState(this.count);

  @override
  GraftProps get props => propsOf(count);
}

class CounterGraft extends Graft<CounterState> {
  CounterGraft() : super(CounterState(0));

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

void main() {
  group('Listenable Interop Tests (Graft implements Listenable)', () {
    testWidgets('Graft works directly with Flutter ListenableBuilder without wrappers',
        (tester) async {
      final counterGraft = CounterGraft();
      int builds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListenableBuilder(
              listenable: counterGraft,
              builder: (context, _) {
                builds++;
                return Text('Count: ${counterGraft.state.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
      expect(builds, 1);

      // Increment
      counterGraft.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(builds, 2);

      counterGraft.dispose();
    });

    testWidgets('Graft works directly with AnimatedBuilder as a Listenable',
        (tester) async {
      final counterGraft = CounterGraft();
      int builds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBuilder(
              animation: counterGraft,
              builder: (context, _) {
                builds++;
                return Text('Value: ${counterGraft.state.count}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: 0'), findsOneWidget);
      expect(builds, 1);

      counterGraft.increment();
      await tester.pump();

      expect(find.text('Value: 1'), findsOneWidget);
      expect(builds, 2);

      counterGraft.dispose();
    });
  });
}

