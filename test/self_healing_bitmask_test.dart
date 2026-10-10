import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AccountState extends GraftState {
  String firstName;
  String lastName;
  String email;
  bool isLoggedIn;
  int unreadNotifications;

  AccountState({
    this.firstName = 'Alice',
    this.lastName = 'Wonderland',
    this.email = 'alice@example.com',
    this.isLoggedIn = true,
    this.unreadNotifications = 0,
  });

  @override
  GraftProps get props => propsOf(
        firstName,
        lastName,
        email,
        isLoggedIn,
        unreadNotifications,
      );
}

class AccountGraft extends Graft<AccountState> {
  AccountGraft() : super(AccountState());

  void setFirstName(String name) {
    state
      ..firstName = name
      ..update();
  }

  void setLastName(String name) {
    state
      ..lastName = name
      ..update();
  }

  void setEmail(String email) {
    state
      ..email = email
      ..update();
  }

  void toggleLoggedIn() {
    state
      ..isLoggedIn = !state.isLoggedIn
      ..update();
  }

  void incrementNotifications() {
    state
      ..unreadNotifications += 1
      ..update();
  }

  void batchUpdate({
    required String first,
    required String last,
    required String email,
  }) {
    state
      ..firstName = first
      ..lastName = last
      ..email = email
      ..update();
  }
}

void main() {
  group('Pillar 4 & 5: Self-Healing Multi-Field Rebuild Tests', () {
    testWidgets('graft((s) => ...) reading multiple fields updates for both and bypasses unrelated fields',
        (tester) async {
      final accountGraft = AccountGraft();
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: accountGraft((s) {
              buildCount++;
              return Text('${s.firstName} ${s.lastName}');
            }),
          ),
        ),
      );

      expect(find.text('Alice Wonderland'), findsOneWidget);
      expect(buildCount, 1);

      // 1. Mutate firstName alone (Field 0)
      accountGraft.setFirstName('Alicia');
      await tester.pump();

      expect(find.text('Alicia Wonderland'), findsOneWidget);
      expect(buildCount, 2);

      // 2. Mutate lastName alone (Field 1)
      accountGraft.setLastName('Kingsleigh');
      await tester.pump();

      expect(find.text('Alicia Kingsleigh'), findsOneWidget);
      expect(buildCount, 3);

      // 3. Mutate unreadNotifications (Field 4, not read in this slot)
      accountGraft.incrementNotifications();
      await tester.pump();

      // Output content is identical -> strictly 0 element rebuilds!
      expect(find.text('Alicia Kingsleigh'), findsOneWidget);
      expect(buildCount, 4); // builder evaluated, but element didn't dirty!
    });

    testWidgets('graft.slots with dynamic conditional branch correctly swaps content',
        (tester) async {
      final accountGraft = AccountGraft();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: accountGraft.slots(
              layout: Column(children: slots),
              slots: [
                const Text('Header Banner'),
                (s) => s.isLoggedIn
                    ? Text('Logged as: ${s.firstName}')
                    : const Text('Guest Mode'),
                (s) => Text('Notifications: ${s.unreadNotifications}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Header Banner'), findsOneWidget);
      expect(find.text('Logged as: Alice'), findsOneWidget);
      expect(find.text('Notifications: 0'), findsOneWidget);

      // Log out
      accountGraft.toggleLoggedIn();
      await tester.pump();

      expect(find.text('Guest Mode'), findsOneWidget);
      expect(find.text('Logged as: Alice'), findsNothing);

      // Update notifications while in guest mode
      accountGraft.incrementNotifications();
      await tester.pump();

      expect(find.text('Notifications: 1'), findsOneWidget);
      expect(find.text('Guest Mode'), findsOneWidget);
    });

    testWidgets('batch atomic cascade mutation notifies listeners once',
        (tester) async {
      final accountGraft = AccountGraft();
      int notifyCount = 0;
      accountGraft.addListener(() => notifyCount++);

      accountGraft.batchUpdate(
        first: 'Bob',
        last: 'Marley',
        email: 'bob@jamaica.com',
      );

      expect(notifyCount, 1);
      expect(accountGraft.state.firstName, 'Bob');
      expect(accountGraft.state.lastName, 'Marley');
      expect(accountGraft.state.email, 'bob@jamaica.com');
    });
  });
}
