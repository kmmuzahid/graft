import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

// =============================================================================
// MODELS FOR MULTI-GRAFT COMBINATOR TESTS
// =============================================================================

class UserState extends GraftState {
  String name;
  String email;

  UserState({this.name = 'Alice', this.email = 'alice@example.com'});

  @override
  List<Object?> get props => [name, email];

  @override
  void onReset() {
    name = 'Alice';
    email = 'alice@example.com';
  }
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String name) => state..name = name..update();
  void updateEmail(String email) => state..email = email..update();
}

class ThemeState extends GraftState {
  bool isDark;
  String accent;

  ThemeState({this.isDark = false, this.accent = 'purple'});

  @override
  List<Object?> get props => [isDark, accent];

  @override
  void onReset() {
    isDark = false;
    accent = 'purple';
  }
}

class ThemeGraft extends Graft<ThemeState> {
  ThemeGraft() : super(ThemeState());

  void toggleTheme() => state..isDark = !state.isDark..update();
  void setAccent(String accent) => state..accent = accent..update();
}

class ParentContainer extends StatelessWidget {
  static int buildCount = 0;
  final Widget child;

  const ParentContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Container(child: child);
  }
}

// =============================================================================
// TEST SUITE
// =============================================================================

void main() {
  setUp(() {
    ParentContainer.buildCount = 0;
  });

  group('Multi-Graft Boundary Tests', () {
    testWidgets(
        'GraftBoundary auto-discovers multiple grafts seamlessly with 0 parent rebuilds',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      int leafBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParentContainer(
              child: GraftBoundary(
                builder: (context) {
                  leafBuildCount++;
                  return Text(
                      '${userGraft.state.name} - ${themeGraft.state.isDark ? "Dark" : "Light"}');
                },
              ),
            ),
          ),
        ),
      );

      expect(ParentContainer.buildCount, 1);
      expect(leafBuildCount, 1);
      expect(find.text('Alice - Light'), findsOneWidget);

      // 1. Update User -> only boundary rebuilds
      userGraft.updateName('Bob');
      await tester.pump();

      expect(ParentContainer.buildCount, 1,
          reason: 'Parent must have 0 rebuilds');
      expect(leafBuildCount, 2, reason: 'Boundary rebuilds on user update');
      expect(find.text('Bob - Light'), findsOneWidget);

      // 2. Update Theme -> only boundary rebuilds
      themeGraft.toggleTheme();
      await tester.pump();

      expect(ParentContainer.buildCount, 1,
          reason: 'Parent must have 0 rebuilds');
      expect(leafBuildCount, 3, reason: 'Boundary rebuilds on theme update');
      expect(find.text('Bob - Dark'), findsOneWidget);

      userGraft.dispose();
      themeGraft.dispose();
    });

    testWidgets(
        'GraftBoundary with fine-grained leaf slots inside',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GraftBoundary(
              builder: (context) => Row(
                children: [
                  userGraft((s) => Text(s.name)),
                  const SizedBox(width: 8),
                  themeGraft((s) => Text(s.accent)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('purple'), findsOneWidget);

      themeGraft.setAccent('teal');
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('teal'), findsOneWidget);

      userGraft.dispose();
      themeGraft.dispose();
    });
  });
}
