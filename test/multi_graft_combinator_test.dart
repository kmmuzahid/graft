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
  List<Object?> get tracked => [name, email];
}

class UserGraft extends Graft<UserState> {
  UserGraft() : super(UserState());

  void updateName(String name) => mutate((s) => s..name = name);
  void updateEmail(String email) => mutate((s) => s..email = email);
}

class ThemeState extends GraftState {
  bool isDark;
  String accent;

  ThemeState({this.isDark = false, this.accent = 'purple'});

  @override
  List<Object?> get tracked => [isDark, accent];
}

class ThemeGraft extends Graft<ThemeState> {
  ThemeGraft() : super(ThemeState());

  void toggleTheme() => mutate((s) => s..isDark = !s.isDark);
  void setAccent(String accent) => mutate((s) => s..accent = accent);
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

  group('Multi-Graft Combinator Boundary Tests', () {
    testWidgets('Dart 3 Record syntax (userGraft, themeGraft).graft(...) combines seamlessly',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      int leafBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParentContainer(
              // Dart 3 Record Syntax:
              child: (userGraft, themeGraft).graft(
                (user, theme) {
                  leafBuildCount++;
                  return Text('${user.name} - ${theme.isDark ? "Dark" : "Light"}');
                },
              ),
            ),
          ),
        ),
      );

      expect(ParentContainer.buildCount, 1);
      expect(leafBuildCount, 1);
      expect(find.text('Alice - Light'), findsOneWidget);

      // 1. Update User -> only leaf rebuilds
      userGraft.updateName('Bob');
      await tester.pump();

      expect(ParentContainer.buildCount, 1, reason: 'Parent must have 0 rebuilds');
      expect(leafBuildCount, 2, reason: 'Leaf rebuilds on user update');
      expect(find.text('Bob - Light'), findsOneWidget);

      // 2. Update Theme -> only leaf rebuilds
      themeGraft.toggleTheme();
      await tester.pump();

      expect(ParentContainer.buildCount, 1, reason: 'Parent must have 0 rebuilds');
      expect(leafBuildCount, 3, reason: 'Leaf rebuilds on theme update');
      expect(find.text('Bob - Dark'), findsOneWidget);

      userGraft.dispose();
      themeGraft.dispose();
    });

    testWidgets('Callable record syntax (userGraft, themeGraft)((u, t) => ...) works cleanly',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Callable syntax on record:
            body: (userGraft, themeGraft)(
              (user, theme) => Text('${user.name} [${theme.accent}]'),
            ),
          ),
        ),
      );

      expect(find.text('Alice [purple]'), findsOneWidget);

      themeGraft.setAccent('teal');
      await tester.pump();

      expect(find.text('Alice [teal]'), findsOneWidget);

      userGraft.dispose();
      themeGraft.dispose();
    });

    testWidgets('Fluent userGraft.combine(themeGraft, ...) works cleanly',
        (tester) async {
      final userGraft = UserGraft();
      final themeGraft = ThemeGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: userGraft.combine(
              themeGraft,
              (user, theme) => Text('${user.name} - ${theme.accent}'),
            ),
          ),
        ),
      );

      expect(find.text('Alice - purple'), findsOneWidget);

      userGraft.updateName('Charlie');
      await tester.pump();

      expect(find.text('Charlie - purple'), findsOneWidget);

      userGraft.dispose();
      themeGraft.dispose();
    });
  });
}
