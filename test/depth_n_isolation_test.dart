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
  GraftProps get props => propsOf(name, role, counter);
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
      ..counter += 1
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

class BoundaryLeafText extends StatelessWidget implements GraftEquivalent {
  static int nameBuildCount = 0;
  static int roleBuildCount = 0;

  final String text;
  final bool isName;

  const BoundaryLeafText(this.text, {super.key, required this.isName});

  @override
  bool isEquivalentTo(Widget other) {
    return other is BoundaryLeafText &&
        other.text == text &&
        other.isName == isName;
  }

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

  testWidgets(
      'graft((s) => ...) provides Depth-N rebuild isolation: parents have 0 rebuilds',
      (tester) async {
    final graft = BoundaryUserGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParentInspectorContainer(
            child: DeepNestedShell(
              child: Column(
                children: [
                  const Text('Static Header in Deep Tree'),
                  // graft((s) => ...) shields entire parent hierarchy
                  graft(
                    (s) => BoundaryLeafText(
                      'Name: ${s.name}',
                      isName: true,
                    ),
                  ),
                  // Second isolated leaf slot: automatically diffs without magic numbers
                  graft(
                    (s) => BoundaryLeafText(
                      'Role: ${s.role}',
                      isName: false,
                    ),
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

    // 1. Update Name -> triggers only Name leaf rebuild
    graft.updateName('Bob');
    await tester.pump();

    // The parents MUST NOT REBUILD
    expect(ParentInspectorContainer.buildCount, 1,
        reason: 'Outer ParentInspectorContainer must have 0 rebuilds');
    expect(DeepNestedShell.buildCount, 1,
        reason: 'DeepNestedShell must have 0 rebuilds');
    // Name leaf rebuilds, Role leaf does NOT rebuild because content is equivalent!
    expect(BoundaryLeafText.nameBuildCount, 2,
        reason: 'Name leaf must rebuild to show new name');
    expect(BoundaryLeafText.roleBuildCount, 1,
        reason: 'Role leaf must have 0 rebuilds when role is unchanged');
    expect(find.text('Name: Bob'), findsOneWidget);

    // 2. Update Role -> triggers only Role leaf rebuild
    graft.updateRole('Architect');
    await tester.pump();

    expect(ParentInspectorContainer.buildCount, 1,
        reason: 'Outer parent still 0 rebuilds');
    expect(DeepNestedShell.buildCount, 1,
        reason: 'Shell container still 0 rebuilds');
    expect(BoundaryLeafText.nameBuildCount, 2,
        reason: 'Name leaf must have 0 rebuilds on role update');
    expect(BoundaryLeafText.roleBuildCount, 2,
        reason: 'Role leaf must rebuild to show new role');
    expect(find.text('Role: Architect'), findsOneWidget);

    graft.dispose();
  });

  testWidgets(
      'graft.slot isolates deeply nested leaf widgets with 0 parent rebuilds',
      (tester) async {
    final graft = BoundaryUserGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParentInspectorContainer(
            child: DeepNestedShell(
              child: Column(
                children: [
                  const Text('Static Header in Deep Tree'),
                  graft.slot(
                    builder: (s) => BoundaryLeafText(
                      'Name: ${s.name}',
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
    expect(ParentInspectorContainer.buildCount, 1,
        reason: 'Parent container never rebuilds');
    expect(DeepNestedShell.buildCount, 1,
        reason: 'DeepNestedShell never rebuilds');
    expect(BoundaryLeafText.nameBuildCount, 2,
        reason: 'Leaf rebuilt to show Charlie');
    expect(find.text('Name: Charlie'), findsOneWidget);

    graft.dispose();
  });
}
