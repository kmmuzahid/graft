import 'package:flutter_test/flutter_test.dart';
import 'package:graft/graft.dart';

class CoalesceState extends GraftState {
  int count;
  String text;
  bool flag;

  CoalesceState({
    this.count = 0,
    this.text = '',
    this.flag = false,
  });

  @override
  List<Object?> get props => [count, text, flag];

  @override
  void onReset() {
    count = 0;
    text = '';
    flag = false;
  }
}

class CoalesceGraft extends Graft<CoalesceState> {
  CoalesceGraft() : super(CoalesceState());
}

void main() {
  test('Synchronous update() triggers notifications immediately', () {
    final graft = CoalesceGraft();
    int notifications = 0;
    graft.addListener(() => notifications++);

    graft.state
      ..count = 1
      ..update();

    expect(notifications, 1);
    expect(graft.state.count, 1);

    graft.state
      ..count = 2
      ..update();

    expect(notifications, 2);
    expect(graft.state.count, 2);

    graft.dispose();
  });

  test('Batch cascade mutation mutates multiple fields and triggers exactly 1 notification', () {
    final graft = CoalesceGraft();
    int notifications = 0;
    GraftMask? finalMask;

    graft.addListener(() => notifications++);
    graft.addMaskListener((mask) => finalMask = mask);

    // Multi-field cascade mutation
    graft.state
      ..count = 42
      ..text = 'Updated'
      ..flag = true
      ..update(); // Exactly 1 update call!

    expect(notifications, 1);
    expect(graft.state.count, 42);
    expect(graft.state.text, 'Updated');
    expect(graft.state.flag, true);

    expect(finalMask, isNotNull);
    expect(finalMask!.isBitSet(0), isTrue);
    expect(finalMask!.isBitSet(1), isTrue);
    expect(finalMask!.isBitSet(2), isTrue);

    graft.dispose();
  });
}
