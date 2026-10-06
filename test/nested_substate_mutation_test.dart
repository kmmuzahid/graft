import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class AddressState extends GraftState {
  String city;
  String zipCode;

  AddressState({this.city = 'London', this.zipCode = '10001'});

  @override
  List<Object?> get props => [city, zipCode];
}

class UserProfileState extends GraftState {
  String userName;
  AddressState address;

  UserProfileState({
    this.userName = 'Alice',
    AddressState? address,
  }) : address = address ?? AddressState();

  @override
  List<Object?> get props => [userName, address];
}

class UserProfileController extends Graft<UserProfileState> {
  UserProfileController() : super(UserProfileState());

  void setCity(String city) {
    state
      ..address.city = city
      ..update();
  }

  void setUserName(String name) {
    state
      ..userName = name
      ..update();
  }
}

class TrackedTextWidget extends StatelessWidget implements GraftEquivalent {
  final String text;
  final VoidCallback? onBuild;

  const TrackedTextWidget(this.text, {super.key, this.onBuild});

  @override
  bool isEquivalentTo(Widget other) {
    return other is TrackedTextWidget && other.text == text;
  }

  @override
  Widget build(BuildContext context) {
    onBuild?.call();
    return Text(text);
  }
}

void main() {
  group('Nested Sub-State Mutation Tests', () {
    test('diffChanges detects in-place mutation on nested GraftState without allocating snapshots when unchanged', () {
      final controller = UserProfileController();

      // Initial state has no dirty mask
      expect(controller.state.dirtyMask.isAllDirty, isTrue);

      // Mutate nested field in address
      controller.setCity('Paris');

      // Index 1 (address) should be dirty in parent dirtyMask!
      expect(controller.state.dirtyMask.isBitSet(1), isTrue);
      expect(controller.state.dirtyMask.isBitSet(0), isFalse);

      // Mutate parent field (userName)
      controller.setUserName('Bob');

      // Index 0 should be dirty, index 1 should NOT be dirty
      expect(controller.state.dirtyMask.isBitSet(0), isTrue);
      expect(controller.state.dirtyMask.isBitSet(1), isFalse);

      controller.dispose();
    });

    testWidgets('graft.slots surgically rebuilds nested substate slot while keeping sibling static', (tester) async {
      final controller = UserProfileController();
      int userBuilds = 0;
      int cityBuilds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: controller.slots(
              layout: (children) => Column(children: children),
              children: (s) => [
                TrackedTextWidget('User: ${s.userName}', onBuild: () => userBuilds++),
                TrackedTextWidget('City: ${s.address.city}', onBuild: () => cityBuilds++),
              ],
            ),
          ),
        ),
      );

      expect(userBuilds, 1);
      expect(cityBuilds, 1);

      // Mutate nested city -> only city slot rebuilds!
      controller.setCity('Berlin');
      await tester.pump();

      expect(userBuilds, 1, reason: 'Parent userName did not change');
      expect(cityBuilds, 2, reason: 'Nested address.city changed');

      // Mutate parent userName -> only userName slot rebuilds!
      controller.setUserName('Charlie');
      await tester.pump();

      expect(userBuilds, 2);
      expect(cityBuilds, 2);

      controller.dispose();
    });
  });
}
