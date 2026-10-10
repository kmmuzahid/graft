import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AsyncDemoState extends GraftState {
  String title;
  GraftAsync<String> profile;

  AsyncDemoState({
    this.title = 'Profile Page',
    this.profile = const GraftAsync.idle(),
  });

  @override
  GraftProps get props => propsOf(title, profile);
}

class AsyncDemoGraft extends Graft<AsyncDemoState> {
  AsyncDemoGraft() : super(AsyncDemoState());

  void setTitle(String newTitle) {
    state
      ..title = newTitle
      ..update();
  }

  Future<void> fetchProfileSuccess() async {
    await runAsync<String>(
      task: () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 'Alice Wonderland';
      },
      onUpdate: (res) => state
        ..profile = res
        ..update(),
    );
  }

  Future<void> fetchProfileError() async {
    await runAsync<String>(
      task: () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        throw Exception('Network Timeout');
      },
      onUpdate: (res) => state
        ..profile = res
        ..update(),
    );
  }
}

void main() {
  group('Declarative graft.async Widget Tests', () {
    testWidgets('renders idle, transitions to loading, and renders data on success',
        (tester) async {
      final graft = AsyncDemoGraft();
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.async<String>(
              selector: (s) => s.profile,
              idle: () => const Text('Idle State'),
              loading: () => const CircularProgressIndicator(),
              data: (data) {
                buildCount++;
                return Text('User: $data');
              },
              error: (err, st) => Text('Error: $err'),
            ),
          ),
        ),
      );

      // 1. Initial idle
      expect(find.text('Idle State'), findsOneWidget);
      expect(buildCount, 0);

      // 2. Trigger async load
      final future = graft.fetchProfileSuccess();
      await tester.pump(); // Pump microtask for loading transition

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 3. Complete async load
      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.text('User: Alice Wonderland'), findsOneWidget);
      expect(buildCount, 1);
    });

    testWidgets('renders error on failure', (tester) async {
      final graft = AsyncDemoGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: graft.async<String>(
              selector: (s) => s.profile,
              idle: () => const Text('Idle State'),
              loading: () => const CircularProgressIndicator(),
              data: (data) => Text('User: $data'),
              error: (err, st) => Text('Error: $err'),
            ),
          ),
        ),
      );

      expect(find.text('Idle State'), findsOneWidget);

      final future = graft.fetchProfileError();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.text('Error: Exception: Network Timeout'), findsOneWidget);
    });

    testWidgets('isolated inside Column: untouched sibling slots experience 0 rebuilds',
        (tester) async {
      final graft = AsyncDemoGraft();
      int headerBuilds = 0;
      int asyncBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                graft((s) {
                  headerBuilds++;
                  return Text('Title: ${s.title}');
                }),
                graft.async<String>(
                  selector: (s) => s.profile,
                  idle: () => const Text('Idle'),
                  loading: () => const Text('Loading...'),
                  data: (data) {
                    asyncBuilds++;
                    return Text('Data: $data');
                  },
                  error: (err, st) => Text('Err: $err'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(headerBuilds, 1);
      expect(find.text('Title: Profile Page'), findsOneWidget);
      expect(find.text('Idle'), findsOneWidget);

      // Mutate title only -> async slot does not re-run
      graft.setTitle('Updated Title');
      await tester.pump();

      expect(headerBuilds, 2);
      expect(find.text('Title: Updated Title'), findsOneWidget);
      expect(asyncBuilds, 0);

      // Now load profile -> header slot does not re-run!
      final future = graft.fetchProfileSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await future;
      await tester.pump();

      expect(find.text('Data: Alice Wonderland'), findsOneWidget);
      expect(asyncBuilds, 1);
      // Header remained at exactly 2 rebuilds!
      expect(headerBuilds, 2);
    });
  });
}
