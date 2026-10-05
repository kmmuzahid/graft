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

  test(
      'updateCoalesced() coalesces 1,000 rapid synchronous updates into a single notification',
      () async {
    final graft = CoalesceGraft();
    int notifications = 0;
    int? finalMask;

    graft.addListener(() => notifications++);
    graft.addMaskListener((mask) => finalMask = mask);

    // Perform 1,000 rapid updates in a tight loop
    for (int i = 1; i <= 1000; i++) {
      graft.state.count = i;
      graft.state.updateCoalesced();
    }

    // Synchronously: 0 notifications have fired yet because it is queued on the microtask
    expect(notifications, 0);

    // Allow microtask to drain
    await Future.microtask(() {});

    // Exactly 1 notification fired!
    expect(notifications, 1);
    expect(graft.state.count, 1000);
    // Field 0 was mutated
    expect(finalMask, 1);

    graft.dispose();
  });

  test('updateCoalesced() accumulates dirty bitmask across different fields',
      () async {
    final graft = CoalesceGraft();
    int notifications = 0;
    int? receivedMask;

    graft.addListener(() => notifications++);
    graft.addMaskListener((mask) => receivedMask = mask);

    // Mutate field 0 (count)
    graft.state.count = 42;
    graft.state.updateCoalesced();

    // Mutate field 1 (text)
    graft.state.text = 'Updated';
    graft.state.updateCoalesced();

    // Mutate field 2 (flag)
    graft.state.flag = true;
    graft.state.updateCoalesced();

    expect(notifications, 0);

    await Future.microtask(() {});

    expect(notifications, 1);
    // Bits 0, 1, 2 changed: (1 << 0) | (1 << 1) | (1 << 2) = 1 | 2 | 4 = 7
    expect(receivedMask, 7);

    graft.dispose();
  });
}
