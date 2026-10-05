import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class DialogLifecycleState extends GraftState {
  int count;
  DialogLifecycleState({this.count = 0});

  @override
  List<Object?> get props => [count];
}

class DialogLifecycleGraft extends Graft<DialogLifecycleState> {
  DialogLifecycleGraft() : super(DialogLifecycleState());

  void increment() {
    state
      ..count += 1
      ..update();
  }
}

void main() {
  setUp(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
  });

  tearDown(() {
    GraftRegistry.reset();
    GraftRouteTracker.reset();
  });

  group('Pillar 3: Dialog & PopupRoute Scoping Safety Tests', () {
    testWidgets('Dialog opening and closing does NOT dispose Graft owned by host screen', (tester) async {
      late DialogLifecycleGraft capturedGraft;
      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) {
              capturedGraft = context.use(DialogLifecycleGraft.new);
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) {
                          // Dialog borrows the existing Graft from host screen
                          final borrowed = dialogCtx.use<DialogLifecycleGraft>();
                          return AlertDialog(
                            title: const Text('Dialog'),
                            content: Text('Count: ${borrowed.state.count}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(capturedGraft.isDisposed, isFalse);

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog'), findsOneWidget);
      expect(find.text('Count: 0'), findsOneWidget);

      // Close dialog (pops the PopupRoute)
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // 🛡️ CRITICAL ASSERTION: Dialog is closed, but Graft MUST NOT be disposed!
      expect(find.text('Dialog'), findsNothing);
      expect(capturedGraft.isDisposed, isFalse,
          reason: 'Popping a transient dialog route must NOT dispose the underlying screen controller');
    });

    testWidgets('Graft created inside dialog anchors ownership to host screen PageRoute', (tester) async {
      DialogLifecycleGraft? dialogCreatedGraft;
      final observer = GraftRouteObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) {
                          // First access happens INSIDE dialog
                          dialogCreatedGraft = dialogCtx.use(DialogLifecycleGraft.new);
                          return AlertDialog(
                            title: const Text('Created In Dialog'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(),
                                child: const Text('Dismiss'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Launch Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Launch Dialog'));
      await tester.pumpAndSettle();

      expect(dialogCreatedGraft, isNotNull);
      expect(dialogCreatedGraft!.isDisposed, isFalse);

      // Dismiss dialog
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // 🛡️ Host screen is still alive: Graft must stay alive
      expect(dialogCreatedGraft!.isDisposed, isFalse,
          reason: 'Ownership must be transferred to parent PageRoute, keeping it alive when dialog closes');
    });
  });
}
