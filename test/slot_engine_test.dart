import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class ProfileState extends GraftState {
  String name;
  String email;
  bool isVerified;
  bool isLoading;

  ProfileState({
    this.name = 'Alice',
    this.email = 'alice@example.com',
    this.isVerified = false,
    this.isLoading = false,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    bool? isVerified,
    bool? isLoading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileGraft extends Graft<ProfileState> {
  ProfileGraft() : super(ProfileState());

  void updateName(String newName) => emit(state.copyWith(name: newName));
  void updateEmail(String newEmail) => emit(state.copyWith(email: newEmail));
  void toggleVerified() => emit(state.copyWith(isVerified: !state.isVerified));
  void setLoading(bool loading) => emit(state.copyWith(isLoading: loading));
}

class ConstHeaderWidget extends StatelessWidget {
  static int buildCount = 0;
  const ConstHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return const Text('Const Header');
  }
}

class DynamicNameWidget extends StatelessWidget implements GraftEquivalent {
  static int buildCount = 0;
  final String name;
  const DynamicNameWidget(this.name, {super.key});

  @override
  bool isEquivalentTo(Widget other) =>
      other is DynamicNameWidget && name == other.name;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Text('Name: $name');
  }
}

class DynamicEmailWidget extends StatelessWidget implements GraftEquivalent {
  static int buildCount = 0;
  final String email;
  const DynamicEmailWidget(this.email, {super.key});

  @override
  bool isEquivalentTo(Widget other) =>
      other is DynamicEmailWidget && email == other.email;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Text('Email: $email');
  }
}

void main() {
  setUp(() {
    ConstHeaderWidget.buildCount = 0;
    DynamicNameWidget.buildCount = 0;
    DynamicEmailWidget.buildCount = 0;
  });

  testWidgets('graft.slots diffs slots and rebuilds ONLY the changed slot',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              const ConstHeaderWidget(),
              DynamicNameWidget(s.name),
              DynamicEmailWidget(s.email),
            ],
          ),
        ),
      ),
    );

    // Initial render: every slot built once
    expect(ConstHeaderWidget.buildCount, 1);
    expect(DynamicNameWidget.buildCount, 1);
    expect(DynamicEmailWidget.buildCount, 1);
    expect(find.text('Const Header'), findsOneWidget);
    expect(find.text('Name: Alice'), findsOneWidget);
    expect(find.text('Email: alice@example.com'), findsOneWidget);

    // 1. Update ONLY the name
    graft.updateName('Bob');
    await tester.pump();

    // Verify: ONLY DynamicNameWidget rebuilt! Const header and email had 0 rebuilds!
    expect(ConstHeaderWidget.buildCount, 1,
        reason: 'Const widget should have 0 extra rebuilds');
    expect(DynamicNameWidget.buildCount, 2,
        reason: 'Changed slot should have rebuilt once');
    expect(DynamicEmailWidget.buildCount, 1,
        reason: 'Unchanged slot should have 0 extra rebuilds');
    expect(find.text('Name: Bob'), findsOneWidget);

    // 2. Update ONLY the email
    graft.updateEmail('bob@example.com');
    await tester.pump();

    // Verify: ONLY DynamicEmailWidget rebuilt! Const header and name had 0 rebuilds!
    expect(ConstHeaderWidget.buildCount, 1,
        reason: 'Const widget should have 0 extra rebuilds');
    expect(DynamicNameWidget.buildCount, 2,
        reason: 'Unchanged slot should have 0 extra rebuilds');
    expect(DynamicEmailWidget.buildCount, 2,
        reason: 'Changed slot should have rebuilt once');
    expect(find.text('Email: bob@example.com'), findsOneWidget);

    graft.dispose();
  });

  testWidgets('graft.slots supports custom layout (e.g. Row)', (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Row(children: children),
            (s) => [
              Text('Rating: ${s.name}'),
              Text('Contact: ${s.email}'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(Row), findsOneWidget);
    expect(find.text('Rating: Alice'), findsOneWidget);
    expect(find.text('Contact: alice@example.com'), findsOneWidget);

    graft.updateName('Charlie');
    await tester.pump();

    expect(find.text('Rating: Charlie'), findsOneWidget);
    graft.dispose();
  });

  testWidgets('ListTile with graft.slot isolates slots and only rebuilds the changed slot',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListTile(
            leading: graft.slot((s) => DynamicNameWidget(s.name)),
            title: graft.slot((s) => DynamicEmailWidget(s.email)),
            trailing: const ConstHeaderWidget(),
          ),
        ),
      ),
    );

    expect(ConstHeaderWidget.buildCount, 1);
    expect(DynamicNameWidget.buildCount, 1);
    expect(DynamicEmailWidget.buildCount, 1);

    // Update ONLY name
    graft.updateName('Zoe');
    await tester.pump();

    // Only leading (name) rebuilt! title and trailing had 0 extra rebuilds!
    expect(ConstHeaderWidget.buildCount, 1,
        reason: 'Trailing const widget should have 0 extra rebuilds');
    expect(DynamicNameWidget.buildCount, 2,
        reason: 'Leading slot should have rebuilt once');
    expect(DynamicEmailWidget.buildCount, 1,
        reason: 'Title slot should have 0 extra rebuilds');

    // Update ONLY email
    graft.updateEmail('zoe@example.com');
    await tester.pump();

    // Only title (email) rebuilt! leading and trailing had 0 extra rebuilds!
    expect(ConstHeaderWidget.buildCount, 1,
        reason: 'Trailing const widget should have 0 extra rebuilds');
    expect(DynamicNameWidget.buildCount, 2,
        reason: 'Leading slot should have 0 extra rebuilds');
    expect(DynamicEmailWidget.buildCount, 2,
        reason: 'Title slot should have rebuilt once');

    graft.dispose();
  });

  testWidgets('graft.slots gracefully handles conditional list resizing with if',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              Text('Name: ${s.name}'),
              if (s.isVerified) const Text('Verified Badge'),
              Text('Email: ${s.email}'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name: Alice'), findsOneWidget);
    expect(find.text('Verified Badge'), findsNothing);
    expect(find.text('Email: alice@example.com'), findsOneWidget);

    // Mount conditional widget (list size 2 -> 3)
    graft.toggleVerified();
    await tester.pump();

    expect(find.text('Verified Badge'), findsOneWidget);

    // Update a property while expanded
    graft.updateName('Bob');
    await tester.pump();

    expect(find.text('Name: Bob'), findsOneWidget);
    expect(find.text('Verified Badge'), findsOneWidget);

    // Unmount conditional widget (list size 3 -> 2)
    graft.toggleVerified();
    await tester.pump();

    expect(find.text('Verified Badge'), findsNothing);
    expect(find.text('Name: Bob'), findsOneWidget);

    graft.dispose();
  });

  testWidgets(
      'graft.compute only rebuilds when the derived value changes, ignoring unrelated field changes',
      (tester) async {
    final graft = ProfileGraft();
    int computeBuilds = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.compute(
            (s) => s.isVerified,
            (isVerified) {
              computeBuilds++;
              return Text(isVerified ? 'VERIFIED' : 'NOT VERIFIED');
            },
          ),
        ),
      ),
    );

    expect(computeBuilds, 1);
    expect(find.text('NOT VERIFIED'), findsOneWidget);

    // 1. Update UNRELATED fields (name and email)
    graft.updateName('Dan');
    await tester.pump();
    graft.updateEmail('dan@example.com');
    await tester.pump();

    // Compute MUST have 0 extra rebuilds!
    expect(computeBuilds, 1,
        reason: 'Compute should ignore changes to name and email');

    // 2. Update COMPUTED field (isVerified)
    graft.toggleVerified();
    await tester.pump();

    expect(computeBuilds, 2, reason: 'Compute must rebuild when derived value changes');
    expect(find.text('VERIFIED'), findsOneWidget);

    graft.dispose();
  });

  testWidgets('graft.slot switches seamlessly between loading and content states',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slot((state) {
            if (state.isLoading) {
              return const Text('Loading...');
            }
            return Text('Content for ${state.name}');
          }),
        ),
      ),
    );

    expect(find.text('Content for Alice'), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);

    // Switch to Loading
    graft.setLoading(true);
    await tester.pump();

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('Content for Alice'), findsNothing);

    // Switch back to Content with new name
    graft.updateName('Elena');
    graft.setLoading(false);
    await tester.pump();

    expect(find.text('Content for Elena'), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);

    graft.dispose();
  });

  // ===========================================================================
  // ANTI-PATTERN & MISUSE RUNTIME GUARD TESTS
  // ===========================================================================

  testWidgets('Nesting graft.slot directly inside graft.slots throws FlutterError',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              graft.slot((s) => Text(s.name)),
            ],
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      (error as FlutterError).message,
      contains('GRAFT ANTI-PATTERN DETECTED: REDUNDANT NESTING'),
    );

    graft.dispose();
  });

  testWidgets('Nesting DIFFERENT grafts inside each other succeeds without error',
      (tester) async {
    final graftA = ProfileGraft();
    final graftB = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graftA.slots(
            (children) => Column(children: children),
            (sA) => [
              Text('User: ${sA.name}'),
              graftB.slot((sB) => Text('Other: ${sB.email}')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('User: Alice'), findsOneWidget);
    expect(find.text('Other: alice@example.com'), findsOneWidget);

    graftA.dispose();
    graftB.dispose();
  });

  testWidgets(
      'Arbitrary custom StatelessWidget (like CkText) inside graft.slots has 0 rebuilds on unrelated updates',
      (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              // Non-const 3rd-party-like widget without GraftEquivalent
              // ignore: prefer_const_constructors
              MockCkText('COREKIT EXAMPLE'),
              Text('Name: ${s.name}'),
              Text('Email: ${s.email}'),
            ],
          ),
        ),
      ),
    );

    // Initial mount build
    expect(find.text('COREKIT EXAMPLE'), findsOneWidget);
    expect(find.text('Name: Alice'), findsOneWidget);
    expect(find.text('Email: alice@example.com'), findsOneWidget);

    // Update email -> Email changes, CkText slot is NOT replaced
    final initialCkText = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;

    graft.updateEmail('bob@example.com');
    await tester.pump();

    final currentCkText = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;

    expect(find.text('Email: bob@example.com'), findsOneWidget);
    expect(identical(currentCkText, initialCkText), isTrue,
        reason: 'MockCkText slot must NOT be replaced when email changes');

    // Update name -> Name changes, CkText slot is NOT replaced
    graft.updateName('Charlie');
    await tester.pump();

    final latestCkText = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;

    expect(find.text('Name: Charlie'), findsOneWidget);
    expect(identical(latestCkText, initialCkText), isTrue,
        reason: 'MockCkText slot must NOT be replaced when name changes');

    graft.dispose();
  });

  testWidgets(
      'Widgets with explicit matching keys skip diffing and have 0 rebuilds',
      (tester) async {
    MockKeyedWidget.buildCount = 0;
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              const MockKeyedWidget(key: ValueKey('stable_key')),
              Text('Name: ${s.name}'),
            ],
          ),
        ),
      ),
    );

    expect(MockKeyedWidget.buildCount, equals(1));

    // Update name -> Keyed widget has 0 rebuilds (count stays 1!)
    graft.updateName('Charlie');
    await tester.pump();

    expect(MockKeyedWidget.buildCount, equals(1),
        reason: 'Keyed widget must never rebuild when key is equal');

    graft.dispose();
  });

  testWidgets(
      'GestureDetector and ElevatedButton with inline closures do not trigger slot rebuilds',
      (tester) async {
    final graft = ProfileGraft();
    int buttonClicks = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              GestureDetector(
                onTap: () => buttonClicks++,
                child: const Text('Tap Me'),
              ),
              ElevatedButton(
                onPressed: () => buttonClicks += 10,
                child: const Text('Submit Button'),
              ),
              Text('Name: ${s.name}'),
            ],
          ),
        ),
      ),
    );

    final initialGestureSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;
    final initialButtonSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[1]
        .value;

    expect(find.text('Tap Me'), findsOneWidget);
    expect(find.text('Submit Button'), findsOneWidget);
    expect(find.text('Name: Alice'), findsOneWidget);

    // Update name -> unrelated state change
    graft.updateName('Bob');
    await tester.pump();

    final currentGestureSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;
    final currentButtonSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[1]
        .value;

    // Both slots must NOT be replaced!
    expect(identical(currentGestureSlot, initialGestureSlot), isTrue,
        reason: 'GestureDetector slot must not be replaced');
    expect(identical(currentButtonSlot, initialButtonSlot), isTrue,
        reason: 'ElevatedButton slot must not be replaced');

    // Tap works
    await tester.tap(find.text('Tap Me'));
    expect(buttonClicks, 1);

    await tester.tap(find.text('Submit Button'));
    expect(buttonClicks, 11);

    graft.dispose();
  });

  testWidgets(
      'Composite design system widget with Row, Flexible, FittedBox does not replace slot',
      (tester) async {
    MockCompositeText.buildCount = 0;
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              const MockCompositeText('Fixed CoreKit Label'),
              Text(s.name),
            ],
          ),
        ),
      ),
    );

    final initialCompositeSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;

    expect(MockCompositeText.buildCount, 1);

    // Update unrelated state
    graft.updateName('Charlie');
    await tester.pump();

    final currentCompositeSlot = (tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>))
            as dynamic)
        .slotNotifiers[0]
        .value;

    expect(identical(currentCompositeSlot, initialCompositeSlot), isTrue,
        reason: 'Composite slot must not be replaced');
    expect(MockCompositeText.buildCount, 1,
        reason: 'MockCompositeText should have 0 rebuilds');
    expect(find.text('Charlie'), findsOneWidget);

    graft.dispose();
  });

  testWidgets(
      'Nested Graft slots inside Container has 0 rebuilds when parent Graft updates',
      (tester) async {
    final graftA = ProfileGraft();
    final graftB = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graftA.slots(
            (children) => Column(children: children),
            (sA) => [
              Text('Name: ${sA.name}'),
              Container(
                color: Colors.amber,
                padding: const EdgeInsets.all(8),
                child: graftB.slots(
                  (children) => Row(children: children),
                  (sB) => [
                    Text('Nested: ${sB.email}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Name: Alice'), findsOneWidget);
    expect(find.text('Nested: alice@example.com'), findsOneWidget);

    final parentEngine = tester.state(find.byType(GraftMultiChildDiffEngine<ProfileState>).first) as dynamic;
    final initialContainerSlot = parentEngine.slotNotifiers[1].value;

    // Update graftA (parent)
    graftA.updateName('Bob');
    await tester.pump();

    expect(find.text('Name: Bob'), findsOneWidget);

    final currentContainerSlot = parentEngine.slotNotifiers[1].value;
    expect(identical(currentContainerSlot, initialContainerSlot), isTrue,
        reason: 'Container wrapping nested graft.slots must not be rebuilt or replaced when parent updates');

    graftA.dispose();
    graftB.dispose();
  });

  testWidgets('graft.builder virtualizes list and isolates item rebuilds with layout callback', (tester) async {
    final graft = ProfileGraft();
    int buildCountAlice = 0;
    int buildCountBob = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.builder<String>(
            (itemCount, itemBuilder) => ListView.builder(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
            items: (s) => [s.name, s.email],
            itemBuilder: (context, val, index) {
              if (index == 0) buildCountAlice++;
              if (index == 1) buildCountBob++;
              return Text('Item $index: $val');
            },
          ),
        ),
      ),
    );

    expect(find.text('Item 0: Alice'), findsOneWidget);
    expect(find.text('Item 1: alice@example.com'), findsOneWidget);
    expect(buildCountAlice, 1);
    expect(buildCountBob, 1);

    // Update only name -> index 0 changes, index 1 must NOT rebuild
    graft.updateName('Charlie');
    await tester.pump();

    expect(find.text('Item 0: Charlie'), findsOneWidget);
    expect(find.text('Item 1: alice@example.com'), findsOneWidget);
    expect(buildCountAlice, 2);
    expect(buildCountBob, 1, reason: 'Item 1 was not modified and must have 0 rebuilds');

    graft.dispose();
  });

  testWidgets('graft.builder works with GridView.builder and isolated item rebuilds', (tester) async {
    final graft = ProfileGraft();
    int buildCount0 = 0;
    int buildCount1 = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.builder<String>(
            (itemCount, itemBuilder) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
            items: (s) => [s.name, s.email],
            itemBuilder: (context, val, index) {
              if (index == 0) buildCount0++;
              if (index == 1) buildCount1++;
              return Text('Grid $index: $val');
            },
          ),
        ),
      ),
    );

    expect(find.text('Grid 0: Alice'), findsOneWidget);
    expect(find.text('Grid 1: alice@example.com'), findsOneWidget);
    expect(buildCount0, 1);
    expect(buildCount1, 1);

    // Update name -> Grid 0 rebuilds, Grid 1 stays at 0 rebuilds
    graft.updateName('Dana');
    await tester.pump();

    expect(find.text('Grid 0: Dana'), findsOneWidget);
    expect(find.text('Grid 1: alice@example.com'), findsOneWidget);
    expect(buildCount0, 2);
    expect(buildCount1, 1, reason: 'Grid 1 was not modified and must have 0 rebuilds');

    graft.dispose();
  });

  testWidgets('graft.item works seamlessly inside GridView.builder', (tester) async {
    final graft = ProfileGraft();
    int buildCount0 = 0;
    int buildCount1 = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: 2,
            itemBuilder: (context, index) {
              return graft.item<String>(
                (s) => index == 0 ? s.name : s.email,
                (ctx, val) {
                  if (index == 0) buildCount0++;
                  if (index == 1) buildCount1++;
                  return Text('Grid $index: $val');
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Grid 0: Alice'), findsOneWidget);
    expect(find.text('Grid 1: alice@example.com'), findsOneWidget);
    expect(buildCount0, 1);
    expect(buildCount1, 1);

    // Update name -> Grid 0 rebuilds, Grid 1 stays at 0 rebuilds
    graft.updateName('Dana');
    await tester.pump();

    expect(find.text('Grid 0: Dana'), findsOneWidget);
    expect(find.text('Grid 1: alice@example.com'), findsOneWidget);
    expect(buildCount0, 2);
    expect(buildCount1, 1, reason: 'Grid 1 was not modified and must have 0 rebuilds');

    graft.dispose();
  });

  testWidgets('graft.builder throws FlutterError when itemBuilder is not passed', (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.builder<String>(
            (itemCount, itemBuilder) => ListView.builder(
              itemCount: itemCount,
              // ❌ Mistake: forgot to pass itemBuilder!
              itemBuilder: (context, index) => Text('Wrong $index'),
            ),
            items: (s) => [s.name],
            itemBuilder: (context, val, index) => Text(val),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      (error as FlutterError).message,
      contains('UNUSED itemBuilder IN graft.builder()'),
    );

    graft.dispose();
  });

  testWidgets('graft.builder throws FlutterError when itemCount is mismatched', (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.builder<String>(
            (itemCount, itemBuilder) => ListView.builder(
              itemCount: 999, // ❌ Mistake: hardcoded count instead of using itemCount
              itemBuilder: itemBuilder,
            ),
            items: (s) => [s.name],
            itemBuilder: (context, val, index) => Text(val),
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      (error as FlutterError).message,
      contains('MISMATCHED itemCount IN graft.builder()'),
    );

    graft.dispose();
  });

  testWidgets('graft.slots throws FlutterError when children is not passed', (tester) async {
    final graft = ProfileGraft();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: graft.slots(
            // ❌ Mistake: forgot to pass children!
            (children) => const Column(children: [Text('Hardcoded')]),
            (s) => [Text(s.name)],
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      (error as FlutterError).message,
      contains('UNUSED children IN graft.slots()'),
    );

    graft.dispose();
  });

  testWidgets(
      'graft.slots reassemble removes deleted child slot immediately on hot reload',
      (tester) async {
    final graft = ProfileGraft();
    bool showMiddleSlot = true;

    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: graft.slots(
            (children) => Column(children: children),
            (s) => [
              const Text('Slot 1: Header'),
              if (showMiddleSlot) const Text('Slot 2: Removable Widget'),
              Text('Slot 3: ${s.name}'),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    expect(find.text('Slot 1: Header'), findsOneWidget);
    expect(find.text('Slot 2: Removable Widget'), findsOneWidget);
    expect(find.text('Slot 3: Alice'), findsOneWidget);

    // Simulate developer deleting Slot 2 in source code and pressing Hot Reload ('r')
    showMiddleSlot = false;
    await tester.pumpWidget(buildApp());
    tester.binding.reassembleApplication();
    await tester.pump();

    // Verify Slot 2 is completely removed from the UI tree
    expect(find.text('Slot 1: Header'), findsOneWidget);
    expect(find.text('Slot 2: Removable Widget'), findsNothing);
    expect(find.text('Slot 3: Alice'), findsOneWidget);

    // Verify state reactivity is still 100% operational
    graft.updateName('Bob');
    await tester.pump();
    expect(find.text('Slot 3: Bob'), findsOneWidget);

    graft.dispose();
  });

  testWidgets(
      'graft.slot reassemble reflects modified slot code immediately on hot reload',
      (tester) async {
    final graft = ProfileGraft();
    String prefix = 'V1: ';

    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: graft.slot(
            (s) => Text('$prefix${s.name}'),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    expect(find.text('V1: Alice'), findsOneWidget);

    // Simulate code edit in builder and hot reload
    prefix = 'V2: ';
    await tester.pumpWidget(buildApp());
    tester.binding.reassembleApplication();
    await tester.pump();

    expect(find.text('V2: Alice'), findsOneWidget);

    graft.dispose();
  });

  testWidgets(
      'graft.builder reassemble reflects modified item code immediately on hot reload',
      (tester) async {
    final graft = ProfileGraft();
    String prefix = 'Name: ';

    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: graft.builder<String>(
            (itemCount, itemBuilder) => ListView.builder(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
            items: (s) => [s.name],
            itemBuilder: (context, name, index) => Text('$prefix$name'),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    expect(find.text('Name: Alice'), findsOneWidget);

    // Simulate code edit in itemBuilder and hot reload
    prefix = 'Item: ';
    await tester.pumpWidget(buildApp());
    tester.binding.reassembleApplication();
    await tester.pump();

    expect(find.text('Item: Alice'), findsOneWidget);

    graft.dispose();
  });
}

class MockCompositeText extends StatelessWidget {
  static int buildCount = 0;
  final String text;
  const MockCompositeText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

class MockCkText extends StatelessWidget {
  final String text;
  const MockCkText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class MockKeyedWidget extends StatelessWidget {
  static int buildCount = 0;
  const MockKeyedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return const Text('Keyed Content');
  }
}

