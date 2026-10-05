import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class BoundaryUserState extends GraftState {
  String name;
  String role;
  int counter;

  BoundaryUserState({
    this.name = 'Alice',
    this.role = 'Engineer',
    this.counter = 0,
  });

  @override
  List<Object?> get tracked => [name, role, counter];
}

class BoundaryUserGraft extends Graft<BoundaryUserState> {
  BoundaryUserGraft() : super(BoundaryUserState());

  void updateName(String name) {
    state
      ..name = name
      ..update();
  }

  void updateRole(String role) {
    state
      ..role = role
      ..update();
  }

  void increment() {
    state
      ..counter = state.counter + 1
      ..update();
  }
}

class ParentInspectorContainer extends StatelessWidget {
  static int buildCount = 0;
  final Widget child;

  const ParentInspectorContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Container(
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

class DeepNestedShell extends StatelessWidget {
  static int buildCount = 0;
  final Widget child;

  const DeepNestedShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class BoundaryLeafText extends StatelessWidget {
  static int nameBuildCount = 0;
  static int roleBuildCount = 0;

  final String text;
  final bool isName;

  const BoundaryLeafText(this.text, {super.key, required this.isName});

  @override
  Widget build(BuildContext context) {
    if (isName) {
      nameBuildCount++;
    } else {
      roleBuildCount++;
    }
    return Text(text);
  }
}

void main() {
  setUp(() {
    ParentInspectorContainer.buildCount = 0;
    DeepNestedShell.buildCount = 0;
    BoundaryLeafText.nameBuildCount = 0;
    BoundaryLeafText.roleBuildCount = 0;
  });

  testWidgets('GraftBoundary provides Depth-N rebuild firewall: parents have 0 rebuilds', (tester) async {
    final graft = BoundaryUserGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParentInspectorContainer(
            child: DeepNestedShell(
              child: Column(
                children: [
                  const Text('Static Header in Deep Tree'),
                  // GraftBoundary shields entire parent hierarchy with field bitmask filtering
                  GraftBoundary(
                    () => BoundaryLeafText(
                      'Name: ${graft.state.name}',
                      isName: true,
                    ),
                    graft: graft,
                    field: 0, // Watched field: name
                  ),
                  // Extension helper graft.boundary with field filtering
                  graft.boundary(
                    () => BoundaryLeafText(
                      'Role: ${graft.state.role}',
                      isName: false,
                    ),
                    field: 1, // Watched field: role
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Initial mount build counts
    expect(ParentInspectorContainer.buildCount, 1);
    expect(DeepNestedShell.buildCount, 1);
    expect(BoundaryLeafText.nameBuildCount, 1);
    expect(BoundaryLeafText.roleBuildCount, 1);
    expect(find.text('Name: Alice'), findsOneWidget);
    expect(find.text('Role: Engineer'), findsOneWidget);

    // 1. Update Name -> triggers boundary leaf rebuild
    graft.updateName('Bob');
    await tester.pump();

    // The parents MUST NOT REBUILD
    expect(ParentInspectorContainer.buildCount, 1,
        reason: 'Outer ParentInspectorContainer must have 0 rebuilds');
    expect(DeepNestedShell.buildCount, 1,
        reason: 'DeepNestedShell must have 0 rebuilds');
    // Name leaf rebuilds, Role leaf does NOT rebuild because field: 1 was clean!
    expect(BoundaryLeafText.nameBuildCount, 2,
        reason: 'Name leaf inside boundary must rebuild to show new name');
    expect(BoundaryLeafText.roleBuildCount, 1,
        reason: 'Role leaf inside boundary with field: 1 must have 0 rebuilds');
    expect(find.text('Name: Bob'), findsOneWidget);

    // 2. Update Role -> triggers boundary leaf rebuild
    graft.updateRole('Architect');
    await tester.pump();

    expect(ParentInspectorContainer.buildCount, 1,
        reason: 'Outer parent still 0 rebuilds');
    expect(DeepNestedShell.buildCount, 1,
        reason: 'Shell container still 0 rebuilds');
    expect(BoundaryLeafText.nameBuildCount, 2,
        reason: 'Name leaf with field: 0 must have 0 rebuilds on role update');
    expect(BoundaryLeafText.roleBuildCount, 2,
        reason: 'Role leaf with field: 1 must rebuild to show new role');
    expect(find.text('Role: Architect'), findsOneWidget);

    graft.dispose();
  });

  testWidgets('GraftBoundary without field parameter acts as a pure zero-boilerplate firewall', (tester) async {
    final graft = BoundaryUserGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParentInspectorContainer(
            child: DeepNestedShell(
              child: Column(
                children: [
                  const Text('Static Header in Deep Tree'),
                  // Pure zero-boilerplate boundary without any field parameter
                  graft.boundary(
                    () => BoundaryLeafText(
                      'Name: ${graft.state.name}',
                      isName: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(ParentInspectorContainer.buildCount, 1);
    expect(DeepNestedShell.buildCount, 1);
    expect(BoundaryLeafText.nameBuildCount, 1);

    graft.updateName('Charlie');
    await tester.pump();

    // Parents STILL have 0 rebuilds!
    expect(ParentInspectorContainer.buildCount, 1, reason: 'Parent container never rebuilds');
    expect(DeepNestedShell.buildCount, 1, reason: 'DeepNestedShell never rebuilds');
    expect(BoundaryLeafText.nameBuildCount, 2, reason: 'Only the leaf inside boundary rebuilds');
    expect(find.text('Name: Charlie'), findsOneWidget);

    graft.dispose();
  });
}
