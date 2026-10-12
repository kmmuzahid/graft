import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'benchmark/suite/scenario_a_micro_mutation.dart';

void main() {
  test('Scenario A in Isolated Heap', () async {
    final statsA = await Isolate.run(() => ScenarioAMicroMutationRunner.runAll());
    print('Scenario A finished in isolated heap: ${statsA.length} stats');
    for (final s in statsA.take(4)) {
      print('${s.scenario} | ${s.framework.padRight(20)} | Median: ${s.medianMs.toStringAsFixed(2)} ms');
    }
  });
}
