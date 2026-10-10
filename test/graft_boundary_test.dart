import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class UserState extends GraftState {
  String name;
  String email;

  UserState({this.name = 'Alice', this.email = 'alice@example.com'});

  @override
  GraftProps get props => propsOf(name, email);

  @override
  void onReset() {
    name = 'Alice';
    email = 'alice@example.com';
  }
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String name) {
    state
      ..name = name
      ..update();
  }

  void updateEmail(String email) {
    state
      ..email = email
      ..update();
  }
}

class ThemeState extends GraftState {
  bool isDark;
  String accent;

  ThemeState({this.isDark = false, this.accent = 'purple'});

  @override
  GraftProps get props => propsOf(isDark, accent);

  @override
  void onReset() {
    isDark = false;
    accent = 'purple';
  }
}

class ThemeGraft extends Graft<ThemeState> {
  ThemeGraft() : super(ThemeState());

  void toggleTheme() {
    state
      ..isDark = !state.isDark
      ..update();
  }

  void setAccent(String accent) {
    state
      ..accent = accent
      ..update();
  }
}

void main() {
  group('GraftBoundary Tests', () {
    testWidgets('Ambient Auto-Discovery: reads multiple Grafts without passing lists',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GraftBoundary(
              builder: (context) {
                return Text(
                  '${userGraft.state.name} - ${themeGraft.state.accent}',
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Alice - purple'), findsOneWidget);

      // Mutate UserGraft
      userGraft.updateName('Bob');
      await tester.pump();
      expect(find.text('Bob - purple'), findsOneWidget);

      // Mutate ThemeGraft
      themeGraft.setAccent('teal');
      await tester.pump();
      expect(find.text('Bob - teal'), findsOneWidget);
    });

    testWidgets('Backward Adaptive Learning: bypasses builder when unused field updates',
        (tester) async {
      final userGraft = UserGraft();
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GraftBoundary(
              builder: (context) {
                buildCount++;
                // Only reads 'name', NEVER reads 'email'
                return Text(userGraft.state.name);
              },
            ),
          ),
        ),
      );

      expect(buildCount, equals(1));
      expect(find.text('Alice'), findsOneWidget);

      // 1. Mutate 'name' (Field 0) -> UI changes -> Field 0 is learned!
      userGraft.updateName('Bob');
      await tester.pump();
      expect(buildCount, equals(2));
      expect(find.text('Bob'), findsOneWidget);

      // 2. Mutate 'email' (Field 1) -> Bit 1 does not intersect learned Bit 0 -> BYPASSED IMMEDIATELY!
      userGraft.updateEmail('bob@newdomain.com');
      await tester.pump();
      expect(buildCount, equals(2)); // Bypassed without calling builder!
      expect(find.text('Bob'), findsOneWidget);

      // 3. Mutate 'email' (Field 1) AGAIN -> Bypassed before running builder!
      userGraft.updateEmail('bob@third.com');
      await tester.pump();
      expect(buildCount, equals(2)); // Still 2! 0 builder calls, 0 allocations!
      expect(find.text('Bob'), findsOneWidget);

      // 4. Mutate 'name' again -> Rebuilds because Field 0 is active!
      userGraft.updateName('Charlie');
      await tester.pump();
      expect(buildCount, equals(3));
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('Tree Rebuild Insulation: parent widget experiences 0 rebuilds',
        (tester) async {
      final userGraft = UserGraft();
      int parentBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              parentBuildCount++;
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Parent Header'),
                    GraftBoundary(
                      builder: (context) => Text(userGraft.state.name),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(parentBuildCount, equals(1));
      expect(find.text('Alice'), findsOneWidget);

      // Mutate state inside GraftBoundary
      userGraft.updateName('David');
      await tester.pump();

      expect(find.text('David'), findsOneWidget);
      // Parent build count must remain strictly 1 (0 element rebuilds!)
      expect(parentBuildCount, equals(1));
    });

    testWidgets('state.reset() restores baseline and updates UI',
        (tester) async {
      final userGraft = UserGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GraftBoundary(
              builder: (context) => Text(userGraft.state.name),
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);

      userGraft.updateName('Zoe');
      await tester.pump();
      expect(find.text('Zoe'), findsOneWidget);

      // Reset state
      userGraft.reset();
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('HeavyPaintContainer above GraftBoundary inside graft.slots has 0 extra rebuilds',
        (tester) async {
      HeavyPaintContainer.buildCount = 0;
      final dashboardGraft = DashboardGraft();
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      int slot1BuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dashboardGraft.slots(
              layout: Column(children: slots),
              slots: [
                // ignore: prefer_const_constructors
                Text('Dashboard Header'),
                (s) => TrackedSlotWidget('Section: ${s.title}',
                    onBuild: () => slot1BuildCount++),
                HeavyPaintContainer(
                  child: GraftBoundary(
                    builder: (context) {
                      return Row(
                        children: [
                          Text('User: ${userGraft.state.name}'),
                          const SizedBox(width: 8),
                          Text('Theme: ${themeGraft.state.accent}'),
                        ],
                      );
                    },
                  ),
                ),
                // ignore: prefer_const_constructors
                Text('Dashboard Footer'),
              ],
            ),
          ),
        ),
      );

      // Initial mount: each slot builds once
      expect(HeavyPaintContainer.buildCount, equals(1));
      expect(slot1BuildCount, equals(1));
      expect(find.text('User: Alice'), findsOneWidget);
      expect(find.text('Theme: purple'), findsOneWidget);

      // 1. Mutate userGraft (read inside GraftBoundary)
      userGraft.updateName('Bob');
      await tester.pump();

      expect(find.text('User: Bob'), findsOneWidget);
      // HeavyPaintContainer is ABOVE GraftBoundary -> MUST HAVE 0 EXTRA REBUILDS!
      expect(HeavyPaintContainer.buildCount, equals(1),
          reason: 'HeavyPaintContainer above GraftBoundary never rebuilds when boundary state updates');
      expect(slot1BuildCount, equals(1),
          reason: 'Slot 1 never rebuilds when userGraft updates');

      // 2. Mutate themeGraft (read inside GraftBoundary)
      themeGraft.setAccent('gold');
      await tester.pump();

      expect(find.text('Theme: gold'), findsOneWidget);
      expect(HeavyPaintContainer.buildCount, equals(1),
          reason: 'HeavyPaintContainer stays at 1 build when themeGraft updates');
      expect(slot1BuildCount, equals(1));

      // 3. Mutate parent dashboardGraft title
      dashboardGraft.updateTitle('Reports');
      await tester.pump();

      expect(find.text('Section: Reports'), findsOneWidget);
      expect(slot1BuildCount, equals(2),
          reason: 'Slot 1 rebuilds when s.title changes');
      // HeavyPaintContainer unwraps and detects GraftBoundary equivalence -> 0 REBUILDS!
      expect(HeavyPaintContainer.buildCount, equals(1),
          reason: 'HeavyPaintContainer is equivalent and has 0 rebuilds even when parent slot diffs');

      dashboardGraft.dispose();
      userGraft.dispose();
      themeGraft.dispose();
    });
  });
}

class HeavyPaintContainer extends StatelessWidget implements GraftEquivalent {
  static int buildCount = 0;
  final Widget child;
  const HeavyPaintContainer({super.key, required this.child});

  @override
  bool isEquivalentTo(Widget other) => other is HeavyPaintContainer;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Container(
      color: Colors.black,
      child: child,
    );
  }
}

class DashboardState extends GraftState {
  String title;
  DashboardState({this.title = 'Analytics'});

  @override
  GraftProps get props => propsOf(title);
}

class DashboardGraft extends Graft<DashboardState> {
  DashboardGraft() : super(DashboardState());

  void updateTitle(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }
}

class TrackedSlotWidget extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback onBuild;

  const TrackedSlotWidget(this.text, {super.key, required this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedSlotWidget && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild();
    return Text(text);
  }
}

