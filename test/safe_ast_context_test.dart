import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class SafeThemeState extends GraftState {
  String title;
  int count;

  SafeThemeState({this.title = 'Hello', this.count = 0});

  @override
  GraftProps get props => propsOf(title, count);
}

class SafeThemeGraft extends Graft<SafeThemeState> {
  SafeThemeGraft() : super(SafeThemeState());

  void updateTitle(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

class ThemedCustomCard extends StatelessWidget {
  final String label;
  const ThemedCustomCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    // Reads Theme from context - must NOT leak dependency to ancestor diff engine
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      color: primaryColor,
      child: Text(label),
    );
  }
}

class KeyedCustomTile extends StatelessWidget {
  final String text;
  const KeyedCustomTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

void main() {
  group('Pillar 3: Safe AST Reconciliation & Context Isolation Tests', () {
    testWidgets('StatelessWidget reading Theme.of(context) does not register dependency on ancestor DiffEngine', (tester) async {
      final graft = SafeThemeGraft();
      ThemeData activeTheme = ThemeData.light();
      late StateSetter themeSetter;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            themeSetter = setState;
            return MaterialApp(
              theme: activeTheme,
              home: Scaffold(
                body: graft.slots(
                  layout: Column(children: slots),
                  slots: [
                    (s) => ThemedCustomCard(label: s.title),
                    (s) => Text('Count: ${s.count}'),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      // Mutate title
      graft.updateTitle('Updated Title');
      await tester.pump();
      expect(find.text('Updated Title'), findsOneWidget);

      // Change theme from Light to Dark
      themeSetter(() {
        activeTheme = ThemeData.dark();
      });
      await tester.pump();

      // Card must be present and render under new theme
      expect(find.text('Updated Title'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      graft.dispose();
    });

    testWidgets('Custom widgets with identical runtimeType and key bypass diff cleanly', (tester) async {
      final graft = SafeThemeGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.slots(
              layout: Column(children: slots),
              slots: [
                const KeyedCustomTile(key: ValueKey('static_tile'), text: 'Static'),
                (s) => Text('Count: ${s.count}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Static'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      // Update count
      graft.increment();
      await tester.pump();

      expect(find.text('Static'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);

      graft.dispose();
    });
  });
}
